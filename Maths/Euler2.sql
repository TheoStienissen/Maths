/*
  Playing with modulo functions and totients

*/
create or replace package euler_pkg
is 
function special_mod (p_prime in integer)       return integer;

function special_mod2 (p_prime in integer)      return types_pkg.fast_int_ty;

function special_mod_count (p_prime in integer) return integer;

function totient_divisor (p_phi in integer)     return integer;

function totient_divisor2 (p_phi in integer)    return types_pkg.fast_int_ty;

function totient_divisor3 (p_phi in integer)    return integer;

function total_mod  (p_phi in integer)          return integer;

procedure add_primes (io_array in out t_field_table, p_totient in integer);

procedure traverse (in_array in t_field_table, io_result_array in out t_field_table, in_depth in integer);

procedure validate_totient (in_depth in integer, in_array in t_field_table, io_result_array in out t_field_table, in_product in integer, in_phi in integer);

function inverse_totient (in_phi in integer) return integer_tab pipelined;
end euler_pkg;
/




create or replace package body euler_pkg
is
--
-- n ** 13 - n = 0 mod 2730. This routine calculates the mod factor.
-- Uses all primes p where p-1 divides the master p-1
--
function special_mod (p_prime in integer) return integer
is
l_product integer := 1;
l_phi     integer := p_prime - 1;
begin
  if maths.is_prime (p_prime)
  then
    for p in 1 .. maths.pi (p_prime)
    loop
      if mod (l_phi, maths.g_prime_tab (p) - 1) = 0
      then l_product := l_product * maths.g_prime_tab (p);
      end if;
    end loop;
  else
    raise_application_error (-20001, 'Not a prime: ' || p_prime);
  end if;
  return l_product;

exception when others then
  util.show_error ('Error in function special_mod for prime: ' || p_prime || '.', sqlerrm);
  return null;
end special_mod;

/*************************************************************************************************************************************************/

--
-- n ** 13 - n = 0 mod 2730. This routine calculates the mod factor for somewhat bigger numbers
--
function special_mod2 (p_prime in integer) return types_pkg.fast_int_ty
is
l_product types_pkg.fast_int_ty := fast_int_pkg.int_to_fast_int (1);
l_phi     integer := p_prime - 1;
begin
  if maths.is_prime (p_prime)
  then
    for p in 1 .. maths.pi (p_prime)
    loop
      if mod (l_phi, maths.g_prime_tab (p) - 1) = 0
      then
        l_product := fast_int_pkg.multiply (l_product, fast_int_pkg.int_to_fast_int (maths.g_prime_tab (p)));
      end if;
    end loop;
  else
    raise_application_error (-20001, 'Not a prime: ' || p_prime);
  end if;
  return l_product;

exception when others then
  util.show_error ('Error in function special_mod2 for prime: ' || p_prime || '.', sqlerrm);
  return l_product;
end special_mod2;

/*************************************************************************************************************************************************/

--
-- n ** 13 - n = 0 mod 2730. This routine calculates the number of primes that build the factor
--
function special_mod_count (p_prime in integer) return integer
is
l_count integer := 0;
l_phi   integer := p_prime - 1;
begin
  if maths.is_prime (p_prime)
  then
    for p in 1 .. maths.pi (p_prime)
    loop
      if mod (l_phi, maths.g_prime_tab (p) - 1) = 0 then l_count := l_count + 1; end if;
    end loop;
  else
    raise_application_error (-20001, 'Not a prime: ' || p_prime);
  end if;
  return l_count;

exception when others then
  util.show_error ('Error in function special_mod_count for prime: ' || p_prime || '.', sqlerrm);
  return null;
end special_mod_count;

/*************************************************************************************************************************************************/

--
-- The totient function is not 1-to-1 or onto. Many domain values can belong to each totient value.
-- This means, a ** phi(n) is conguent to each of the n-values modulo n if (a, n) = 1
-- This function calculates for each phi (n) the congruency with 1 when relatively prime.
--
function totient_divisor (p_phi in integer) return integer
is
type        pfo_row_ty  is table of integer index by pls_integer;
l_product   integer := 1;
l_count     integer := 0;
l_pfo_row   pfo_row_ty;
l_found     boolean;
begin
  l_pfo_row.delete;
  for j in (select nr id from table (inverse_totient (p_phi)))
  loop
    for p in (select prime, occurences from table (maths.get_pfo_rows (j.id)))
    loop  
      l_found := false;
      <<found>>
      for u in 1 .. l_count
      loop
        l_found := l_pfo_row (u) = p.prime;
		exit when l_found;
      end loop;
      if not l_found
      then	
       l_count := l_count + 1;	
       l_pfo_row (l_count) := p.prime;
	   l_product := l_product * p.prime;
      end if;
    end loop;
  end loop;
  return l_product;

