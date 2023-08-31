/*
	Author  : Theo Stienissen
	Contact	: theo.stienissen@gmail.com
	Date	: December 2021
	Purpose	: Cantor approach for continuous funtions: f(x) = l_result
	          Either l_lower_bound or l_upper_bound must be less than l_result and the other one greater than l_result
	          The function and the number of iterations can be adjusted as requred.

*/

set serveroutput on size unlimited
declare
l_count integer(4)   := 200;
l_lower_bound number := 30;
l_upper_bound number := 3;
l_result number      := 0;
l_middle number;
l_increasing boolean;
-- Middle
function halfway (p_lower_bound in number, p_upper_bound in number) return number
is
begin
  return (p_lower_bound + p_upper_bound) / 2;
end halfway;
--
function f (p_x in number) return number
is 
begin
-- Change function description here!!
-- E.g.: (x - 3) * (x - 4)
  return p_x ** 2 - 7 * p_x + 12;
end f;
--
procedure print_result
is
begin
  if l_lower_bound < l_upper_bound
  then
    dbms_output.put_line ('Low:  ' || to_char (l_lower_bound, '990D999999999999999999999999999999999999999'));
    dbms_output.put_line ('High: ' || to_char (l_upper_bound, '990D999999999999999999999999999999999999999'));
  else 
    dbms_output.put_line ('Low:  ' || to_char (l_upper_bound, '990D999999999999999999999999999999999999999'));
    dbms_output.put_line ('High: ' || to_char (l_lower_bound, '990D999999999999999999999999999999999999999'));
  end if;
  dbms_output.put_line ('Diff: ' || to_char (abs (l_upper_bound - l_lower_bound), '990D999999999999999999999999999999999999999'));
end print_result;

-- Validate start data
begin
if    f (l_lower_bound) < l_result and f (l_upper_bound) < l_result
then  raise_application_error (-20001, 'Both boundaries have values that are lower than ' || l_result);
elsif f (l_lower_bound) > l_result and f (l_upper_bound) > l_result
then  raise_application_error (-20002, 'Both boundaries have values that are higher than ' || l_result);
else  l_increasing := f (l_lower_bound) < f (l_upper_bound);
end if;

<<done>>
for j in 1 .. l_count
loop
  l_middle := halfway (l_lower_bound, l_upper_bound);
  if   f (l_middle) > l_result
  then if l_increasing then l_upper_bound := l_middle; else l_lower_bound := l_middle; end if;
  else if l_increasing then l_lower_bound := l_middle; else l_upper_bound := l_middle; end if;
  end if;
  exit done when l_upper_bound = l_lower_bound;
end loop;
print_result;
end;
/
