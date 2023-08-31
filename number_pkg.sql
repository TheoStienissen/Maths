
create table number_tbl
( id       number(10)  not null
, sign     number(1)   not null);

alter table number_tbl add constraint number_tbl_pk primary key (id) using index;

create or replace package number_pkg
is

positive  constant signtype :=  1;
negative  constant signtype := -1;
zero      constant signtype :=  0;
type number_ty is record(sign signtype not null default positive, digits fast_int.p_int_ty);

function string_to_int (p_string in varchar2) return number_ty;

function int_to_string (p_number in number_ty) return varchar2;

procedure print  (p_number in number_ty);

function save_number (p_number in number_ty) return integer;

function load_number(p_id in integer) return number_ty;

function gt (p_number1 in number_ty, p_number2 in number_ty) return boolean;

function eq (p_number1 in number_ty, p_number2 in number_ty) return boolean;

function add (p_number1 in number_ty, p_number2 in number_ty) return number_ty;

function subtract (p_number1 in number_ty, p_number2 in number_ty) return number_ty;

function multiply (p_number1 in number_ty, p_number2 in number_ty) return number_ty;

function divide (p_number1 in number_ty, p_number2 in number_ty, p_remainder out number_ty) return number_ty;

end  number_pkg;
/

create or replace package body number_pkg
is

--
-- Convert string to integer. Indexing from right to left
--
function string_to_int (p_string in varchar2) return number_ty
is
l_return number_ty;
begin
if p_string like '+%'
then
  l_return.sign   := positive;
  l_return.digits := fast_int.string_to_int(substr(p_string, 2));
  return l_return;

elsif p_string like '-%'
then
  l_return.sign   := negative;
  l_return.digits := fast_int.string_to_int(substr(p_string, 2));
  return l_return;
else
  l_return.sign   := positive;
  l_return.digits := fast_int.string_to_int(p_string);
  return l_return;
end if;

exception
when others then
  util.show_error('Error in function string_to_int.' , sqlerrm);
end string_to_int;

/*************************************************************************************************************************************************/

--
-- Convert integer to a string
--
function int_to_string (p_number in number_ty) return varchar2
is
begin
  return p_number.sign || fast_int.int_to_string(p_number.digits);

exception
when others then
  util.show_error('Error in function int_to_string.' , sqlerrm);
end int_to_string;

/*************************************************************************************************************************************************/

--
-- Prints an integer
--
procedure print  (p_number in number_ty)
is
begin
dbms_output.put(case p_number.sign when positive then 'POS +' when negative then 'MIN -' else null end);
fast_int.print(p_number.digits);

exception
when others then
  util.show_error('Error in procedure print.' , sqlerrm);
end print;

/*************************************************************************************************************************************************/

--
-- Saves value of an integer in a table
--
function save_number (p_number in number_ty) return integer
is
l_dummy  integer(10);
begin
  insert into number_tbl (id, sign) values (fast_int_seq.nextval, p_number.sign);
  l_dummy := fast_int.save_number(p_number.digits, fast_int_seq.currval);

  return l_dummy;

exception
when others then
  util.show_error('Error in procedure save_number.' , sqlerrm);
end save_number;

/*************************************************************************************************************************************************/

--
-- Loads value from an integer from a table
--
function load_number(p_id in integer) return number_ty
is
l_return number_ty;
begin
select sign into l_return.sign from number_tbl where id = p_id;
l_return.digits := fast_int.load_number(p_id);

  return l_return;

exception
when others then
  util.show_error('Error in function load_number.' , sqlerrm);
end load_number;

/*************************************************************************************************************************************************/

--
-- greater than
--
function gt (p_number1 in number_ty, p_number2 in number_ty) return boolean
is
begin
 if    p_number1.sign = positive and p_number2.sign = negative then return true;
 elsif p_number1.sign = negative and p_number2.sign = positive then return false;
 elsif p_number1.sign = positive and p_number2.sign = positive then return fast_int.gt (p_number1.digits, p_number2.digits);
 elsif p_number1.sign = negative and p_number2.sign = negative then return fast_int.gt (p_number2.digits, p_number1.digits);
 else  raise_application_error(-20001, 'Sign not correct!');
 end if;

