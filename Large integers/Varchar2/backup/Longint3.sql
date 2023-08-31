DOC

-- Author Theo Stienissen
-- Created Feb. 2017
-- ToDo Support for negative numbers.

#

create or replace package long_int
is

positive boolean;

function gt (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function eq (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function ge (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function lt (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function le (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function add (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function subtract (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function divide (p_number1 in varchar2, p_number2 in varchar2, p_remainder out varchar2) return varchar2;

function nfac (p_number in integer) return varchar2;

function gcd (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function lcm (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

/*

function power_mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2;
*/

end  long_int;
/

create or replace package body long_int
is

function to_int  (p_number in varchar2) return varchar2
is
l_number varchar2(32767) := trim(p_number);
invalid_number   exception;
begin
if l_number is null then return null; end if;
if substr(l_number, 1, 1) = '+' or substr(l_number, 1, 1) = '-'
then
  positive :=  substr(l_number, 1, 1) = '+';
  l_number := substr(l_number, 2);
else
  positive := true;
end if;
if translate (l_number, '0123456789','') is not null
then
  raise invalid_number;
end if;

  return nvl(ltrim(l_number, '0'), '0');

exception
when invalid_number then
  util.show_error('Invalid number in function to_int.' || p_number, sqlerrm);
when others then
  util.show_error('Error in function to_int.' , sqlerrm);
end to_int;

/*************************************************************************************************************************************************/

function gt (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
l_number1 varchar2(32767) := to_int(p_number1);
l_number2 varchar2(32767) := to_int(p_number2);
begin

if length(l_number1) = length(l_number2)
then
  return l_number1 > l_number2;
else
  return length(l_number1) > length(l_number2);
end if;

exception when others then
  util.show_error('Error in function GT.' , sqlerrm);
end gt;

/*************************************************************************************************************************************************/

function eq (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return to_int (p_number1) = to_int (p_number2);

exception when others then
  util.show_error('Error in function EQ. NR1: ' || p_number1 || ' NR2: ' || p_number2, sqlerrm);
end eq;

/*************************************************************************************************************************************************/

function ge (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return gt (p_number1, p_number2) or eq (p_number1, p_number2);

exception when others then
  util.show_error('Error in function GE. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end ge;

/*************************************************************************************************************************************************/

function lt (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return gt (p_number2, p_number1);

exception when others then
  util.show_error('Error in function LT. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end lt;

/*************************************************************************************************************************************************/

function le (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return  gt (p_number2, p_number1) or eq (p_number1, p_number2);

exception when others then
  util.show_error('Error in function LE. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end le;

/*************************************************************************************************************************************************/

function add (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_overflow   number(1) := 0;
l_temp       number(2);
l_number1 varchar2(32767);
l_number2 varchar2(32767);
l_result  varchar2(32767) := '';
begin
l_number1 := to_int(p_number1);
l_number2 := to_int(p_number2);

for j in 1 .. greatest(length(l_number1), length(l_number2))
loop
  l_temp :=  nvl(substr(l_number1, -j, 1), 0) + nvl(substr(l_number2, -j, 1), 0) + l_overflow;
  if l_temp >= 10
  then
    l_result := to_char(l_temp - 10) || l_result;
    l_overflow := 1;
  else
    l_result := to_char(l_temp) || l_result;
    l_overflow := 0;
  end if;
end loop;

if l_overflow = 1 then l_result := '1' || l_result; end if;

return to_int(l_result);

exception when others then
  util.show_error('Error in function add. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end add;

/*************************************************************************************************************************************************/

function multiply_1_digit (p_number in varchar2, p_digit in varchar2) return varchar2
is
l_result varchar2(32767) := '';
l_temp       number(2);
l_overflow   number(1) := 0;
begin
for j in 1 .. length(p_number)
loop
  l_temp := substr(p_number, -j, 1) * to_number(p_digit) + l_overflow; 
  l_result := substr(l_temp, -1) || l_result;
  l_overflow := trunc(l_temp / 10);
end loop;

if l_overflow != 0
then 
  l_result := l_overflow || l_result;
end if;

  return l_result;

exception when others then
  util.show_error('Error in function multiply_1_digit. Digit: ' || p_digit || ' Nr: ' || p_number, sqlerrm);
end multiply_1_digit;

/*************************************************************************************************************************************************/

function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_overflow   number(1) := 0;
l_temp       number(2);
l_number1    varchar2(32767) := to_int(p_number1);
l_number2    varchar2(32767) := to_int(p_number2);
l_result     varchar2(32767) := '';
begin
for j in 1 .. length(l_number2)
loop
  l_result := add(l_result || '0', multiply_1_digit(l_number1, substr(l_number2, j, 1)));
end loop;

  return to_int(l_result);

exception when others then
  util.show_error('Error in function multiply. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

-- p_number1 - p_number2
function subtract (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_borrow     number(1) := 0;
l_number1    varchar2(32767) := to_int(p_number1);
l_number2    varchar2(32767) := to_int(p_number2);
l_result     varchar2(32767) := '';
l_tmp        number(2);
begin
if  gt(l_number2, l_number1)
then
  return '*';
else
  for j in 1 .. length(l_number1)
  loop
    l_tmp := substr(l_number1, -j, 1) - nvl(substr(l_number2, -j, 1), 0) - l_borrow;
    if l_tmp < 0
    then
      l_tmp := l_tmp + 10;
      l_borrow := 1;
    else
      l_borrow := 0;
    end if;
    l_result := to_char(l_tmp) || l_result;
  end loop;
end if;

  return to_int(l_result);

exception when others then
  util.show_error('Error in function subtract. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function divide (p_number1 in varchar2, p_number2 in varchar2, p_remainder out varchar2) return varchar2
is
l_number1    varchar2(32767) := to_int(p_number1);
l_number2    varchar2(32767) := to_int(p_number2);
l_result     varchar2(32767) := '0';
l_rest       varchar2(32767);
l_help       varchar2(32767);
l_tmp        number(1);
l_length2    number(6);
begin
if l_number2 = '0' then raise zero_divide;
elsif gt (l_number2, l_number1)
then
  p_remainder := l_number1;
  return '0';
elsif eq (l_number2, l_number1)
then
  p_remainder := '0';
  return '1';
else
  l_length2 := length(l_number2);
  l_help := substr(p_number1, 1, l_length2);
  l_rest := substr(p_number1, l_length2 + 1);

  while l_rest is not null
  loop
    l_tmp := 0;
    while  gt(l_help, l_number2) or eq(l_help, l_number2)
    loop
      l_tmp := l_tmp + 1;
      l_help := subtract(l_help, p_number2);
    end loop;
 --
    l_result := l_result || to_char(l_tmp);
    l_help   := l_help || substr(l_rest, 1, 1);
    l_rest := substr(l_rest, 2);
  end loop;

  l_tmp := 0;
  while gt(l_help, l_number2) or eq (l_help, l_number2)
  loop
    l_tmp := l_tmp + 1;
    l_help := subtract(l_help, p_number2);
  end loop;

  p_remainder := l_help;
  l_result := l_result || to_char(l_tmp);

  return to_int(l_result);
 end if;

exception when others then
util.show_error('Error in function divide. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function nfac (p_number in integer) return varchar2
is
begin
if p_number <= 2 then return to_char(p_number);
else
  return  multiply(to_char(p_number),  nfac (p_number - 1));
end if;

exception when others then
util.show_error('Error in function nfac. NR: ' || p_number, sqlerrm);
end nfac;

/*************************************************************************************************************************************************/

function gcd (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_number1    varchar2(32767) := to_int(p_number1);
l_number2    varchar2(32767) := to_int(p_number2);
begin
if eq(l_number1, '0')
then
  return p_number2;
else
  return gcd (long_int.mod(p_number2, p_number1), p_number1);
end if;

exception when others then
util.show_error('Error in function gcd. NR1: ' || p_number1 || ' NR2: ' || p_number2, sqlerrm);
end gcd;

/*************************************************************************************************************************************************/

function lcm (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_number1    varchar2(32767) := to_int(p_number1);
l_number2    varchar2(32767) := to_int(p_number2);
l_multiple   varchar2(32767);
l_rest       varchar2(32767);
begin
l_multiple := multiply(l_number1, l_number2);
if eq(l_multiple, '0')
then
  return '0';
else
  return to_int(divide(l_multiple, gcd ( long_int.mod(p_number2, p_number1), p_number1), l_rest));
end if;

exception when others then
util.show_error('Error in function lcm. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end lcm;

/*************************************************************************************************************************************************/

-- mod(p_number1, p_number2)
function mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_rest   varchar2(32767);
l_tmp    varchar2(32767);
begin
l_tmp := divide(p_number1, p_number2, l_rest);

  return to_int(l_rest);

exception when others then
util.show_error('Error in function mod. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end mod;

end  long_int;
/

set serveroutput on size unlimited
declare
l_nr1 varchar2(1000) :=   '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr2 varchar2(1000) :=   '996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998';
l_rest   varchar2(32767);
begin
if long_int.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;

if long_int.eq(l_nr1, l_nr2)
then
  dbms_output.put_line('Equal');
else
  dbms_output.put_line('NOT Equal');
end if;
  dbms_output.put_line('Add:    ' || long_int.add(l_nr1, l_nr2));
  dbms_output.put_line('Mult:   ' || long_int.multiply(l_nr1, l_nr1));
  dbms_output.put_line('Substr: ' || long_int.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:    ' || long_int.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:   ' || l_rest);
  dbms_output.put_line('Mod:    ' || long_int.mod(l_nr1, l_nr2));
  dbms_output.put_line('Gcd:    ' || long_int.gcd(l_nr1, l_nr2));
  dbms_output.put_line('Lcm:    ' || long_int.lcm(l_nr1, l_nr2));
end;
/

declare
l_rest   varchar2(32767);
begin
  dbms_output.put_line( long_int.divide('5625','75', l_rest));
  dbms_output.put_line( l_rest);
end;
/

create or replace package util
is
procedure show_error(p_text in varchar2, p_error in varchar2);
end util;
/

create or replace package body util
is
procedure show_error(p_text in varchar2, p_error in varchar2)
is
begin
dbms_output.put_line(p_text);
dbms_output.put_line(p_error);
end show_error;
end util;
/

select long_int.nfac(100) from dual;
select long_int.mod(100, 19) from dual;
select long_int.lcm(10011, 192) lcm, long_int.gcd(10011, 192) gcd from dual;
