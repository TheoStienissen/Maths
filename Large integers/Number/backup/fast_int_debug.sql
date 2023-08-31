set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  fast_int.p_int_ty := fast_int.string_to_int(l_string);
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  fast_int.p_int_ty;
l_id  integer;
begin
fast_int.print(l_nr1);
dbms_output.put_line('--');
dbms_output.put_line(fast_int.int_to_string(l_nr1));
dbms_output.put_line('--');
fast_int.print(l_nr2);
dbms_output.put_line('--');
if fast_int.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;
if fast_int.eq(l_nr1, l_nr2)
then
  dbms_output.put_line('Equal');
else
  dbms_output.put_line('NOT Equal');
end if;
  dbms_output.put_line('Add:');
  fast_int.print(fast_int.add(l_nr1, l_nr2));
  dbms_output.put_line('Mult:');
  fast_int.print(fast_int.multiply(l_nr1, l_nr2));
  dbms_output.put_line('Substr:');
  fast_int.print(fast_int.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:');
  fast_int.print(fast_int.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  fast_int.print(l_rest);
end;
/

declare
s1  varchar2(1000) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435';
s2  varchar2(1000) := '8971053113110642009862056521054640739909710531131106420098620565210546407399097105311311064200986205652105464073982';
l_nr1  fast_int.p_int_ty := fast_int.string_to_int('89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435');
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('8971053113110642009862056521054640739909710531131106420098620565210546407399097105311311064200986205652105464073982');
begin
if fast_int.gt(l_nr1, l_nr2)
then
  dbms_output.put_line('Greater');
else
  dbms_output.put_line('Smaller or equal');
end if;
 dbms_output.put_line(length(s1));
 dbms_output.put_line(length(s2));
if fast_int.eq(l_nr1, l_nr1)
then
  dbms_output.put_line('Equal');
end if;
end;
/


declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  fast_int.p_int_ty := fast_int.string_to_int(l_string);
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_id  integer;
begin
fast_int.print(l_nr2);
dbms_output.put_line(fast_int.int_to_string(l_nr1));
dbms_output.put_line('--');
fast_int.print(l_nr1);
for x in 1 .. fast_int.get_length(l_nr1)
loop
  dbms_output.put_line(to_char(x) || '   '|| fast_int.get_digit(x, l_nr1));
end loop;
end;
/

set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  fast_int.p_int_ty := fast_int.string_to_int(l_string);
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  fast_int.p_int_ty;
l_id  integer;
begin
fast_int.print(l_nr1);
dbms_output.put_line('--');
dbms_output.put_line(fast_int.int_to_string(l_nr1));
dbms_output.put_line('--');
fast_int.print(l_nr2);
dbms_output.put_line('--');
  dbms_output.put_line('Mult:');
  fast_int.print(fast_int.multiply(l_nr1, l_nr2));
  dbms_output.put_line('Substr:');
  fast_int.print(fast_int.subtract(l_nr1, l_nr2));
  dbms_output.put_line('Div:');
  fast_int.print(fast_int.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  fast_int.print(l_rest);
  dbms_output.put_line('Gcd:    ');
  fast_int.print(fast_int.gcd(l_nr1, l_nr2));
end;
/


set serveroutput on size unlimited
declare
l_string varchar2(32767) := '89991766235738378245624727488915637849889991766235738378245624727488915637849594853483485637383889507859048635435754398899917662357383782456247274889156378498';
l_nr1  fast_int.p_int_ty := fast_int.string_to_int(l_string);
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('996783679234515778873561835672737859989967836792345157788735618356727378599899678367923451577887356183567273785998');
l_rest  fast_int.p_int_ty;
l_id  integer;
begin
  dbms_output.put_line('Div:');
  fast_int.print(fast_int.divide(l_nr1, l_nr2, l_rest));
  dbms_output.put_line('Rest:');
  fast_int.print(l_rest);
end;
/

declare
l_nr1  fast_int.p_int_ty :=  fast_int.nfac(10000);
begin
fast_int.print(l_nr1);
dbms_output.put_line('--');
end;
/

declare
l_nr2  fast_int.p_int_ty := fast_int.string_to_int('996783679234515778873');
x integer;
begin
for j in 1 .. 20
loop
  fast_int.print(l_nr2);
  l_nr2 := fast_int.mult_n(10, l_nr2);
end loop;
end;
/


declare
l_rest   varchar2(32767);
begin
  dbms_output.put_line( fast_int.divide('5625','75', l_rest));
  dbms_output.put_line( l_rest);
end;
/

select fast_int.nfac(100) from dual;
select fast_int.mod(100, 19) from dual;
select fast_int.lcm(10011, 192) lcm, fast_int.gcd(10011, 192) gcd from dual;

select fast_int.prime_test('256247274891563554478498177', 1) from dual;


create table Faculties
( n    number(6)
, fact  varchar2(32767));


declare
l_fact   varchar2(32767);
begin
for j in 1 .. 400
loop
  insert into Faculties values (j * 100, fast_int.nfac(j * 100));
  commit;
end loop;
end;
/

