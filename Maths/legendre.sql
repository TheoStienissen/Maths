
-- Legendre
-- (A/P) = 0 if mod (a,p) = 0
--       = 1 if A is QR (mod p) Quadratic Residue
--       =-1 if A is not QR (mod p)
--
create or replace function legendre (p_a in integer, p_prime in integer) return integer
is
l_legendre integer := 1;
begin
if    not maths.is_prime (p_prime)
then  raise_application_error (-20001, 'Second parameter ' || p_prime || ' is not a prime.');
elsif mod (p_a, p_prime) = 0 then l_legendre := 0;
elsif p_a = 1 then null;
elsif p_a = p_prime - 1 then if odd ((p_prime - 1) / 2) then l_legendre := -1; end if;
elsif p_a = 2 then if mod (p_prime, 8) in (3, 5) then l_legendre := -1; end if; -- mod (p_prime, 8) in (3, 5)
elsif maths.is_prime (p_a)
then
  if    p_a > p_prime
  then  return legendre (mod(p_a, p_prime), p_prime);
  elsif mod (p_prime, 4) = 1 or mod (p_a, 4) = 1
  then  return   legendre (mod (p_prime, p_a), p_a);
  else  return - legendre (mod (p_prime, p_a), p_a);
  end if;
else
  for j in (select prime from table (maths.get_pfo_rows (p_a)) where mod (occurences, 2) = 1)
  loop
    l_legendre := l_legendre * legendre (j.prime, p_prime);
  end loop;
end if;
  return l_legendre;

exception when others then
  util.show_error ('Error in function legendre. A=' || p_a ||', Prime=' || p_prime, sqlerrm);
  return null;
end legendre;
