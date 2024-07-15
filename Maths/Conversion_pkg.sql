/*

Author  : Theo Stienissen
Date    : November 2021
Changed : July     2024 (added support for Garmin watch)
Purpose : Conversion e.g.: between radians / degrees
Contact : theo.stienissen@gmail.com


set serveroutput on size unlimited
select conversion_pkg.convert_radians_degrees (180,'dm','r') from dual;

dd = d + m/60 + s/3600

The minutes (m) are equal to the integer part of the decimal degrees (dd) minus integer degrees (d) times 60: m = integer((dd - d) × 60)
The seconds (s) are equal to the decimal degrees (dd) minus integer degrees (d) minus minutes (m) divided by 60 times 3600: s = (dd - d - m/60) × 3600

Example:
Convert 30.263888889° angle to degrees,minutes,seconds:
	d = trunc (30.263888889°) = 30°
	m = trunc ((dd - d) × 60) = 15 min.
	s = trunc ((dd - d - m/60) × 3600) = 50 sec.
--
	r = trunc ((dd - d - m/60 - s/3600)

*/

create or replace package conversion_pkg
is 

g_max_int        constant integer     := power (2, 31);

function dec_to_dms (in_dd in number) return number;

function dms_to_dec (in_dm in number) return number;

function get_digits (in_input in number, in_position in integer, in_offset in integer) return integer;

function convert_radians_degrees (in_input in number, in_format in varchar2, out_format in varchar2 default 'R') return number;

function day_to_sec_to_varchar2 (in_deg_sec in interval day to second) return varchar2;

function to_nr (in_string in varchar2) return number;

function tempo_to_nr (in_string in varchar2) return number;

function to_ds (in_string in varchar2) return interval day to second;

function to_dt (in_string in varchar2) return date;

function interval_ds_to_seconds (in_interval in interval day to second) return integer;

function seconds_to_ds_interval (in_seconds in integer) return interval day to second;

function date_offset_to_date (in_offset in integer) return date;

function semicircles_to_lon_lat (in_semicircle in integer) return number;

end conversion_pkg;
/

create or replace package body conversion_pkg
is 

--
-- Decimal to degrees / minutes / seconds. One degree is equal to 60 minutes and equal to 3600 seconds
--
function dec_to_dms (in_dd in number) return number
is
begin
  return floor (in_dd) + floor (mod (abs (in_dd), 1) * 60) / 100 + mod (mod (abs (in_dd), 1) * 60, 1) * 60 / 10000; 
  
exception when others 
then 
  util.show_error ('Error in function dec_to_dms for: ' || to_char (in_dd), sqlerrm);
  return null;
end dec_to_dms;

/************************************************************************************************************************************/

--
-- Degrees / minutes / seconds to decimal
--
function dms_to_dec (in_dm in number) return number
is
begin
  return trunc (in_dm) + get_digits (in_dm, 1, 2) / 60 + get_digits (in_dm, 3, 2) / 3600;
  
exception when others 
then 
  util.show_error ('Error in function dms_to_dec for: ' || to_char (in_dm), sqlerrm);
  return null;
end dms_to_dec;

/************************************************************************************************************************************/

--
-- get in_position-th digit after the comma and the in_offset digits after that
--
function get_digits (in_input in number, in_position in integer, in_offset in integer) return integer
is 
begin 
  return mod (trunc (power (10, in_position + in_offset - 1) * abs (in_input)), power (10, in_offset));

exception when others 
then 
  util.show_error ('Error in function get_digit. Input: ' || to_char (in_input) || '. Position: ' || to_char (in_position) ||  '. Offset: ' || to_char (in_offset), sqlerrm);
  return null;
end get_digits;

/************************************************************************************************************************************/

