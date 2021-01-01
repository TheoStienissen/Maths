/*************************************************************************************************************************************************

Name          : Fractions.sql

Last update   : October 2020

Author        : Theo Stienissen

E-mail        : theo.stienissen@gmail.com

Purpose       : Calculations with fractions

Prerequisites : types_pkg, maths and util error package

@C:\Users\Theo\OneDrive\Theo\Project\Maths\Fractions\Fractions.sql

*************************************************************************************************************************************************/


create or replace package fractions
as

procedure print  (p_fraction in types_pkg.fraction_ty);

function to_fraction (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty) return types_pkg.fraction_ty;

function normalize (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty)   return types_pkg.fraction_ty;

function normalize (p_fraction in types_pkg.fraction_ty)                                    return types_pkg.fraction_ty;

function add       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function subtract  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function multiply  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function divide    (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function eq        (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return boolean;

function gt        (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return boolean;

function gcd       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function lcm       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function sqr       (p1 in types_pkg.fraction_ty)                                            return types_pkg.fraction_ty;

function power     (p1 in types_pkg.fraction_ty, p_power in integer)                        return types_pkg.fraction_ty;

function absQ      (p1 in types_pkg.fraction_ty)                                            return types_pkg.fraction_ty;

procedure egyptian_fractions (p_fraction in types_pkg.fraction_ty);

end fractions;
/

create or replace package body fractions
as

procedure print (p_fraction in types_pkg.fraction_ty)
is
begin
if sign (p_fraction.numerator) * sign (p_fraction.denominator) = -1 -- Negative fraction
then
  dbms_output.put('- ');
end if;

if mod (p_fraction.numerator, p_fraction.denominator) = 0 --  Whole number
then
  dbms_output.put_line(to_char(abs(p_fraction.numerator/p_fraction.denominator)));
else
  if abs(p_fraction.numerator) > abs(p_fraction.denominator)
  then
    dbms_output.put(to_char(trunc(abs(p_fraction.numerator)/abs(p_fraction.denominator))) || ':' );
  end if;
  dbms_output.put_line(mod(abs(p_fraction.numerator), abs(p_fraction.denominator)) || '/' || abs(p_fraction.denominator));
end if;

exception when others then
  util.show_error ('Error in procedure print for: ' || p_fraction.numerator || ' /  ' || p_fraction.denominator, sqlerrm);
end print;

/*************************************************************************************************************************************************/

function to_fraction (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty) return types_pkg.fraction_ty
is
l_return types_pkg.fraction_ty;
begin
if p_denom >= 0
then
  l_return.numerator   := p_num;
  l_return.denominator := p_denom;
else
  l_return.numerator   := - p_num;
  l_return.denominator := - p_denom;
end if;
  return l_return;

exception when others then
  util.show_error ('Error in function to_fraction. Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
end to_fraction;

/*************************************************************************************************************************************************/

function normalize (p_num types_pkg.numerator_ty, p_denom types_pkg.denominator_ty) return types_pkg.fraction_ty
is
l_gcd    types_pkg.numerator_ty;
begin
if p_num is null or p_denom is null
then
  return null;
else
  l_gcd := maths.gcd (p_num, p_denom);
  return to_fraction (p_num / l_gcd, p_denom / l_gcd);
end if;

exception when others then
  util.show_error ('Error in function normalize. Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
end normalize;

/*************************************************************************************************************************************************/

function normalize (p_fraction types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions.normalize (p_fraction.numerator, p_fraction.denominator);

exception when others then
  util.show_error ('Error in 2-nd function normalize.', sqlerrm);
end normalize;

/*************************************************************************************************************************************************/

-- p1 + p2
function add (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
l_return types_pkg.fraction_ty;
begin
if p1.numerator is null or p2.numerator is null
then return null;
else
  l_return.denominator := maths.lcm (p1.denominator, p2.denominator);
  l_return.numerator  := (l_return.denominator / p1.denominator) * p1.numerator + (l_return.denominator / p2.denominator) * p2.numerator;
  return fractions.normalize(l_return);
end if;

exception when others then
  util.show_error ('Error in function add.', sqlerrm);
end add;

/*************************************************************************************************************************************************/

-- p1 - p2
function subtract (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions.add(p1, to_fraction(- p2.numerator, p2.denominator));

exception when others then
  util.show_error ('Error in function subtract.', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

-- p1 * p2
function multiply (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)       return types_pkg.fraction_ty
is
begin
  return normalize(to_fraction(p1.numerator * p2.numerator, p1.denominator * p2.denominator));

exception when others then
  util.show_error ('Error in function multiply.', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

-- p1 / p2
function divide (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)       return types_pkg.fraction_ty
is
begin
  return fractions.multiply (p1, to_fraction(p2.denominator, p2.numerator));

exception when others then
  util.show_error ('Error in function divide.', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

-- Are 2 franctions equal?
function eq  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return boolean
is
begin
  return p1.numerator * p2.denominator = p2.numerator * p1.denominator;

exception when others then
  util.show_error ('Error in function eq.', sqlerrm);
end eq;

/*************************************************************************************************************************************************/

-- Greater than
function gt (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return boolean
is
l_p1  types_pkg.numerator_ty;
l_p2  types_pkg.numerator_ty;
l_lcm types_pkg.numerator_ty;
begin
if p1.denominator < 0 then l_p1 := - p1.numerator; else l_p1 := p1.numerator; end if;
if p2.denominator < 0 then l_p2 := - p2.numerator; else l_p2 := p2.numerator; end if;
l_lcm := maths.lcm (abs (p1.denominator), abs (p2.denominator));

  return l_p1 * (l_lcm / abs (p1.denominator)) > l_p2 * (l_lcm / abs (p2.denominator));

exception when others then
  util.show_error ('Error in function gt.', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

-- Greatest common divisor
function gcd (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
l_lcm types_pkg.denominator_ty := maths.lcm(p1.denominator, p2.denominator);
l_gcd types_pkg.numerator_ty;
begin
l_gcd := maths.gcd(p1.numerator * (l_lcm / p1.denominator), p2.numerator * (l_lcm / p2.denominator));
  
  return fractions.normalize (to_fraction (l_gcd, l_lcm));

exception when others then
  util.show_error ('Error in function gcd.', sqlerrm);
end gcd;

/*************************************************************************************************************************************************/

-- Least common multiple
function lcm (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions.normalize (divide (multiply (p1,p2), gcd(p1,p2)));

exception when others then
  util.show_error ('Error in function lcm.', sqlerrm);
end lcm;

/*************************************************************************************************************************************************/

-- Square: p1 * p1
function sqr (p1 in types_pkg.fraction_ty)                                    return types_pkg.fraction_ty
is
begin
  return fractions.multiply (p1,p1);

exception when others then
  util.show_error ('Error in function sqr.', sqlerrm);
end sqr;

/*************************************************************************************************************************************************/

function power (p1 in types_pkg.fraction_ty, p_power in integer)                return types_pkg.fraction_ty
is
l_result types_pkg.fraction_ty;
begin
if p_power = 0    then return to_fraction (1, 1);
elsif p_power < 0
then return fractions.power(fractions.to_fraction(p1.denominator, p1.numerator), - p_power);
else
  l_result := p1;
  for j in 1 .. p_power - 1
  loop
    l_result := fractions.multiply (p1, l_result);
  end loop;
  return fractions.normalize (l_result);
end if;

exception when others then
  util.show_error ('Error in power.', sqlerrm);
end power;

/*************************************************************************************************************************************************/

-- Absolute value
function absQ (p1 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return to_fraction (abs (p1.numerator), abs (p1.denominator));

exception when others then
  util.show_error ('Error in function absQ.', sqlerrm);
end absQ;

/*************************************************************************************************************************************************/

procedure egyptian_fractions (p_fraction in types_pkg.fraction_ty)
is
l_fraction types_pkg.fraction_ty;
begin
if mod(p_fraction.denominator, p_fraction.numerator) = 0
then
  print(to_fraction(1, p_fraction.denominator/p_fraction.numerator));
else
  l_fraction := to_fraction (1, trunc(p_fraction.denominator/p_fraction.numerator) +1);
  print(l_fraction);
  egyptian_fractions (subtract (p_fraction, l_fraction));
end if;

exception when others then
  util.show_error ('Error in procedure Egyptian_fractions.', sqlerrm);
end egyptian_fractions;

end fractions;
/

/* Demo's
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
 fractions.print(fractions.power(l_fraction1, -32));
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


*/