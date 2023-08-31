DOC
--
-- Author      : Theo Stienissen
-- email       : theo.stienissen@gmail.com
-- Created     : March 2017
-- Last Update : April  2023
-- @"C:\Users\Theo\OneDrive\Theo\Project\Maths\Large integers\Number\FastInt3_test_restrict.sql"
-- Integers based on integer datatype
-- ToDo Support for negative numbers.
-- Indexing is from right to left

alter session set plsql_warnings='ENABLE:ALL';
set serveroutput on size unlimited

create table fast_int_tbl
( id       number(10)  not null
, seq      number(10)  not null
, val      number(20)  not null);

alter table fast_int_tbl add constraint fast_int_tbl_pk primary key (id, seq) using index;
create sequence fast_int_seq;

create or replace type int_ty is table of integer (38);
/

create or replace type number_ty as object
( sign     integer(1)
, whole    int_ty
, fraction int_ty);
/

create table certificates
( id          number generated always as identity
, certificate varchar2 (4000)
, website     varchar2 (200));

alter table certificates add constraint certificates_pk primary key (id) using index;

create table rsa_factoring
( fast_int_id  number(10)  not null
, lowerbound   integer 
, upperbound   integer
, confirmed    number(10));

-- alter table rsa_factoring add constraint rsa_factoring_pk primary key (id) using index;
-- alter table rsa_factoring add constraint rsa_factoring_fk1 foreign key (cert_id) references certificates (id) on delete set null;

-- Cross link table
create table fast_int_cert_join
( fast_int_id  number (10)  not null
, cert_id      number (10) 
, sqrt_id      number (10)
, init_val     number (10));

create unique index fast_int_cert_join_uk1 on fast_int_cert_join (fast_int_id);
create unique index fast_int_cert_join_uk2 on fast_int_cert_join (cert_id);
create unique index fast_int_cert_join_uk3 on fast_int_cert_join (sqrt_id);


#
set serveroutput on size unlimited

create or replace package fast_int_pkg
is