-- Formats:
--  DD  : Degrees decimal
--  DM  : Degrees, minutes, seconds
--  R   : radians
function convert_radians_degrees (in_input in number, in_format in varchar2, out_format in varchar2 default 'R') return number
is
l_radians   number := in_input;
l_return    number;
begin
  if    upper (in_format)  not in ('DD', 'DM', 'R')
  then  raise_application_error (-20001, 'Invalid input format: ' || in_format);
  elsif upper (out_format) not in ('DD', 'DM', 'R')
  then  raise_application_error (-20002, 'Invalid output format: ' || out_format);
  end if;

  if upper(in_format) = upper (out_format) then return in_input; end if;

  -- Conversion of all formats to radians
  if    upper(in_format) = 'DD'
  then  l_radians := constants_pkg.g_pi * in_input / 180;
  elsif upper(in_format) = 'DM' -- One degree is equal to 60 minutes and equal to 3600 seconds
  then  l_radians := constants_pkg.g_pi * dms_to_dec (in_input) / 180;
  end if;

  -- Normalize: 0 < l_radians <= 2 * π
  l_radians := l_radians - floor (l_radians / (2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi;

  -- Convert to output format
  if    upper (out_format) = 'DD'
  then  l_return := round (180 * l_radians / constants_pkg.g_pi, 4);
  elsif upper (out_format) = 'DM'
  then  l_return := round (dec_to_dms (180 * l_radians / constants_pkg.g_pi), 4);
  else  l_return := l_radians;
  end if;
  return l_return;
  
exception when others 
then 
  util.show_error ('Error in function convert_radians_degrees for: ' || to_char (in_input) || '. In format: ' || to_char (in_format)
      || '. Out format: ' || to_char (out_format), sqlerrm);
  return null;
end convert_radians_degrees;

/******************************************************************************************************************************************************************/

--
-- Convert "interval day to second" to a standard format string
--
function day_to_sec_to_varchar2 (in_deg_sec in interval day to second) return varchar2
is 
begin 
  return substr (in_deg_sec, 12,8);

exception when others then
  util.show_error ('Error in function day_to_sec_to_varchar2 for ' || in_deg_sec, sqlerrm);
  return null;
end day_to_sec_to_varchar2;

/******************************************************************************************************************************************************************/

--
-- Convert the Dutch number format to the English format. So comma to dot
--
function to_nr (in_string in varchar2) return number
is
begin
  if
   in_string is null or in_string = '--' then return null; 
  end if;
  return to_number (replace (in_string, ',', '.'));

exception when others then
  util.show_error ('Error in function to_nr. Not a number: ' || in_string , sqlerrm);
  return null;
end to_nr;

/******************************************************************************************************************************************************************/

--
-- Convert tempo to seconds. Tempo must contain a colon. Format: '99:99'
--
function tempo_to_nr (in_string in varchar2) return number
is
begin
  return round (3600 / (60 * substr (in_string, 1, instr (in_string, ':') - 1) + substr (in_string, instr (in_string, ':') + 1)), 2);

exception when zero_divide then return null;
when others then
  util.show_error ('Error in function tempo_to_nr. Not a tempo: ' || in_string , sqlerrm);
  return null;
end tempo_to_nr;

/******************************************************************************************************************************************************************/

--
-- To interval day to second for different formats
--
function to_ds (in_string in varchar2) return interval day to second
is
l_ds interval day to second;
begin
  if    in_string is null or in_string = '--' then l_ds := null;
  elsif instr (in_string, ':') = 0            then l_ds := to_dsinterval ( '00 00:00:' || replace (in_string, ',', '.'));
  elsif instr (in_string, ':', 1, 2) = 0      then l_ds := to_dsinterval ( '00 00:'    || replace (in_string, ',', '.'));
  else  l_ds := to_dsinterval ( '00 ' || replace (in_string, ',', '.'));
  end if;
  return l_ds;
  
exception when others then
  util.show_error ('Not an interval: ' || in_string, sqlerrm);
  return null;
end to_ds;

/******************************************************************************************************************************************************************/

-- to_date (substr (sleependtimestampgmt, 1, 10) || substr (sleependtimestampgmt, 12, 8), 'YYYY-MM-DDHH24:MI:SS'),
--
-- Convert string from 4 different date formats: 'YYYY-MM-DD HH24:MI:SS', 'MM/DD/YYYY HH24:MI:SS', 'YYYY-MM-DD HH24:MI' or 'MM/DD/YYYY HH24:MI'
--
function to_dt (in_string in varchar2) return date
is
l_date  date;
begin

  if   instr (in_string, ':', 1, 2) > 0
  then
    if substr (in_string, 11, 1) = 'T'
    then l_date := to_date (substr (in_string, 1, 10) || substr (in_string, 12, 8), 'YYYY-MM-DDHH24:MI:SS');
    elsif instr (in_string, '-') > 0
    then l_date := to_date (in_string, 'YYYY-MM-DD HH24:MI:SS');
	else l_date := to_date (in_string, 'MM/DD/YYYY HH24:MI:SS');
	end if;
  else
    if instr (in_string, '-') > 0
    then l_date := to_date (in_string, 'YYYY-MM-DD HH24:MI');
    else l_date := to_date (in_string, 'MM/DD/YYYY HH24:MI');
    end if;
  end if;
  return l_date;

exception when others then
  util.show_error ('Error in function to_dt for: ' || in_string, sqlerrm);
  return null;
end to_dt;

/******************************************************************************************************************************************************************/

--
-- Convert interval Day to second to seconds
--
function interval_ds_to_seconds (in_interval in interval day to second) return integer
is 
begin
  return extract (day from (in_interval) * 86400);
--  return 86400 * extract (day from in_interval) + 3600 * extract (hour from in_interval) + 60 * extract (minute from in_interval) + extract (second from in_interval);

exception when others then 
   util.show_error ('Error in function interval_ds_to_seconds for interval: ' || in_interval, sqlerrm);
   return null;
end interval_ds_to_seconds;

/******************************************************************************************************************************************************************/

--
-- Convert seconds to interval day to second
--
function seconds_to_ds_interval (in_seconds in integer) return interval day to second
is
begin
  return numtodsinterval (in_seconds, 'second');

exception when others then 
   util.show_error ('Error in function seconds_to_ds_interval for: ' || in_seconds, sqlerrm);
   return null;
end seconds_to_ds_interval;

/******************************************************************************************************************************************************************/

--
-- Number of seconds that have past since the 31-st of Dec 1989. Correction for dst is still required?
--
function date_offset_to_date (in_offset in integer) return date
is
begin
  return to_date ('31-12-1989', 'DD-MM-YYYY') + in_offset / 86400;

exception when others then 
   util.show_error ('Error in function date_offset_to_date for: ' || in_offset, sqlerrm);
   return null;
end date_offset_to_date;

/******************************************************************************************************************************************************************/

--
-- Convert semicircles to degrees longitude or lattitude
--
function semicircles_to_lon_lat (in_semicircle in integer) return number
is
begin 
  return in_semicircle * (180 / g_max_int);

exception when others then 
   util.show_error ('Error in function semicircles_to_lon_lat for: ' || in_semicircle, sqlerrm);
   return null;
end semicircles_to_lon_lat;

end conversion_pkg;
/

/*
Debug:
set serveroutput on size 1000000
declare 
l_test1 number;
l_test2 number;
l_test3 number;
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