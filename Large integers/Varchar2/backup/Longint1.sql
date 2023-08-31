create or replace package long_int
is

function gt (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function eq (p_number1 in varchar2, p_number2 in varchar2) return boolean;

function add (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

/*
function subtract (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function divide (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

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
  l_number := substr(l_number, 2);
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
  util.show_error('Error in function EQ.' , sqlerrm);
end eq;

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
  util.show_error('Error in function add.' , sqlerrm);
end add;

/*************************************************************************************************************************************************/

function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_overflow   number(1) := 0;
l_temp       number(2);
l_number1 varchar2(32767);
l_number2 varchar2(32767);
l_result  varchar2(32767) := '';
begin


exception when others then
  util.show_error('Error in function multiply.' , sqlerrm);
end multiply;

end  long_int;
/

set serveroutput on size unlimited
declare
l_nr1 varchar2(100) :=   '899917662357383782456247274889156378498';
l_nr2 varchar2(100) :=   '99678367923451577887356183567273785998';
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
  dbms_output.put_line( long_int.add(l_nr1, l_nr2));
end;
/


