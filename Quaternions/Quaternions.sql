/*************************************************************************************************************************************************

Name        : Quaternions.sql

Last update : May 2023

Author      : Theo Stienissen

E-mail      : theo.stienissen@gmail.com

Purpose     : Calculations with quaternion numbers
			: N for whole numbers
			: Q for fractions
			: C for generic quaternion numbers
			
Prerequisites : types_pkg, fractions, maths and util error package

@C:\Users\Theo\OneDrive\Theo\Project\Maths\Quaternions\Quaternions.sql

---------------------------------
Sir William Rowan Hamilton in 1843 as a generalization of complex numbers.
  i**2 = j**2 = k**  nb2 = ijk = − 1
 q = a+bi+cj+dk
 
-- Inverse
(a+bi+cj+dk) ** -1 = (a -bi_cj_dk)/(a**2+b**2+c**2+d**2)
 
B=sqrt(b**2+d**2+d**2) I=(bi+cj+dk)/B q=A+BI
https://www.springer.com/series/136
https://link.springer.com/book/10.1007/978-3-030-56694-4
-- Calculate
I**2 = -1
 
--Eulers formula in H
e**q = e**a((cos(sqrt(B)) + I*sin(sqrt((B)))
 
e ** (i*pi/2)=i
e ** (j*pi/2)=j
e ** (k*pi/2)=k
 
 
declare
type hamilton is record (r number, i number, j number, k number);
begin 
  NULL;
end;
 
ijk
 
z1 * z2 = (a+bi+cj+dk)(e+fi+gj+hk)
 
ae - bf - cg - dh + i (af + eb + hc -dg) + j (ag - bh +ec + df) + k (ah + bg - fc + de)
 
z1 * z2= a*e - b*f - c*g- d*h + i (b*e + a*f + c*h - d*g) + j (a*g - b*h + c*e + d*f) + k (a*h + b*g - c*f + d*e)


*************************************************************************************************************************************************/

type HamiltonianN_ty     is record (r integer(36), i integer(36), j integer(36), k integer(36));
type HamiltonianQ_ty     is record (r fraction_ty, i fraction_ty, j fraction_ty, k fraction_ty);
type Hamiltonian_ty      is record (r number     , i number     , j number     , k number);

create or replace package quaternion_pkg
as
-- Print quaternion number with natural integers
procedure print  (p_number in types_pkg.HamiltonianN_ty);
-- Print quaternion number with fractions
procedure print  (p_number in types_pkg.HamiltonianQ_ty);
-- Print generic quaternion number
procedure print  (p_number in types_pkg.Hamiltonian_ty);

--Conversion to quaternion numbers
function to_quaternionN (p_r in types_pkg.integer_ty, p_i in types_pkg.integer_ty,p_im in types_pkg.integer_ty) return types_pkg.quaternionN_ty;
function to_quaternion  (p_re in types_pkg.fraction_ty, p_im in types_pkg.fraction_ty) return types_pkg.quaternionQ_ty;
function to_quaternion  (p_re_num in types_pkg.numerator_ty, p_re_denom in types_pkg.denominator_ty,
                      p_im_num in types_pkg.numerator_ty, p_im_denom in types_pkg.denominator_ty) return types_pkg.quaternionQ_ty;
function to_quaternion (p_re in number, p_im in number) return types_pkg.quaternion_ty;					  

-- Checks if equal to zero
function eq        (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty)      return boolean;
function eq0       (p1 in types_pkg.quaternionN_ty)                                   return boolean;
function eq        (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty)      return boolean;
function eq0       (p1 in types_pkg.quaternionQ_ty)                                   return boolean;

-- Greater than zero if no parameters. Self defined > function!!
function gt       (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty)       return boolean;
function gt0      (p1 in types_pkg.quaternionN_ty)                                    return boolean;
function gt       (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty)       return boolean;
function gt0      (p1 in types_pkg.quaternionQ_ty)                                    return boolean;