exception
when others then
  util.show_error('Error in function gt.' , sqlerrm);
end gt;

/*************************************************************************************************************************************************/

--
-- Equal
--
function eq (p_number1 in number_ty, p_number2 in number_ty) return boolean
is
begin
 if    p_number1.sign != p_number2.sign then return fast_int.is_zero(p_number1.digits) and fast_int.is_zero(p_number2.digits);
 else return fast_int.eq(p_number1.digits, p_number2.digits);
 end if;

exception
when others then
  util.show_error('Error in function eq.' , sqlerrm);
end eq;

/*************************************************************************************************************************************************/

--
-- Add 2 integers
--
function add (p_number1 in number_ty, p_number2 in number_ty) return number_ty
is
l_return number_ty;
begin
if    p_number1.sign = zero and fast_int.is_zero(p_number1.digits) then return p_number2;
elsif p_number2.sign = zero and fast_int.is_zero(p_number2.digits) then return p_number1;
elsif p_number1.sign = p_number2.sign
then
  l_return.sign := p_number1.sign;
  l_return.digits := fast_int.add(p_number1.digits, p_number2.digits);
  return l_return;
elsif p_number1.sign = positive and p_number2.sign = negative
then
  if fast_int.gt (p_number1.digits, p_number2.digits)
  then
    l_return.sign   := positive;
    l_return.digits := fast_int.subtract(p_number1.digits, p_number2.digits);
  elsif fast_int.eq (p_number1.digits, p_number2.digits)
  then
    l_return.sign   := zero;
    l_return.digits := fast_int.string_to_int('0');
  else
    l_return.sign   := negative;
    l_return.digits := fast_int.subtract(p_number2.digits, p_number1.digits);
  end if;
  return l_return;
elsif p_number1.sign = negative and p_number2.sign = positive
then
  if fast_int.gt(p_number1.digits, p_number2.digits)
  then
    l_return.sign   := negative;
    l_return.digits := fast_int.subtract(p_number1.digits, p_number2.digits);
  elsif fast_int.eq (p_number1.digits, p_number2.digits)
  then
    l_return.sign   := zero;
    l_return.digits := fast_int.string_to_int('0');
  else
    l_return.sign   := positive;
    l_return.digits := fast_int.subtract(p_number2.digits, p_number1.digits);
  end if;
  return l_return;
else  raise_application_error(-20001, 'Invalid input!');
end if;

exception
when others then
  util.show_error('Error in function add.' , sqlerrm);
end add;

/*************************************************************************************************************************************************/

--
-- Subtract 2 integers. Result is p_number1 - p_number2
--
function subtract (p_number1 in number_ty, p_number2 in number_ty) return number_ty
is
l_return number_ty;
l_demi   number_ty := p_number2;
begin
if    p_number2.sign = positive
then    l_demi.sign := negative;
elsif p_number2.sign = zero
then    l_demi.sign := zero;
else    l_demi.sign := positive;
end if;
l_demi.digits       :=  p_number2.digits;

  return add(p_number1, l_demi);

exception when others then
 util.show_error('Error in function subtract.', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

--
-- Multiply 2 integers
--
function multiply (p_number1 in number_ty, p_number2 in number_ty) return number_ty
is
l_result    number_ty;
l_demi      number_ty;
l_mult      integer(38);
l_overflow  integer(38);
l_cnt       integer(10);
begin
if p_number1.sign = p_number2.sign
then
  l_result.sign := positive;
else
  l_result.sign := negative;
end if;
l_result.digits := fast_int.multiply(p_number1.digits, p_number2.digits);

  return l_result;

exception when others then
  util.show_error('Error in function multiply.', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- Divide 2 integers
--
function divide (p_number1 in number_ty, p_number2 in number_ty, p_remainder out number_ty) return number_ty
is
l_result    number_ty;
begin
if p_number1.sign = p_number2.sign
then
  l_result.sign  := positive;
else
  l_result.sign  := negative;
end if;
p_remainder.sign := positive;
l_result.digits  := fast_int.divide(p_number1.digits, p_number2.digits, p_remainder.digits);

  return l_result;

exception when others then
 util.show_error('Error in function divide.', sqlerrm);
end divide;

end  number_pkg;
/

