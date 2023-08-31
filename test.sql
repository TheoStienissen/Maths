Hypothese : (g, a) = 1 ^ d / (g + na, g + ma) => d / (n - m) ?

declare
g integer := 25;
a integer := 41;
d integer;
begin
for n in -20 .. 2000
loop
  for m in n + 1 .. 200
  loop
    d := maths.gcd(g + n * a, g + m * a);
    if d != 1
	then
      if mod(abs(n - m), d) != 0
	  then
	    dbms_output.put_line('g: ' || g || '. a: ' || a || '. n: ' || n || '. m: ' || m || '. d: ' || d);
	  end if;
	end if;
  end loop;
end loop;
end;
/

-- Calculate sqrt(2);
declare 
l_low  number;
l_high number;
l_avg  number;
l_prev number;
begin 
for root in 1 .. 99
loop
  l_low  := 1;
  l_high := root;
  <<done>>
  loop 
    l_avg := (l_low + l_high) / 2;
    if l_avg * l_avg > root
    then l_high := l_avg;
    else l_low  := l_avg;
    end if;
    exit done when l_prev = l_high - l_low;
    l_prev := l_high - l_low;
  end loop;
  dbms_output.put_line (rpad(root, 4) || to_char (l_low , '90D99999999999999999999999999999999999999'));
end loop;
end;
/


