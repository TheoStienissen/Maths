/*************************************************************************************************************************************************

Name        : Fractions.sql

Last update : April 2018 / August 2023

Author      : Theo stienissen

E-mail      : theo.stienissen@gmail.com

Purpose     : Calculations with fractions

*************************************************************************************************************************************************/


create or replace package fractions
as
subtype numerator_ty    is integer(36);
subtype denominator_ty  is integer(36) not null;
type fraction_ty        is record (numerator numerator_ty, denominator denominator_ty default 1);

procedure print  (p_fraction in fraction_ty);
function to_fraction (p_num in numerator_ty, p_denom in denominator_ty) return fraction_ty;
function normalize (p_num in numerator_ty, p_denom in denominator_ty) return fraction_ty;
function normalize (p_fraction in fraction_ty) return fraction_ty;
function add       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;

-- p1 - p2
function subtract  (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;
function multiply  (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;
function divide    (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;
function eq        (p1 in fraction_ty, p2 in fraction_ty)       return boolean;
function gt        (p1 in fraction_ty, p2 in fraction_ty)       return boolean;
function gcd       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;
function lcm       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty;
procedure egyptian_fractions (p_fraction in fraction_ty);
end fractions;
/

create or replace package body fractions
as

procedure print (p_fraction in fraction_ty)
is
begin
if mod(p_fraction.numerator, p_fraction.denominator) = 0
then
  dbms_output.put_line(to_char(p_fraction.numerator/p_fraction.denominator));
else
  dbms_output.put_line(p_fraction.numerator || '/' || p_fraction.denominator);
end if;

exception when others then
  util.show_error('Error in procedure print', sqlerrm);
end print;

/*************************************************************************************************************************************************/

function to_fraction (p_num in numerator_ty, p_denom in denominator_ty) return fraction_ty
is
l_return fraction_ty;
begin
  l_return.numerator   := p_num;
  l_return.denominator := p_denom;
  return l_return;

exception when others then
  util.show_error('Error in function to_fraction.' ||
      ' Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
end to_fraction;

/*************************************************************************************************************************************************/

function normalize (p_num numerator_ty, p_denom denominator_ty) return fraction_ty
is
l_gcd    numerator_ty;
begin
if p_num is null or p_denom is null
then
  return null;
else
  l_gcd := maths.gcd (p_num, p_denom);
  return to_fraction(p_num / l_gcd, p_denom / l_gcd);
end if;

exception when others then
  util.show_error('Error in function normalize.' ||
      ' Numerator: ' || p_num || '. Denominator: ' || p_denom || '.', sqlerrm);
end normalize;

/*************************************************************************************************************************************************/

function normalize (p_fraction fraction_ty) return fraction_ty
is
begin
  return fractions.normalize (p_fraction.numerator, p_fraction.denominator);

exception when others then
  util.show_error('Error in 2-nd function normalize.', sqlerrm);
end normalize;

/*************************************************************************************************************************************************/

function add       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
l_return fraction_ty;
begin
if p1.numerator is null or p2.numerator is null
then return null;
else
  l_return.denominator := maths.lcm (p1.denominator, p2.denominator);
  l_return.numerator  := (l_return.denominator / p1.denominator) * p1.numerator + (l_return.denominator / p2.denominator) * p2.numerator;
  return fractions.normalize(l_return);
end if;

exception when others then
  util.show_error('Error in function add.', sqlerrm);
end add;

/*************************************************************************************************************************************************/

-- p1 - p2
function subtract  (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
begin
  return fractions.add(p1, to_fraction(- p2.numerator, p2.denominator));

exception when others then
  util.show_error('Error in function subtract.', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function multiply  (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
begin
  return normalize(to_fraction(p1.numerator * p2.numerator, p1.denominator * p2.denominator));

exception when others then
  util.show_error('Error in function multiply.', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function divide    (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
begin
  return fractions.multiply(p1, to_fraction(p2.denominator, p2.numerator));

exception when others then
  util.show_error('Error in function divide.', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function eq        (p1 in fraction_ty, p2 in fraction_ty)       return boolean
is
begin
  return p1.numerator * p2.denominator = p2.numerator * p1.denominator;

exception when others then
  util.show_error('Error in function eq.', sqlerrm);
end eq;

/*************************************************************************************************************************************************/

function gt        (p1 in fraction_ty, p2 in fraction_ty)       return boolean
is
l_p1  numerator_ty;
l_p2  numerator_ty;
l_lcm numerator_ty;
begin
if p1.denominator < 0 then l_p1 := - p1.numerator; else l_p1 := p1.numerator; end if;
if p2.denominator < 0 then l_p2 := - p2.numerator; else l_p2 := p2.numerator; end if;
l_lcm := maths.lcm (abs(p1.denominator), abs(p2.denominator));

  return l_p1 * (l_lcm / abs(p1.denominator)) > l_p2 * (l_lcm / abs(p2.denominator));

exception when others then
  util.show_error('Error in function gt.', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

function gcd       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
l_lcm denominator_ty := maths.lcm(p1.denominator, p2.denominator);
l_gcd numerator_ty;
begin
  l_gcd := maths.gcd(p1.numerator * (l_lcm / p1.denominator), p2.numerator * (l_lcm / p2.denominator));
  return fractions.normalize(to_fraction(l_gcd, l_lcm));

exception when others then
  util.show_error('Error in function gcd.', sqlerrm);
end gcd;

/*************************************************************************************************************************************************/

function lcm       (p1 in fraction_ty, p2 in fraction_ty)       return fraction_ty
is
begin
  return fractions.normalize(divide(multiply(p1,p2), gcd(p1,p2)));

exception when others then
  util.show_error('Error in function lcm.', sqlerrm);
end lcm;

/*************************************************************************************************************************************************/

procedure egyptian_fractions (p_fraction in fraction_ty)
is
l_fraction fraction_ty;
begin
if mod(p_fraction.denominator, p_fraction.numerator) = 0
then
  print(to_fraction(1, p_fraction.denominator/p_fraction.numerator));
else
  l_fraction := to_fraction(1, trunc(p_fraction.denominator/p_fraction.numerator) +1);
  print(l_fraction);
  egyptian_fractions(subtract(p_fraction, l_fraction));
end if;

exception when others then
  util.show_error('Error in procedure Egyptian_fractions.', sqlerrm);
end egyptian_fractions;
end fractions;
/

set serveroutput on size unlimited
declare
l_fraction1 fractions.fraction_ty := fractions.to_fraction(11, 137);
l_fraction2 fractions.fraction_ty := fractions.to_fraction(1, 1313);
l_fraction3 fractions.fraction_ty;
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