exception when others then
  util.show_error ('Error in function totient_divisor for totient: ' || p_phi || '.', sqlerrm);
  return null;
end totient_divisor;

/*************************************************************************************************************************************************/

--
-- Similar to totient_divisor, but for somewhat bigger results
--
function totient_divisor2 (p_phi in integer) return types_pkg.fast_int_ty
is
type        pfo_ty      is record (prime integer, occurences integer);
type        pfo_row_ty  is table of pfo_ty index by pls_integer;
l_product   types_pkg.fast_int_ty := fast_int_pkg.int_to_fast_int (1);
l_count     integer := 0;
l_pfo_row   pfo_row_ty;
l_found     boolean;
begin
  l_pfo_row.delete;
  for j in (select nr id from table (inverse_totient (p_phi)))
  loop
    for p in (select prime, occurences from table (maths.get_pfo_rows (j.id)))
    loop  
      l_found := false;
      <<found>>
      for u in 1 .. l_count
      loop
        l_found := l_pfo_row (u).prime = p.prime;
    	if l_found then l_pfo_row (u).occurences := greatest (l_pfo_row (u).occurences, p.occurences); exit found; end if;
      end loop;
      if not l_found
      then	
       l_count := l_count + 1;	
       l_pfo_row (l_count) := pfo_ty (prime => p.prime, occurences => p.occurences);
      end if;
    end loop;
  end loop;
  
  -- Find the max divisor for this totient value
  for p in 1 .. l_count
  loop
    l_product := fast_int_pkg.multiply (l_product, fast_int_pkg.int_to_fast_int (power (l_pfo_row (p).prime, l_pfo_row (p).occurences)));
  end loop;  
  return l_product;

exception when others then
  util.show_error ('Error in function totient_divisor2 for totient: ' || p_phi || '.', sqlerrm);
  return fast_int_pkg.int_to_fast_int (0);
end totient_divisor2;

/*************************************************************************************************************************************************/

--
-- Similar to totient_divisor, maxed out. To be investigated why it is wrong.
--
function totient_divisor3 (p_phi in integer)     return integer
is
type        pfo_ty      is record (prime integer, occurences integer);
type        pfo_row_ty  is table of pfo_ty index by pls_integer;
l_product   integer := 1;
l_count     integer := 0;
l_pfo_row   pfo_row_ty;
l_found     boolean;
begin
  l_pfo_row.delete;
  for j in (select nr id from table (inverse_totient (p_phi)))
  loop
    for p in (select prime, occurences from table (maths.get_pfo_rows (j.id)))
    loop  
      l_found := false;
      <<found>>
      for u in 1 .. l_count
      loop
        l_found := l_pfo_row (u).prime = p.prime;
    	if l_found then l_pfo_row (u).occurences := greatest (l_pfo_row (u).occurences, p.occurences); exit found; end if;
      end loop;
      if not l_found
      then	
       l_count := l_count + 1;	
       l_pfo_row (l_count) := pfo_ty (prime => p.prime, occurences => p.occurences);
      end if;
    end loop;
  end loop;
  
  -- Find the max divisor for this totient value
  for p in 1 .. l_count
  loop
    l_product := l_product * power (l_pfo_row (p).prime, l_pfo_row (p).occurences);
  end loop;  
  return l_product;

exception when others then
  util.show_error ('Error in function totient_divisor3 for totient: ' || p_phi || '.', sqlerrm);
  return null;
end totient_divisor3;

/*************************************************************************************************************************************************/

--
-- Similar to totient_divisor, but for somewhat bigger results
--
function total_mod  (p_phi in integer)          return integer
is
l_total_mod  integer;
begin
  if maths.is_prime (p_phi + 1)
  then l_total_mod := maths.lcm (euler_pkg.special_mod (p_phi + 1), euler_pkg.totient_divisor (p_phi));
  else l_total_mod := euler_pkg.totient_divisor (p_phi);
  end if;
  return l_total_mod;

exception when others then
  util.show_error ('Error in function total_mod for totient: ' || p_phi || '.', sqlerrm);
  return null;
end total_mod;

/*************************************************************************************************************************************************/
--
-- Check for all divisors if d + 1 is a prime and adds these to an array
--
procedure add_primes (io_array in out t_field_table, p_totient in integer)
is
begin
  for j in (select nr from table (maths.number_of_divisors (p_totient)) where maths.is_prime_n (nr + 1) = 1)
  loop
    collections_pkg.add_array (io_array, j.nr + 1);
  end loop;
  
