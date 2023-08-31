declare
l_first    integer;
l_second   integer;
l_gcd integer;
l_div integer := 5;
begin
for j in 1 .. 50
loop
  l_first  := power (j,13) - j;
  l_second := power (j + l_div,13) - j - l_div;
  l_gcd    := maths.gcd (l_first,l_second);
  dbms_output.put_line ('First: '  || j || '. Gcd:  ' || l_gcd || '. Div:  ' || l_gcd/2730);
end loop;
end;
/

μ(n) = 1 if n is a square-free positive integer with an even number of prime factors.
μ(n) = −1 if n is a square-free positive integer with an odd number of prime factors.
μ(n) = 0 if n has a squared prime factor.


function mu (p_integer in integer) return integer
is
begin
l_primes   integer;
l_max      integer;
begin
select count(prime), max(occurences) into l_primes, l_max from table(maths.get_pfo_rows(p_integer));
if l_max >= 2  then return 0;
elsif maths.odd (l_primes) then return -1;
else return 1;
end if;

select prime from table(maths.get_pfo_rows(p_integer)) where prime <= 13 and mod (p_integer -1, prime -1) = 0