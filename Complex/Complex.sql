/*************************************************************************************************************************************************

Name        : complex.sql

Last update : May 2021

Author      : Theo Stienissen

E-mail      : theo.stienissen@gmail.com

Purpose     : Calculations with complex numbers
			: N for whole numbers
			: Q for fractions
			: C for generic complex numbers
			
Prerequisites : types_pkg, fractions, maths and util error package

@C:\Users\Theo\OneDrive\Theo\Project\Maths\Complex\Complex.sql

*************************************************************************************************************************************************/

create or replace package complex
as
-- Print complex number with natural integers
procedure print  (p_number in types_pkg.complexN_ty);
-- Print complex number with fractions
procedure print  (p_number in types_pkg.complexQ_ty);
-- Print generic complex number
procedure print  (p_number in types_pkg.complex_ty);

--Conversion to complex numbers
function to_complexN (p_re in types_pkg.integer_ty, p_im in types_pkg.integer_ty) return types_pkg.complexN_ty;
function to_complex (p_re in types_pkg.fraction_ty, p_im in types_pkg.fraction_ty) return types_pkg.complexQ_ty;
function to_complex (p_re_num in types_pkg.numerator_ty, p_re_denom in types_pkg.denominator_ty,
                      p_im_num in types_pkg.numerator_ty, p_im_denom in types_pkg.denominator_ty) return types_pkg.complexQ_ty;
function to_complex (p_re in number, p_im in number) return types_pkg.complex_ty;					  

-- Checks if equal to zero
function eq        (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty)      return boolean;
function eq0       (p1 in types_pkg.complexN_ty)                                   return boolean;
function eq        (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty)      return boolean;
function eq0       (p1 in types_pkg.complexQ_ty)                                   return boolean;

-- Greater than zero if no parameters. Self defined > function!!
function gt       (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty)       return boolean;
function gt0      (p1 in types_pkg.complexN_ty)                                    return boolean;
function gt       (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty)       return boolean;
function gt0      (p1 in types_pkg.complexQ_ty)                                    return boolean;

-- Add complex numbers
function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty;
function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty;
function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;

-- Subtract complex numbers
function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty;
function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function subtract  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty;
function subtract  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;