function ltrim_int (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function nice (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function get_length (p_number types_pkg.fast_int_ty) return integer;

function get_digit (p_digit in integer, p_number in types_pkg.fast_int_ty) return integer;

procedure print (p_number in types_pkg.fast_int_ty, p_width in integer default 5);

function save_number (p_number in types_pkg.fast_int_ty, p_id in number default null) return integer;

function load_number(p_id in integer) return types_pkg.fast_int_ty result_cache;

function eq_value (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return boolean;

function eq_zero (p_number in types_pkg.fast_int_ty) return boolean;

function string_to_int (p_string in varchar2) return types_pkg.fast_int_ty;

function int_to_string (p_number in types_pkg.fast_int_ty) return varchar2;

function int_to_fast_int (p_number in integer) return types_pkg.fast_int_ty;
	
function gt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function eq (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function ge (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function lt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function le (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean;

function add (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function mult_n (p_factor in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function add_n (p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function mult_f_add_n (p_factor in integer, p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function multiply (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty;

function nfac (p_number in integer) return types_pkg.fast_int_ty result_cache;

function divide (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty, p_remainder out nocopy types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function gcd (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function lcm (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function fmod (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty;

function fmodi (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return integer;

function is_square (p_number in integer) return boolean;

function is_square (p_number in types_pkg.fast_int_ty) return boolean;

function odd (p_number in types_pkg.fast_int_ty) return boolean;

function power_mod (p_base in integer, p_power in integer, p_mod in integer) return types_pkg.fast_int_ty result_cache;

function fpower (p_base in integer, p_power in integer) return types_pkg.fast_int_ty result_cache;

function fsubstr (p_number in types_pkg.fast_int_ty, p_pos in integer) return types_pkg.fast_int_ty;

function fsqrt (p_sqr in integer, p_precision in integer) return types_pkg.fast_int_ty;

function fsqrt (p_number in types_pkg.fast_int_ty, p_upper in boolean default TRUE) return types_pkg.fast_int_ty;

function f_save_certificate (p_certificate in varchar2, p_website in varchar2) return integer;

function f_certificate_hex_to_dec (p_certificate in varchar2) return types_pkg.fast_int_ty;
function f_certificate_hex_to_dec (p_integer_id in number) return types_pkg.fast_int_ty;

function f_certificate_dec_to_hex (p_certificate in types_pkg.fast_int_ty) return varchar2;

function f_square_matches_modulo (p_number in types_pkg.fast_int_ty, p_modulo in integer) return integer;

function f_get_divisors (p_product in integer) return integer_tab pipelined;

procedure p_factor_product (p_integer_id in integer, p_lower_bound in integer default null, p_interval integer default 100);

procedure run_factoring_routine (p_integer_id in integer, p_iterations in integer default 100, p_interval integer default 10000000);

procedure stop_all_jobs;

procedure p_shor (p_integer_id in integer, p_iterations in integer default 100);

end  fast_int_pkg;
/

create or replace package body fast_int_pkg
is
-- Base is 10 ** 18
g_base        constant integer (20)          := 1E18;
g_base_length constant integer (2)           := 18;
g_hex_base    constant integer               := power (16, 16);
g_hex_base_f  constant types_pkg.fast_int_ty := int_to_fast_int (power (16, 16));
g_save        types_pkg.fast_int_ty;
g_empty       types_pkg.fast_int_ty;
g_job_name    constant varchar2 (30) := 'fast_int_pkg.p_factor_product';

/*************************************************************************************************************************************************/

--
-- Convert a hexadecimal value to decimal
--
function f_hex_to_dec (p_string in varchar2) return integer
is
begin
  return to_number (p_string, rpad ('X', length(p_string), 'X'));

exception when others then
  util.show_error ('Error in function f_hex_to_dec for: ' || p_string, sqlerrm);
  return null;
end f_hex_to_dec;

/*************************************************************************************************************************************************/

--
-- Convert a decimal value to hexadecimal
--
function f_dec_to_hex (p_piece in integer) return varchar2
is
begin
  return to_char (p_piece, rpad ('X', length(p_piece), 'X'));

exception when others then
  util.show_error ('Error in function f_dec_to_hex for ' || p_piece, sqlerrm);
  return null;
end f_dec_to_hex;

/*************************************************************************************************************************************************/

--
-- Remove leading zeros. Indexing is from right to left
--
function ltrim_int (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_return types_pkg.fast_int_ty := p_number;
begin
  while l_return.count > 1 and l_return (l_return.count) = 0
  loop
     l_return.delete (l_return.count);
  end loop;
  return l_return;

exception when others then
  util.show_error ('Error in function ltrim_int.' , sqlerrm);
  return g_empty;
end ltrim_int;

/*************************************************************************************************************************************************/

--
-- Reorg array to base 1E18
--
function nice (p_number types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_overflow  integer (38) := 0;
begin
  for j in p_number.first ..  p_number.last
  loop
    l_result (j):= p_number (j) + l_overflow;
    l_overflow  := trunc (l_result (j) / g_base);
    l_result(j) := mod (l_result (j), g_base);
  end loop;
  if l_overflow != 0 then l_result (l_result.count + 1) := l_overflow; end if;
  return ltrim_int (l_result);

exception when others then
  util.show_error ('Error in function nice.' , sqlerrm);
  return g_empty;
end nice;

/*************************************************************************************************************************************************/

--
-- Calculate lenght of an integer
--
function get_length (p_number types_pkg.fast_int_ty) return integer
is
l_return types_pkg.fast_int_ty := p_number;
begin
  if   p_number.count = 0
  then return 0;
  else return (p_number.count - 1) * g_base_length + length (p_number (p_number.count));
  end if;

exception when others then
  util.show_error ('Error in function get_length.' , sqlerrm);
  return null;
end get_length;

/*************************************************************************************************************************************************/

--
-- Get n-th digit of an integer. Sequences from left to right.
--
function get_digit (p_digit in integer, p_number in types_pkg.fast_int_ty) return integer
is
l_seq   integer (10);
l_digit integer (10);
begin
-- First determine in which sequence to look
  l_seq := p_number.count - 1 - floor ((p_digit -1 - length (p_number(p_number.count))) / g_base_length);

  if  l_seq = p_number.count
  then
    return substr (p_number(l_seq), p_digit, 1);
  else
    l_digit :=  mod (p_digit - length (p_number (p_number.count)) -1 , g_base_length) + 1;
    return substr (lpad (p_number (l_seq), g_base_length, '0'), l_digit, 1);
  end if;

exception when others then
  util.show_error ('Error in function get_digit. Digit = ' || p_digit , sqlerrm);
  return null;
end get_digit;

/*************************************************************************************************************************************************/

--
-- Convert string to integer. Indexing from right to left
-- To be checked
--
function string_to_int (p_string in varchar2) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_lenght    integer (10) := length (p_string);
begin
  for j in 1 .. ceil (length(p_string) / g_base_length)
  loop
    if   l_lenght > j * g_base_length
    then l_result(j) := substr (p_string, l_lenght - j * g_base_length + 1, g_base_length);
    else l_result(j) := substr (p_string, 1, l_lenght - (j - 1) * g_base_length);
    end if;
  end loop;
  return l_result;

exception when others then
  util.show_error ('Error in function string_to_int.' , sqlerrm);
  return g_empty;
end string_to_int;

/*************************************************************************************************************************************************/

--
-- Convert integer to a string
--
function int_to_string (p_number in types_pkg.fast_int_ty) return varchar2
is
l_string varchar2 (4000) := '';
begin
  for j in p_number.first ..  p_number.last
  loop
    l_string := lpad (trim (p_number(j)), g_base_length, '0') || l_string;
  end loop;
  return ltrim(l_string, '0');

exception when others then
  util.show_error ('Error in function int_to_string.' , sqlerrm);
  return null;
end int_to_string;
	
/*************************************************************************************************************************************************/

--
-- Convert single word
--
function int_to_fast_int (p_number in integer) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
begin
  l_result (1) := p_number;
  return nice (l_result);

exception when others then
  util.show_error ('Error in function int_to_fast_int_pkg.' , sqlerrm);
  return g_empty;
end int_to_fast_int;

/*************************************************************************************************************************************************/

--
-- Prints a fast_int integer
--
procedure print (p_number in types_pkg.fast_int_ty, p_width in integer default 5)
is
l_cnt  integer (10) := 0;
begin
  if   p_number.count = 0
  then dbms_output.put_line ('Print issue. Number not initialized.');
  else
    for j in reverse p_number.first ..  p_number.last
    loop
      if mod (l_cnt, p_width) = 0 then dbms_output.new_line; end if;
      if j = p_number.last
      then
        dbms_output.put (p_number (j));
      else
        dbms_output.put (lpad (p_number (j), g_base_length, '0'));
      end if;
      l_cnt := l_cnt + 1;
    end loop;
    dbms_output.new_line;
  end if;

exception when others then
  util.show_error ('Error in procedure print. Count: ' || l_cnt || '. First: ' || p_number.first || '. Last ' || p_number.last, sqlerrm);
end print;

/*************************************************************************************************************************************************/

--
-- Saves value of an large integer in a table
--
function save_number (p_number in types_pkg.fast_int_ty, p_id in number default null) return integer
is
l_seq            integer := nvl (p_id, fast_int_seq.nextval);
type save_ty     is record (id number (10), seq number (5), val number (36));
type save_row_ty is table of save_ty index by pls_integer;
l_save           save_row_ty;
begin
  for j in p_number.first .. p_number.last loop l_save (j) := save_ty (l_seq, j, p_number (j)); end loop;
  forall j in indices of l_save insert into fast_int_tbl (id, seq, val) values (l_save (j).id, l_save (j).seq, l_save (j).val);
  commit;
  return l_seq;

exception when others then
  util.show_error ('Error in procedure save_number' , sqlerrm);
  return null;
end save_number;

/*************************************************************************************************************************************************/

--
-- Loads value from a large integer from a table
--
function load_number (p_id in integer) return types_pkg.fast_int_ty result_cache
is
l_return types_pkg.fast_int_ty;
begin
  select val bulk collect into l_return from fast_int_tbl where id = p_id order by seq;
  return l_return;

exception when others then
  util.show_error ('Error in function load_number.' , sqlerrm);
  return g_empty;
end load_number;

/*************************************************************************************************************************************************/

--
-- Compare a fast_int to a regular integer
--
function eq_value (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return boolean
is
l_return types_pkg.fast_int_ty := nice (p_number1);
begin
  return l_return.count = 1 and l_return (1) = p_number2;

exception when others then
  util.show_error ('Error in function eq_value.' , sqlerrm);
  return null;
end eq_value;

/*************************************************************************************************************************************************/

--
-- Checks if a value = 0
--
function eq_zero (p_number in types_pkg.fast_int_ty) return boolean
is
l_return types_pkg.fast_int_ty := nice (p_number);
begin
  return eq_value (p_number, 0);

exception when others then
  util.show_error ('Error in function eq_zero.' , sqlerrm);
  return null;
end eq_zero;

/*************************************************************************************************************************************************/

--
-- Greater than
--
function gt (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
  if   p_number1.count != p_number2.count
  then return p_number1.count > p_number2.count;
  else
    for j in reverse p_number1.first ..  p_number1.last
    loop
      if   p_number1 (j) != p_number2 (j)
      then return p_number1 (j) > p_number2 (j);
      end if;
    end loop;
  end if;
  return false;

exception when others then
  util.show_error ('Error in function GT.' , sqlerrm);
  return null;
end gt;

/*************************************************************************************************************************************************/

--
-- Equal
--
function eq (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
  if   p_number1.count != p_number2.count
  then return false;
  else
    for j in p_number1.first ..  p_number1.last
    loop
      if p_number1 (j) != p_number2 (j)
      then return false;
      end if;
    end loop;
  end if;
  return true;

exception when others then
  util.show_error ('Error in function EQ.', sqlerrm);
  return null;
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
  util.show_error ('Error in function GE.', sqlerrm);
  return null;
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
  util.show_error ('Error in function LT.', sqlerrm);
  return null;
end lt;

/*************************************************************************************************************************************************/

--
-- Less or equal
--
function le (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return boolean
is
begin
  return gt (p_number2, p_number1) or eq (p_number1, p_number2);

exception when others then
  util.show_error ('Error in function LE.', sqlerrm);
  return null;
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
      l_result (j) := p_number1 (j) + p_number2 (j);
    end loop;  
  else
    l_result := p_number2;
    for j in 1 .. p_number1.count
    loop
      l_result (j) := p_number1 (j) + p_number2 (j);
    end loop;
  end if;
  return nice (l_result);

exception when others then
  util.show_error ('Error in function add.', sqlerrm);
  return g_empty;
end add;

/*************************************************************************************************************************************************/

--
-- Multiply long integer with regular integer factor N
--
function mult_n (p_factor in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty;
l_overflow  integer (38) := 0;
begin
  if    p_factor < 0 or p_factor is null then  raise_application_error(-20001, 'Invalid factor: ' || p_factor);
  elsif p_factor = 0 then return string_to_int ('0');
  elsif p_factor = 1 then return p_number;
  else
    for j in 1 .. p_number.count
    loop
      l_result (j) := p_factor * p_number (j) + l_overflow;
	  l_overflow   := trunc (l_result (j) / g_base);
      l_result(j)  := mod (l_result (j), g_base);
    end loop;
  end if;
  if l_overflow != 0 then l_result (l_result.count + 1) := l_overflow; end if;
  return l_result;

exception when others then
  util.show_error ('Error in function mult_n for factor: ' || p_factor ||'.', sqlerrm);
  return g_empty;
end mult_n;
 
/*************************************************************************************************************************************************/

--
-- Add integer n for a fast_int
--
function add_n (p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty := p_number;
l_overflow  integer (38);
begin
  l_result (1) := l_result (1) + p_offset;
  l_overflow  := trunc (l_result (1) / g_base);
  <<done>>
  for j in p_number.first + 1 ..  p_number.last
  loop
    exit done when l_overflow = 0;
	l_result(j) := l_result(j) + l_overflow;
    l_overflow  := trunc (l_result(j) / g_base);
    l_result(j) := mod (l_result(j), g_base);
  end loop;
  if l_overflow != 0 then l_result (l_result.count + 1) := l_overflow; end if; 
  return l_result;

exception when others then
  util.show_error ('Error in function add_n for offset: ' || p_offset || '.', sqlerrm);
  return g_empty;
end add_n;

/*************************************************************************************************************************************************/

--
-- Multiply with factor and add offset
--
function mult_f_add_n (p_factor in integer, p_offset in integer, p_number in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
begin
  return add_n (p_offset, mult_n (p_factor, p_number));

exception when others then
  util.show_error ('Error in function mult_f_add_n for offset: ' || p_offset || '.', sqlerrm);
  return g_empty;
end mult_f_add_n;

/*************************************************************************************************************************************************/

--
-- Multiply 2 integers
--
function multiply (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result    types_pkg.fast_int_ty := int_to_fast_int (0);
l_demi      types_pkg.fast_int_ty;
l_mult      integer (38);
l_overflow  integer (38);
l_cnt       integer (10);
begin
  for x in 1 .. p_number1.count
  loop
    l_demi.delete;
    l_overflow := 0;
    for y in 1 .. p_number2.count
    loop
      l_mult     := p_number1 (x) * p_number2 (y) + l_overflow;
      l_overflow := trunc (l_mult / g_base);
      l_demi(y)  := mod (l_mult, g_base);
    end loop;
    if l_overflow != 0 then l_demi (p_number2.count + 1) := l_overflow; end if;

    l_overflow := 0;
    for j in 1 .. l_demi.count
    loop
      l_cnt := j + x - 1;
      if l_result.count  < l_cnt
      then l_result(l_cnt)  := l_demi (j) + l_overflow;
      else l_result(l_cnt)  := l_result (l_cnt) + l_demi (j) + l_overflow;
      end if;

      l_overflow            := trunc (l_result(l_cnt) / g_base);
      l_result(l_cnt)       := mod (l_result(l_cnt), g_base);
    end loop;

    while l_overflow != 0
    loop
      l_cnt := l_cnt + 1;
      if l_result.count  < l_cnt
      then l_result(l_cnt)  :=  l_overflow;
      else l_result(l_cnt)  :=  l_result (l_cnt) + l_overflow;
      end if;

      l_overflow            := trunc (l_result (l_cnt) / g_base);
      l_result(l_cnt)       := mod (l_result (l_cnt), g_base);
    end loop; -- while loop
  end loop; -- x loop
  return l_result;

exception when others then
  util.show_error ('Error in function multiply.', sqlerrm);
  return g_empty;
end multiply;

/*************************************************************************************************************************************************/

--
-- Subtract 2 integers. Result is: p_number1 - p_number2
--
function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
 l_result    types_pkg.fast_int_ty := p_number1;
 l_borrow    integer (1) := 0;
 l_cnt       number (10);
begin
  if gt (p_number2, p_number1)
  then return subtract (p_number2, p_number1);
  else
    for j in p_number2.first .. p_number2.last
    loop
      l_result(j) :=  l_result (j) - p_number2 (j);
      if l_result (j) < 0
      then
        l_result (j)     := l_result (j) + g_base;
        l_result (j + 1) := l_result (j + 1) - 1;
      end if;
    end loop;
  end if;
  return nice (l_result);

exception when others then
  util.show_error ('Error in function subtract.', sqlerrm);
  return g_empty;
end subtract;

/*************************************************************************************************************************************************/

--
-- Subtract 2 integers. Result is: p_number1 - p_number2
--
function subtract (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return types_pkg.fast_int_ty
is
begin
  return subtract (p_number1, fast_int_pkg.string_to_int (p_number2));

exception when others then
  util.show_error('Error in function subtract 2.', sqlerrm);
  return g_empty;
end subtract;

/*************************************************************************************************************************************************/

--
-- Calculate facultorial
--
function nfac (p_number in integer) return types_pkg.fast_int_ty result_cache
is
l_result types_pkg.fast_int_ty;
begin
  l_result(1) := p_number;
  if   p_number <= 2 then return l_result;
  else return multiply (nfac (p_number -1), l_result);
  end if;

exception when others then
  util.show_error ('Error in function nfac.', sqlerrm);
  return g_empty;
end nfac;

/*************************************************************************************************************************************************/

--
-- Divide 2 long integers
--
function divide (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty, p_remainder out nocopy types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_result        types_pkg.fast_int_ty;
l_borrow        number (1) := 0;
l_remain        types_pkg.fast_int_ty;
l_mult_array    types_pkg.fast_int_array_ty;
l_length1       integer (10) := get_length (p_number1);
l_length2       integer (10) := get_length (p_number2);
begin
  if gt (p_number2, p_number1)
  then
    p_remainder := p_number1;
    return string_to_int ('0');
  else
-- Determine the 8 multiples
  for j in 2 .. 9
  loop
    l_mult_array (j) := mult_n (j, p_number2);
  end loop;
--
  l_remain(1) := 0;
  for j in 1 .. l_length2 -1
  loop
    l_remain := mult_f_add_n (10, get_digit (j, p_number1), l_remain);
  end loop;

  l_result(1) := 0;
  for j in l_length2 .. l_length1
  loop
    l_remain := mult_f_add_n (10, get_digit (j, p_number1), l_remain);
    if    ge (l_remain, l_mult_array (9)) then l_result := mult_f_add_n (10, 9, l_result); l_remain := subtract (l_remain, l_mult_array(9));
    elsif ge (l_remain, l_mult_array (8)) then l_result := mult_f_add_n (10, 8, l_result); l_remain := subtract (l_remain, l_mult_array(8));
    elsif ge (l_remain, l_mult_array (7)) then l_result := mult_f_add_n (10, 7, l_result); l_remain := subtract (l_remain, l_mult_array(7));
    elsif ge (l_remain, l_mult_array (6)) then l_result := mult_f_add_n (10, 6, l_result); l_remain := subtract (l_remain, l_mult_array(6));
    elsif ge (l_remain, l_mult_array (5)) then l_result := mult_f_add_n (10, 5, l_result); l_remain := subtract (l_remain, l_mult_array(5));
    elsif ge (l_remain, l_mult_array (4)) then l_result := mult_f_add_n (10, 4, l_result); l_remain := subtract (l_remain, l_mult_array(4));
    elsif ge (l_remain, l_mult_array (3)) then l_result := mult_f_add_n (10, 3, l_result); l_remain := subtract (l_remain, l_mult_array(3));
    elsif ge (l_remain, l_mult_array (2)) then l_result := mult_f_add_n (10, 2, l_result); l_remain := subtract (l_remain, l_mult_array(2));
    elsif ge (l_remain, p_number2)        then l_result := mult_f_add_n (10, 1, l_result); l_remain := subtract (l_remain, p_number2);
    else  l_result := mult_n (10, l_result);
    end if;
  end loop;
  p_remainder := nice (l_remain);
  return nice (l_result);
end if;

exception when others then
  util.show_error ('Error in function divide.', sqlerrm);
  return g_empty;
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
  if eq_zero (p_number1)
  then return p_number2;
  else
    l_div := divide (p_number2, p_number1, l_rest);
    return gcd (l_rest, p_number1);
  end if;

exception when others then
  util.show_error ('Error in function gcd.', sqlerrm);
  return g_empty;
end gcd;

/*************************************************************************************************************************************************/

--
-- Least common multiple
--
function lcm (p_number1 in types_pkg.fast_int_ty, p_number2 in types_pkg.fast_int_ty) return types_pkg.fast_int_ty
is
l_rest types_pkg.fast_int_ty;
begin
if    eq_zero (p_number1)
then  return string_to_int ('0');
elsif eq_zero (p_number2)
then  return string_to_int ('0');
else  return nice (divide (multiply (p_number1, p_number2), gcd (p_number1, p_number2), l_rest));
end if;
	
exception when others then
  util.show_error ('Error in function lcm.', sqlerrm);
  return g_empty;
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
  l_div := divide (p_number1, p_number2, l_rest);
  return l_rest;

exception when others then
  util.show_error ('Error in function fmod 1.', sqlerrm);
  return g_empty;
end fmod;

/*************************************************************************************************************************************************/

--
-- Modulus mod (fast_int, integer) return integer
--
function fmodi (p_number1 in types_pkg.fast_int_ty, p_number2 in integer) return integer
is
l_remainder integer(20) := 0;
begin
if p_number2 in (2, 4, 5, 8, 10, 20, 25, 40, 50, 100, 200)
then
  return mod (p_number1 (1), p_number2);
else
  for j in reverse 1 .. p_number1.count
  loop
    l_remainder := mod (l_remainder * g_base + p_number1 (j), p_number2);
  end loop;
  return l_remainder;
end if;

exception when others then
  util.show_error ('Error in function fmodi.', sqlerrm);
  return null;
end fmodi;

/*************************************************************************************************************************************************/

--
-- Checks if a number is a perfect square
--
function is_square (p_number in integer) return boolean
is
l_sqrt    constant number := sqrt (p_number);
begin
  return round (l_sqrt * l_sqrt) = p_number;

exception when others then
  util.show_error ('Error in function is_square for number: ' || p_number || '.', sqlerrm);
  return null;
end is_square;

/*************************************************************************************************************************************************/

--
-- Checks if a number is a perfect square
--
function is_square (p_number in types_pkg.fast_int_ty) return boolean
is
l_low_sqrt types_pkg.fast_int_ty  := fast_int_pkg.fsqrt (p_number, false);
l_high_sqrt types_pkg.fast_int_ty := fast_int_pkg.fsqrt (p_number, true);
begin
   return fast_int_pkg.eq (fast_int_pkg.multiply (l_low_sqrt, l_low_sqrt), p_number) or fast_int_pkg.eq (fast_int_pkg.multiply (l_high_sqrt, l_high_sqrt), p_number);

exception when others then
  util.show_error ('Error in function is_square', sqlerrm);
  return null;
end is_square;

/*************************************************************************************************************************************************/

--
-- Checks if a number is a perfect square
--
function odd (p_number in types_pkg.fast_int_ty) return boolean
is 
begin 
 return mod (p_number(1), 2) = 1;

exception when others then
  util.show_error ('Error in function odd', sqlerrm);
  return null;
end odd;

/*************************************************************************************************************************************************/

--
-- PowerMod. Only "small" integers
--
function power_mod (p_base in integer, p_power in integer, p_mod in integer) return types_pkg.fast_int_ty result_cache
is
l_return   types_pkg.fast_int_ty;
begin
  if    p_power = 1 then l_return (1) := mod (p_base, p_mod);          return nice (l_return);
  elsif p_power = 2 then l_return (1) := mod (p_base * p_base, p_mod); return nice (l_return);
  else
    return fast_int_pkg.fmod (fast_int_pkg.multiply (power_mod (p_base, ceil (p_power / 2), p_mod), power_mod (p_base, floor (p_power / 2), p_mod)), string_to_int (p_mod));
  end if;

exception when others then
  util.show_error ('Error in function power_mod.', sqlerrm);
  return g_empty;
end power_mod;

/*************************************************************************************************************************************************/

--
-- Power
--
function fpower (p_base in integer, p_power in integer) return types_pkg.fast_int_ty result_cache
is
l_return   types_pkg.fast_int_ty;
begin
  if    p_power = 1
  then  l_return(1) := p_base; return nice (l_return);
  elsif p_power = 2
  then  l_return(1) := p_base * p_base; return nice (l_return);
  else  return fast_int_pkg.multiply (fpower (p_base, floor (p_power / 2)), fpower (p_base, ceil (p_power / 2)));
  end if;

exception when others then
  util.show_error ('Error in function fpower for power: ' || p_power || '.', sqlerrm);
  return g_empty;
end fpower;

/*************************************************************************************************************************************************/

function fsubstr (p_number in types_pkg.fast_int_ty, p_pos in integer) return types_pkg.fast_int_ty
is
l_number types_pkg.fast_int_ty := string_to_int('0');
begin
  if   get_length (p_number) <= p_pos
  then return p_number;
  else
    for j in 1 .. p_pos
    loop
      l_number := mult_f_add_n (10, get_digit (j, p_number), l_number);
    end loop;
  end if;
  return l_number;

exception when others then
  util.show_error ('Error in function fsubstr for position: ' || p_pos ||'.', sqlerrm);
  return g_empty;
end fsubstr;

/*************************************************************************************************************************************************/

-- Square root function. Comma's removed.
-- Result between last digit and last_digit + 1
--
function fsqrt (p_sqr in integer, p_precision in integer) return types_pkg.fast_int_ty
is
l_sqr  types_pkg.fast_int_ty := int_to_fast_int (p_sqr);
begin
  for j in 1 .. greatest (ceil (2 * p_precision / g_base_length), 33)
  loop
    l_sqr := multiply (l_sqr, int_to_fast_int (g_base));
  end loop;
  return fsqrt (l_sqr);

exception when others then
  util.show_error ('Error in function fsqrt.', sqlerrm);
  return g_empty;
end fsqrt;

/*************************************************************************************************************************************************/

--
-- Function to assist in cracking certificates
-- Result between outcome and outcome + 1
--
function fsqrt (p_number in types_pkg.fast_int_ty, p_upper in boolean default TRUE) return types_pkg.fast_int_ty
is
l_lower_bound  types_pkg.fast_int_ty;
l_upper_bound  types_pkg.fast_int_ty;
l_remainder    types_pkg.fast_int_ty;
l_result       types_pkg.fast_int_ty;
l_string       varchar2(4000);
l_length       number(5);
l_int          integer;
l_count integer := 0;
begin
  l_string :=  int_to_string (p_number);
  l_length :=  length (l_string);
  if    mod(l_length, 2) = 0
  then l_int := trunc (sqrt (substr (l_string, 1, 32)));
  else l_int := trunc (sqrt (substr (l_string, 1, 33)));
  end if;
  l_lower_bound := string_to_int (rpad (l_int    , ceil (l_length / 2), '0'));
  l_upper_bound := string_to_int (rpad (l_int + 1, ceil (l_length / 2), '0'));
 
  while gt (subtract (l_upper_bound, l_lower_bound), string_to_int ('1')) -- and l_count < 10
  loop
    l_result := fast_int_pkg.divide (fast_int_pkg.add (l_lower_bound, l_upper_bound), int_to_fast_int (2), l_remainder);
    if le (multiply (l_result, l_result), p_number)
    then l_lower_bound := l_result;
    else l_upper_bound := l_result;
    end if; 
  end loop;

  if p_upper
  then
    g_save := l_lower_bound;
    return l_upper_bound;
  else
    g_save := l_upper_bound;
    return l_lower_bound;
  end if;

exception when others then
  util.show_error ('Error in function fsqrt.', sqlerrm);
  return g_empty;
end fsqrt;

/*************************************************************************************************************************************************/

--
-- Save certificate in a table.
--
function f_save_certificate (p_certificate in varchar2, p_website in varchar2) return integer
is 
l_id pls_integer;
begin 
  insert into certificates (certificate, website) values (p_certificate, p_website) returning id into l_id;
  commit;
  return l_id;

exception when others then
  util.show_error ('Error in function f_save_certificate.', sqlerrm);
  return null;
end f_save_certificate;

/*************************************************************************************************************************************************/

--
-- Hex with base 16 ** 16. Load from table
--
function f_certificate_hex_to_dec (p_integer_id in number) return types_pkg.fast_int_ty
is 
l_certificate certificates.certificate%type;
begin 
  select certificate into l_certificate from certificates where id = p_integer_id;
  return f_certificate_hex_to_dec (l_certificate);

exception when others then
  util.show_error ('Error in function f_certificate_hex_to_dec.', sqlerrm);
  return g_empty;
end f_certificate_hex_to_dec;

/*************************************************************************************************************************************************/

--
-- Hex with base 16 ** 16
--
function f_certificate_hex_to_dec (p_certificate in varchar2) return types_pkg.fast_int_ty
is
l_result       types_pkg.fast_int_ty :=  int_to_fast_int (0);
l_hex_pos      types_pkg.fast_int_ty :=  int_to_fast_int (1);
l_cert_length  constant integer(5) := length (p_certificate);
l_cert_pieces  constant integer(5) := trunc ((length (p_certificate) - 1)/ 16);
begin
-- Cut certificate in pieces of 16 bytes and convert these to decimal. Indexed from left to right
  for j in  1 .. l_cert_pieces
  loop
    l_result  := add (l_result, multiply (l_hex_pos, int_to_fast_int (f_hex_to_dec (substr (p_certificate, l_cert_length -  16 * j + 1,  16)))));
    l_hex_pos := multiply (l_hex_pos, g_hex_base_f);
  end loop;
  l_result  := add (l_result, multiply (l_hex_pos, int_to_fast_int (f_hex_to_dec (substr (p_certificate, 1, mod(l_cert_length, 16))))));
  return nice (l_result);

exception when others then
  util.show_error ('Error in function f_certificate_hex_to_dec.', sqlerrm);
  return g_empty;
end f_certificate_hex_to_dec;

/*************************************************************************************************************************************************/

--
-- Conversion decimal to hex.
-- 
function f_certificate_dec_to_hex (p_certificate in types_pkg.fast_int_ty) return varchar2
is
l_result      varchar2(4000) := '';
l_certificate types_pkg.fast_int_ty := p_certificate;
l_dummy       types_pkg.fast_int_ty;
begin
  while l_certificate.count > 1
  loop
    l_result      := f_dec_to_hex (fmodi (l_certificate, g_base)) || l_result;
    l_certificate := divide (l_certificate, g_hex_base_f, l_dummy);
  end loop;
  l_result        := f_dec_to_hex (fmodi (l_certificate, g_base)) || l_result;
  return l_result;

exception when others then
  util.show_error ('Error in function f_certificate_dec_to_hex.', sqlerrm);
  return null;
end f_certificate_dec_to_hex;

/*************************************************************************************************************************************************/

--
-- Supporting function for cracking certificates: x ** 2 mod (n) must be in the allowed range
--
function f_square_matches_modulo (p_number in types_pkg.fast_int_ty, p_modulo in integer) return integer
is
l_int integer := fast_int_pkg.fmodi (p_number, p_modulo);
begin
  select nvl (max (id), -1) into l_int from table (test_pkg.f_id_list (2, p_modulo)) where id = l_int;
  return l_int;

exception when others then
  util.show_error ('Error in function f_square_matches_modulo for: ' || p_modulo || '.', sqlerrm);
  return null;
end f_square_matches_modulo;

/*************************************************************************************************************************************************/

--
-- Small integers pfo for product of 2 primes.
--
function f_get_divisors (p_product in integer) return integer_tab pipelined
is
l_lower_bound        integer := 3;
l_a                  integer := floor (sqrt (p_product));
l_b                  integer;
l_b2                 integer;
l_int                integer;
l_ok                 boolean;
l_mod                integer;
begin
<<outer>>
while l_lower_bound <= l_a
loop
   l_lower_bound := l_lower_bound + 1;
   l_b2 := l_a + l_lower_bound;
   l_b2 := l_b2 * l_b2 - p_product;
   l_ok := TRUE;
  <<inner>>
  for modu in 3 .. 30
  loop
    select nvl(max(id), -1) into l_int from table (test_pkg.f_id_list (2, modu)) where id = mod (l_b2, modu);
    l_ok := l_ok and l_int >= 0;
    exit inner when not l_ok;
  end loop;
  if l_ok and is_square (l_b2)
  then
	l_a := sqrt (l_b2 + p_product);
    l_b := sqrt (l_b2);
	pipe row (integer_row (l_a + l_b));
	pipe row (integer_row (l_a - l_b));
	exit outer;
  end if;
end loop;

exception when others then
  util.show_error ('Error in procedure f_get_divisors for product: ' || p_product || '.', sqlerrm);
end f_get_divisors;

/*************************************************************************************************************************************************/

--
--  This is the serving routine
-- b ** 2 = a ** 2 - N.
--
procedure p_factor_product (p_integer_id in integer, p_lower_bound in integer default null, p_interval integer default 100)
is
l_N                  types_pkg.fast_int_ty;
l_a                  types_pkg.fast_int_ty;
l_b2                 types_pkg.fast_int_ty;
l_first_b2           types_pkg.fast_int_ty;
l_sqrt               types_pkg.fast_int_ty;
l_rc                 integer;
l_sqrt_id            integer;
l_init_val           integer;
l_lower_bound        integer;
l_upper_bound        integer;
l_count              integer;
--
function validate_if_square return boolean 
is 
begin 
if substr (l_b2 (1), -1) in (2,3,7,8)                                                                                     then return false;                      
elsif fmodi (l_b2,   3) = 2                                                                                               then return false;
elsif fmodi (l_b2,   4) in (2, 3)                                                                                         then return false;
elsif fmodi (l_b2,   5) in (2, 3)                                                                                         then return false;
elsif fmodi (l_b2,   7) in (3, 5, 6)                                                                                      then return false;
elsif fmodi (l_b2,   8) in (2, 3, 5, 6, 7)                                                                                then return false;
elsif fmodi (l_b2,   9) in (3, 6)                                                                                         then return false;
elsif fmodi (l_b2,  11) in (2, 6, 7, 8, 10)                                                                               then return false;
elsif fmodi (l_b2,  12) in (3, 6, 7, 10)                                                                                  then return false;
elsif fmodi (l_b2,  13) in (2, 5, 6, 7, 8, 11)                                                                            then return false;
elsif fmodi (l_b2,  16) in (2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15)                                                     then return false;
elsif fmodi (l_b2,  17) in (3, 5, 6, 7, 10, 11, 12, 14)                                                                   then return false;
elsif fmodi (l_b2,  18) in (3, 6, 12, 15)                                                                                 then return false;
elsif fmodi (l_b2,  19) in (2, 3, 8, 10, 12, 13, 14, 15, 18)                                                              then return false;
elsif fmodi (l_b2,  20) in (6, 10, 11, 14, 15, 19)                                                                        then return false;
elsif fmodi (l_b2,  23) in (5, 7, 10, 11, 14, 15, 17, 19, 20, 21, 22)                                                     then return false;
elsif fmodi (l_b2,  24) in (3, 6, 7, 10, 13, 15, 18, 19, 21, 22)                                                          then return false;
elsif fmodi (l_b2,  25) in (5, 10, 15, 20)                                                                                then return false;
elsif fmodi (l_b2,  27) in (3, 6, 12, 15, 18, 21, 24)                                                                     then return false;
elsif fmodi (l_b2,  28) in (2, 7, 11, 14, 15, 18, 22, 23)                                                                 then return false;
elsif fmodi (l_b2,  29) in (2, 3, 8, 10, 11, 12, 14, 15, 17, 18, 19, 21, 26, 27)                                          then return false;
elsif fmodi (l_b2,  31) in (3, 6, 11, 12, 13, 15, 17, 21, 22, 23, 24, 26, 27, 29, 30)                                     then return false;
elsif fmodi (l_b2,  32) in (2, 3, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15, 18, 19, 20, 21, 22, 23, 24, 26, 27, 28, 29, 30, 31) then return false;
-- elsif fmodi (l_b2,  36) in (3, 6, 7, 10, 12, 15, 18, 19, 21, 22, 24, 27, 30, 31, 33, 34)                                  then return false;
-- elsif fmodi (l_b2,  37) in (2, 5, 6, 8, 13, 14, 15, 17, 18, 19, 20, 22, 23, 24, 29, 31, 32, 35)                           then return false;
else  return true;  
end if;
end validate_if_square;
--
begin
--  Initial load
  l_N := fast_int_pkg.load_number (p_integer_id);
  select sqrt_id, init_val into l_sqrt_id, l_init_val from fast_int_cert_join where fast_int_id = p_integer_id;
  l_a         := fast_int_pkg.load_number (l_sqrt_id);
  l_first_b2  := fast_int_pkg.load_number (l_init_val);
  
-- Determine where to start testing
  if p_lower_bound is null 
  then select nvl (max (upperbound), 0) + 1 into l_lower_bound from rsa_factoring where fast_int_id = p_integer_id;
  else l_lower_bound := p_lower_bound;
  end if;	
  l_upper_bound := l_lower_bound + p_interval;
  insert into rsa_factoring (fast_int_id, confirmed, lowerbound, upperbound) values (p_integer_id, -1, l_lower_bound, l_upper_bound);
  commit;
	
  for j in 0 .. p_interval
  loop
	l_count := l_lower_bound + j;
    l_b2 := add (l_first_b2, mult_f_add_n (2 * l_count, l_count * l_count, l_a));
    if validate_if_square
    then
      l_sqrt := fast_int_pkg.fsqrt (l_b2, true);
	  if fast_int_pkg.eq (fast_int_pkg.multiply (l_sqrt, l_sqrt), l_b2)
	  then  	
        l_rc := fast_int_pkg.save_number (l_sqrt);
        update rsa_factoring set confirmed = l_rc where fast_int_id = p_integer_id and upperbound = l_upper_bound;
	    l_rc := fast_int_pkg.save_number (fast_int_pkg.add_n (l_count, l_a));
        insert into rsa_factoring (fast_int_id, confirmed, lowerbound, upperbound) values (p_integer_id, l_rc, l_lower_bound, l_count);
	  elsif fast_int_pkg.eq (fast_int_pkg.multiply (g_save, g_save), l_b2)
	  then  		
        l_rc := fast_int_pkg.save_number (g_save);	
        update rsa_factoring set confirmed = l_rc where fast_int_id = p_integer_id and upperbound = l_upper_bound;
	    l_rc := fast_int_pkg.save_number (fast_int_pkg.add_n (l_count, l_a));
        insert into rsa_factoring (fast_int_id, confirmed, lowerbound, upperbound) values (p_integer_id, l_rc, l_lower_bound, l_count);
	  end if;
     end if;
  end loop;
  commit;

exception when others then
  util.show_error ('Error in procedure p_factor_product.', sqlerrm);
end p_factor_product;

/*************************************************************************************************************************************************/

--
-- Testing parallel at max capacity using the dbms_job package. This is the calling routine
--
procedure run_factoring_routine (p_integer_id in integer, p_iterations in integer default 100, p_interval integer default 10000000)
is 
l_lower_start integer;
l_count       pls_integer;
l_job         integer;
l_cpus        pls_integer;
l_id          integer;
l_sqrt_id     integer;
l_init_val    integer;
l_max         integer;
l_min         integer;
l_N           types_pkg.fast_int_ty;
l_a           types_pkg.fast_int_ty;
l_certificate varchar2(4000);
--
procedure check_if_done
is 
begin 
-- if the integer is not present in fast_int_tbl yet, then try to load it from the certificates table
  select count (*) into l_count from rsa_factoring where confirmed != -1 and fast_int_id = p_integer_id;
  if l_count > 0
  then
    select min (confirmed), max (confirmed) into l_min, l_max from rsa_factoring where fast_int_id = p_integer_id and confirmed != -1;
	fast_int_pkg.print (fast_int_pkg.add (fast_int_pkg.load_number (l_min), fast_int_pkg.load_number (l_max)));
	fast_int_pkg.print (fast_int_pkg.subtract (fast_int_pkg.load_number (l_min), fast_int_pkg.load_number (l_max)));
	raise_application_error (-20002, 'We have cracked the code!!');
  end if;
end;
--
begin
  check_if_done;
  
  select count(*) into l_count from fast_int_cert_join where fast_int_id = p_integer_id;
  if l_count = 0 then insert into fast_int_cert_join (fast_int_id) values (p_integer_id); end if;  
  	
  select count (*) into l_count from fast_int_tbl where id = p_integer_id;
  if l_count = 0
  then
    select count(*) into l_count from certificates where id = p_integer_id;
	if l_count = 0
	then 
      update fast_int_cert_join set cert_id = p_integer_id where fast_int_id = p_integer_id;
      select certificate into l_certificate from certificates where id = p_integer_id;
      l_N  := fast_int_pkg.f_certificate_hex_to_dec (l_certificate);
	  l_id := fast_int_pkg.save_number (l_N); 
    else raise_application_error (-20001, 'No large integer for this value exists!'); end if;
  else
	l_N := fast_int_pkg.load_number (p_integer_id);
  end if;
  if not odd (l_N) then raise_application_error (-20001, 'Prime product of large primes cannot be even!'); end if;

-- Load sqrt (N) into l_a
  select sqrt_id, init_val into l_sqrt_id, l_init_val from fast_int_cert_join where fast_int_id = p_integer_id;
  if l_sqrt_id is null	
  then
    l_a  := fast_int_pkg.fsqrt (l_N);
	l_sqrt_id := fast_int_pkg.save_number (l_a);
    update fast_int_cert_join set sqrt_id = l_sqrt_id where fast_int_id = p_integer_id;
	commit;
  else
    l_a := fast_int_pkg.load_number (l_sqrt_id);
  end if;

-- Get initial value for  A ** 2 - N 
  if l_init_val is null	
  then
    l_init_val := fast_int_pkg.save_number (fast_int_pkg.subtract (fast_int_pkg.multiply (l_a, l_a), l_N));
    update fast_int_cert_join set init_val = l_init_val where fast_int_id = p_integer_id;
	commit;
  end if;

-- Determine where to start and start the routines
  select nvl (max (upperbound), 0) + 1 into l_lower_start from rsa_factoring where fast_int_id = p_integer_id;
  dbms_output.put_line ('Initial lowerbound: ' || l_lower_start);
  select to_number (value) into l_cpus from v$parameter where name = 'cpu_count';
  for i in  0 .. p_iterations
  loop
    select count(*) into l_count from dba_jobs_running r, dba_jobs j where r.job = j.job and j.what like g_job_name || '%';
    for j in 0 .. 2 * (l_cpus - l_count)
    loop
      dbms_job.submit (l_job, 'fast_int_pkg.p_factor_product (' || p_integer_id || ',' || l_lower_start || ',' || p_interval || ');', sysdate);
      l_lower_start := l_lower_start + p_interval;
    end loop;
    commit;
    sys.dbms_lock.sleep (1);
  end loop;

-- Do not exit until all previous jobs have finished
  select count(*) into l_count from dba_jobs_running r, dba_jobs j where r.job = j.job and j.what like g_job_name || '%';
  while l_count != 0
  loop
    sys.dbms_lock.sleep (1);
    select count(*) into l_count from dba_jobs_running r, dba_jobs j where r.job = j.job and j.what like g_job_name || '%';
  end loop;
 
--  Delete old history. Keep last 25 rows
  delete rsa_factoring where (fast_int_id, upperbound) in 
    (select fast_int_id, upperbound from rsa_factoring where fast_int_id = p_integer_id order by upperbound desc offset 25 rows) and confirmed = -1;
  commit;

  check_if_done;  
  select max (upperbound) into l_lower_start from rsa_factoring where fast_int_id = p_integer_id;
  dbms_output.put_line ('Final   upperbound: ' || l_lower_start);

exception when others then
  util.show_error ('Error in procedure run_factoring_routine.', sqlerrm);
end run_factoring_routine;

/*************************************************************************************************************************************************/

--
-- Stop all factoring jobs
--
procedure stop_all_jobs
is 
begin 
  for j in (select job from dba_jobs where what like g_job_name || '%')
  loop 
    dbms_job.remove (j.job);
  end loop;
  commit;

exception when others then
  util.show_error ('Error in procedure stop_all_jobs.', sqlerrm);
end stop_all_jobs;

/*************************************************************************************************************************************************/

--
-- Shor's algorithm to calculate divisors of a certificate. V2.0
--
procedure p_shor (p_integer_id in integer, p_iterations in integer default 100)
is
l_N                  types_pkg.fast_int_ty;
l_certificate        varchar2 (4000);
l_product            types_pkg.fast_int_ty := fast_int_pkg.int_to_fast_int (1);
l_guess              types_pkg.fast_int_ty;
l_length             integer (10);
l_cnt                integer (10) := 0;
l_ok                 boolean := FALSE;
begin
  select certificate into l_certificate from certificates where id = p_integer_id;
  l_N := fast_int_pkg.f_certificate_hex_to_dec (l_certificate);
  l_length :=  fast_int_pkg.get_length (l_N);

  -- Calculate an educated guess for the pfo so "guess - 1" has many different factors
  maths.check_init;
  while fast_int_pkg.get_length (l_product) < l_length / 2
  loop
    l_cnt     := l_cnt + 1;
    l_product := fast_int_pkg.mult_n (maths.g_prime_tab (l_cnt), l_product);
  end loop;
  l_product   := fast_int_pkg.add_n (1, l_product);
  l_product   := fast_int_pkg.multiply (l_product, l_product);
  l_guess     := fast_int_pkg.fmod (l_product, l_N);

  <<done>>
  for pwr in 1 .. p_iterations
  loop
    l_ok := fast_int_pkg.eq_value (l_guess, 1);
    exit done when l_ok;
    l_guess := fast_int_pkg.fmod (fast_int_pkg.multiply (l_guess, l_product), l_N);
  end loop;
  
  if not l_ok
  then l_ok := fast_int_pkg.eq_value (l_guess, 1);
  end if;
  
  if l_ok
  then
    l_cnt := fast_int_pkg.save_number (l_guess);
	dbms_output. put_line ('Guess saved as: ' || l_cnt);
	fast_int_pkg.print (fast_int_pkg.gcd (l_guess, l_N));
  end if;    

exception when others then
  util.show_error ('Error in procedure p_shor for certificate: ' || p_integer_id || '. Iterations: ' || p_iterations, sqlerrm);
end p_shor;
end fast_int_pkg;
/



/*
select distinct id   from fast_int_tbl where sqrt_id = (select distinct id from fast_int_tbl where sqrt_id = 1);
-- truncate table fast_int_tbl;
-- truncate table  rsa_factoring;
@"C:\Users\Theo\OneDrive\Theo\Project\Maths\Large integers\Number\FastInt2.sql"

begin
  fast_int_pkg.run_factoring_routine (188, 400, 1000000);
end;
/


https://en.wikipedia.org/wiki/RSA_numbers#RSA-260

select distinct confirmed from rsa_factoring;
select * from rsa_factoring where cert_id = 100 order by lowerbound;

-- select * from rsa_factoring;

-- select distinct id, sqrt_id from fast_int_tbl;
DECLARE
l_x integer;
begin 
fast_int_pkg.print(fast_int_pkg.string_to_int (
'2211282552952966643528108525502623092761208950247001539441374831912882294140' ||
'2001986512729726569746599085900330031400051170742204560859276357953757185954' ||
'2988389587092292384910067030341246205457845664136645406842143612930176940208' ||
          '46391065875914794251435144458199'));
--
end;
/

-- 269
set serveroutput on size UNLIMITED
select  731041 * 472697 x from dual;
DECLARE
l_x integer;
begin 
l_x := fast_int_pkg.save_number(fast_int_pkg.string_to_int ('345560887577'));
dbms_output.put_line('X:  '|| l_x);
end;
/


a = (731041 + 472697 )/2 = 601869
b = (731041 - 472697 )/2 = 129172

set serveroutput on size UNLIMITED
set time on timing on
begin
  fast_int_pkg.run_factoring_routine (188, 400, 100000);
end;
/

declare
l_x integer;
begin 
fast_int_pkg.print(fast_int_pkg.load_number (272));
dbms_output. put_line ('----------------------------');
end;
/


--truncate table rsa_factoring;
-- Non quadratic residu's 
set serveroutput on size unlimited
create or replace function f_not_qr (p_integer integer, p_power in integer default 2) return integer_tab pipelined
is
type quadratic_residue_ty is record (ind number (10), available number (1));
type quadratic_residue_row is table of quadratic_residue_ty index by pls_integer;
l_array quadratic_residue_row;
begin
select qr, 1 bulk collect into l_array from (select level - 1 qr from dual connect by level <= p_integer
            minus select mod (power (level - 1, p_power), p_integer) from dual connect by level <= p_integer);
  
for p in (select pfo.prime from table (maths.get_pfo_rows (p_integer)) pfo where pfo.prime between 3 and p_integer - 1)
loop 
  for c2 in (select level - 1 qr from dual connect by level <= p.prime
            minus select mod (power (level - 1, p_power), p.prime) from dual connect by level <= p.prime)
   loop null;
     for a in 1 .. l_array.count
     loop
       if mod (l_array (a).ind, p.prime)  = c2.qr then l_array (a).available := 0; end if;
     end loop;
   end loop;
end loop;

for a in 1 .. l_array.count
loop
  if l_array (a).available  in (1) then pipe row (integer_row (l_array (a).ind)); end if;
end loop;
end;
/

select nr from table(f_not_qr (13));

begin
for j in 1 .. 37
loop
  dbms_output.put ('elsif fmodi (l_b2, ' || to_char (j, '90') || ' in (');
  for c in (select nr from table(f_not_qr (j)))
  loop
    dbms_output.put (to_char (c.nr) || ', ');
  end loop;
  dbms_output.put_line (')           then return false;');
end loop;
end;
/

declare 
l_int_id integer := 269;
begin
  update fast_int_cert_join set sqrt_id = null, init_val=null where fast_int_id = l_int_id;
  delete fast_int_tbl where id in (select confirmed from rsa_factoring where fast_int_id = l_int_id and confirmed != -1);
  delete rsa_factoring where fast_int_id = l_int_id;
  commit;
end;
/



SELECT id, type, creation_timestamp, block_count,
       column_count, pin_count, row_count
  FROM V$RESULT_CACHE_OBJECTS;

*/

sho error
