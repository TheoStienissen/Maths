create table primitive_roots
( prime_no      integer
, prime         integer
, base          integer);

set serveroutput on size unlimited
declare
l_count  integer(10);
l_id     integer(10);
l_max    integer(10);
begin
select max(prime_no) into l_max from primitive_roots;
delete primitive_roots where prime_no = l_max;
for j in l_max .. maths.p_prime_tab.count
loop
  dbms_output.put_line(lpad(j, 4) || '    '  || lpad(maths.p_prime_tab(j), 6));
  for base in 2 .. maths.p_prime_tab(j) - 1
  loop
    select count(distinct diff) into l_count from
	(select maths.powermod(base, level, maths.p_prime_tab(j)) diff from dual connect by level <= maths.p_prime_tab(j) - 1);
	if l_count = maths.p_prime_tab(j) - 1
	then
	  insert into primitive_roots values(j, maths.p_prime_tab(j), base);
	  commit;
--      dbms_output.put_line(maths.p_prime_tab(j) ||  '. Base  '  || base || '. Prime no ' || j);
	end if;
  end loop;
end loop;
end;
/

select prime_no, count(*) from primitive_roots group by prime_no order by prime_no;

begin
  for j in 1 .. 50
  loop
    dbms_output.put_line(lpad(j, 4) || '    '  || lpad(maths.p_prime_tab(j), 6));
  end loop;
end;
/

---------------------------------------------------------------------------------------

-- Primitive roots only exist for prime numbers???

set serveroutput on size unlimited
declare
l_count  integer(10);
l_id     integer(10);
begin
for j in 1 .. 100
loop
  if maths.is_prime_n(j) = 0
  then
--  dbms_output.put_line(lpad(j, 4) || '    '  || lpad(maths.p_prime_tab(j), 6));
  for base in 2 .. j - 1
  loop
    select count(distinct diff) into l_count from
	(select maths.powermod(base, level, j) diff from dual connect by level <= j - 1);
	if l_count = j - 1
	then
--	  insert into primitive_roots values(j, maths.p_prime_tab(j), base);
--	  commit;
     dbms_output.put_line(j ||  '. Base  '  || base );
	end if;
  end loop;
end if;
end loop;
end;
/

-- Every prime has at least one primitive root.
-- 7 Is a primitive root modulo 22, so not only primes have primitive roots.
  
-- For all primes > 2 the number of primitive roots is even.
select prime, count(*) from primitive_roots group by prime order by prime;

-- These primitive roots come in pairs where the second permutation is the reverse / inverse of the first one.
-- Example. For prime = 11, the pairs are (2,6) and (7,8).
 PRIME  BASE PERMUTATION
------ ----- -------------------------------
    11     2 2, 4, 8, 5, 10, 9, 7, 3, 6, 1
    11     6 6, 3, 7, 9, 10, 5, 8, 4, 2, 1
    11     7 7, 5, 2, 3, 10, 4, 6, 9, 8, 1
    11     8 8, 9, 6, 4, 10, 3, 2, 5, 7, 1
	
-- If 2 is a primitive root. Phi(11) = 10. The numbers 1,3,7 and 9 are relatively prime to phi(11).
-- Then primitive roots are 2 ** 1, 2 ** 3 = 8, 2 ** 7 = 7 and 2 ** 9 = 6

-- For all primes > 5, if mod(prime, 4) = 1 then the number of primitive roots is a multiple of 4
select prime, count(*) from primitive_roots where mod(prime, 4) = 1 and prime > 5 group by prime having mod(count(*), 4) != 0;
 
-- if n is a primitive root and mod(p, 4) = 1 then p - n is also a primitive root
select p1.prime, p1.base from primitive_roots p1
   where (p1.prime, p1.base) not in (select p2.prime, p2.prime - p2.base from primitive_roots p2 where p1.prime = p2.prime)
     and mod(p1.prime, 4) =1;
 
-- if n is a primitive root and mod(p, 4) = 3 then p - n is never a primitive root.
select p1.prime, p1.base from primitive_roots p1
   where (p1.prime, p1.base) in (select p2.prime, p2.prime - p2.base from primitive_roots p2 where p1.prime = p2.prime)
     and mod(p1.prime, 4) = 3;
  
 -- No relation found yet for mod(prime, 4) = 3