-- Multiply complex numbers
function multiply (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty;
function multiply (p1 in types_pkg.integer_ty , p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty;
function multiply (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function multiply (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty;
function multiply (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function multiply (p1 in types_pkg.integer_ty , p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;

-- Divide complex numers
function divide  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function divide  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty;
function divide  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty;
function divide  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty;

-- Absolute value. Radius. sqrt(re * re + im * im)
function abs (p in types_pkg.complexQ_ty) return number;
function abs (p in types_pkg.complexN_ty) return number;
function abs (p in types_pkg.complex_ty)  return number;

-- Convert Carthesian co-ordinates to polar
function carth_to_polar (p in types_pkg.complexQ_ty) return types_pkg.polar_ty;
function carth_to_polar (p in types_pkg.complexN_ty) return types_pkg.polar_ty;
function carth_to_polar (p in types_pkg.complex_ty)  return types_pkg.polar_ty;

-- Polar <--> Carthesian co-ordinates
function polar_to_carth (p in types_pkg.polar_ty) return types_pkg.complex_ty;
function polar_to_carth (p_radius in number, p_angle in number) return types_pkg.complex_ty;

function cpower (p_value in types_pkg.complexQ_ty, p_power in number) return types_pkg.polar_ty;
function cpower (p_value in types_pkg.complexN_ty, p_power in number) return types_pkg.polar_ty;
function cpower (p_value in types_pkg.complex_ty , p_power in number) return types_pkg.polar_ty;
end complex;
/

create or replace package body complex
as
--
-- Reduce radian value to between 0 and 2 * pi.
--
function normalise (p_value in number) return number
is
begin
  return p_value - floor (p_value/(2 * constants_pkg.g_pi)) * 2 * constants_pkg.g_pi;

exception when others then
  util.show_error ('Error in function normalise', sqlerrm);
end normalise;

/*************************************************************************************************************************************************/
--
--
--
procedure print (p_number in types_pkg.complexN_ty)
is
begin
  dbms_output.put_line ('Re: ' || p_number.re || '. Im: ' || p_number.im);

exception when others then
  util.show_error ('Error in procedure print for complex integers', sqlerrm);
end print;

/*************************************************************************************************************************************************/
--
--
--
procedure print (p_number in types_pkg.complexQ_ty)
is
begin
  dbms_output.put ('Re: '); fractions_pkg.print (p_number.re);
  dbms_output.put ('Im: '); fractions_pkg.print (p_number.im);

exception when others then
  util.show_error ('Error in procedure print for complex fractions', sqlerrm);
end print;

/*************************************************************************************************************************************************/
--
--
--
procedure print  (p_number in types_pkg.complex_ty)
is
begin
  dbms_output.put_line ('Re: ' || to_char ( p_number.re) || '. Im: ' || to_char (p_number.im));

exception when others then
  util.show_error ('Error in procedure print for complex numbers', sqlerrm);
end print;

/*************************************************************************************************************************************************/
--
--
--
function to_complexN (p_re in types_pkg.integer_ty, p_im in types_pkg.integer_ty) return types_pkg.complexN_ty
is
begin
  return types_pkg.complexN_ty (p_re, p_im);

exception when others then
  util.show_error ('Error in function to_complexN for integer numbers', sqlerrm);
end to_complexN;

/*************************************************************************************************************************************************/
--
--
--
function to_complex (p_re in types_pkg.fraction_ty, p_im in types_pkg.fraction_ty) return types_pkg.complexQ_ty
is
begin
  return types_pkg.complexQ_ty (p_re, p_im);

exception when others then
  util.show_error ('Error in 1-st function to_complex for fractions', sqlerrm);
end to_complex;

/*************************************************************************************************************************************************/
--
--
--
function to_complex (p_re_num in types_pkg.numerator_ty, p_re_denom in types_pkg.denominator_ty,
                     p_im_num in types_pkg.numerator_ty, p_im_denom in types_pkg.denominator_ty) return types_pkg.complexQ_ty					  
is
begin
  return to_complex (fractions_pkg.to_fraction (p_re_num, p_re_denom), fractions_pkg.to_fraction (p_im_num, p_im_denom));

exception when others then
  util.show_error ('Error in 2-nd function to_complex for fractions', sqlerrm);
end to_complex;

/*************************************************************************************************************************************************/
--
--
--
function to_complex (p_re in number, p_im in number) return types_pkg.complex_ty
is
begin
  return types_pkg.complex_ty (p_re, p_im);

exception when others then
  util.show_error ('Error in 3-rd function to_complex', sqlerrm);
end to_complex;
				  				  
/*************************************************************************************************************************************************/
--
--
--
function eq (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return boolean
is
begin
  return p1.re = p2.re and p1.im = p2.im;

exception when others then
  util.show_error ('Error in 1-st function eq', sqlerrm);
end eq;

/*************************************************************************************************************************************************/
--
-- is complex number equal to 0?
--
function eq0 (p1 in types_pkg.complexN_ty) return boolean
is
begin
  return p1.re = 0 and p1.im = 0;

exception when others then
  util.show_error ('Error in 1-st function eq0', sqlerrm);
end eq0;

/*************************************************************************************************************************************************/
--
--
--
function eq (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return boolean
is 
begin
  return fractions_pkg.eq (p1.re, p2.re) and fractions_pkg.eq (p1.im, p2.im);

exception when others then
  util.show_error ('Error in 2-nd function eqQ', sqlerrm);
end eq;

/*************************************************************************************************************************************************/
--
-- is value equal to 0?
--
function eq0 (p1 in types_pkg.complexQ_ty) return boolean
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
function gt (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return boolean
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
--
-- Self defined definition!!
--
function gt0 (p1 in types_pkg.complexN_ty) return boolean
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
--
--
--
function gt (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty)       return boolean
is
begin
  if fractions_pkg.eq (p1.re, p2.re)
  then return fractions_pkg.gt (p1.im, p2.im);
  else return fractions_pkg.gt (p1.re, p2.re);
  end if;

exception when others then
  util.show_error ('Error in 2-nd function gt for fractions', sqlerrm);
end gt;

/*************************************************************************************************************************************************/
--
--
--
function gt0 (p1 in types_pkg.complexQ_ty) return boolean
is
begin
  return gt (p1, to_complex (0,1,0,1));

exception when others then
  util.show_error ('Error in 2-nd function gtQ0', sqlerrm);
end gt0;

/*************************************************************************************************************************************************/
--
-- Discrete values
--
function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
begin
  return to_complexN (p1.re + p2.re, p1.im + p2.im);

exception when others then
  util.show_error ('Error in 1-st function add for integer values', sqlerrm);
end add;

/*************************************************************************************************************************************************/
--
--
--
function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.add (fractions_pkg.to_fraction (p1.re, 1), p2.re), fractions_pkg.add (fractions_pkg.to_fraction (p1.im, 1), p2.im));

exception when others then
  util.show_error ('Error in 2-nd function add for integers and fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/
--
--
--
function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return add (p2, p1);
  
exception when others then
  util.show_error ('Error in 3-rd function add for fractions and integers', sqlerrm);
end add;

/*************************************************************************************************************************************************/
--
--
--
function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.add (p1.re, p2.re), fractions_pkg.add (p1.im, p2.im));

exception when others then
  util.show_error ('Error in 4-th function add for fractions + fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/
--
--
--
function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
begin
  return to_complexN (p1.re - p2.re, p1.im - p2.im);

exception when others then
  util.show_error ('Error in 1-st function subtract for discrete values', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/
--
--
--
function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.subtract (fractions_pkg.to_fraction (p1.re, 1), p2.re), fractions_pkg.subtract (fractions_pkg.to_fraction (p1.im, 1), p2.im));
  
exception when others then
  util.show_error ('Error in 2-nd function subtract for integer and fraction', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/
--
--
--
function subtract (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.subtract (p1.re, fractions_pkg.to_fraction(p2.re, 1)), fractions_pkg.subtract (p1.im, fractions_pkg.to_fraction(p2.im, 1)));
  
exception when others then
  util.show_error ('Error in 3-rd function subtract for fraction and integer', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/
--
--
--
function subtract (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.subtract (p1.re, p2.re), fractions_pkg.subtract (p1.im, p2.im));

exception when others then
  util.show_error ('Error in 4-th function subtract for 2 fractions', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/
--
--
--
function multiply  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
begin
  return to_complexN (p1.re * p2.re - p1.im * p2.im, p1.im * p2.re + p2.im * p1.re);

exception when others then
  util.show_error ('Error in 1-st function multiply for discrete values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
--
--
function multiply  (p1 in types_pkg.integer_ty, p2 in types_pkg.complexN_ty)  return types_pkg.complexN_ty
is
begin
  return to_complexN (p1 * p2.re, p1 * p2.im);

exception when others then
  util.show_error ('Error in 2-nd function multiply with integer values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- N * Q
--
function multiply (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (to_complex (fractions_pkg.to_fraction (p1.re, 1), fractions_pkg.to_fraction (p1.im, 1)), p2);

exception when others then
  util.show_error ('Error in 3-rd function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- Q * N
--
function multiply (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (p2, p1);

exception when others then
  util.show_error ('Error in 4-th function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- Q * Q
--
function multiply (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions_pkg.subtract(fractions_pkg.multiply (p1.re, p2.re), fractions_pkg.multiply (p1.im, p2.im)),
                     fractions_pkg.add (fractions_pkg.multiply (p1.im, p2.re), fractions_pkg.multiply (p2.im, p1.re)));

exception when others then
  util.show_error ('Error in 5-th function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
--
--
function multiply (p1 in types_pkg.integer_ty, p2 in types_pkg.complexQ_ty)  return types_pkg.complexQ_ty
is
begin
  return multiply (to_complex (fractions_pkg.to_fraction (p1, 1), fractions_pkg.to_fraction (0 , 1)), p2);

exception when others then
  util.show_error ('Error in 6-th function multiply for integers and fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
--
-- 4 times elements from Q
--
function divide (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (p1, to_complex(p2.im, p2.re));
  
exception when others then
  util.show_error ('Error in 1-st function divide for 2 fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
--
-- 2 times elements from N, 2 times elements from Q
--
function divide   (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (types_pkg.complexQ_ty (fractions_pkg.to_fraction (p1.re, 1), fractions_pkg.to_fraction (p1.im, 1)), types_pkg.complexQ_ty (p2.im, p2.re));

exception when others then
  util.show_error ('Error in 2-nd function divide discrete values with fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
--
--
--
function divide (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (p1, to_complex (fractions_pkg.to_fraction (p2.im, 1), fractions_pkg.to_fraction (p2.re, 1)));

exception when others then
  util.show_error ('Error in 3-rd function divide for fractions with discrete values', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
--
-- 4 times elements from N
--
function divide (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return multiply (to_complex (fractions_pkg.to_fraction (p1.re, 1), fractions_pkg.to_fraction (p1.im, 1)),
                   to_complex (fractions_pkg.to_fraction (p2.im, 1), fractions_pkg.to_fraction (p2.re, 1)));

exception when others then
  util.show_error ('Error in 4-th function divide with 2 discrete complex numbers', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
--
-- Absolute value. Radius. sqrt(re * re + im * im)
--
function abs (p in types_pkg.complexQ_ty) return number
is
l_result number;
begin
  l_result := ((p.re.numerator / p.re.denominator) * (p.re.numerator / p.re.denominator)) +
              ((p.im.numerator / p.im.denominator) * (p.im.numerator / p.im.denominator));
  return sqrt (l_result);

exception when others then
  util.show_error ('Error in 1-st function abs for fraction complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/
--
-- Absolute value. Radius. sqrt(re * re + im * im)
--
function abs (p in types_pkg.complexN_ty) return number
is
begin
  return sqrt (p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error ('Error in 2-nd function abs for integer complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/
--
-- Absolute value. Radius. sqrt(re * re + im * im)
--
function abs (p in types_pkg.complex_ty)  return number
is
begin
  return sqrt (p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error ('Error in 3-rd function abs for complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/
--
-- Not validated yet. Returns radians
--
function carth_to_polar (p in types_pkg.complexQ_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re.numerator = 0
  then
    if p.im.numerator * p.im.denominator > 0 then  l_return.angle  :=  constants_pkg.g_pi / 2; else  l_return.angle  :=  constants_pkg.g_pi * 3 / 2; end if;
  elsif p.re.numerator * p.re.denominator > 0
  then l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator));
  else l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator)) + constants_pkg.g_pi;
  end if; 
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for complex fractions', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Not validated yet. Returns radians.
--
function carth_to_polar (p in types_pkg.complexN_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re = 0
  then
    if p.im > 0 then l_return.angle  :=  constants_pkg.g_pi / 2; else  l_return.angle  :=  constants_pkg.g_pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle  := atan (p.im / p.re);
  else l_return.angle  := atan (p.im / p.re) + constants_pkg.g_pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for complex integers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function carth_to_polar (p in types_pkg.complex_ty)  return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re = 0
  then
    if p.im > 0 then l_return.angle :=  constants_pkg.g_pi / 2; else l_return.angle  :=  constants_pkg.g_pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle := atan (p.im / p.re);
  else l_return.angle := atan (p.im / p.re) + constants_pkg.g_pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error ('Error in function carth_to_polar for complex numbers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/
--
-- Converts polar co-ordinates to Carthesian. Not validated yet
--
function polar_to_carth (p in types_pkg.polar_ty) return types_pkg.complex_ty
is
begin
  return types_pkg.complex_ty (p.radius * cos (p.angle), p.radius * sin (p.angle));
  
exception when others then
  util.show_error ('Error in function polar_to_carth for polar co-ordinates', sqlerrm);
end polar_to_carth;

/*************************************************************************************************************************************************/
--
-- Angle to be provided in radians. Not validated yet
--
function polar_to_carth (p_radius in number, p_angle in number) return types_pkg.complex_ty
is
begin
  return types_pkg.complex_ty (p_radius * cos (p_angle), p_radius * sin (p_angle));
  
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
  return p_value * 180 / constants_pkg.g_pi;

exception when others then
  util.show_error ('Error in function radians_to_degrees for a radian: ' || p_value, sqlerrm);
end radians_to_degrees;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.complexQ_ty, p_power in number) return types_pkg.polar_ty
is
begin
  return types_pkg.polar_ty (power(complex.abs(p_value), p_power), 0);
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.complexN_ty, p_power in number) return types_pkg.polar_ty
is
begin
  return types_pkg.polar_ty (power (complex.abs (p_value), p_power), 0);
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

/*************************************************************************************************************************************************/
--
-- Not validated yet
--
function cpower (p_value in types_pkg.complex_ty , p_power in number) return types_pkg.polar_ty
is
begin
  return types_pkg.polar_ty (power (complex.abs (p_value), p_power), 0);
  
exception when others then
  util.show_error ('Error in function cpower', sqlerrm);
end cpower;

end complex;
/
