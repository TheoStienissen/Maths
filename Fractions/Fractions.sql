/*************************************************************************************************************************************************

Name          : fractions_pkg.sql
Created       : 2022
Last update   : June 2023
Author        : Theo Stienissen
E-mail        : theo.stienissen@gmail.com
Purpose       : Calculations with fractions
Prerequisites : types_pkg, maths and util error package
Script        : @C:\Users\Theo\OneDrive\Theo\Project\Maths\Fractions\fractions.sql

*************************************************************************************************************************************************/


set serveroutput on size unlimited

alter session set plsql_warnings = 'ENABLE:ALL'; 

drop type fraction_ty;
drop type numerator_ty;
drop type denominator_ty;


create or replace type numerator_ty as object (numerator integer);
/

create or replace type denominator_ty as object (denominator integer);
/

create or replace type fraction_ty as object (numerator integer (38), denominator integer (38),
   member procedure print, 
   order member function measure (r fraction_ty) return number); 
/

create or replace type body fraction_ty as 
   member procedure print is 
   begin 
      fractions_pkg.print (fractions_pkg.to_fraction (numerator, denominator));
   end print;  
   order member function measure (r fraction_ty) return number is 
   begin 
      if  self.numerator *  r.denominator =  self.denominator * r.numerator then return 0;
	  elsif self.numerator = 0 then return   sign (r.numerator * r.denominator);
	  elsif r.numerator    = 0 then return - sign (self.numerator * self.denominator);
      elsif sign (self.numerator * self.denominator) = 1 and sign (r.numerator * r.denominator) = - 1 then return 1;
	  elsif sign (self.numerator * self.denominator) = - 1 and sign (r.numerator * r.denominator) = 1 then return -1;
	  elsif sign (self.numerator * self.denominator) = 1 and sign (r.numerator * r.denominator) = 1
        then if self.numerator * r.denominator > r.numerator * self.denominator then return 1; else return -1; end if;
      else if self.numerator * r.denominator > r.numerator * self.denominator then return - 1; else return  1; end if;
      end if; 
   end measure; 
end; 
/

create or replace package fractions_pkg
as

procedure print    (p_fraction in types_pkg.fraction_ty, p_new_line boolean default true);

function  to_fraction (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty default 1) return types_pkg.fraction_ty;
function  nr_to_fraction (p_number in number) return types_pkg.fraction_ty;

function  normalize (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty)   return types_pkg.fraction_ty;

function  normalize (p_fraction in types_pkg.fraction_ty)                                    return types_pkg.fraction_ty;