-- Add quaternion numbers
function add (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty;
function add (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function add (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty;
function add (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;

-- Subtract quaternion numbers
function subtract  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty;
function subtract  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function subtract  (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty;
function subtract  (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;

-- Multiply quaternion numbers
function multiply (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty;
function multiply (p1 in types_pkg.integer_ty , p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty;
function multiply (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function multiply (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty;
function multiply (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function multiply (p1 in types_pkg.integer_ty , p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;

-- Divide quaternion numers
function divide  (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function divide  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty;
function divide  (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty;
function divide  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty;

-- Absolute value. Radius. sqrt(re * re + im * im)
function abs (p in types_pkg.quaternionQ_ty) return number;
function abs (p in types_pkg.quaternionN_ty) return number;
function abs (p in types_pkg.quaternion_ty)  return number;

-- Convert Carthesian co-ordinates to polar
function carth_to_polar (p in types_pkg.quaternionQ_ty) return types_pkg.polar_ty;
function carth_to_polar (p in types_pkg.quaternionN_ty) return types_pkg.polar_ty;
function carth_to_polar (p in types_pkg.quaternion_ty)  return types_pkg.polar_ty;

-- Polar <--> Carthesian co-ordinates
function polar_to_carth (p in types_pkg.polar_ty) return types_pkg.quaternion_ty;
function polar_to_carth (p_radius in number, p_angle in number) return types_pkg.quaternion_ty;

function cpower (p_value in types_pkg.quaternionQ_ty, p_power in number) return types_pkg.polar_ty;
function cpower (p_value in types_pkg.quaternionN_ty, p_power in number) return types_pkg.polar_ty;
function cpower (p_value in types_pkg.quaternion_ty , p_power in number) return types_pkg.polar_ty;
end quaternion_pkg;
/

create or replace package body quaternion_pkg
as
--
-- Reduce value to between 0 and 2 * pi.
--
function normalise (p_value in number) return number
is
begin
if p_value between - maths.pi and maths.pi
then
  return p_value;
elsif p_value > 0
then
  return p_value - trunc (p_value/maths.pi) * maths.pi;
else
  return p_value + trunc (p_value/maths.pi) * maths.pi + maths.pi;
end if;

exception when others then
  util.show_error ('Error in function normalise', sqlerrm);
end normalise;

/*************************************************************************************************************************************************/

procedure print (p_number in types_pkg.quaternionN_ty)
is
begin
  dbms_output.put_line('Re: ' || p_number.re || '. Im: ' || p_number.im);

exception when others then
  util.show_error ('Error in procedure print for quaternion integers', sqlerrm);
end print;

/*************************************************************************************************************************************************/

procedure print (p_number in types_pkg.quaternionQ_ty)
is
begin
  dbms_output.put ('Re: ');
  fractions.print (p_number.re);
  dbms_output.put ('Im: ');
  fractions.print (p_number.im);

exception when others then
  util.show_error ('Error in procedure print for quaternion fractions', sqlerrm);
end print;

/*************************************************************************************************************************************************/

procedure print  (p_number in types_pkg.quaternion_ty)
is
begin
  dbms_output.put_line('Re: ' || to_char(p_number.re) || '. Im: ' || to_char(p_number.im));

exception when others then
  util.show_error ('Error in procedure print for quaternion numbers', sqlerrm);
end print;

/*************************************************************************************************************************************************/

function to_quaternionN (p_re in types_pkg.integer_ty, p_im in types_pkg.integer_ty) return types_pkg.quaternionN_ty
is
l_return types_pkg.quaternionN_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error ('Error in function to_quaternionN for integer numbers', sqlerrm);
end to_quaternionN;

/*************************************************************************************************************************************************/

function to_quaternion (p_re in types_pkg.fraction_ty, p_im in types_pkg.fraction_ty) return types_pkg.quaternionQ_ty
is
l_return types_pkg.quaternionQ_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error ('Error in 1-st function to_quaternion for fractions', sqlerrm);
end to_quaternion;

/*************************************************************************************************************************************************/

function to_quaternion (p_re_num in types_pkg.numerator_ty, p_re_denom in types_pkg.denominator_ty,
                     p_im_num in types_pkg.numerator_ty, p_im_denom in types_pkg.denominator_ty) return types_pkg.quaternionQ_ty					  
is
begin
  return to_quaternion (fractions.to_fraction(p_re_num, p_re_denom), fractions.to_fraction(p_im_num, p_im_denom));

exception when others then
  util.show_error ('Error in 2-nd function to_quaternion for fractions', sqlerrm);
end to_quaternion;

/*************************************************************************************************************************************************/

function to_quaternion (p_re in number, p_im in number) return types_pkg.quaternion_ty
is
l_return types_pkg.quaternion_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error ('Error in 3-rd function to_quaternion', sqlerrm);
end to_quaternion;
				  				  
/*************************************************************************************************************************************************/

function eq (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return boolean
is
begin
  return p1.re = p2.re and p1.im = p2.im;

exception when others then
  util.show_error ('Error in 1-st function eq', sqlerrm);
end eq;

/*************************************************************************************************************************************************/
--
-- is quaternion number equal to 0?
--
function eq0 (p1 in types_pkg.quaternionN_ty) return boolean
is
begin
  return p1.re = 0 and p1.im = 0;

exception when others then
  util.show_error ('Error in 1-st function eq0', sqlerrm);
end eq0;

/*************************************************************************************************************************************************/

function eq (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return boolean
is 
begin
  return fractions.eq (p1.re, p2.re) and fractions.eq (p1.im, p2.im);

exception when others then
  util.show_error ('Error in 2-nd function eqQ', sqlerrm);
end eq;

/*************************************************************************************************************************************************/
--
-- is value equal to 0?
--
function eq0 (p1 in types_pkg.quaternionQ_ty) return boolean
is 
begin
  return p1.re.numerator = 0 and p1.im.numerator = 0;

exception when others then
  util.show_error ('Error in 2-nd function eq0', sqlerrm);
end eq0;

/*************************************************************************************************************************************************/
--
-- Self defined definition!!
--
function gt (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return boolean
is
begin
  if p1.re = p2.re
  then return p1.im > p2.im;
  else return p1.re > p2.re;
  end if;

exception when others then
  util.show_error ('Error in 1-st function gt for integers', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

-- Self defined definition!!
function gt0 (p1 in types_pkg.quaternionN_ty) return boolean
is
begin
  if p1.re = 0
  then return p1.im > 0;
  else return p1.re > 0;
  end if;

exception when others then
  util.show_error ('Error in 1-st function gt0', sqlerrm);
end gt0;

/*************************************************************************************************************************************************/

function gt (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty)       return boolean
is
begin
  if fractions.eq (p1.re, p2.re)
  then return fractions.gt (p1.im, p2.im);
  else return fractions.gt (p1.re, p2.re);
  end if;

exception when others then
  util.show_error ('Error in 2-nd function gt for fractions', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

function gt0 (p1 in types_pkg.quaternionQ_ty) return boolean
is
begin
  return gt (p1, to_quaternion (0,1,0,1));

exception when others then
  util.show_error ('Error in 2-nd function gtQ0', sqlerrm);
end gt0;

/*************************************************************************************************************************************************/
--
-- Discrete values
--
function add (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty
is
begin
  return to_quaternionN (p1.re + p2.re, p1.im + p2.im);

exception when others then
  util.show_error ('Error in 1-st function add for integer values', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.add (fractions.to_fraction (p1.re, 1), p2.re), fractions.add (fractions.to_fraction (p1.im, 1), p2.im));

exception when others then
  util.show_error ('Error in 2-nd function add for integers and fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty
is
begin
  return add (p2, p1);
  
exception when others then
  util.show_error ('Error in 3-rd function add for fractions and integers', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.add (p1.re, p2.re), fractions.add (p1.im, p2.im));

exception when others then
  util.show_error ('Error in 4-th function add for fractions + fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty
is
begin
  return to_quaternionN (p1.re - p2.re, p1.im - p2.im);

exception when others then
  util.show_error ('Error in 1-st function subtract for discrete values', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.subtract (fractions.to_fraction (p1.re, 1), p2.re), fractions.subtract (fractions.to_fraction (p1.im, 1), p2.im));
  
exception when others then
  util.show_error ('Error in 2-nd function subtract for integer and fraction', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.subtract (p1.re, fractions.to_fraction(p2.re, 1)), fractions.subtract (p1.im, fractions.to_fraction(p2.im, 1)));
  
exception when others then
  util.show_error ('Error in 3-rd function subtract for fraction and integer', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.subtract (p1.re, p2.re), fractions.subtract (p1.im, p2.im));

exception when others then
  util.show_error ('Error in 4-th function subtract for 2 fractions', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function multiply  (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionN_ty
is
begin
  return to_quaternionN (p1.re * p2.re - p1.im * p2.im, p1.im * p2.re + p2.im * p1.re);

exception when others then
  util.show_error ('Error in 1-st function multiply for discrete values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply  (p1 in types_pkg.integer_ty, p2 in types_pkg.quaternionN_ty)  return types_pkg.quaternionN_ty
is
begin
  return to_quaternionN (p1 * p2.re, p1 * p2.im);

exception when others then
  util.show_error ('Error in 2-nd function multiply with integer values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- N * Q
--
function multiply (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return multiply (to_quaternion (fractions.to_fraction (p1.re, 1), fractions.to_fraction (p1.im, 1)), p2);

exception when others then
  util.show_error ('Error in 3-rd function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- Q * N
--
function multiply (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty
is
begin
  return multiply(p2, p1);

exception when others then
  util.show_error ('Error in 4-th function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- Q * Q
--
function multiply (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return to_quaternion (fractions.subtract(fractions.multiply(p1.re, p2.re), fractions.multiply(p1.im, p2.im)),
                     fractions.add(fractions.multiply(p1.im, p2.re), fractions.multiply(p2.im, p1.re)));

exception when others then
  util.show_error ('Error in 5-th function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply (p1 in types_pkg.integer_ty, p2 in types_pkg.quaternionQ_ty)  return types_pkg.quaternionQ_ty
is
begin
  return multiply (to_quaternion (fractions.to_fraction (p1, 1), fractions.to_fraction (0 , 1)), p2);

exception when others then
  util.show_error ('Error in 6-th function multiply for integers and fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- 4 times elements from Q
--
function divide (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
begin
  return multiply (p1, to_quaternion(p2.im, p2.re));
  
exception when others then
  util.show_error ('Error in 1-st function divide for 2 fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
--
-- 2 times elements from N, 2 times elements from Q
--
function divide   (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionQ_ty) return types_pkg.quaternionQ_ty
is
l_dummy1 types_pkg.quaternionQ_ty;
l_dummy2 types_pkg.quaternionQ_ty;
begin
  l_dummy1.re := fractions.to_fraction (p1.re, 1);
  l_dummy1.im := fractions.to_fraction (p1.im, 1);
  l_dummy2.re := p2.im;
  l_dummy2.im := p2.re;
  return multiply (l_dummy1, l_dummy2);

exception when others then
  util.show_error ('Error in 2-nd function divide discrete values with fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function divide (p1 in types_pkg.quaternionQ_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty
is
begin
  return multiply (p1, to_quaternion(fractions.to_fraction (p2.im, 1), fractions.to_fraction (p2.re, 1)));

exception when others then
  util.show_error ('Error in 3-rd function divide for fractions with discrete values', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

-- 4 times elements from N
function divide (p1 in types_pkg.quaternionN_ty, p2 in types_pkg.quaternionN_ty) return types_pkg.quaternionQ_ty
is
begin
  return multiply (to_quaternion (fractions.to_fraction (p1.re, 1), fractions.to_fraction (p1.im, 1)),
                   to_quaternion (fractions.to_fraction (p2.im, 1), fractions.to_fraction (p2.re, 1)));

exception when others then
  util.show_error ('Error in 4-th function divide with 2 discrete quaternion numbers', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

-- Absolute value. Radius. sqrt(re * re + im * im)
function abs (p in types_pkg.quaternionQ_ty) return number
is
l_result number;
begin
  l_result := ((p.re.numerator / p.re.denominator) * (p.re.numerator / p.re.denominator)) +
              ((p.im.numerator / p.im.denominator) * (p.im.numerator / p.im.denominator));
  return sqrt(l_result);

exception when others then
  util.show_error ('Error in 1-st function abs for fraction quaternion numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/

function abs (p in types_pkg.quaternionN_ty) return number
is
begin
  return sqrt(p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error ('Error in 2-nd function abs for integer quaternion numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/

function abs (p in types_pkg.quaternion_ty)  return number
is
begin
  return sqrt(p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error ('Error in 3-rd function abs for quaternion numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/
--
-- Not validated yet. Returns radians
--
function carth_to_polar (p in types_pkg.quaternionQ_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := quaternion.abs(p);
  if p.re.numerator = 0
  then
    if p.im.numerator * p.im.denominator > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re.numerator * p.re.denominator > 0
  then l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator));
  else l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator)) + maths.pi;
  end if; 
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for quaternion fractions', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Not validated yet. Returns radians.
--
function carth_to_polar (p in types_pkg.quaternionN_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := quaternion.abs(p);
  if p.re = 0
  then
    if p.im > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle  := atan(p.im / p.re);
  else l_return.angle  := atan(p.im / p.re) + maths.pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for quaternion integers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function carth_to_polar (p in types_pkg.quaternion_ty)  return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := quaternion.abs(p);
  if p.re = 0
  then
    if p.im > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle  := atan(p.im / p.re);
  else l_return.angle  := atan(p.im / p.re) + maths.pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for quaternion numbers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Converts polar co-ordinates to Carthesian. Not validated yet
--
function polar_to_carth (p in types_pkg.polar_ty) return types_pkg.quaternion_ty
is
l_return types_pkg.quaternion_ty;
begin
  l_return.re := p.radius * cos (p.angle);
  l_return.im := p.radius * sin (p.angle);
  return l_return;
  
exception when others then
  util.show_error ('Error in function polar_to_carth for polar co-ordinates', sqlerrm);
end polar_to_carth;

/*************************************************************************************************************************************************/
--
-- Angle to be provided in radians. Not validated yet
--
function polar_to_carth (p_radius in number, p_angle in number) return types_pkg.quaternion_ty
is
l_return types_pkg.quaternion_ty;
begin
  l_return.re := p_radius * cos (p_angle);
  l_return.im := p_radius * sin (p_angle);
  return l_return;
  
exception when others then
  util.show_error ('Error in function polar_to_carth for a radius and angle', sqlerrm);
end polar_to_carth;

/*************************************************************************************************************************************************/
--
-- Conversion radians to degrees
--
function radians_to_degrees (p_value in number) return number
is
begin
  return p_value * 57.295779513;

exception when others then
  util.show_error ('Error in function radians_to_degrees for a radian: ' || p_value, sqlerrm);
end radians_to_degrees;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.quaternionQ_ty, p_power in number) return types_pkg.polar_ty
is
l_return  types_pkg.polar_ty;
begin
  l_return.radius := power(quaternion.abs(p_value), p_power);
  l_return.angle  := 0;
  return l_return;
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.quaternionN_ty, p_power in number) return types_pkg.polar_ty
is
l_return  types_pkg.polar_ty;
begin
  l_return.radius := power(quaternion.abs(p_value), p_power);
  l_return.angle  := 0;
  return l_return;
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.quaternion_ty , p_power in number) return types_pkg.polar_ty
is
l_return  types_pkg.polar_ty;
begin
  l_return.radius := power(quaternion.abs(p_value), p_power);
  l_return.angle  := 0;
  return l_return;
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

end quaternion_pkg;
/
