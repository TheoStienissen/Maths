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
set serveroutput on size unlimited
declare
type int_array is table of integer index by binary_integer;
l_rest_array int_array;
l_fraction number(10) := 16;
l_rest     number(10) := 1;
l_digit    number(1);
l_counter  number(5);
begin
dbms_output.put('0.');
for j in 0 .. l_fraction
loop
  l_rest_array(j) := -1;
end loop;
<<done>>
for j in 1 .. l_fraction
loop
  l_counter := j;
  l_rest := l_rest * 10;
  l_digit :=  trunc(l_rest/l_fraction);
  l_rest := mod(l_rest, l_fraction);
  dbms_output.put(l_digit);
  exit done when l_rest_array(l_rest) != -1 or l_rest = 0;
  l_rest_array(l_rest) := 1;
end loop;
  dbms_output.new_line;
  dbms_output.put_line(l_counter);
end;
/
