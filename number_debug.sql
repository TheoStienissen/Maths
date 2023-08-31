set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  number_pkg.number_ty := number_pkg.string_to_int (l_string);
l_nr2  number_pkg.number_ty := number_pkg.string_to_int('-996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  number_pkg.number_ty;
l_id    integer;
begin
number_pkg.print(l_nr1);
dbms_output.put_line('--');
number_pkg.print(l_nr2);
if number_pkg.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;
if number_pkg.eq(l_nr1, l_nr2)
then
  dbms_output.put_line('Equal');
else
  dbms_output.put_line('NOT Equal');
end if;

  dbms_output.put_line('Add:');
  number_pkg.print(number_pkg.add(l_nr1, l_nr2));
  dbms_output.put_line('Mult:');
  number_pkg.print(number_pkg.multiply(l_nr1, l_nr2));
  l_id := number_pkg.save_number(l_nr1);
  l_nr1 := number_pkg.load_number(l_id);
  number_pkg.print(l_nr1);
end;
/


  dbms_output.put_line('Substr:');
  number_pkg.print(number_pkg.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:');
  number_pkg.print(number_pkg.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  number_pkg.print(l_rest);
end;
/

declare
s1  varchar2(1000) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435';
s2  varchar2(1000) := '8971053113110642009862056521054640739909710531131106420098620565210546407399097105311311064200986205652105464073982';
l_nr1  number_pkg.number_ty := number_pkg.string_to_int('89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435');
l_nr2  number_pkg.number_ty := number_pkg.string_to_int('8971053113110642009862056521054640739909710531131106420098620565210546407399097105311311064200986205652105464073982');
begin
if number_pkg.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;
 dbms_output.put_line(length(s1));
 dbms_output.put_line(length(s2));

end;
/


declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  number_pkg.p_int_ty := number_pkg.string_to_int(l_string);
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_id  integer;
begin
number_pkg.print(l_nr2);
dbms_output.put_line(number_pkg.int_to_string(l_nr1));
dbms_output.put_line('--');
number_pkg.print(l_nr1);
for x in 1 .. number_pkg.get_length(l_nr1)
loop
  dbms_output.put_line(to_char(x) || '   '|| number_pkg.get_digit(x, l_nr1));
end loop;
end;
/

set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  number_pkg.p_int_ty := number_pkg.string_to_int(l_string);
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  number_pkg.p_int_ty;
l_id  integer;
begin
number_pkg.print(l_nr1);
dbms_output.put_line('--');
dbms_output.put_line(number_pkg.int_to_string(l_nr1));
dbms_output.put_line('--');
number_pkg.print(l_nr2);
dbms_output.put_line('--');
  dbms_output.put_line('Mult:');
  number_pkg.print(number_pkg.multiply(l_nr1, l_nr2));
  dbms_output.put_line('Substr:');
  number_pkg.print(number_pkg.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:');
  number_pkg.print(number_pkg.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  number_pkg.print(l_rest);
  dbms_output.put_line('Gcd:    ');
  number_pkg.print(number_pkg.gcd(l_nr1, l_nr2));
end;
/

set time on timing on
set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  number_pkg.p_int_ty := number_pkg.string_to_int(l_string);
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  number_pkg.p_int_ty;
l_id  integer;
begin
  dbms_output.put_line('Div:');
  number_pkg.print(number_pkg.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  number_pkg.print(l_rest);
end;
/

declare
l_nr1  number_pkg.p_int_ty :=  number_pkg.nfac(100);
begin
number_pkg.print(l_nr1);
dbms_output.put_line('--');
--number_pkg.print(number_pkg.nice(l_nr1));
end;
/

declare
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('996783679234515778873');
x integer;
begin
for j in 1 .. 20
loop
  number_pkg.print(l_nr2);
  l_nr2 := number_pkg.mult_n(10, l_nr2);
end loop;
end;
/


declare
l_rest   varchar2(32767);
begin
  dbms_output.put_line( number_pkg.divide('5625','75', l_rest));
  dbms_output.put_line( l_rest);
end;
/

select number_pkg.nfac(100) from dual;
select number_pkg.mod(100, 19) from dual;
select number_pkg.lcm(10011, 192) lcm, number_pkg.gcd(10011, 192) gcd from dual;

select number_pkg.prime_test('256247274891563554478498177', 1) from dual;


create table Faculties
( n    number(6)
, fact  varchar2(32767));



declare
l_string1 varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_string2 varchar2(32767) := '996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998';
l_nr1  number_pkg.p_int_ty;
l_nr2  number_pkg.p_int_ty;
l_rest number_pkg.p_int_ty;
l_id  integer;
begin
l_nr1 := number_pkg.string_to_int(l_string1);
l_nr2 := number_pkg.string_to_int(l_string2);
dbms_output.put_line(number_pkg.get_length (l_nr1)  || ' #  ' ||length(l_string1));
dbms_output.put_line(number_pkg.get_length (l_nr2)  || ' #  ' ||length(l_string2));
dbms_output.put_line('GCD:');
number_pkg.print(number_pkg.gcd(l_nr1, l_nr2));
dbms_output.put_line('LCM:');
number_pkg.print(number_pkg.lcm(l_nr1, l_nr2));
end;
/

declare
l_string varchar2(32767) := '899376543912';
l_nr1  number_pkg.p_int_ty := number_pkg.string_to_int(l_string);
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('9987226786');
l_rest  number_pkg.p_int_ty;
l_id  integer;
begin
number_pkg.print(number_pkg.gcd(l_nr1, l_nr2));
end;
/

declare
l_string varchar2(32767) := '899376543912';
l_nr1  number_pkg.p_int_ty := number_pkg.string_to_int(l_string);
l_nr2  number_pkg.p_int_ty := number_pkg.string_to_int('9987226786');
l_rest  number_pkg.p_int_ty;
l_id  integer;
begin
number_pkg.print(number_pkg.power_mod(541,25624573673120173487653466262,174512365));
end;
/


set serveroutput on size unlimited
declare
l_nr1 number_pkg.p_int_ty:= number_pkg.string_to_int( '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498');
l_nr2 number_pkg.p_int_ty:= number_pkg.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  number_pkg.p_int_ty;
begin
if number_pkg.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;

if number_pkg.eq(l_nr1, l_nr2)
then
  dbms_output.put_line('Equal');
else
  dbms_output.put_line('NOT Equal');
end if;
  dbms_output.put_line('Add:    ');
  number_pkg.print(number_pkg.add(l_nr1, l_nr2));
  dbms_output.put_line('Mult:   ');
  number_pkg.print(number_pkg.multiply(l_nr1, l_nr1));
  dbms_output.put_line('Substr: ');
  number_pkg.print(number_pkg.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:    ');
  number_pkg.print(number_pkg.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:   ');
  number_pkg.print(l_rest);
  dbms_output.put_line('Mod:    ');
  number_pkg.print(number_pkg.mod(l_nr1, l_nr2));
  dbms_output.put_line('Gcd:    ');
  number_pkg.print(number_pkg.gcd(l_nr1, l_nr2));
  dbms_output.put_line('Lcm:    ');
  number_pkg.print(number_pkg.lcm(l_nr1, l_nr2));
--  dbms_output.put_line('Powermod:    '||number_pkg.power_mod(l_nr1, '2562467', l_nr2));
end;
/

declare
begin
number_pkg.print(number_pkg.power(541,255619));
end;
/

