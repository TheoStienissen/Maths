doc
Program for computing the value for which the cardinality of a ** p is the lowest, possible combinations and restrictions

#


create table test
( power integer
, modulus integer
, val   integer);

-- Add new value(s) to the test table
set serveroutput on size unlimited
declare
l_power number(5) := 13;
l_first boolean;
l_id  integer;
l_prime integer;
begin
select max(power) into l_power from test;
maths.check_init;
-- First find the next lowest prime that is not in the table.
for prime in 1 .. 1000
loop
  l_prime := prime;
  exit when maths.p_prime_tab(prime) > l_power;
end loop;
-- Calculate 
for prime in l_prime .. l_prime
loop
	for modulo in 2 .. 50 * prime
	loop
	  for k in (select count(distinct maths.powermod (level - 1, maths.p_prime_tab(prime), modulo)) cnt from dual connect by level <= modulo)
	  loop
		l_first := TRUE;
		if 3 * k.cnt < modulo
		then
		  insert into test values (maths.p_prime_tab(prime), modulo, k.cnt);
		  commit;
		  end if;
	  end loop;
	end loop;
commit;
end loop;
end;
/

-- Belangrijk!!
select distinct power, modulus, val, (modulus - 1) / power/ 2 pp, mod(power, 8) modulo8 from test
  where (power, val) in (select power, min(val) val  from test group by  power)
    and power > 3
  order by power;

-- Belangrijk!! 
select pm, listagg (id, ',') within group (order by id) 
from (select level id , maths.powermod (level, 2, 20) pm from dual connect by level <= 19)
group by pm
order by pm;

drop type test_tab;
drop type test_row;

create type test_row as object ( id integer, list_count integer, int_list varchar2(4000));
/

create type test_tab as table of test_row;
/

create type test_combinations_row as object ( a integer, b integer, c integer);
/

create type test_combinations_tab as table of test_combinations_row;
/

create or replace package test_pkg
is
function f_first_prime_for_multiple (p_base in integer) return integer;

function f_different_val_cnt (p_power in integer, p_modulus in integer default null) return integer;

function f_min_modulus (p_power in integer) return integer;

function f_id_list (p_power in integer, p_modulus in integer) return test_tab pipelined;

function f_show_combinations (p_power in integer, p_modulus in integer default null) return test_combinations_tab pipelined;

function f_combinations_with_one_zero (p_power in integer, p_min_interations in integer default 2, p_max_interations in integer default 100) return  test_tab pipelined;
end test_pkg;
/ 

create or replace package body test_pkg
is
type int_array_ty is table of pls_integer index by pls_integer;

-- Find lowest k so 2 * k * p_base + 1 is prime
function f_first_prime_for_multiple (p_base in integer) return integer
is
l_prime integer(10) := 0;
begin
  maths.check_init;
  loop
    l_prime := l_prime + 1;
    exit when maths.is_prime (2 * l_prime * p_base + 1);
  end loop;
  return 2 * l_prime * p_base + 1;

exception when others then
  util.show_error ('Error in function f_first_prime_for_multiple. For base: ' || p_base || '.', sqlerrm);
end f_first_prime_for_multiple;

/*************************************************************************************************************************************************/

-- Number of distinct values given a power and a modulus. If modulus is null then return the least number
function f_different_val_cnt (p_power in integer, p_modulus in integer default null) return integer
is
l_return integer;
begin
  select count(distinct maths.powermod (level - 1, p_power, nvl (p_modulus, f_first_prime_for_multiple (p_power)))) into l_return from dual connect by level <= p_modulus;
  return l_return;

exception when others then
  util.show_error ('Error in function f_different_val_cnt. For power: ' || p_power || '. Modulus: ' || p_modulus, sqlerrm);
end f_different_val_cnt;

/*************************************************************************************************************************************************/

-- Returns the modulus with the least number of different values
function f_min_modulus (p_power in integer) return integer
is
l_dummy integer;
l_min_modulus integer := power(10,10);
begin
  select min(modulus) into l_min_modulus from test where power = p_power and val = (select min (val) from test where power = p_power);
  if l_min_modulus is null
  then
    l_min_modulus := test_pkg.f_first_prime_for_multiple (p_power);
  end if;
  return l_min_modulus;

exception when others then
  util.show_error ('Error in function f_min_modulus. For power: ' || p_power, sqlerrm);
end f_min_modulus;

/*************************************************************************************************************************************************/

