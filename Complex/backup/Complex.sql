/*************************************************************************************************************************************************

Name        : complex.sql

Last update : August 2019

Author      : Theo stienissen

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

--Conversion to complex
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
end complex;
/

create or replace package body complex
as

procedure print (p_number in types_pkg.complexN_ty)
is
begin
  dbms_output.put_line('Re: ' || p_number.re || '. Im: ' || p_number.im);

exception when others then
  util.show_error('Error in procedure print for complex integers', sqlerrm);
end print;

/*************************************************************************************************************************************************/

procedure print (p_number in types_pkg.complexQ_ty)
is
begin
dbms_output.put('Re: ');
fractions.print(p_number.re);
/*
if mod(p_number.re.numerator, p_number.re.denominator) = 0
then
  dbms_output.put('Re: ' || to_char(p_number.re.numerator/p_number.re.denominator));
else
  dbms_output.put('Re: ' || to_char(p_number.re.numerator) || '/' || to_char(p_number.re.denominator));
end if;
 
if mod(p_number.im.numerator, p_number.im.denominator) = 0
then
  dbms_output.put_line('. Im: ' || to_char(p_number.im.numerator/p_number.im.denominator));
else
  dbms_output.put_line('. Im: ' || to_char(p_number.im.numerator) || '/' || to_char(p_number.im.denominator));
end if;
*/

exception when others then
  util.show_error('Error in procedure print for complex fractions', sqlerrm);
end print;

/*************************************************************************************************************************************************/

procedure print  (p_number in types_pkg.complex_ty)
is
begin
  dbms_output.put_line('Re: ' || to_char(p_number.re) || '. Im: ' || to_char(p_number.im));

exception when others then
  util.show_error('Error in procedure print for complex numbers', sqlerrm);
end print;

/*************************************************************************************************************************************************/

function to_complexN (p_re in types_pkg.integer_ty, p_im in types_pkg.integer_ty) return types_pkg.complexN_ty
is
l_return types_pkg.complexN_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error('Error in function to_complexN for integer numbers', sqlerrm);
end to_complexN;


/*************************************************************************************************************************************************/

function to_complex (p_re in types_pkg.fraction_ty, p_im in types_pkg.fraction_ty) return types_pkg.complexQ_ty
is
l_return types_pkg.complexQ_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error('Error in 1-st function to_complex for fractions', sqlerrm);
end to_complex;

/*************************************************************************************************************************************************/

function to_complex (p_re_num in types_pkg.numerator_ty, p_re_denom in types_pkg.denominator_ty,
                     p_im_num in types_pkg.numerator_ty, p_im_denom in types_pkg.denominator_ty) return types_pkg.complexQ_ty					  
is
begin
  return to_complex (fractions.to_fraction(p_re_num, p_re_denom), fractions.to_fraction(p_im_num, p_im_denom));

exception when others then
  util.show_error('Error in 2-nd function to_complex for fractions', sqlerrm);
end to_complex;

/*************************************************************************************************************************************************/

function to_complex (p_re in number, p_im in number) return types_pkg.complex_ty
is
l_return types_pkg.complex_ty;
begin
  l_return.re := p_re;
  l_return.im := p_im;
  return l_return;

exception when others then
  util.show_error('Error in function to_complex', sqlerrm);
end to_complex;
				  				  
/*************************************************************************************************************************************************/

function eq (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty)       return boolean
is
begin
  return p1.re = p2.re and p1.im = p2.im;

exception when others then
  util.show_error('Error in function eq', sqlerrm);
end eq;

/*************************************************************************************************************************************************/

-- is complex number equal to 0?
function eq0       (p1 in types_pkg.complexN_ty)       return boolean
is
begin
  return p1.re = 0 and p1.im = 0;

exception when others then
  util.show_error('Error in function eq0', sqlerrm);
end eq0;

/*************************************************************************************************************************************************/

function eq       (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty)       return boolean
is 
begin
  return fractions.eq(p1.re, p2.re) and fractions.eq(p1.im, p2.im);

exception when others then
  util.show_error('Error in function eqQ', sqlerrm);
end eq;

/*************************************************************************************************************************************************/
-- is value equal to 0?
function eq0       (p1 in types_pkg.complexQ_ty)      return boolean
is 
begin
  return p1.re.numerator = 0;

exception when others then
  util.show_error('Error in second function eq0', sqlerrm);
end eq0;

/*************************************************************************************************************************************************/

function gt        (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty)       return boolean
is
begin
  if p1.re = p2.re
  then return p1.im > p2.im;
  else return p1.re > p2.re;
  end if;

