
create or replace package complex2
as
-- Print complex number with natural integers
procedure printN  (p_number in types_pkg.complexN_ty);
-- Print complex number with fractions
procedure printQ  (p_number in types_pkg.complexQ_ty);
-- Print generic complex number
procedure printC  (p_number in types_pkg.complex_ty);

end complex2;
/


create or replace package body complex
as

procedure printN (p_number in types_pkg.complexN_ty)
is
begin
  dbms_output.put_line('Re: ' || p_number.re || '. Im: ' || p_number.im);

exception when others then
  util.show_error('Error in procedure printN', sqlerrm);
end printN;

/*************************************************************************************************************************************************/

procedure printQ (p_number in types_pkg.complexQ_ty)
is
begin
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

exception when others then
  util.show_error('Error in procedure printQ', sqlerrm);
end printQ;

/*************************************************************************************************************************************************/

procedure printC  (p_number in types_pkg.complex_ty)
is
begin
  dbms_output.put_line('Re: ' || to_char(p_number.re) || '. Im: ' || to_char(p_number.im));

exception when others then
  util.show_error('Error in procedure printC', sqlerrm);
end printN;
