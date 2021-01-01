DOC
--
-- Author    : Theo Stienissen
-- email     : theo.stienissen@gmail.com
-- Created   : March 2017. Update Feb 2019
--
-- Integers based on number datatype
-- ToDo Support for negative numbers.

create table fast_int_tbl
( id       number(10)  not null
, seq      number(10)  not null
, val      number(20)  not null);

alter table fast_int_tbl add constraint fast_int_tbl_pk primary key (id, seq) using index;
create sequence fast_int_seq;

create or replace type int_ty is table of integer(38);
/

create or replace type number_ty as object
( sign     integer(1)
, whole    int_ty
, fraction int_ty);
/

#

create or replace package fast_int
is

-- Base is 10 ** 18
p_base        constant integer(20) := 1E18;
p_base_length constant integer(2)  := 18;

function ltrim_int (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function nice  (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function get_length (p_number types_pkg.fast_int_ty) return integer;

function get_digit (p_digit in integer, p_number in types_pkg.fast_int_ty) return integer;

procedure print (p_number in types_pkg.fast_int_ty, p_width in integer default 5);

function save_number (p_number in types_pkg.fast_int_ty, p_id in number default null) return integer;

function load_number(p_id in integer) return types_pkg.fast_int_ty;

function is_zero (p_number in types_pkg.fast_int_ty) return boolean;

function string_to_int (p_string in varchar2) return types_pkg.fast_int_ty;

function int_to_string (p_number in types_pkg.fast_int_ty) return varchar2;
	
function gt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function eq (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function ge (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function lt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function le (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function add (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function mult_n (p_factor in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function add_n (p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function multiply (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty;

function nfac (p_number in integer) return types_pkg.fast_int_ty result_cache;

function divide (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty, p_remainder out types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function gcd (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function lcm (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function fmod (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function fmod (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty;

function power_mod(p_base in integer, p_power in integer, p_mod in integer) return types_pkg.fast_int_ty result_cache;

function fpower (p_base in integer, p_power in integer) return types_pkg.fast_int_ty result_cache;

function fsubstr(p_number in types_pkg.fast_int_ty, p_pos in integer) return types_pkg.fast_int_ty;

function fsqrt  (p_sqr  in integer, p_precision in integer) return types_pkg.fast_int_ty;

end  fast_int;
/

create or replace package body fast_int
is

-- 
-- Indexing is from right to left
-- Remove leading zeros
--
function ltrim_int (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_return types_pkg.fast_int_ty := p_number;
begin
while l_return.count > 1 and l_return(l_return.count) = 0
loop
   l_return.delete(l_return.count);
end loop;

return l_return;

exception
when others then
  util.show_error('Error in function ltrim_int.' , sqlerrm);
end ltrim_int;

/*************************************************************************************************************************************************/

--
-- Reorg array to base 1E18
--
function nice  (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_overflow  integer(38) := 0;
l_demi      integer(38);
begin
for j in p_number.first ..  p_number.last
loop
  l_demi      := p_number(j) + l_overflow;
  l_result(j) := mod(l_demi, p_base);
  l_overflow  := trunc(l_demi / p_base);
end loop;

if l_overflow != 0 then l_result(l_result.count + 1) := l_overflow; end if;

return ltrim_int(l_result);

exception
when others then
  util.show_error('Error in function nice.' , sqlerrm);
end nice;

/*************************************************************************************************************************************************/

--
-- Calculate lenght of an integer
--
function get_length (p_number types_pkg.fast_int_ty) return integer
is
l_return types_pkg.fast_int_ty := p_number;
begin

if p_number.count = 0
then
  return 0;
else
  return (p_number.count - 1) * p_base_length + length(p_number(p_number.count));
end if;

exception
when others then
  util.show_error('Error in function get_length.' , sqlerrm);
end get_length;

/*************************************************************************************************************************************************/

--
-- Get n-th digit of an integer. Sequences from left to right.
--
function get_digit (p_digit in integer, p_number in types_pkg.fast_int_ty) return integer
is
l_seq   integer(10);
l_digit integer(10);
begin
-- First determine in which sequence to look
  l_seq := p_number.count - 1 - floor ((p_digit -1 - length(p_number(p_number.count))) / p_base_length);

  if  l_seq = p_number.count
  then
    return substr(p_number(l_seq), p_digit, 1);
  else
    l_digit :=  mod(p_digit - length(p_number(p_number.count)) -1 , p_base_length) + 1;
    return substr(lpad(p_number(l_seq), p_base_length, '0'), l_digit, 1);
  end if;

exception
when others then
  util.show_error('Error in function get_digit. Digit = ' || p_digit , sqlerrm);
end get_digit;

/*************************************************************************************************************************************************/

--
-- Convert string to integer. Indexing from right to left
--
function string_to_int (p_string in varchar2) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_lenght    integer(10) := length(p_string);
begin
for j in 1 .. ceil(length(p_string) / p_base_length)
loop
  if   l_lenght > j * p_base_length
  then l_result(j) := substr (p_string, l_lenght - j * p_base_length + 1, p_base_length);
  else l_result(j) := substr (p_string, 1, l_lenght - (j - 1) * p_base_length);
  end if;
end loop;

  return l_result;

exception
when others then
  util.show_error('Error in function string_to_int.' , sqlerrm);
end string_to_int;

/*************************************************************************************************************************************************/

--
-- Convert integer to a string
--
function int_to_string (p_number in types_pkg.fast_int_ty) return varchar2
is
l_nr varchar2 (32767) := '';
begin
for j in p_number.first ..  p_number.last
loop
  l_nr := lpad(trim(p_number(j)), p_base_length, '0') || l_nr;
end loop;

  return ltrim(l_nr, '0');

exception
when others then
  util.show_error('Error in function int_to_string.' , sqlerrm);
end int_to_string;
	
/*************************************************************************************************************************************************/

--
-- Prints an integer
--
procedure print (p_number in types_pkg.fast_int_ty, p_width in integer default 5)
is
l_cnt  integer (10) := 0;
begin
for j in reverse p_number.first ..  p_number.last
loop
  if mod(l_cnt, p_width) = 0 then dbms_output.new_line; end if;
  if j = p_number.last
  then
    dbms_output.put(p_number(j));
  else
    dbms_output.put(lpad(p_number(j), p_base_length, '0'));
  end if;
  l_cnt := l_cnt + 1;
end loop;
dbms_output.new_line;

exception
when others then
  util.show_error('Error in procedure print.' , sqlerrm);
end print;

/*************************************************************************************************************************************************/

--
-- Saves value of an integer in a table
--
function save_number (p_number in types_pkg.fast_int_ty, p_id in number default null) return integer
is
l_seq    integer (10);
begin
if p_id is null
then
  l_seq := fast_int_seq.nextval;
else 
  l_seq := p_id;
end if;

for j in p_number.first .. p_number.last
loop
  insert into fast_int_tbl (id, seq, val) values (l_seq, j, p_number(j));
end loop;
commit;

 return l_seq;

exception
when others then
  util.show_error('Error in procedure save_number.' , sqlerrm);
end save_number;

/*************************************************************************************************************************************************/

--
-- Loads value from an integer from a table
--
function load_number(p_id in integer) return types_pkg.fast_int_ty
is
l_return types_pkg.fast_int_ty;
begin
select val bulk collect into l_return from fast_int_tbl where id = p_id order by seq;

return l_return;

exception
when others then
  util.show_error('Error in function load_number.' , sqlerrm);
end load_number;

/*************************************************************************************************************************************************/

--
-- Checks if a value = 0
--
function is_zero (p_number in types_pkg.fast_int_ty) return boolean
is
l_return types_pkg.fast_int_ty := nice(p_number);
begin

if l_return.count = 1
then
  return l_return(1) = 0;
else
  return false;
end if;

exception
when others then
  util.show_error('Error in function is_zero.' , sqlerrm);
end is_zero;


/*************************************************************************************************************************************************/

--
-- greater than
--
function gt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
if p_number1.count != p_number2.count
then
  return p_number1.count > p_number2.count;
else
  for j in reverse p_number1.first ..  p_number1.last
  loop
    if p_number1(j) != p_number2(j)
    then
	return p_number1(j) > p_number2(j);
    end if;
  end loop;

  return false;
end if;

exception when others then
  util.show_error('Error in function GT.' , sqlerrm);
end gt;

/*************************************************************************************************************************************************/

--
-- Equal
--
function eq (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
if p_number1.count != p_number2.count
then
  return false;
else
  for j in p_number1.first ..  p_number1.last
  loop
    if p_number1(j) != p_number2(j)
    then
	return false;
    end if;
  end loop;

  return true;
end if;

exception when others then
  util.show_error('Error in function EQ.', sqlerrm);
end eq;

/*************************************************************************************************************************************************/

--
-- Greater or equal
--
function ge (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
  return gt (p_number1, p_number2) or eq (p_number1, p_number2);

exception when others then
  util.show_error('Error in function GE.', sqlerrm);
end ge;

/*************************************************************************************************************************************************/

--
-- Less than
--
function lt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
  return gt (p_number2, p_number1);

exception when others then
  util.show_error('Error in function LT.', sqlerrm);
end lt;

/*************************************************************************************************************************************************/

--
-- Less or equal
--
function le (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin

  return  gt (p_number2, p_number1) or eq (p_number1, p_number2);

exception when others then
  util.show_error('Error in function LE.', sqlerrm);
end le;

/*************************************************************************************************************************************************/

--
-- Add 2 integers
--
function add (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_sum       integer(20);
l_overflow  integer(2) := 0;
begin
if p_number1.count > p_number2.count
then
  l_result := p_number1;
  for j in 1 .. p_number2.count
  loop
    l_result(j) := p_number1(j) + p_number2(j);
  end loop;  
else
  l_result := p_number2;
  for j in 1 .. p_number1.count
  loop
    l_result(j) := p_number1(j) + p_number2(j);
  end loop;
end if;

  return nice(l_result);

exception when others then
  util.show_error('Error in function add.', sqlerrm);
end add;

/*************************************************************************************************************************************************/

--
-- Multiply long integer with factor N
--
function mult_n (p_factor in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_demi types_pkg.fast_int_ty;
begin
if p_factor < 0 or p_factor is null
then
  raise_application_error(-20001, 'Invalid factor');
else
  if p_factor = 0
  then return string_to_int('0');
  elsif p_factor = 1
  then return p_number;
  else
    for j in 1 .. p_number.count
    loop
      l_demi(j) := p_factor * p_number(j);
    end loop;

    return nice(l_demi);
  end if;
end if;

exception when others then
 util.show_error('Error in function mult_n for factor: ' || p_factor ||'.', sqlerrm);
end mult_n;

/*************************************************************************************************************************************************/

--
-- Add N to an integer
--
function add_n (p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_demi types_pkg.fast_int_ty := p_number;
begin
l_demi(1) := l_demi(1) + p_offset;

  return nice(l_demi);

exception when others then
 util.show_error('Error in function add_n for offset: ' || p_offset ||'.', sqlerrm);
end add_n;

/*************************************************************************************************************************************************/

--
-- Multiply with factor 10 and add offset
--
function mult_add_n (p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_demi types_pkg.fast_int_ty;
begin
for j in 1 .. p_number.count
loop
  l_demi(j) := 10 * p_number(j);
end loop;
l_demi(1) := l_demi(1) + p_offset;

  return nice(l_demi);

exception when others then
 util.show_error('Error in function mult_add_n.', sqlerrm);
end mult_add_n;

/*************************************************************************************************************************************************/

--
-- Multiply 2 integers
--
function multiply (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_demi      types_pkg.fast_int_ty;
l_mult      integer(38);
l_overflow  integer(38);
l_cnt       integer(10);
begin
l_result(1) := 0;

for x in 1 .. p_number1.count
loop
  l_demi.delete;
  l_overflow := 0;
  for y in 1 .. p_number2.count
  loop
    l_mult     := p_number1(x) * p_number2(y) + l_overflow;
    l_overflow := trunc(l_mult / p_base);
    l_demi(y)  := mod(l_mult, p_base);
  end loop;
  if l_overflow != 0 then l_demi (p_number2.count + 1) := l_overflow; end if;

  l_overflow := 0;
  for j in 1 .. l_demi.count
  loop
   l_cnt := j + x -1;
   if l_result.count  < l_cnt
   then
     l_result(l_cnt)  := l_demi(j) + l_overflow;
   else
     l_result(l_cnt)  := l_result(l_cnt) + l_demi(j) + l_overflow;
   end if;

   l_overflow         := trunc(l_result(l_cnt) / p_base);
   l_result(l_cnt)    := mod(l_result(l_cnt), p_base);
  end loop;

  while l_overflow != 0
  loop
    l_cnt := l_cnt + 1;
    if l_result.count  < l_cnt
    then
      l_result(l_cnt)  :=  l_overflow;
    else
      l_result(l_cnt)  :=  l_result(l_cnt) + l_overflow;
    end if;

    l_overflow         := trunc(l_result(l_cnt) / p_base);
    l_result(l_cnt)    := mod(l_result(l_cnt), p_base);
  end loop;

end loop; -- x loop

  return l_result;

exception when others then
  util.show_error('Error in function multiply.', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- Subtract 2 integers. Result is p_number1 - p_number2
--
function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
 l_result    types_pkg.fast_int_ty := p_number1;
 l_borrow    integer(1) := 0;
 l_cnt       number(10);
begin
if gt(p_number2, p_number1)
then return subtract (p_number2, p_number1);
else
  for j in p_number2.first .. p_number2.last
  loop
    l_result(j) :=  l_result(j) - p_number2(j);
    if l_result(j) < 0
    then
      l_result(j)     := l_result(j) + p_base;
      l_result(j + 1) := l_result(j + 1) - 1;
    end if;
  end loop;
  
  return nice(l_result);
end if;

exception when others then
 util.show_error('Error in function subtract.', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

--
-- Subtract 2 integers. Result is p_number1 - p_number2
--
function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty
is
begin

return subtract(p_number1, fast_int.string_to_int(p_number2));

exception when others then
 util.show_error('Error in function subtract 2.', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

--
-- Calculate faculty
--
function nfac (p_number in integer) return types_pkg.fast_int_ty  result_cache
is
l_result types_pkg.fast_int_ty;
begin
l_result(1) := p_number;

if p_number <= 2 then return l_result;
else
  return multiply (nfac (p_number -1), l_result);
end if;

exception when others then
 util.show_error('Error in function nfac.', sqlerrm);
end nfac;

/*************************************************************************************************************************************************/

--
-- Divide 2 long integers
--
function divide (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty, p_remainder out types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result        types_pkg.fast_int_ty;
l_borrow        number(1) := 0;
l_remain        types_pkg.fast_int_ty;
l_mult_array    types_pkg.fast_int_array_ty;
l_length1       integer(10) := get_length (p_number1);
l_length2       integer(10) := get_length (p_number2);
begin
if gt (p_number2, p_number1)
then
  p_remainder := p_number1;
  return string_to_int('0');
else

-- Determine 8 multiples
for j in 2 .. 9
loop
  l_mult_array(j) := mult_n(j, p_number2);
end loop;

--
l_remain(1) := 0;
for j in 1 .. l_length2 -1
loop
  l_remain := mult_add_n (get_digit(j, p_number1), l_remain);
end loop;
-- print(l_remain);

l_result(1) := 0;
for j in l_length2 .. l_length1
loop
  l_remain := mult_add_n(get_digit(j, p_number1), l_remain);
  if    ge (l_remain, l_mult_array(9)) then l_result := mult_add_n (9, l_result); l_remain := subtract(l_remain, l_mult_array(9));
  elsif ge (l_remain, l_mult_array(8)) then l_result := mult_add_n (8, l_result); l_remain := subtract(l_remain, l_mult_array(8));
  elsif ge (l_remain, l_mult_array(7)) then l_result := mult_add_n (7, l_result); l_remain := subtract(l_remain, l_mult_array(7));
  elsif ge (l_remain, l_mult_array(6)) then l_result := mult_add_n (6, l_result); l_remain := subtract(l_remain, l_mult_array(6));
  elsif ge (l_remain, l_mult_array(5)) then l_result := mult_add_n (5, l_result); l_remain := subtract(l_remain, l_mult_array(5));
  elsif ge (l_remain, l_mult_array(4)) then l_result := mult_add_n (4, l_result); l_remain := subtract(l_remain, l_mult_array(4));
  elsif ge (l_remain, l_mult_array(3)) then l_result := mult_add_n (3, l_result); l_remain := subtract(l_remain, l_mult_array(3));
  elsif ge (l_remain, l_mult_array(2)) then l_result := mult_add_n (2, l_result); l_remain := subtract(l_remain, l_mult_array(2));
  elsif ge (l_remain, p_number2)       then l_result := mult_add_n (1, l_result); l_remain := subtract(l_remain, p_number2);
  else  l_result := mult_n (10, l_result);
  end if;
end loop;

  p_remainder := nice(l_remain);
  return nice(l_result);

end if;

exception when others then
 util.show_error('Error in function divide.', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

--
-- Greates common divisor
--
function gcd (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_rest types_pkg.fast_int_ty;
l_div  types_pkg.fast_int_ty;
begin
if is_zero (p_number1)
then
  return p_number2;
else
  l_div := divide(p_number2, p_number1, l_rest);
  return gcd(l_rest, p_number1);
end if;

exception when others then
 util.show_error('Error in function gcd.', sqlerrm);
end gcd;

/*************************************************************************************************************************************************/

--
-- Least common multiple
--
function lcm (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_rest types_pkg.fast_int_ty;
begin
if is_zero (p_number1)
then
  return string_to_int('0');
elsif  is_zero (p_number2)
then
  return string_to_int ('0');
else
  return nice(divide( multiply(p_number1, p_number2), gcd(p_number1, p_number2), l_rest));
end if;
	
exception when others then
 util.show_error('Error in function lcm.', sqlerrm);
end lcm;

/*************************************************************************************************************************************************/

--
-- Modulus for 2 * long integers
--
function fmod (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_rest types_pkg.fast_int_ty;
l_div  types_pkg.fast_int_ty;
begin
l_div := divide(p_number1, p_number2, l_rest);

  return l_rest;

exception when others then
 util.show_error('Error in function fmod 1.', sqlerrm);
end fmod;

/*************************************************************************************************************************************************/

--
-- Modulus mod(long int, number)
--
function fmod (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty
is
l_rest types_pkg.fast_int_ty;
l_div  types_pkg.fast_int_ty;
begin
l_div := divide(p_number1, string_to_int(p_number2), l_rest);

  return l_rest;

exception when others then
 util.show_error('Error in function fmod. 2', sqlerrm);
end fmod;

/*************************************************************************************************************************************************/

--
-- PowerMod. Only small integers
--
function power_mod(p_base in integer, p_power in integer, p_mod in integer) return types_pkg.fast_int_ty result_cache
is
l_halve integer;
l_tmp   types_pkg.fast_int_ty;
begin
if p_power = 1 then return string_to_int(mod(p_base, p_mod)); end if;

l_halve := trunc(p_power / 2);
l_tmp   := fast_int.fmod(fast_int.multiply(power_mod(p_base, l_halve, p_mod), power_mod(p_base, l_halve, p_mod)), string_to_int(p_mod));

if mod(p_power, 2) = 0
then
  return l_tmp;
else
  return fast_int.fmod(mult_n(p_base, l_tmp), string_to_int(p_mod));
end if;

exception when others then
 util.show_error('Error in function power_mod.', sqlerrm);
end power_mod;

/*************************************************************************************************************************************************/

--
-- Power
--
function fpower (p_base in integer, p_power in integer) return types_pkg.fast_int_ty result_cache
is
l_halve integer;
l_tmp   types_pkg.fast_int_ty;
begin
if p_power = 1 then return string_to_int(p_base); end if;

l_halve := trunc(p_power / 2);
l_tmp   := fast_int.multiply(fpower(p_base, l_halve),  fpower(p_base, l_halve));

if mod(p_power, 2) = 0
then
  return l_tmp;
else
  return mult_n(p_base, l_tmp);
end if;

exception when others then
 util.show_error('Error in function fpower.', sqlerrm);
end fpower;

/*************************************************************************************************************************************************/

function fsubstr(p_number in types_pkg.fast_int_ty, p_pos in integer) return types_pkg.fast_int_ty
is
l_number types_pkg.fast_int_ty := string_to_int('0');
begin
if get_length(p_number) <= p_pos
then
  return p_number;
else
  for j in 1 .. p_pos
  loop
    l_number := mult_add_n (get_digit (j, p_number), l_number);
  end loop;

  return l_number;
end if;

exception when others then
 util.show_error('Error in function fsubstr.', sqlerrm);
end fsubstr;

/*************************************************************************************************************************************************/

function fsqrt (p_sqr in integer, p_precision in integer) return types_pkg.fast_int_ty
is
l_passes       integer := ceil(10 * p_precision / 3) - 90;
l_base         integer;
l_sqrt         varchar2(32767);
l_sqr          types_pkg.fast_int_ty;
l_lower_bound  types_pkg.fast_int_ty;
l_upper_bound  types_pkg.fast_int_ty;
l_diff         types_pkg.fast_int_ty;
l_dummy        types_pkg.fast_int_ty;
l_dummy2       types_pkg.fast_int_ty;
l_digits       number(10) := 1;
l_count        number(10) := 1;
l_ten          boolean;
begin
l_sqrt := to_char(sqrt(p_sqr));
if instr(l_sqrt, '.') = 0 -- Pure square, so ready
then
    return fsubstr(string_to_int(l_sqrt), p_precision);
elsif p_precision <= 30
then
  return fsubstr(string_to_int(replace(l_sqrt, '.')), p_precision);
else
  l_sqrt := rpad(replace(l_sqrt, '.') , 2 * p_precision + length(mod(p_sqr, 100)) + 6,'0');
  l_base := length(l_sqrt);
  l_ten  := rtrim(p_sqr, '0') = '1' and mod(length(p_sqr), 2) = 0;

  l_sqr  := string_to_int(rpad(to_char(p_sqr), l_base, '0'));
  l_lower_bound := string_to_int(rpad(substr(l_sqrt, 1, 30), l_base, '0'));

  <<found>>
  for j in 31 .. l_base
  loop
   if substr(l_sqrt, j, 1) != '9'
   then
     l_upper_bound := string_to_int(rpad(substr(l_sqrt, 1, j - 1) || to_char(substr(l_sqrt, j, 1) + 1), l_base, '0'));
     exit found;
   end if;
  end loop;

  dbms_output.put_line('Lower: ');
  print(l_lower_bound);
  dbms_output.put_line('Upper:');
  print(l_upper_bound);


  l_diff := subtract (l_upper_bound, l_lower_bound);
  while l_digits < p_precision and l_count <= l_passes * 2
  loop
    l_diff :=  divide(l_diff, string_to_int('2'), l_dummy);
    l_dummy := add(l_lower_bound, l_diff);
    if l_ten
    then l_dummy2 := fsubstr(multiply (l_dummy, l_dummy), l_base + 1);
    else l_dummy2 := fsubstr(multiply (l_dummy, l_dummy), l_base);
    end if;
    if gt(l_dummy2, l_sqr)
    then
      l_upper_bound := l_dummy;
    else
      l_lower_bound := l_dummy;
    end if;

  dbms_output.put_line('Lower: ');
  print(l_lower_bound);
  dbms_output.put_line('Upper:');
  print(l_upper_bound);
  dbms_output.put_line('SQR:');
  print(l_dummy2);
  dbms_output.put_line('Diff:');
  print(l_diff);

    l_digits := 1;
    while get_digit(l_digits, l_lower_bound) = get_digit(l_digits, l_upper_bound) and l_digits <= l_base
    loop
      l_digits := l_digits + 1;
    end loop;
    l_count := l_count + 1;
  end loop;
  dbms_output.put_line('------------ Digits: ' || l_digits);

  return fsubstr(l_lower_bound, p_precision);
end if;

exception when others then
 util.show_error('Error in function fsqrt.', sqlerrm);
end fsqrt;

/*************************************************************************************************************************************************/

--
-- Rabin-Miller primality test
-- ToDo
/*
function prime_test (p_candidate in types_pkg.fast_int_ty, p_trials in integer default 64) return number
is
l_remainder      integer  := p_candidate - 1;
l_rest           types_pkg.fast_int_ty := fast_int.string_to_int('0');
l_witness        integer  := 2;
l_power          integer  := 0;
l_starttime number := dbms_utility.get_time;

function witness (p_candidate in types_pkg.fast_int_ty, p_remainder in types_pkg.fast_int_ty) return boolean
is
x      types_pkg.fast_int_ty;
n1     types_pkg.fast_int_ty;
b      boolean;
begin
dbms_output.put_line('P0: ' || to_char( dbms_utility.get_time - l_starttime));
x := fast_int.power_mod (l_witness, p_remainder, p_candidate);

n1 := subtract(p_candidate,fast_int.string_to_int('1'));
if fast_int.eq (x, fast_int.string_to_int('1')) or fast_int.eq (x, n1) then return false; end if;
dbms_output.put_line('P1: ' || to_char( dbms_utility.get_time - l_starttime));
<<ready>>
for r in 0 .. l_power - 1
looexec fast_int.print(fast_int.fsqrt(5,20))p
  x := fast_int.mod(fast_int.multiply(x, x), p_candidate);
  if  eq(x, '1')
  then b:= true; exit ready;
  elsif eq (x, n1)
  then b:= false; exit ready;
  end if;
end loop;
return nvl(b,true);
exception when others then
  util.show_error('Error in function witness. Candidate: ' || p_candidate, sqlerrm);
end witness;
--
begin
if lt(p_candidate,fast_int.string_to_int('3')) or eq(p_candidate, fast_int.string_to_int('5')) or eq(p_candidate, fast_int.string_to_int('7')) then return 1; end if;
while l_rest = '0'
loop
  l_remainder := divide(l_remainder, '2', l_rest);
  l_power     := l_power + 1;
end loop;
-- l_witness := 2;  round(dbms_random.value (2, 10));  random number. To be checked what the range can be.
for v in 0 .. p_trials
loop
  if witness(p_candidate, l_remainder) then return 0; end if;
end loop;
return 1;

exception when others then
  util.show_error('Error in function prime_test.', sqlerrm);
end prime_test;
*/

end  fast_int;
/
