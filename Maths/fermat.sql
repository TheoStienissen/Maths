/*
Let P be an odd number. Define: N = P - 1. If P is a prime, then N is φ(P) where φ is Eulers totient function.
Define V = {p1, p2, .. , pn} as the set of prime numbers so that p<i> - 1 divides N, so φ(p<i>) / N for each i.
Each prime in the set V should only be present once!
Then, for any non-empty subset S of V it is true, that for the product of members of set S,
call this M and for any integer A:
A ** P is congruent to A mod M. A **P ≡ A (mod M)
 

Example:
Suppose P =  13. Then φ(P) = 12 and V = { 2, 3, 5, 7, 13}.

So A ** P is congruent to A (mod M) for M in  { 2, 6, 30, 910, 2730}
A ** 13 ≡ A (mod 2730)
a ** (power -1) = 1 mod(power) ^ (a,power) = 1
a ** power = a mod(power) 
--
a ** phi(m) = 1 mod(m)

create table fermat 
( power             number(8)
, phi_power         number(8)
, max_modulus       number(8)
, power_is_prime    number(1,0));
	
create table fermat_children 
( power             number(8)
, modulus           number(8)
, phi_modulus       number(8)
, mod_modulus_power number(8)
, stage             number(1)
, modulus_is_prime  number(1));


alter table fermat add constraint fermat_pk primary key(power) using index;
alter table fermat_children add constraint fermat_children_pk primary key(power, modulus) using index;
alter table fermat_children add constraint fermat_children_fk1 foreign key (power) references fermat (power) on delete set null;
*/

-- This view contains the original data
create or replace view v_fermat_data
as
  select f.power, f.phi_power, f.power_is_prime, c.modulus, c.phi_modulus, c.mod_modulus_power, f.max_modulus
  from fermat f
  left join fermat_children c on f.power = c.power
  order by f.power, c.modulus;

create or replace view v_fermat_children
as
  select f.power, listagg(c.modulus, ',') within group (order by c.modulus) modulus_group, f.max_modulus
  from fermat f
  left join fermat_children c on f.power = c.power
  group by f.power, f.max_modulus
  order by f.power;

-- Routine to get all the modulo values less than:  power - 1
set serveroutput on size unlimited
declare
l_match      boolean;
l_max        integer := 20;
l_powermod   integer;
l_power      integer;
begin
select max(power) into l_power from fermat_tmp;
for j in (select f1.power, f1.phi_power from fermat f1 where power between l_power + 1 and l_power + 350)
loop
    for modulo in 2 .. j.power - 1
	loop
	 <<done>>
    for a in 2 .. j.power - 1
    loop
	  l_powermod := mod(maths.powermod(a, j.power, modulo) - a, modulo);
	  l_match := l_powermod = 0;
	  exit done when not l_match; 
	end loop;
	
	if l_match
	then
	-- dbms_output.put_line ('Match: Power: ' || j.power || '. Phi: ' || j.phi_power || '. Modulo:  ' || modulo);
	insert into fermat_tmp values (j.power, modulo);
	end if;
	end loop;
	commit;
end loop;
end;
/

------
mod(power,12) = 1 --> 2730 / a ** p - a
mod(power,12) = 3 --> 6  a ** p - a
mod(power,12) = 5 --> 30 / a ** p - a
mod(power,12) = 7 --> 42 / a ** p - a
mod(power,12) = 9 --> 30 / a ** p - a
mod(power,12) = 11 --> 6 / a ** p - a


