--SQRT
https://www.beterrekenen.nl/website/index.php?pag=258

declare
l_to_calculate  number     := 6.25;
l_result        number     := 0;
l_between       number     := 0;
l_difference    integer;
l_nr_digits     number(2, 0) := 20;
l_comma         number(2, 0) := 0;
l_digit         number(2, 0) := 0;
function        f_get_digit (p_between integer, p_difference integer) return integer
is 
l_digit1         number(2, 0) := 0;
begin
  while (10 * p_between + l_digit1 + 1) * (l_digit1 + 1) <= p_difference and l_digit1 <= 10
  loop 
    l_digit1 := l_digit1 + 1;
  end loop;
  return l_digit1;
end f_get_digit;
begin 
if    l_to_calculate < 0 then raise_application_error (-20001, 'Square root not defined for negative value: ' || l_to_calculate);
elsif l_to_calculate = 0 then l_result := 0;
else 
-- Normalise 1 < value < 100
  while l_to_calculate >= 100
  loop 
    l_to_calculate := l_to_calculate / 100;
	l_comma := l_comma + 1;
  end loop;
  while l_to_calculate < 1
  loop 
	l_to_calculate := l_to_calculate * 100;
	l_comma := l_comma - 1;
  end loop;

  l_difference := trunc(l_to_calculate);
  l_result   := f_get_digit (l_between, l_difference);  
  l_difference := l_difference - l_result * l_result;
  l_between   := 2 * l_result;
  
  l_to_calculate :=  (l_to_calculate- trunc(l_to_calculate))  * 100;
  l_difference := l_difference * 100 + trunc(l_to_calculate);
  
  for d in 1 .. l_nr_digits - 1
  loop 
    l_digit   := f_get_digit (l_between, l_difference);	
    l_result  := 10 * l_result + l_digit;

    l_difference  := l_difference - (10 * l_between + l_digit) * l_digit; 
	l_between     := 10 * l_between + 2 * l_digit;

    l_to_calculate :=  (l_to_calculate- trunc(l_to_calculate))  * 100;	
	l_difference   :=  l_difference * 100 - trunc(l_to_calculate * 100);	
  end loop;
end if;

l_result := l_result * power(10, 1 - l_nr_digits + l_comma);
dbms_output.put_line(to_char(l_result));
end;
/

create or replace function sqrt1 (p_value in number, p_precision in integer) return number 
is 
l_to_calculate  number     := p_value;
l_result        number;
l_between       number     := 0;
l_difference    integer;
l_comma         number(2, 0) := 0;
l_digit         number(2, 0) := 0;
function        f_get_digit (p_between integer, p_difference integer) return integer
is 
l_digit1         number(2, 0) := 0;
begin
  while (10 * p_between + l_digit1 + 1) * (l_digit1 + 1) <= p_difference and l_digit1 <= 10
  loop 
    l_digit1 := l_digit1 + 1;
  end loop;
  return l_digit1;
end f_get_digit;
begin 
if    l_to_calculate < 0 then raise_application_error (-20001, 'Square root not defined for negative value: ' || l_to_calculate);
elsif l_to_calculate = 0 then l_result := 0;
else 
-- Normalise 1 < value < 100
  while l_to_calculate >= 100
  loop 
    l_to_calculate := l_to_calculate / 100;
	l_comma        := l_comma + 1;
  end loop;
  while l_to_calculate < 1
  loop 
	l_to_calculate := l_to_calculate * 100;
	l_comma        := l_comma - 1;
  end loop;

  l_difference := trunc(l_to_calculate);
  l_result     := f_get_digit (l_between, l_difference);  
  l_difference := l_difference - l_result * l_result;
  l_between    := 2 * l_result; 
  
  l_to_calculate := (l_to_calculate- trunc(l_to_calculate))  * 100;
  l_difference   := l_difference * 100 + trunc(l_to_calculate);
  
  for d in 1 .. p_precision - 1
  loop 
    l_digit   := f_get_digit (l_between, l_difference);	
    l_result  := 10 * l_result + l_digit;

    l_difference  := l_difference - (10 * l_between + l_digit) * l_digit; 
	l_between     := 10 * l_between + 2 * l_digit;

    l_to_calculate :=  (l_to_calculate- trunc(l_to_calculate))  * 100;	
	l_difference   :=  l_difference * 100 - trunc(l_to_calculate * 100);	
  end loop;
end if;

  return l_result * power (10, 1 - p_precision + l_comma);
end sqrt1;
/
