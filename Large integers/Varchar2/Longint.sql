DOC

-- Author Theo Stienissen
-- Created February 2017
-- Last changed June 2022
-- Integers based on varchar2 datatype
-- ToDo Support for negative numbers.
-- Square roots based on Cantor method

#

type lnumber is object
( sign   signtype
, digits varchar2(32767)
, comma  number(10))

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

function divide (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function nfac (p_number in integer) return varchar2;

function gcd (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function lcm (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2;

function power_mod (p_base in varchar2, p_power in varchar2, p_mod in varchar2) return varchar2 result_cache;

function prime_test (p_candidate in varchar2, p_trials in integer default 64) return number;

end  long_int;
/

create or replace package body long_int
is

-- Remove +- at the beginning and trailing blanks
function to_int  (p_number in varchar2) return varchar2
is
l_number         varchar2 (32767) := trim (p_number);
invalid_number   exception;
pragma exception_init (invalid_number, -20001);
begin
if l_number is null then return null; end if;
if substr (l_number, 1, 1) = '+' or substr (l_number, 1, 1) = '-'
then
  positive := substr (l_number, 1, 1) = '+';
  l_number := substr (l_number, 2);
else
  positive := true;
end if;
if translate (l_number, '0123456789','') is not null
then
  raise invalid_number;
end if;

  return nvl (ltrim (l_number, '0'), '0');

exception
when invalid_number then
  util.show_error ('Invalid number in function to_int.' || p_number, sqlerrm);
when others then
  util.show_error ('Error in function to_int.' , sqlerrm);
end to_int;

/*************************************************************************************************************************************************/

-- Greater than
function gt (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
l_number1 varchar2 (32767) := to_int (p_number1);
l_number2 varchar2 (32767) := to_int (p_number2);
begin

if length (l_number1) = length (l_number2)
then
  return l_number1 > l_number2;
else
  return length (l_number1) > length (l_number2);
end if;

exception when others then
  util.show_error ('Error in function GT.' , sqlerrm);
end gt;

/*************************************************************************************************************************************************/

-- Equal
function eq (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return to_int (p_number1) = to_int (p_number2);

exception when others then
  util.show_error ('Error in function EQ. NR1: ' || p_number1 || ' NR2: ' || p_number2, sqlerrm);
end eq;

/*************************************************************************************************************************************************/

-- Greater or equal
function ge (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return gt (p_number1, p_number2) or eq (p_number1, p_number2);

exception when others then
  util.show_error ('Error in function GE. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end ge;

/*************************************************************************************************************************************************/

-- Less than
function lt (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return gt (p_number2, p_number1);

exception when others then
  util.show_error ('Error in function LT. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end lt;

/*************************************************************************************************************************************************/

-- Less or equal
function le (p_number1 in varchar2, p_number2 in varchar2) return boolean
is
begin

  return  gt (p_number2, p_number1) or eq (p_number1, p_number2);

exception when others then
  util.show_error ('Error in function LE. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
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

for j in 1 .. greatest (length (l_number1), length (l_number2))
loop
  l_temp :=  nvl (substr (l_number1, -j, 1), 0) + nvl (substr (l_number2, -j, 1), 0) + l_overflow;
  if l_temp >= 10
  then
    l_result   := to_char (l_temp - 10) || l_result;
    l_overflow := 1;
  else
    l_result := to_char (l_temp) || l_result;
    l_overflow := 0;
  end if;
end loop;

if l_overflow = 1 then l_result := '1' || l_result; end if;

return to_int (l_result);

exception when others then
  util.show_error ('Error in function add. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end add;

/*************************************************************************************************************************************************/

function multiply_1_digit (p_number in varchar2, p_digit in varchar2) return varchar2 result_cache
is
l_result     varchar2 (32767) := '';
l_temp       number (2);
l_overflow   number (1) := 0;
begin
if    p_digit = '0' then return '0';
elsif p_digit = '1' then return p_number;
else
  for j in 1 .. length(p_number)
  loop
    l_temp     := substr (p_number, -j, 1) * to_number (p_digit) + l_overflow; 
    l_result   := substr (l_temp, -1) || l_result;
    l_overflow := trunc (l_temp / 10);
  end loop;

  if l_overflow != 0
  then 
    l_result := l_overflow || l_result;
  end if;

  return l_result;
end if;

exception when others then
  util.show_error ('Error in function multiply_1_digit. Digit: ' || p_digit || ' Nr: ' || p_number, sqlerrm);
end multiply_1_digit;

/*************************************************************************************************************************************************/

-- Choose p_number2 so that is has less digits then p_number1
function multiply (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_overflow   number (1) := 0;
l_temp       number (2);
l_number1    varchar2 (32767) := to_int (p_number1);
l_number2    varchar2 (32767) := to_int (p_number2);
l_result     varchar2 (32767) := '';
begin
for j in 1 .. length (l_number2)
loop
  l_result := add (l_result || '0', multiply_1_digit (l_number1, substr(l_number2, j, 1)));
end loop;

  return to_int (l_result);

exception when others then
  util.show_error ('Error in function multiply. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

-- p_number1 - p_number2
function subtract (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_borrow     number (1) := 0;
l_number1    varchar2 (32767) := to_int(p_number1);
l_number2    varchar2 (32767) := to_int(p_number2);
l_result     varchar2 (32767) := '';
l_tmp        number (2);
begin
if  gt (l_number2, l_number1)
then
  return '*';
else
  for j in 1 .. length (l_number1)
  loop
    l_tmp := substr (l_number1, -j, 1) - nvl (substr (l_number2, -j, 1), 0) - l_borrow;
    if l_tmp < 0
    then
      l_tmp := l_tmp + 10;
      l_borrow := 1;
    else
      l_borrow := 0;
    end if;
    l_result := to_char (l_tmp) || l_result;
  end loop;
end if;

  return to_int(l_result);

exception when others then
  util.show_error ('Error in function subtract. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

-- Divide 2 huge integers. Result is an integer. Remainder is also returned
function divide (p_number1 in varchar2, p_number2 in varchar2, p_remainder out varchar2) return varchar2
is
l_number1    varchar2 (32767) := to_int (p_number1);
l_number2    varchar2 (32767) := to_int (p_number2);
l_result     varchar2 (32767) := '0';
l_rest       varchar2 (32767);
l_help       varchar2 (32767);
l_tmp        number (1);
l_length2    number (6);
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
  l_length2 := length (l_number2);
  l_help := substr (p_number1, 1, l_length2);
  l_rest := substr (p_number1, l_length2 + 1);

  while l_rest is not null
  loop
    l_tmp := 0;
    while  gt (l_help, l_number2) or eq (l_help, l_number2)
    loop
      l_tmp  := l_tmp + 1;
      l_help := subtract (l_help, p_number2);
    end loop;
 --
    l_result := l_result || to_char (l_tmp);
    l_help   := l_help || substr (l_rest, 1, 1);
    l_rest := substr(l_rest, 2);
  end loop;

  l_tmp := 0;
  while gt (l_help, l_number2) or eq (l_help, l_number2)
  loop
    l_tmp  := l_tmp + 1;
    l_help := subtract (l_help, p_number2);
  end loop;

  p_remainder := to_int (l_help);
  l_result := l_result || to_char (l_tmp);

  return to_int (l_result);
 end if;

exception when others then
util.show_error ('Error in function divide 1. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function divide (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_rest       varchar2(32767);
begin

  return divide (p_number1, p_number2, l_rest);

exception when others then
util.show_error ('Error in function divide 2. NR1: ' || p_number1 || ' NR2: ' || p_number2, sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function nfac (p_number in integer) return varchar2
is
begin
if p_number <= 2 then return to_char(p_number);
else
  return  multiply (to_char (p_number),  nfac (p_number - 1));
end if;

exception when others then
util.show_error ('Error in function nfac. NR: ' || p_number, sqlerrm);
end nfac;

/*************************************************************************************************************************************************/

function gcd (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_number1    varchar2 (32767) := to_int (p_number1);
l_number2    varchar2 (32767) := to_int (p_number2);
begin
if eq (l_number1, '0')
then
  return p_number2;
else
  return gcd (long_int.mod (p_number2, p_number1), p_number1);
end if;

exception when others then
util.show_error ('Error in function gcd. NR1: ' || p_number1 || ' NR2: ' || p_number2, sqlerrm);
end gcd;

/*************************************************************************************************************************************************/

function lcm (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_number1    varchar2 (32767) := to_int (p_number1);
l_number2    varchar2 (32767) := to_int (p_number2);
l_multiple   varchar2 (32767);
l_rest       varchar2 (32767);
begin
l_multiple := multiply (l_number1, l_number2);
if eq (l_multiple, '0')
then
  return '0';
else
  return to_int (divide (l_multiple, gcd ( long_int.mod (p_number2, p_number1), p_number1), l_rest));
end if;

exception when others then
util.show_error ('Error in function lcm. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end lcm;

/*************************************************************************************************************************************************/

-- mod(p_number1, p_number2)
function mod  (p_number1 in varchar2, p_number2 in varchar2) return varchar2
is
l_rest   varchar2 (32767);
l_tmp    varchar2 (32767);
begin
l_tmp := divide(p_number1, p_number2, l_rest);

  return to_int(l_rest);

exception when others then
util.show_error ('Error in function mod. NR1: ' || p_number1 || ' NR2: ' || p_number2 , sqlerrm);
end mod;

/*************************************************************************************************************************************************/

function power_mod(p_base in varchar2, p_power in varchar2, p_mod in varchar2) return varchar2 result_cache
is
l_rest   varchar2 (32767);
l_halve  varchar2 (32767);
l_tmp    varchar2 (32767);
begin
if p_power = '1' then return long_int.mod (p_base, p_mod); end if;

l_halve := divide(p_power, '2', l_rest);
l_tmp   := long_int.mod (multiply (power_mod (p_base, l_halve, p_mod), power_mod (p_base, l_halve, p_mod)), p_mod);

if l_rest  = '0'
then
  return l_tmp;
else
  return long_int.mod (multiply (p_base, l_tmp), p_mod);
end if;

exception when others then
  util.show_error ('Error in function power_mod. Base: ' || p_base || '. Power: ' || p_power || '. Mod: ' || p_mod, sqlerrm);
end power_mod;

/*************************************************************************************************************************************************/

-- Rabin-Miller primality test
function prime_test (p_candidate in varchar2, p_trials in integer default 64) return number
is
l_remainder      varchar2 (32767) :=subtract (p_candidate, '1');
l_rest           varchar2 (32767) := '0';
l_witness        integer := 2;
l_power          integer := 0;
l_starttime number := dbms_utility.get_time;
function witness (p_candidate in varchar2, p_remainder in varchar2) return boolean
is
x      varchar2(32767);
n1     varchar2(32767);
b      boolean;
begin
dbms_output.put_line('P0: ' || to_char( dbms_utility.get_time - l_starttime));
x := long_int.power_mod (l_witness, p_remainder, p_candidate);
n1 := subtract(p_candidate, '1');
if eq(x, '1') or eq (x, n1) then return false; end if;
dbms_output.put_line ('P1: ' || to_char( dbms_utility.get_time - l_starttime));
<<ready>>
for r in 0 .. l_power - 1
loop
  x := long_int.mod (multiply (x, x), p_candidate);
  if  eq (x, '1')
  then b:= true; exit ready;
  elsif eq (x, n1)
  then b:= false; exit ready;
  end if;
end loop;
return nvl (b,true);

exception when others then
  util.show_error ('Error in function witness. Candidate: ' || p_candidate || '. Remainder: ' || p_remainder, sqlerrm);
end witness;
--
begin
if lt (p_candidate, '3') or eq (p_candidate, '5') or eq (p_candidate, '7') then return 1; end if;
while l_rest = '0'
loop
  l_remainder := divide (l_remainder, '2', l_rest);
  l_power     := l_power + 1;
end loop;
-- l_witness := 2;  round(dbms_random.value (2, 10));  random number. To be checked what the range can be.
for v in 0 .. p_trials
loop
  if witness (p_candidate, l_remainder) then return 0; end if;
end loop;
return 1;

exception when others then
  util.show_error ('Error in function prime_test. Candidate: ' || p_candidate || '. Trials: ' || p_trials, sqlerrm);
end prime_test;

end  long_int;
/

-- Demo
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
  dbms_output.put_line('Powermod:    ' || long_int.power_mod(l_nr1, '2562467', l_nr2));
end;
/

declare
l_rest   varchar2(32767);
begin
  dbms_output.put_line( long_int.divide('5625','75', l_rest));
  dbms_output.put_line( l_rest);
end;
/

select long_int.nfac(100) from dual;
select long_int.mod(100, 19) from dual;
select long_int.lcm(10011, 192) lcm, long_int.gcd(10011, 192) gcd from dual;

select long_int.prime_test('256247274891563554478498177', 1) from dual;


create table Faculties
( n    number(6)
, fact  varchar2(32767));


declare
l_fact   varchar2(32767);
begin
for j in 1 .. 400
loop
  insert into Faculties values (j * 100, long_int.nfac(j * 100));
  commit;
end loop;
end;
/