exception when others
then
  util.show_error ('Error in procedure add_primes for totient: ' || p_totient, sqlerrm);  
end add_primes;

/*******************************************************************************************************************/
--
-- Calculate all possible combinations and corresponding totients of the inverse of the totient function
--
procedure traverse (in_array in t_field_table, io_result_array in out t_field_table, in_depth in integer)
is
l_product  integer;
l_field1   integer;
begin
  l_field1  := in_array (in_depth).field1;
  l_product := l_field1;
  collections_pkg.add_array (io_result_array, l_field1, 0);
  for j in 1 .. in_array (in_depth).field2 + 1
  loop
    l_product := l_product * l_field1;
	collections_pkg.add_array (io_result_array, l_product);
	if in_depth < in_array.count
    then
      traverse (in_array, io_result_array, in_depth + 1);
    end if;
  end loop;

exception when others
then
  util.show_error ('Error in procedure traverse', sqlerrm);  
end traverse;

/*******************************************************************************************************************/

--
-- Check all possible combinations that can contribute to the totient. Needed to calculate the inverse.
--
procedure validate_totient (in_depth in integer, in_array in t_field_table, io_result_array in out t_field_table, in_product in integer, in_phi in integer)
is
begin
  if maths.phi (in_product) = in_phi
  then
    collections_pkg.add_array (io_result_array, in_product, 0, 0);      
  elsif maths.phi (in_product) < in_phi
  then
    for j in in_depth .. in_array.count
	loop
      validate_totient (in_depth + 1, in_array, io_result_array, in_product * in_array (j).field1, in_phi);
    end loop;
  end if;

exception when others
then
  util.show_error ('Error in procedure validate_totient', sqlerrm);  
end validate_totient;

/*******************************************************************************************************************/
--
-- The inverse function of totient function phi
--
function inverse_totient (in_phi in integer) return integer_tab pipelined
is
l_divisor_array   t_field_table := t_field_table ();
l_piece        t_field_table := t_field_table ();
l_return        t_field_table := t_field_table ();
l_index         integer;
begin 
  for j in (select prime, occurences from table (maths.get_pfo_rows (in_phi)))
  loop
    collections_pkg.add_array (l_divisor_array, j.prime, j.occurences, 0);
  end loop;
  add_primes (l_piece, in_phi);
  traverse (l_divisor_array, l_piece, 1);
  l_piece   := collections_pkg.sort_unique (l_piece);
  validate_totient (1, l_piece, l_return, 1, in_phi);
  l_return   := collections_pkg.sort_unique (l_return);
  l_index    := l_return.first;
  while l_index is not null
  loop
    pipe row (integer_row (l_return (l_index).field1));
	l_index := l_return.next (l_index);
  end loop;
end inverse_totient; 
end euler_pkg;
/



set serveroutput on size unlimited

-- Determine for which primes n ** p - n is always divisible by a number bigger than 100 digits.
-- 2730 / n ** 13 - n
-- Example: n ** 604801 - n is always divisable by this number with 213 digits:
-- 731338863298910160211889582138779985970590913594108709983795302345406655722535886591555644290825489320482549577823903081026350693447528700094097240169875680569543452934586009983
-- 739787467070105965182768408319729810
declare
l_phi     integer;
l_product types_pkg.fast_int_ty;
l_length  integer;
begin
maths.check_init;
for j in 1 .. 20000 -- max value is the total number of primes in memory
loop
  l_product := euler_pkg.special_mod2 (maths.g_prime_tab (j));
  l_length  := fast_int_pkg.get_length (l_product);
  if l_length >= 100
  then
--    dbms_output.put ('P:  ' || maths.g_prime_tab (j) || '.  CNT: ' || euler_pkg.special_mod_count (maths.g_prime_tab (j)) || '.  Length: ' || l_length);
    dbms_output.put ('P:  ' || maths.g_prime_tab (j) || '.  Length: ' || l_length);
    fast_int_pkg.print (l_product, 10);
  end if;
end loop;
end;
/

-- Demo
declare
l_result types_pkg.fast_int_ty;
begin
  l_result :=  euler_pkg.totient_divisor2 (80640);
  fast_int_pkg.print (l_result, 10);
end;
/

select maths.lcm(euler_pkg.special_mod (13), euler_pkg.totient_divisor (12)) from dual;

