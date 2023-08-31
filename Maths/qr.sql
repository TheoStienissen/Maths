-- Quadratic residue
-- p = 11 - q = 13
create table tmp (prime integer, pwer integer, ind integer, cnt integer);
set serveroutput on size unlimited
declare
type int_array_ty is table of integer index by binary_integer;
l_array             int_array_ty;
l_power integer(5)  := 5;
l_count integer     := 0;
l_loop_ctr  integer := 0;
begin
  maths.check_init;
  for j in 1 .. l_power
  loop
    l_array(j) := 0;
  end loop;

  for j in 5111 .. 5111 -- maths.p_prime_tab.count
  loop
	  for p in (select qr, count(*) cnt, listagg (id, '; ') within group (order by id) QR_list
		        from (select maths.powermod(level, l_power, maths.p_prime_tab(j)) qr, level id from dual
                      connect by level <  maths.p_prime_tab(j)) group by qr order by qr)
	  loop
		  dbms_output.put_line(maths.p_prime_tab(j) || ' :  ' || l_power || ' :  ' || p.cnt || ' :  ' || p.qr  || ' :  ' || p.QR_list);
		  l_count := l_count + p.cnt;
		  l_loop_ctr := l_loop_ctr + 1;
		  l_array(p.cnt) := l_array(p.cnt) + 1;
	  end loop;
  dbms_output.put_line('Count: ' || l_count || '. Loop ctr:  ' || l_loop_ctr);
  end loop;

  for j in 1 .. l_power
  loop
    if l_array(j) != 0
	then
	  dbms_output.put_line('Iteration: ' || j || ', Count: ' || l_array(j));
	end if;
  end loop;
end;
/

========================================


declare
type int_array_ty is table of integer index by binary_integer;
l_array             int_array_ty;
l_power integer(5)  := 16;
l_prime integer(10) := 71;  --maths.random_prime;
l_count integer     := 0;
l_loop_ctr  integer := 0;
begin
  maths.check_init;
  dbms_output.put_line(l_prime);

for j in 1 .. l_prime - 1
loop
  dbms_output.put_line (l_prime || ' :  ' || j || ' :  ' || maths.powermod(j, l_power, l_prime) || ' :  ' || maths.powermod(j, l_power -1, l_power)
                            || ' :  ' || maths.powermod(j, l_prime -1 , l_prime));
--		  l_array(p.cnt) := l_array(p.cnt) + 1;
end loop;
--  dbms_output.put_line('Count: ' || l_count || '. Loop ctr:  ' || l_loop_ctr);

/*
  for j in 1 .. l_power
  loop
    if l_array(j) != 0
	then
	  dbms_output.put_line('Iteration: ' || j || ', Count: ' || l_array(j));
	end if;
  end loop;
  */
end;
/



select maths.legendre(level, 54851), count(*) from dual group by maths.legendre(level, 54851)  connect by level <= 54850;