-- Returns for a given power and modulus all valies for each different value
function f_id_list (p_power in integer, p_modulus in integer) return test_tab pipelined
is
begin
for j in (select pm, listagg (id, ',') within group (order by id) string_list, count(*) cnt
          from (select level - 1 id, maths.powermod (level - 1, p_power, p_modulus) pm from dual connect by level <= p_modulus)
          group by pm
          order by pm) 
loop
  pipe row (test_row (j.pm, j.cnt, j.string_list));
end loop;

exception when others then
  util.show_error ('Error in function f_id_list. For power: ' || p_power || '. Modulus: ' || p_modulus, sqlerrm);
end f_id_list;

/*************************************************************************************************************************************************/

-- Table of all possible value combinations a ** p + b ** p (mod modulus) = c ** p (mod modulus)
function f_show_combinations (p_power in integer, p_modulus in integer default null) return test_combinations_tab pipelined
is
l_int_array int_array_ty;
begin
select id bulk collect into l_int_array from table (test_pkg.f_id_list (p_power, nvl(p_modulus, test_pkg.f_first_prime_for_multiple (p_power))));
for a in 1 .. l_int_array.count
loop
  for b in 1 .. l_int_array.count
  loop
    for c in 1 .. l_int_array.count
	loop
      if mod(l_int_array (a) + l_int_array (b), p_modulus) = l_int_array (c)
	  then
	    pipe row (test_combinations_row (l_int_array (a), l_int_array (b), l_int_array (c)));
	  end if;
	end loop;
  end loop;
end loop;

exception when others then
  util.show_error ('Error in function f_show_combinations. For power: ' || p_power || '. Modulus: ' || p_modulus, sqlerrm);
end f_show_combinations;

/*************************************************************************************************************************************************/

-- Modulo values which have at least 1 zero in each row. The int_list column returns 1 if it concerns a prime
function f_combinations_with_one_zero (p_power in integer, p_min_interations in integer default 2, p_max_interations in integer default 100) return  test_tab pipelined
is
l_found_modulus boolean;
begin
for j in p_min_interations .. p_max_interations
loop
  l_found_modulus := TRUE;
  for v in (select * from table (test_pkg.f_show_combinations (p_power, j)))
  loop
    l_found_modulus := v.a = 0 or v.b = 0 or v.c = 0;
  end loop;
  if l_found_modulus
  then
    pipe row (test_row (j, maths.is_prime_n(j), null));
  end if;
end loop;

exception when others then
  util.show_error ('Error in function f_combinations_with_one_zero. For power: ' || p_power ||
                   '. Min iterations: ' || p_min_interations || '. Max iterations: ' || p_max_interations, sqlerrm);
end f_combinations_with_one_zero;
end test_pkg;
/

-- Demo:
set lines 190
col_id for 90
col a for 90
col b for 90
col c for 90
col int_list for a100
select test_pkg.f_different_val_cnt (p_power => 7, p_modulus => 29) from dual;
select test_pkg.f_different_val_cnt (p_power => 7) from dual;

select * from table (test_pkg.f_id_list(7,29));
select * from table (test_pkg.f_id_list(11,89));
-- Fermat's little theorem is hidden here...
select * from table (test_pkg.f_id_list(11,69));
-- To be investigated.
select * from table (test_pkg.f_id_list(17,18));

select test_pkg.f_first_prime_for_multiple (383) from dual;

select test_pkg.f_min_modulus (383) from dual;
select test_pkg.f_min_modulus (383) from dual;

select * from table (test_pkg..f_combinations (7, 29));

select * from table (test_pkg.f_combinations_with_one_zero(41, 2, 1500));
select * from table (test_pkg.f_combinations_with_one_zero(41,1220,1240));
select * from table (test_pkg.f_id_list(41,1231));

select 2*level*41+1 id,maths.is_prime_n(2*level*41+1) from dual connect by level <= 100;

select id from table (test_pkg.f_id_list(11,69));

declare
l_power   integer := 23;
l_modulus integer := 188;
begin
for x in (select id from table (test_pkg.f_id_list(l_power,l_modulus)))
loop
  for y in (select id from table (test_pkg.f_id_list(l_power,l_modulus)))
  loop
    dbms_output.put(to_char(maths.powermod(x.id*y.id, l_power,l_modulus), '990'));
  end loop;
  dbms_output.new_line;
  for y in (select id from table (test_pkg.f_id_list(l_power,l_modulus)))
  loop
    dbms_output.put(to_char(mod(x.id*y.id,l_modulus), '990'));
  end loop;
  dbms_output.new_line;
end loop;
end;
/