exception when others then
  util.show_error('Error in function gt for integers', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

function gt0      (p1 in types_pkg.complexN_ty)                                    return boolean
is
begin
  if p1.re = 0
  then return p1.im > 0;
  else return p1.re > 0;
  end if;

exception when others then
  util.show_error('Error in function gt0', sqlerrm);
end gt0;

/*************************************************************************************************************************************************/

function gt        (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty)       return boolean
is
begin
  if fractions.eq(p1.re, p2.re)
  then return fractions.gt(p1.im, p2.im);
  else return fractions.gt(p1.re, p2.re);
  end if;

exception when others then
  util.show_error('Error in function gt for fractions', sqlerrm);
end gt;

/*************************************************************************************************************************************************/

function gt0       (p1 in types_pkg.complexQ_ty)       return boolean
is
begin
  return gt(p1, to_complex(0,1,0,1));

exception when others then
  util.show_error('Error in function gtQ0', sqlerrm);
end gt0;


function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
l_return types_pkg.complexN_ty;
begin
  l_return.re := p1.re + p2.re;
  l_return.im := p1.im + p2.im;
  return l_return;

exception when others then
  util.show_error('Error in function add for integer values', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex(fractions.add(fractions.to_fraction(p1.re, 1), p2.re), fractions.add(fractions.to_fraction(p1.im, 1), p2.im));

exception when others then
  util.show_error('Error in function add for integers and fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return add(p2, p1);
  
exception when others then
  util.show_error('Error in function add for fractions and integers', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function add (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex(fractions.add(p1.re, p2.re), fractions.add(p1.im, p2.im));

exception when others then
  util.show_error('Error in function add for fractions + fractions', sqlerrm);
end add;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
l_return types_pkg.complexN_ty;
begin
  l_return.re := p1.re - p2.re;
  l_return.im := p1.im - p2.im;
  return l_return;

exception when others then
  util.show_error('Error in function subtract for discrete values', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex(fractions.subtract(fractions.to_fraction(p1.re, 1), p2.re), fractions.subtract(fractions.to_fraction(p1.im, 1), p2.im));
  
exception when others then
  util.show_error('Error in function subtract for integer and fraction', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex(fractions.subtract(p1.re, fractions.to_fraction(p2.re, 1)), fractions.subtract(p1.im, fractions.to_fraction(p2.im, 1)));
  
exception when others then
  util.show_error('Error in function subtract for fraction and integer', sqlerrm);
end subtract;

/*************************************************************************************************************************************************/

function subtract  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex(fractions.subtract(p1.re, p2.re), fractions.subtract(p1.im, p2.im));

exception when others then
  util.show_error('Error in function subtract for 2 fractions', sqlerrm);
end subtract;

function multiply  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexN_ty
is
l_return types_pkg.complexN_ty;
begin
  l_return.re := p1.re * p2.re - p1.im * p2.im;
  l_return.im := p1.im * p2.re + p2.im * p1.re;
  return l_return;

exception when others then
  util.show_error('Error in function multiply for discrete values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply  (p1 in types_pkg.integer_ty, p2 in types_pkg.complexN_ty)  return types_pkg.complexN_ty
is
l_return types_pkg.complexN_ty;
begin
  l_return.re := p1 * p2.re;
  l_return.im := p1 * p2.im;
  return l_return;

exception when others then
  util.show_error('Error in function multiply with integer values', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
l_dummy types_pkg.complexQ_ty;
begin
  l_dummy.re := fractions.to_fraction (p1.re, 1);
  l_dummy.im := fractions.to_fraction (p1.im, 1);  
  return multiply(l_dummy, p2);

exception when others then
  util.show_error('Error in function subtract for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
begin
  return multiply(p2, p1);

exception when others then
  util.show_error('Error in function subtract for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply  (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
begin
  return to_complex (fractions.subtract(fractions.multiply(p1.re, p2.re), fractions.multiply(p1.im, p2.im)),
                     fractions.add(fractions.multiply(p1.im, p2.re), fractions.multiply(p2.im, p1.re)));

exception when others then
  util.show_error('Error in function multiply for 2 fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply  (p1 in types_pkg.integer_ty, p2 in types_pkg.complexQ_ty)  return types_pkg.complexQ_ty
is
l_dummy types_pkg.complexQ_ty;
begin
  l_dummy.re := fractions.to_fraction (p1, 1);
  l_dummy.im := fractions.to_fraction (0 , 1);  
  return multiply(l_dummy, p2);

exception when others then
  util.show_error('Error in function multiply for integers and fractions', sqlerrm);
end multiply;

/*************************************************************************************************************************************************/
-- 4 times elements from Q
function divide   (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
l_dummy types_pkg.complexQ_ty;
begin
  l_dummy.re := p2.im;
  l_dummy.im := p2.re;
  return multiply (p1, l_dummy);
  
exception when others then
  util.show_error('Error in function divide for 2 fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
-- 2 times elements from N, 2 times elements from Q
function divide   (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexQ_ty) return types_pkg.complexQ_ty
is
l_dummy1 types_pkg.complexQ_ty;
l_dummy2 types_pkg.complexQ_ty;
begin
  l_dummy1.re := fractions.to_fraction (p1.re, 1);
  l_dummy1.im := fractions.to_fraction (p1.im, 1);
  l_dummy2.re := p2.im;
  l_dummy2.im := p2.re;
  return multiply (l_dummy1, l_dummy2);

exception when others then
  util.show_error('Error in function divide discrete values with fractions', sqlerrm);
end divide;

/*************************************************************************************************************************************************/

function divide   (p1 in types_pkg.complexQ_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
l_dummy types_pkg.complexQ_ty;
begin
  l_dummy.re := fractions.to_fraction (p2.im, 1);
  l_dummy.im := fractions.to_fraction (p2.re, 1);  
  return multiply (p1, l_dummy);

exception when others then
  util.show_error('Error in function divide for fractions with discrete values', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
-- 4 times elements from N
function divide  (p1 in types_pkg.complexN_ty, p2 in types_pkg.complexN_ty) return types_pkg.complexQ_ty
is
l_dummy1 types_pkg.complexQ_ty;
l_dummy2 types_pkg.complexQ_ty;
begin
  l_dummy1.re := fractions.to_fraction (p1.re, 1);
  l_dummy1.im := fractions.to_fraction (p1.im, 1);
  l_dummy2.re := fractions.to_fraction (p2.im, 1);
  l_dummy2.im := fractions.to_fraction (p2.re, 1);
  return multiply (l_dummy1, l_dummy2);

exception when others then
  util.show_error('Error in function divide with 2 discrete complex numbers', sqlerrm);
end divide;

/*************************************************************************************************************************************************/
-- Absolute value. Radius. sqrt(re * re + im * im)
function abs (p in types_pkg.complexQ_ty) return number
is
l_result number;
begin
  l_result := ((p.re.numerator / p.re.denominator) * (p.re.numerator / p.re.denominator)) +
              ((p.im.numerator / p.im.denominator) * (p.im.numerator / p.im.denominator));
  return sqrt(l_result);

exception when others then
  util.show_error('Error in function abs for fraction complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/

function abs (p in types_pkg.complexN_ty) return number
is
begin
  return sqrt(p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error('Error in function abs for integer complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/

function abs (p in types_pkg.complex_ty)  return number
is
begin
  return sqrt(p.re * p.re + p.im * p.im);
  
exception when others then
  util.show_error('Error in function abs for complex numbers', sqlerrm);
end abs;

/*************************************************************************************************************************************************/

-- Not validated yet
function carth_to_polar (p in types_pkg.complexQ_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re.numerator = 0
  then
    if p.im.numerator * p.im.denominator > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re.numerator * p.re.denominator > 0
  then l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator));
  else l_return.angle  := atan((p.im.numerator * p.re.denominator) / (p.im.denominator * p.re.numerator)) + maths.pi;
  end if; 
  return l_return;
  
exception when others then
  util.show_error('Error in function carth_to_polar for complex fractions', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/

function carth_to_polar (p in types_pkg.complexN_ty) return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re = 0
  then
    if p.im > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle  := atan(p.im / p.re);
  else l_return.angle  := atan(p.im / p.re) + maths.pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error('Error in function carth_to_polar for complex integers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/

function carth_to_polar (p in types_pkg.complex_ty)  return types_pkg.polar_ty
is
l_return types_pkg.polar_ty;
begin
  l_return.radius := complex.abs(p);
  if p.re = 0
  then
    if p.im > 0 then  l_return.angle  :=  maths.pi / 2; else  l_return.angle  :=  maths.pi * 3 / 2; end if;
  elsif p.re > 0
  then l_return.angle  := atan(p.im / p.re);
  else l_return.angle  := atan(p.im / p.re) + maths.pi;
  end if;
  return l_return;
  
exception when others then
  util.show_error('Error in function carth_to_polar for complex numbers', sqlerrm);
end carth_to_polar;

/*************************************************************************************************************************************************/

-- Converts polar co-ordinates to Carthesian
function polar_to_carth (p in types_pkg.polar_ty) return types_pkg.complex_ty
is
l_return types_pkg.complex_ty;
begin
  l_return.re := p.radius * cos (p.angle);
  l_return.im := p.radius * sin (p.angle);
  return l_return;
  
exception when others then
  util.show_error('Error in function polar_to_carth for polar co-ordinates', sqlerrm);
end polar_to_carth;

/*************************************************************************************************************************************************/

function polar_to_carth (p_radius in number, p_angle in number) return types_pkg.complex_ty
is
l_return types_pkg.complex_ty;
begin
  l_return.re := p_radius * cos (p_angle);
  l_return.im := p_radius * sin (p_angle);
  return l_return;
  
exception when others then
  util.show_error('Error in function polar_to_carth for a radius and angle', sqlerrm);
end polar_to_carth;

end complex;
/