function  add       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  subtract  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  multiply  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  divide    (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  gt_zero   (p_fraction in types_pkg.fraction_ty)                                    return boolean;

function  eq        (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return boolean;

function  gt        (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return boolean;

function  gcd       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  lcm       (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)               return types_pkg.fraction_ty;

function  sqr       (p1 in types_pkg.fraction_ty)                                            return types_pkg.fraction_ty;

function  fpower    (p1 in types_pkg.fraction_ty, p_power in integer)                        return types_pkg.fraction_ty;

function  fabs      (p1 in types_pkg.fraction_ty)                                            return types_pkg.fraction_ty;

procedure egyptian_fractions (p_fraction in types_pkg.fraction_ty);

function  is_integer (p_fraction in types_pkg.fraction_ty) return boolean;

end fractions_pkg;
/
show error

create or replace package body fractions_pkg
as
--
-- Print a fraction
--
procedure print (p_fraction in types_pkg.fraction_ty, p_new_line boolean default true)
is
begin
  if p_fraction.denominator = 0 then raise zero_divide; end if;
 
  if p_fraction.numerator is not null and p_fraction.denominator is not null
  then
    if sign (p_fraction.numerator) * sign (p_fraction.denominator) = -1 -- Negative fraction
    then dbms_output.put ('- ');
	else dbms_output.put ('+ ');
    end if;

    if mod (p_fraction.numerator, p_fraction.denominator) = 0 --  Whole number
    then
	    dbms_output.put (to_char (trunc (abs (p_fraction.numerator) / abs (p_fraction.denominator))));
    else
      if abs (p_fraction.numerator) > abs (p_fraction.denominator)
      then
	    dbms_output.put (to_char (trunc (abs (p_fraction.numerator) / abs (p_fraction.denominator))) || ':' );
      end if;
	  dbms_output.put (mod (abs (p_fraction.numerator), abs (p_fraction.denominator)) || '/' || abs (p_fraction.denominator));	  
    end if;
	if p_new_line then dbms_output.new_line; end if;
  end if;

exception when others then
  util.show_error ('Error in procedure print for: ' || p_fraction.numerator || ' /  ' || p_fraction.denominator, sqlerrm);
end print;

/*************************************************************************************************************************************************/
--
-- Convert to Fraction and make denominator gt_zero
--
function  to_fraction (p_num in types_pkg.numerator_ty, p_denom in types_pkg.denominator_ty default 1) return types_pkg.fraction_ty
is
l_return types_pkg.fraction_ty;
begin
  if p_denom = 0 then raise zero_divide; end if;

  if p_num is null or p_denom is null
  then return l_return;
  else
    if p_denom > 0
    then l_return := types_pkg.fraction_ty (p_num, p_denom);
    else l_return := types_pkg.fraction_ty (- p_num, - p_denom);
    end if;
  return normalize(l_return);
  end if;

exception when others then
  util.show_error ('Error in function to_fraction. Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
  return constants_pkg.empty_fraction;
end to_fraction;

/*************************************************************************************************************************************************/

--
-- Convert number to (approximate) Fraction
--
function  nr_to_fraction (p_number in number) return types_pkg.fraction_ty
is 
l_vc_fraction varchar2(100) := to_char(p_number - floor (p_number));
begin
  l_vc_fraction := ltrim (substr (l_vc_fraction, instr (l_vc_fraction, '.') + 1));
  if    l_vc_fraction              is null then return constants_pkg.empty_fraction;
  elsif ltrim (l_vc_fraction, '0') is null then return fractions_pkg.to_fraction (floor (p_number));
  else l_vc_fraction := substr(l_vc_fraction, 1, 30);
  return fractions_pkg.add (fractions_pkg.to_fraction (floor (p_number)), fractions_pkg.to_fraction (l_vc_fraction, power (10, length (l_vc_fraction))));
  end if;

exception when others then
  util.show_error ('Error in function nr_to_fraction for number: ' || to_char(p_number) || '.', sqlerrm);
  return constants_pkg.empty_fraction;
end nr_to_fraction;

/*************************************************************************************************************************************************/

--
-- Divide by gcd
--
function normalize (p_num types_pkg.numerator_ty, p_denom types_pkg.denominator_ty) return types_pkg.fraction_ty
is
l_gcd    types_pkg.numerator_ty;
begin
  if    p_num is null or p_denom is null then return null;
  elsif p_denom = 0 then raise zero_divide; end if;

  l_gcd := maths.gcd (p_num, p_denom);
  return types_pkg.fraction_ty (p_num / l_gcd, p_denom / l_gcd);

exception when others then
  util.show_error ('Error in function normalize. Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
  return constants_pkg.empty_fraction;
end normalize;

/*************************************************************************************************************************************************/
--
-- Overloaded copy
--
function normalize (p_fraction types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions_pkg.normalize (p_fraction.numerator, p_fraction.denominator);

exception when others then
  util.show_error ('Error in 2-nd function normalize.', sqlerrm);
  return constants_pkg.empty_fraction;
end normalize;

/*************************************************************************************************************************************************/
--
-- Sum: p1 + p2
--
function add (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
l_return types_pkg.fraction_ty;
begin
  if    p1.numerator is null or p2.numerator is null then return null;
  elsif p1.denominator = 0   or p2.denominator = 0 then raise zero_divide; 
  else
    l_return.denominator := maths.lcm (p1.denominator, p2.denominator);
    l_return.numerator   := (l_return.denominator / p1.denominator) * p1.numerator + (l_return.denominator / p2.denominator) * p2.numerator;
    return fractions_pkg.normalize (l_return);
  end if;

exception when others then
  util.show_error ('Error in function add.', sqlerrm);
  return constants_pkg.empty_fraction;
end add;

/*************************************************************************************************************************************************/
--
-- Subtract: p1 - p2
--
function subtract (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions_pkg.add (p1, types_pkg.fraction_ty (- p2.numerator, p2.denominator));

exception when others then
  util.show_error ('Error in function subtract.', sqlerrm);
  return constants_pkg.empty_fraction;
end subtract;

/*************************************************************************************************************************************************/
--
-- Multiply: p1 * p2
--
function multiply (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)       return types_pkg.fraction_ty
is
begin
  return normalize (types_pkg.fraction_ty (p1.numerator * p2.numerator, p1.denominator * p2.denominator));

exception when others then
  util.show_error ('Error in function multiply.', sqlerrm);
  return constants_pkg.empty_fraction;
end multiply;

/*************************************************************************************************************************************************/
--
-- Divide: p1 / p2
--
function divide (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty)       return types_pkg.fraction_ty
is
begin
  return fractions_pkg.multiply (p1, types_pkg.fraction_ty (p2.denominator, p2.numerator));

exception when others then
  util.show_error ('Error in function divide.', sqlerrm);
  return constants_pkg.empty_fraction;
end divide;

/*************************************************************************************************************************************************/
--
-- Checks if a fraction is gt_zero
--
function  gt_zero (p_fraction in types_pkg.fraction_ty) return boolean
is
begin
  if p_fraction.denominator = 0 then raise zero_divide; end if;
  return sign (p_fraction.numerator) = sign (p_fraction.denominator);

exception when others then
  util.show_error ('Error in function gt_zero: ' || p_fraction.numerator || ' and  ' || p_fraction.denominator, sqlerrm);
  return null;
end gt_zero;

/*************************************************************************************************************************************************/
--
-- Are 2 franctions equal?
--
function eq  (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return boolean
is
begin
  return p1.numerator * p2.denominator = p2.numerator * p1.denominator;

exception when others then
  util.show_error ('Error in function eq.', sqlerrm);
  return null;
end eq;

/*************************************************************************************************************************************************/
--
-- Greater than
--
function gt (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return boolean
is
l_p1  types_pkg.fraction_ty := fractions_pkg.fabs (p1);
l_p2  types_pkg.fraction_ty := fractions_pkg.fabs (p2);
begin
  if    l_p1.numerator is null or l_p2.numerator is null or l_p1.denominator is null or l_p2.denominator is null then return null;
  elsif l_p1.denominator = 0 or l_p2.denominator = 0 then raise zero_divide; 
  elsif gt_zero (p1) and not gt_zero (p2) then return true;
  elsif not gt_zero (p1) and gt_zero (p2) then return false;
  elsif gt_zero (p1) and gt_zero (p2)     then return abs (l_p1.numerator) * abs (l_p2.denominator) > abs (l_p2.numerator) * abs (l_p1.denominator);
  else  return abs (l_p1.numerator) * abs (l_p2.denominator) < abs (l_p2.numerator) * abs (l_p1.denominator);
  end if;

exception when others then
  util.show_error ('Error in function gt.', sqlerrm);
  return null;
end gt;

/*************************************************************************************************************************************************/
--
-- Greatest common divisor
--
function gcd (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
l_lcm types_pkg.denominator_ty := maths.lcm(p1.denominator, p2.denominator);
l_gcd types_pkg.numerator_ty;
begin
  l_gcd := maths.gcd (p1.numerator * (l_lcm / p1.denominator), p2.numerator * (l_lcm / p2.denominator));
  return fractions_pkg.normalize (types_pkg.fraction_ty (l_gcd, l_lcm));

exception when others then
  util.show_error ('Error in function gcd.', sqlerrm);
  return constants_pkg.empty_fraction;
end gcd;

/*************************************************************************************************************************************************/
--
-- Least common multiple
--
function lcm (p1 in types_pkg.fraction_ty, p2 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions_pkg.normalize (divide (multiply (p1,p2), gcd (p1,p2)));

exception when others then
  util.show_error ('Error in function lcm.', sqlerrm);
  return constants_pkg.empty_fraction;
end lcm;

/*************************************************************************************************************************************************/
--
-- Square: p1 * p1
--
function sqr (p1 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return fractions_pkg.multiply (p1, p1);

exception when others then
  util.show_error ('Error in function sqr.', sqlerrm);
  return constants_pkg.empty_fraction;
end sqr;

/*************************************************************************************************************************************************/

function fpower (p1 in types_pkg.fraction_ty, p_power in integer) return types_pkg.fraction_ty
is
l_result types_pkg.fraction_ty;
begin
if p_power = 0    then return types_pkg.fraction_ty (1, 1);
elsif p_power < 0
then return fractions_pkg.fpower (types_pkg.fraction_ty (p1.denominator, p1.numerator), - p_power);
else
  l_result := p1;
  for j in 1 .. p_power - 1
  loop
    l_result := fractions_pkg.multiply (p1, l_result);
  end loop;
  return fractions_pkg.normalize (l_result);
end if;

exception when others then
  util.show_error ('Error in fpower.', sqlerrm);
  return constants_pkg.empty_fraction;
end fpower;

/*************************************************************************************************************************************************/
--
-- Absolute value
--
function fabs (p1 in types_pkg.fraction_ty) return types_pkg.fraction_ty
is
begin
  return types_pkg.fraction_ty (abs (p1.numerator), abs (p1.denominator));

exception when others then
  util.show_error ('Error in function fabs.', sqlerrm);
  return constants_pkg.empty_fraction;
end fabs;

/*************************************************************************************************************************************************/
--
-- Egyption fractions
--
procedure egyptian_fractions (p_fraction in types_pkg.fraction_ty)
is
l_fraction types_pkg.fraction_ty;
begin
if mod (p_fraction.denominator, p_fraction.numerator) = 0
then
  print (to_fraction (1, p_fraction.denominator / p_fraction.numerator));
else
  l_fraction := to_fraction (1, trunc (p_fraction.denominator / p_fraction.numerator) +1);
  print (l_fraction);
  egyptian_fractions (subtract (p_fraction, l_fraction));
end if;

exception when others then
  util.show_error ('Error in procedure Egyptian_fractions_pkg.', sqlerrm);
end egyptian_fractions;

/*************************************************************************************************************************************************/
--
-- Checks wheter the fraction is in fact an integer
--
function  is_integer (p_fraction in types_pkg.fraction_ty) return boolean
is
begin
  return mod (p_fraction.numerator, p_fraction.denominator) = 0;

exception when others then
  util.show_error ('Error in unction  is_integer.', sqlerrm);
  return null;
end is_integer;

end fractions_pkg;
/

show error

alter package matrix_Q_pkg compile;
select object_type, status from user_objects where object_name =  'FRACTIONS_PKG';


/* Demo's
set serveroutput on size unlimited
declare
l_fraction1 types_pkg.fraction_ty := fractions_pkg.to_fraction(1, 225);
l_fraction2 types_pkg.fraction_ty := fractions_pkg.to_fraction(1, 400);
l_fraction3 types_pkg.fraction_ty;
begin
if fractions_pkg.eq(l_fraction1, l_fraction2)
then dbms_output.put_line('Equal');
else dbms_output.put_line('Not Equal');
end if;

if fractions_pkg.gt(l_fraction1, l_fraction2)
then dbms_output.put_line('Greater');
else dbms_output.put_line('Not Greater');
end if;

l_fraction3 := fractions_pkg.gcd(l_fraction1, l_fraction2);
dbms_output.put('Gcd     : ');
fractions_pkg.print(l_fraction3);
l_fraction3 := fractions_pkg.lcm(l_fraction1, l_fraction2);
dbms_output.put('Lcm     : ');
fractions_pkg.print(l_fraction3);

dbms_output.put('Add     : ');
fractions_pkg.print(fractions_pkg.add(l_fraction1, l_fraction2));
dbms_output.put('Subtract: ');
fractions_pkg.print(fractions_pkg.subtract(l_fraction1, l_fraction2));
dbms_output.put('Multiply: ');
fractions_pkg.print(fractions_pkg.multiply(l_fraction1, l_fraction2));
dbms_output.put('Divide  : ');
fractions_pkg.print(fractions_pkg.divide(l_fraction1, l_fraction2));

-- Not unique! 3/11 = 1/4 + 1/44 = 1/11 + 1/6 + 1/66
dbms_output.put_line('Egyptian: ');
fractions_pkg.egyptian_fractions(fractions_pkg.to_fraction(3, 11));
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
l_fraction1 := fractions_pkg.to_fraction(1, l_trip1 * l_trip3 * l_trip1 * l_trip3);
fractions_pkg.print(l_fraction1);
l_fraction2 := fractions_pkg.to_fraction(1, l_trip2 * l_trip3 * l_trip2 * l_trip3);
fractions_pkg.print(l_fraction2);
dbms_output.put_line('Add     : ');
fractions_pkg.print(fractions_pkg.add(l_fraction1, l_fraction2));
end;
/

set serveroutput on size unlimited
declare
l_fraction1 types_pkg.fraction_ty := fractions_pkg.to_fraction(-2, 3);
l_fraction2 types_pkg.fraction_ty := fractions_pkg.to_fraction(-1, 3);
begin
 fractions_pkg.print(fractions_pkg.add(l_fraction1, l_fraction2));
end;
/

set serveroutput on size unlimited
begin
 fractions_pkg.print(fractions_pkg.fpower(l_fraction1, -32));
end;
/


begin
 fractions_pkg.print(fractions_pkg.to_fraction(-4, -8));
end;
/


-- Cantor
declare
l_pi       types_pkg.fraction_ty := fractions_pkg.to_fraction(3141592653589793238462643383279502, 1000000000000000000000000000000000);
l_upper    types_pkg.fraction_ty := fractions_pkg.to_fraction(32,10);
l_lower    types_pkg.fraction_ty := fractions_pkg.to_fraction(31,10);
l_middle   types_pkg.fraction_ty;
l_diff     types_pkg.fraction_ty;
begin
for j in 1 .. 40
loop
 l_middle := fractions_pkg.multiply(fractions_pkg.add(l_lower, l_upper), fractions_pkg.to_fraction(1,2));
 if fractions_pkg.gt(l_middle, l_pi)
 then l_upper := l_middle;
 else l_lower := l_middle;
 end if;
 l_diff := fractions_pkg.subtract(l_upper, l_lower);
 dbms_output.put_line('Iteration    : ' || j);
 fractions_pkg.print(l_lower);
 fractions_pkg.print(l_upper);
 fractions_pkg.print(l_diff);
end loop;
end;
/


*/