select prime, count(*) from primitive_roots where mod(prime, 4) = 3 group by prime having mod(count(*), 4) != 0  order by prime;

select base from primitive_roots p1 where p1.prime = 19 order by p1.base;
-- phi(phi(19)) = phi(18) = 18 * (1 - 1/2) (1-1/3) = 6
   
-- ord(n) / phi(n). Primitive roots must be relatively prime to the modulo
-- There are phi(phi(n)) primitive roots mod(n)
-- RRS reduced residue system phi(13) = {1,5,7,11}
-- pr: 2 ** 1, 2 ** 5, 2 ** 7, 2 ** 11 

create or replace type root_ty as object (prime integer, base integer, permutation varchar2(4000));
/

create or replace type root_tab as table of root_ty;
/

-- Pipelined function gives all permutations for agiven prime
create or replace function f_primitive_perm (p_prime in integer) return root_tab pipelined
is
l_permutation varchar2(4000);
l_first       boolean;
begin
for j in (select base from primitive_roots where prime = p_prime order by base)
loop
  l_first := true;
  l_permutation := '';
  for c in 1 .. p_prime - 1
  loop
    if l_first then l_first := false; else l_permutation := l_permutation || ', '; end if;
	l_permutation := l_permutation || maths.powermod(j.base, c, p_prime);
  end loop;
  pipe row (root_ty(p_prime, j.base, l_permutation));
end loop;
end;
/

set lines 190
col prime for 99999
col base for 9999
col permutation for a100

select * from table(f_primitive_perm(11));

create or replace function f_order (p_base in integer, p_mod in integer) return integer
is
l_order   integer;
begin
if p_base <= 0 or p_mod <= 0
then raise_application_error(-20001, 'Input error. Both values must be positive.');
else
	<<done>>
	for j in 1 .. p_mod -1
	loop
	  if maths.powermod(p_base, j, p_mod) = 1
	  then l_order := j;
		   exit done;
	  end if;
	end loop;
end if;

return l_order;
end f_order;
/

select f_order(level + 1,11) from dual connect by level <= 10;
select level + 1 ind, f_order(level + 1,32) from dual connect by level <= 31;

 select prime_no,maths.phi (maths.phi (maths.get_prime (prime_no))) cnt, count(*) from primitive_roots group by prime_no order by prime_no;
 
 
 create or replace function f_n_over_2 (p_n in integer, p_k in integer) return integer result_cache
 is
 begin
 if p_k not between 0 and p_n then return null;
 elsif p_k = 0 or p_k = p_n then return 1;
 elsif p_k = 1 or p_k = p_n - 1 then return p_n;
 else return f_n_over_2 (p_n - 1, p_k - 1) + f_n_over_2 (p_n - 1, p_k);
 end if;
 end;
 /
 
-- Works for integers up to 131
 create or replace function f_n_over_prime (p_n in integer, p_k in integer) return integer result_cache
 is
 begin
 if p_k not between 0 and p_n then return null;
 elsif p_k = 0 or p_k = p_n then return 1;
 elsif p_k = 1 or p_k = p_n - 1 then return p_n;
 elsif mod(f_n_over_2 (p_n - 1, p_k - 1), p_n) = 0 and mod(f_n_over_2 (p_n - 1, p_k), p_n) = 0 then return 0;
 elsif mod(f_n_over_2 (p_n - 1, p_k - 1), p_n) = 0 then return mod(f_n_over_2 (p_n - 1, p_k), p_n);
 else return mod(f_n_over_2 (p_n - 1, p_k - 1), p_n) + mod(f_n_over_2 (p_n - 1, p_k), p_n);
 end if;
 end;
 /
 
 select f_n_over_prime(19,level) from dual connect by level <= 18;
 
 
 create or replace function f_is_prime (p_n in integer) return integer
 is
 l_max integer;
 begin
 select max(n_max) into l_max from (select f_n_over_prime(p_n,level) n_max from dual connect by level <= p_n);
 if mod(l_max, p_n) = 0 then return 1; else return 0; end if;
 end;
 /
 select f_is_prime(97) from dual;
 
 