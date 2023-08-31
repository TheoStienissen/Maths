/*

Author  : Theo Stienissen
Date    : November 2021
Purpose : Conversion between radians / degrees
Contact : theo.stienissen@gmail.com


set serveroutput on size unlimited
select conversion_pkg.convert_radians_degrees(180,'dm','r') from dual;

dd = d + m/60 + s/3600

The minutes (m) are equal to the integer part of the decimal degrees (dd) minus integer degrees (d) times 60: m = integer((dd - d) × 60)
The seconds (s) are equal to the decimal degrees (dd) minus integer degrees (d) minus minutes (m) divided by 60 times 3600: s = (dd - d - m/60) × 3600

Example:
Convert 30.263888889° angle to degrees,minutes,seconds:
	d = trunc(30.263888889°) = 30°
	m = trunc((dd - d) × 60) = 15 min.
	s = trunc((dd - d - m/60) × 3600) = 50 sec.
--
	r = trunc((dd - d - m/60 - s/3600)

*/

create or replace package conversion_pkg
is 

function dd_to_dm (p_in_dd in number) return number;

function dm_to_dd (p_in_dm in number) return number;

function get_digits (p_input in number, p_position in integer, p_offset in integer) return integer;

function convert_radians_degrees (p_input in number, p_in_format in varchar2, p_out_format in varchar2 default 'R') return number;

end conversion_pkg;
/

create or replace package body conversion_pkg
is 

-- Decimal to minutes / seconds. One degree is equal to 60 minutes and equal to 3600 seconds
function dd_to_dm (p_in_dd in number) return number
is
l_degrees integer(10) := trunc (p_in_dd);
l_minutes integer(2);
l_seconds integer(2);
begin
  l_minutes := trunc ((p_in_dd - l_degrees) * 60);
  l_seconds := round ((p_in_dd - l_degrees - l_minutes / 60) * 3600);
  if l_seconds = 60 then l_seconds := 0; l_minutes := l_minutes + 1; end if;
  if l_minutes = 60 then l_minutes := 0; l_degrees := l_degrees + 1; end if;
  return l_degrees + l_minutes / 100 + l_seconds / 10000;  
  
exception when others 
then 
  util.show_error ('Error in function dd_to_dm for: ' || to_char (p_in_dd), sqlerrm);
  return null;
end dd_to_dm;

/************************************************************************************************************************************/
-- Minutes / seconds to decimal
function dm_to_dd (p_in_dm in number) return number
is
begin
  return trunc (p_in_dm) + get_digits (p_in_dm, 1, 2) / 60 + get_digits (p_in_dm, 3, 2) / 3600;
  
exception when others 
then 
  util.show_error ('Error in function dm_to_dd for: ' || to_char (p_in_dm), sqlerrm);
  return null;
end dm_to_dd;

/************************************************************************************************************************************/
-- get p_position-th digit after the comma and the p_offset digits after that
function get_digits (p_input in number, p_position in integer, p_offset in integer) return integer
is 
begin 
  return mod (trunc (power (10, p_position + p_offset - 1) * p_input), power (10, p_offset));

exception when others 
then 
  util.show_error ('Error in function get_digit. Input: ' || to_char (p_input) || '. Position: ' || to_char (p_position) ||  '. Offset: ' || to_char (p_offset), sqlerrm);
  return null;
end get_digits;

/************************************************************************************************************************************/
-- Formats:
--  DD  : Degrees decimal
--  DM  : Degrees, minutes, seconds
--  R   : radians
function convert_radians_degrees (p_input in number, p_in_format in varchar2, p_out_format in varchar2 default 'R') return number
is
l_radians   number := p_input;
l_return    number;
begin
  if    upper(p_in_format)  not in ('DD', 'DM', 'R')
  then  raise_application_error (-20001, 'Invalid input format: ' || p_in_format);
  elsif upper(p_out_format) not in ('DD', 'DM', 'R')
  then  raise_application_error (-20002, 'Invalid output format: ' || p_out_format);
  end if;

  if upper(p_in_format) = upper (p_out_format) then return p_input; end if;

  -- Conversion of all formats to radians
  if    upper(p_in_format) = 'DD'
  then  l_radians := constants_pkg.g_pi * p_input / 180;
  elsif upper(p_in_format) = 'DM' -- One degree is equal to 60 minutes and equal to 3600 seconds
  then  l_radians := constants_pkg.g_pi * dm_to_dd (p_input) / 180;
  end if;

  -- Normalize: 0 < l_radians <= 2 * π
  l_radians := l_radians - floor (l_radians / (2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi;

  -- Convert to output format
  if    upper (p_out_format) = 'DD'
  then  l_return := round (180 * l_radians / constants_pkg.g_pi, 4);
  elsif upper (p_out_format) = 'DM'
  then  l_return := round (dd_to_dm (180 * l_radians / constants_pkg.g_pi), 4);
  else  l_return := l_radians;
  end if;
  return l_return;
  
exception when others 
then 
  util.show_error ('Error in function convert_radians_degrees for: ' || to_char (p_input) || '. In format: ' || to_char (p_input)
      || '. Out format: ' || to_char (p_out_format), sqlerrm);
  return null;
end convert_radians_degrees;

end conversion_pkg;
/

/*
Debug:
set serveroutput on size 1000000
declare 
l_test1 number;
l_test2 number;
l_test3 number;
constants_pkg.g_pi constant number := 3.14159265358979323846264338327950288419;
begin
for j in (select decode(trunc(dbms_random.value(1,4)), 1, 'DD', 2, 'DM', 'R') val1, decode(trunc(dbms_random.value(1,4)), 1, 'DD', 2, 'DM', 'R') val2 from dual connect by level <= 5000)
loop
  l_test1  := dbms_random.value(1,360);
  if j.val1 = 'R' then l_test1 := l_test1 - floor (l_test1 / (2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi; end if; 
  if j.val1 = 'DM'
  then
    l_test1 := trunc(l_test1, 4);
	l_test2 := conversion_pkg.get_digits (l_test1, 1, 2);
	if l_test2 >= 60 then l_test2 := dbms_random.value(1,59); end if;
	l_test3 := conversion_pkg.get_digits (l_test1, 3, 2);
    if l_test3 >= 60 then l_test3 := dbms_random.value(1,59); end if;
	l_test1 := trunc(l_test1) + l_test2 / 100 + l_test3 / 10000;
  end if;    
  l_test2 := conversion_pkg.convert_radians_degrees(l_test1, j.val1, j.val2); -- Convert
  l_test3 := conversion_pkg.convert_radians_degrees(l_test2, j.val2, j.val1); -- Convert back
-- 
  if abs(greatest(l_test1, l_test3) / least (l_test1, l_test3) - 1) > 0.001
  then 
    dbms_output.put_line(rpad(j.val1, 5)  || ' ;  '|| rpad(j.val2, 5) || to_char (l_test1) || '    ' || to_char (l_test2) || '    ' || to_char (l_test3));
  end if;
end loop;
end;
/
*/