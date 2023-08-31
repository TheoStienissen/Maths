declare
l_string varchar2(400) := '&1';
l_seq    number;
l_int    fast_int.p_int_ty;
begin
l_int := fast_int.string_to_int(l_string);
l_seq := fast_int.save_number(l_int);
fast_int.print(l_int);
end;
/

declare
l_int    fast_int.p_int_ty;
begin
for j in (select distinct id from fast_int_tbl order by 1)
loop
  l_int := fast_int.load_number(j.id);
  dbms_output.put_line('Length: '|| fast_int.get_length(l_int) || '.  Seq: ' || to_char(j.id));
  fast_int.print(l_int,10);
end loop;
end;
/

exec fast_int.print(fast_int.fsqrt(10,35))

-- After how many digits will the sequence in a fraction repeat itself?
-- Max is (fraction - 1)
--
declare
type int_array is table of integer index by binary_integer;
l_rest_array int_array;
l_fraction number(10) := 6;
l_rest     number(10) := 1;
l_digit    number(1);
l_counter  number(10) := -1;
l_leading  boolean := true;
begin
if maths.gcd(l_fraction, 10) = 1
then
  <<done1>>
  for r in 1 .. l_fraction
  loop
    if maths.powermod (10, r, l_fraction) = 1
    then
      dbms_output.put_line('First cycle: ' || r);
      exit done1;
    end if;
  end loop;
else
  dbms_output.put('0.');
  for j in 0 .. l_fraction
  loop
    l_rest_array(j) := -1;
  end loop;
  <<done2>>
  for j in 1 .. l_fraction
  loop
    l_rest := l_rest * 10;
    l_digit :=  trunc(l_rest/l_fraction);
	if l_leading
	then l_leading := l_digit != 0;
	else l_counter := l_counter + 1;
	end if;
    l_rest := mod(l_rest, l_fraction);
    dbms_output.put(l_digit);
    if mod(j,200) = 0 then  dbms_output.new_line; end if;
    exit done2 when l_rest_array(l_rest) != -1 or l_rest = 0;
    l_rest_array(l_rest) := 1;
  end loop;
  dbms_output.new_line;
  dbms_output.put_line('Second cycle:  ' || l_counter);
end if;  
end;
/
