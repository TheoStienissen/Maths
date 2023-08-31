set serveroutput on size unlimited
declare
l_fraction1 types_pkg.fraction_ty := fractions.to_fraction(1, 225);
l_fraction2 types_pkg.fraction_ty := fractions.to_fraction(1, 400);
l_fraction3 types_pkg.fraction_ty;
begin
if fractions.eq(l_fraction1, l_fraction2)
then dbms_output.put_line('Equal');
else dbms_output.put_line('Not Equal');
end if;

if fractions.gt(l_fraction1, l_fraction2)
then dbms_output.put_line('Greater');
else dbms_output.put_line('Not Greater');
end if;

l_fraction3 := fractions.gcd(l_fraction1, l_fraction2);
dbms_output.put('Gcd     : ');
fractions.print(l_fraction3);
l_fraction3 := fractions.lcm(l_fraction1, l_fraction2);
dbms_output.put('Lcm     : ');
fractions.print(l_fraction3);

dbms_output.put('Add     : ');
fractions.print(fractions.add(l_fraction1, l_fraction2));
dbms_output.put('Subtract: ');
fractions.print(fractions.subtract(l_fraction1, l_fraction2));
dbms_output.put('Multiply: ');
fractions.print(fractions.multiply(l_fraction1, l_fraction2));
dbms_output.put('Divide  : ');
fractions.print(fractions.divide(l_fraction1, l_fraction2));

-- Not unique! 3/11 = 1/4 + 1/44 = 1/11 + 1/6 + 1/66
dbms_output.put_line('Egyptian: ');
fractions.egyptian_fractions(fractions.to_fraction(3, 11));
end;
/

1/a + 1/b = 1/c
set serveroutput on size unlimited
declare
l_trip1 number(10) := 40;
l_trip2 number(10) := 9;
l_trip3 number(10);
l_fraction1 types_pkg.fraction_ty;
l_fraction2 types_pkg.fraction_ty;
l_fraction3 types_pkg.fraction_ty;
begin
l_trip3 := sqrt(l_trip1 * l_trip1 + l_trip2 * l_trip2);
dbms_output.put_line('Sqrt    : ' || l_trip3);
l_fraction1 := fractions.to_fraction(1, l_trip1 * l_trip3 * l_trip1 * l_trip3);
fractions.print(l_fraction1);
l_fraction2 := fractions.to_fraction(1, l_trip2 * l_trip3 * l_trip2 * l_trip3);
fractions.print(l_fraction2);
dbms_output.put_line('Add     : ');
fractions.print(fractions.add(l_fraction1, l_fraction2));
end;
/

set serveroutput on size unlimited
declare
l_fraction1 types_pkg.fraction_ty := fractions.to_fraction(-2, 3);
l_fraction2 types_pkg.fraction_ty := fractions.to_fraction(-1, 3);
begin
 fractions.print(fractions.add(l_fraction1, l_fraction2));
end;
/

set serveroutput on size unlimited
declare
l_fraction1 types_pkg.fraction_ty := fractions.to_fraction(4, 8);
begin
 fractions.print(fractions.fpower(l_fraction1, -32));
end;
/

-- Cantor
declare
l_pi       types_pkg.fraction_ty := fractions.to_fraction(3141592653589793238462643383279502, 1000000000000000000000000000000000);
l_upper    types_pkg.fraction_ty := fractions.to_fraction(32,10);
l_lower    types_pkg.fraction_ty := fractions.to_fraction(31,10);
l_middle   types_pkg.fraction_ty;
l_diff     types_pkg.fraction_ty;
begin
for j in 1 .. 40
loop
 l_middle := fractions.multiply(fractions.add(l_lower, l_upper), fractions.to_fraction(1,2));
 if fractions.gt(l_middle, l_pi)
 then l_upper := l_middle;
 else l_lower := l_middle;
 end if;
 l_diff := fractions.subtract(l_upper, l_lower);
 dbms_output.put_line('Iteration    : ' || j);
 fractions.print(l_lower);
 fractions.print(l_upper);
 fractions.print(l_diff);
end loop;
end;
/

-- Twee willekeurige breuken. Eerste is groter of gelijk aan de tweede
create or replace procedure maak_breuken (p_low integer default 15, p_high integer default 25)
is
l_fraction1 types_pkg.fraction_ty;
begin
  types_pkg.g_fraction1 := fractions.to_fraction(trunc(dbms_random.value(1,p_low)), trunc(dbms_random.value(1,p_high)));
  types_pkg.g_fraction2 := fractions.to_fraction(trunc(dbms_random.value(1,p_low)), trunc(dbms_random.value(1,p_high)));
  if fractions.gt(types_pkg.g_fraction2, types_pkg.g_fraction1 )
  then
    l_fraction1           := types_pkg.g_fraction1;
	types_pkg.g_fraction1 := types_pkg.g_fraction2;
    types_pkg.g_fraction2 := l_fraction1;
  end if;
  fractions.print(types_pkg.g_fraction1);
  fractions.print(types_pkg.g_fraction2);
end maak_breuken;
/

-- De operaties
create or replace procedure bereken_som (p_operatie in varchar2 default '+')
is
begin
  dbms_output.put_line(chr(10) || '+++++++++++++++++++++++++++++  Resultaat  +++++++++++++++++++++++++++++');
  if    p_operatie = '+' then fractions.print(fractions.add     (types_pkg.g_fraction1, types_pkg.g_fraction2));
  elsif p_operatie = '-' then fractions.print(fractions.subtract(types_pkg.g_fraction1, types_pkg.g_fraction2));
  elsif p_operatie = '*' then fractions.print(fractions.multiply(types_pkg.g_fraction1, types_pkg.g_fraction2));
  elsif p_operatie = ':' then fractions.print(fractions.divide  (types_pkg.g_fraction1, types_pkg.g_fraction2));
  else raise_application_error(-20001, 'Onbekende bewerking: ' || p_operatie);
  end if;
end bereken_som;
/

set feedback off
set serveroutput on size unlimited
exec maak_breuken(9,11)
exec bereken_som('+')