-- Determine for which primes n ** p - n is always divisible by a number bigger than 100 digits.
-- 2730 / n ** 13 - n
-- Example: n ** 604801 - n is always divisable by this number with 213 digits:
-- 731338863298910160211889582138779985970590913594108709983795302345406655722535886591555644290825489320482549577823903081026350693447528700094097240169875680569543452934586009983
-- 739787467070105965182768408319729810
declare
l_phi     integer;
l_product types_pkg.fast_int_ty;
l_length  integer;
begin
maths.check_init;
for j in 1 .. 20000 -- max value is the total number of primes in memory
loop
  l_product := euler_pkg.special_mod2 (maths.g_prime_tab (j));
  l_length  := fast_int_pkg.get_length (l_product);
  if l_length >= 100
  then
--    dbms_output.put ('P:  ' || maths.g_prime_tab (j) || '.  CNT: ' || euler_pkg.special_mod_count (maths.g_prime_tab (j)) || '.  Length: ' || l_length);
    dbms_output.put ('P:  ' || maths.g_prime_tab (j) || '.  Length: ' || l_length);
    fast_int_pkg.print (l_product, 10);
  end if;
end loop;
end;
/

-- 
set serverout on size unl
declare
l_prime_save   integer;
l_totient_save integer;
l_lcm          integer;
l_test         integer := 5;
l_powermod     integer;
begin
    for j in (select phi, count (*) cnt from totient_tab where phi >= 2 group by phi order by 1 fetch first 100 rows only)
    loop
	  begin
      l_prime_save  := 1;
    	if maths.is_prime (j.phi + 1)
    	then --dbms_output.put_line ('.   Prime: ' || rpad (to_char (j.phi + 1), 15));
    	     l_prime_save := euler_pkg.special_mod (j.phi + 1);
  --           dbms_output.put_line (rpad ('.   Mod for prime:    ', 25) || l_prime_save ||  '.   PFO:  ' || maths.pfo (l_prime_save));
        end if;
    --
	  l_totient_save := euler_pkg.totient_divisor3 (j.phi);
      l_lcm := maths.lcm (l_prime_save, l_totient_save);
    if (l_lcm != l_totient_save and l_lcm != l_prime_save) or (l_totient_save > l_prime_save and l_prime_save != 1)
  	then
--      l_powermod := maths.powermod (l_test, j.phi + 1, l_lcm) - l_test;
  	  dbms_output.put_line ('PHI:    ' || j.phi || '.  #: ' || j.cnt);
  	  dbms_output.put_line (rpad ('.   LCM:    ', 25) || l_lcm || '. Prime part: ' || l_prime_save || '. Totient: ' || l_totient_save);
    elsif l_prime_save != l_totient_save and l_prime_save != 1
	then dbms_output.put_line ('PHI:  ' || j.phi || '. Prime part: ' || l_prime_save || '. Totient: ' || l_totient_save);
    end if;
    exception when others then null;
	end;
    end loop;
end;
/

--
-- AKS primality test
--
create or replace function prime_check (p_number in integer) return integer result_cache
is
l_test  types_pkg.fast_int_ty := fast_int_pkg.string_to_int (to_char(p_number));
l_number   types_pkg.fast_int_ty;
l_mod   types_pkg.fast_int_ty;
begin
  l_number := l_test;
  for k in 2 .. floor (l_test(1) / 2)
  loop
    l_test := fast_int_pkg.divide (fast_int_pkg.multiply (l_test, fast_int_pkg.subtract (l_number, k - 1)), fast_int_pkg.string_to_int (to_char (k)), l_mod);	
    l_mod  := fast_int_pkg.fmod (l_test, l_number);
    exit when not fast_int_pkg.eq_zero (l_mod);
  end loop;
  if fast_int_pkg.eq_zero (l_mod) then return 1; else return 0; end if;
end prime_check;
/


set serverout on size unl
declare
l_test  types_pkg.fast_int_ty;
l_number   types_pkg.fast_int_ty;
l_mod   types_pkg.fast_int_ty;
begin
for j in 1 .. 30
loop
  dbms_output.put_line ('Index: '|| j);
  l_test   := fast_int_pkg.string_to_int (to_char(j));
  l_number := l_test;
  for k in 2 .. floor (l_test(1) / 2)
  loop
      l_test := fast_int_pkg.divide ( fast_int_pkg.multiply (l_test, fast_int_pkg.subtract (l_number, k - 1)), fast_int_pkg.string_to_int (to_char (k)), l_mod);
	  fast_int_pkg.print (l_test);
  end loop;
  dbms_output.put_line ('Remainder: ' || mod (l_test(1), j));
 dbms_output.put_line (rpad('-',80,'+-'));
end loop;
end;
/

---
