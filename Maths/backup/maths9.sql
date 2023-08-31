Doc

  Author   :  Theo Stienissen
  Date     :  2017 / 2018 / 2019 / 2020 / 2021 / 2023
  Purpose  :  Implement numeric functions
  Contact  :  theo.stienissen@gmail.com
  @C:\Users\Theo\OneDrive\Theo\Project\Maths\Maths\maths9.sql

#

set feedback on
set serveroutput on size unlimited
prompt 
prompt  -- Recreating Types --
prompt

drop type integer_tab;
drop type integer_row;

create or replace type integer_row as object (nr integer);
/
  
create or replace type integer_tab as table of integer_row;
/

drop type number_tab;
drop type number_row;

create or replace type number_row as object (nr1 number);
/

create or replace type number_tab as table of number_row;
/

drop type prime_tab;
drop type prime_row;

create or replace type prime_row as object (nr integer, prime integer);
/
  
create or replace type prime_tab as table of prime_row;
/

drop type pfo_tab;
drop type pfo_row;

create or replace type pfo_row as object (prime integer(15), occurences integer(4));
/

create or replace type pfo_tab  as table of pfo_row;
/

drop type int_pair_tab;
drop type int_pair_row;

create or replace type int_pair_row as object (nr1 integer(10), nr2 integer(10));
/

create or replace type int_pair_tab as table of int_pair_row;
/

prompt
prompt -- Recreating package and package body --
prompt 

create or replace package maths
as

type prime_ty is table of integer (12) index by binary_integer;
p_prime_tab prime_ty;

-- RSA
g_public_key  integer;
g_private_key integer;
g_product     integer;

function  decimal_to_bin (p_value in integer) return varchar2;

function  bin_to_decimal (p_value in varchar2) return integer;

function  decimal_to_new_base (p_value in integer, p_base in integer) return varchar2;

function  base_n_to_decimal (p_value in varchar2, p_base in integer) return integer;

function  nfac (p_value in integer) return integer result_cache;

function  pfac (p_value in integer) return integer result_cache;

function  gcd (p_value1 in integer, p_value2 in integer) return integer;

function  lcm (p_value1 in integer, p_value2 in integer) return integer;

function  xgcd_first (p_value1 in integer, p_value2 in integer) return integer;

function  xgcd_last  (p_value1 in integer, p_value2 in integer) return integer;

function  x_euclid (p_n in integer, p_m in integer) return integer result_cache;

function  y_euclid (p_n in integer, p_m in integer) return integer result_cache;

procedure init_primes (p_max in integer default 1000000);

procedure init_primes2 (p_max in integer default 1000000);

procedure check_init;

function  is_prime (p_integer in integer) return boolean;

function  is_prime_n (p_integer in integer) return integer;

function  get_prime (p_integer in integer) return integer;

function  get_smallest_divisor (p_integer in integer) return integer;

function  pfo (p_integer in integer) return varchar2;

procedure get_divisors (p_integer in integer);

function  get_divisors (p_integer in integer) return integer_tab pipelined;

function  get_pfo_rows (p_integer in integer) return pfo_tab pipelined;

function  get_no_divisors (p_integer in integer) return integer;

function  last_digit (p_integer in integer, p_base in integer default 10) return integer;

function  sum_digits (p_integer in integer, p_base in integer default 10) return integer;

function  total_sum_digits (p_integer in integer, p_base in integer default 10) return integer;

function  f_miller_rabin (p_prime_candidate in integer, p_iterations in integer default 20) return integer;

function  odd (p_integer in integer) return boolean;

function  fermat (p_integer in integer) return integer;

function  mersenne (p_integer in integer) return integer;

function  totient (p_integer in integer) return integer;
function  phi (p_integer in integer)     return integer;

function  reverse (p_integer in integer) return integer;

function  fibonacci (p_n in integer) return integer result_cache;

function  pi return number;

function  pi (p_integer in integer) return integer;

function  k# (p_integer in integer) return integer;

function  e return number;

function  powermod (p_n in integer, p_power in integer, p_mod in integer) return integer result_cache;

function  d (p_n in integer) return integer;

function  sigma (p_n in integer) return integer;

function  random_prime (p_low in integer default 100, p_high in integer default 75000) return integer;

function  legendre (p_a in integer, p_prime in integer) return integer;

function  is_primitive_root (a in integer, p_prime in integer) return boolean;

function  order_of (p_a in integer, p_prime in integer) return integer;

procedure rsa_keygen (p_private in out integer, p_public in out integer, p_product in out integer);

function  rsa_encrypt (p_message in integer, p_key in integer, p_product in integer) return integer;

function  chinese_remainder (p_a in integer, p_mod_n in integer, p_b in integer, p_mod_m in integer) return integer;

function  n_over (p_n in integer, p_k in integer) return integer result_cache;

function  mod (p_n in integer, p_m in integer) return integer;

function  classify (p_n in integer) return varchar2;

function  quadratic_equation (p_b number, p_c number) return number_tab pipelined;
function  quadratic_equation (p_a number, p_b number, p_c number) return number_tab pipelined;

function  show_primes return prime_tab pipelined;

function  mu (p_integer in integer) return integer;

function  tau (p_integer in integer) return integer;

function  sqrtx (p_value in number, p_precision in integer) return number;

function heron_triangle_area (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number;

function bretschneider_quadrilateral_area (p_a in number, p_b in number, p_c in number, p_d in number, l_angle1 in number, l_angle2 in number) return number;

function digits_order (p_prime in integer, p_base in integer default 10) return integer;

end maths;
/

create or replace package body maths
as

--
-- Binary to decimal
--
function bin_to_decimal (p_value in varchar2) return integer
is
l_result  integer (38) := 0;
begin
  if p_value is not null
  then
    for j in 1 .. length(p_value)
    loop
      l_result := 2 * l_result + substr (p_value, j, 1);
    end loop;
  end if;
  return l_result;

exception when others then
  util.show_error ('Error in function bin_to_decimal. For value: ' || p_value || '.', sqlerrm);
  return null;
end bin_to_decimal;

/*************************************************************************************************************************************************/

--
-- Decimal to binary
--
function decimal_to_bin (p_value in integer) return varchar2
is
l_value      integer (38) := p_value;
l_bin_string varchar2 (100);
begin
  select listagg (sign (bitand (p_value, power (2, level-1))),'') within group (order by level desc) into l_bin_string  from dual connect by power (2, level - 1) <= p_value;
  return l_bin_string;

exception when others then
  util.show_error ('Error in function decimal_to_bin. For value: ' || to_char(p_value) || '.', sqlerrm);
end decimal_to_bin;

/*************************************************************************************************************************************************/

--
-- Convert an integer from base 10 to another base.
--
function decimal_to_new_base (p_value in integer, p_base in integer) return varchar2
is
l_string     constant varchar2(36) := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
l_value      integer (38) := p_value;
l_result     varchar2 (40);
begin
  if    nvl(p_value, 0) = 0 then l_result := to_char (p_value);
  elsif p_value < 0 then return '-' || decimal_to_new_base (- p_value, p_base);
  elsif p_base not between 2 and 36 then l_result := null;
  else
    while l_value > 0
    loop
      l_result := l_result || substr (l_string, mod (l_value, p_base) + 1, 1);
      l_value  := trunc (l_value / p_base);    
    end loop;
    select reverse (l_result) into l_result from dual;
  end if;
  return l_result;
  
exception when others then
  util.show_error ('Error in function decimal_to_new_base. For value: ' || to_char (p_value) || ' and base: ' || to_char (p_base) || '.', sqlerrm);
  return null;
end decimal_to_new_base;

/*************************************************************************************************************************************************/

--
-- Convert an integer from another base to base 10. Decimal.
--
function base_n_to_decimal (p_value in varchar2, p_base in integer) return integer
is
l_string     constant varchar2(36) := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
l_result     integer (38);
begin
  if p_value is not null and rtrim (p_value, substr (l_string, 1, p_base)) is null and p_base between 2 and 36
  then
    l_result := 0;
    for j in 1 .. length (p_value)
    loop
                l_result := p_base * l_result + instr (l_string, substr (p_value, j, 1)) - 1;
    end loop;
  end if;
  return l_result;

exception when others then
  util.show_error ('Error in function base_n_to_decimal. For value: ' || p_value || ' and base: ' || p_base || '.', sqlerrm);
  return null;
end base_n_to_decimal;

/*************************************************************************************************************************************************/

--
-- Simple faculty routine for small numbers between 1 and 33
--
function nfac (p_value in integer) return integer result_cache
is
begin
  if    p_value not between 0 and 34 then  return -1;
  elsif p_value  = 0 then return 1;
  elsif p_value <= 2 then return p_value;
  else  return p_value * nfac (p_value - 1);
  end if;

exception when others then
  util.show_error ('Error in function nfac for value: ' || p_value || '.', sqlerrm);
end nfac;

/*************************************************************************************************************************************************/

--
-- Product of the first p_val prime factors
--
function pfac (p_value in integer) return integer result_cache
is
l_result integer(38) := 1;
begin
  if p_value >= 25 then return -1;
  else
    if maths.p_prime_tab.count = 0 then maths.init_primes; end if;
    for j in 1 .. p_value
    loop
      l_result := l_result * p_prime_tab(j);
    end loop;
  end if;
  return l_result;

exception when others then
  util.show_error ('Error in function pfac for value: ' || p_value || '.', sqlerrm);
end pfac;

/*************************************************************************************************************************************************/

--
-- Greatest common divisor
--
function gcd (p_value1 in integer, p_value2 in integer) return integer
is
begin
  if p_value1 = 0 then return abs (p_value2); else return gcd (mod (p_value2, p_value1), p_value1); end if;

exception when others then
  util.show_error ('Error in function gcd. First value: ' || p_value1 || '. Second value: ' || p_value2 || '.', sqlerrm);
  return null;
end gcd;

/*************************************************************************************************************************************************/

--
-- Least common multiple
--
function lcm (p_value1 in integer, p_value2 in integer) return integer
is
begin
  if   p_value1 = 0 or p_value2 = 0 then return 0; else return p_value1 * p_value2 / gcd (p_value2, p_value1); end if;

exception when others then
  util.show_error ('Error in function lcm. First value: ' || p_value1 || '. Second value: ' || p_value2 || '.', sqlerrm);
  return null;
end lcm;

/*************************************************************************************************************************************************/

--
-- Extended Euclidian algorithm
-- maths.gcd(x,y) = x * maths.xgcd_first(x,y) + y * maths.xgcd_last(x,y)
--
function xgcd_first (p_value1 in integer, p_value2 in integer) return integer
is
--
l_a        integer := p_value1;
l_b        integer := p_value2;
l_r        integer;
l_q        prime_ty;
l_depth    integer(5) := 1;
--
function alpha (p_s in integer) return integer;
--
function beta (p_s in integer) return integer
is
begin
  if p_s <= 0 then return 0; else return  alpha (p_s - 1); end if;
end beta;
--
function alpha (p_s in integer) return integer
is
begin
  if p_s <= 0 then return 1; else return beta (p_s - 1) - alpha (p_s - 1) * l_q (l_depth - p_s); end if;
end alpha;
--
begin
  if l_a = 0 or l_b = 0 or l_a is null or l_b is null then return null;
  elsif l_a = l_b then return 1;
  else
    l_r    := mod (l_a, l_b );
    l_q (1):= trunc (l_a/l_b );

    while l_r != 0
    loop
      l_depth := l_depth + 1;
      l_a := l_b;
      l_b := l_r;
      l_r := mod (l_a, l_b);
      l_q (l_depth) := trunc (l_a/l_b);
    end loop;
    return beta (l_depth - 1);
  end if;

exception when others then
  util.show_error ('Error in function xgcd_first for pair: ' || p_value1 || ', ' || p_value2 || '.', sqlerrm);
  return null;
end xgcd_first;

/*************************************************************************************************************************************************/

function xgcd_last (p_value1 in integer, p_value2 in integer) return integer
is
--
begin
  if p_value1 = p_value2 then return 0; else return xgcd_first (p_value2,p_value1); end if;

exception when others then
  util.show_error ('Error in function xgcd_last for pair: ' || p_value1 || ', ' || p_value1 || '.', sqlerrm);
  return null;
end xgcd_last;

/*************************************************************************************************************************************************/

--
-- Euclid: x.a + y.b = 1
-- Euler:  a ** phi(b) = 1 (mod b)
--
function x_euclid (p_n in integer, p_m in integer) return integer result_cache
is
begin
  return maths.powermod (p_n, maths.phi (p_m), maths.lcm (p_n, p_m)) / p_n;
   
exception when others then
  util.show_error ('Error in function x_euclid for pair: ' || p_n || ', ' || p_m || '.', sqlerrm);
  return null;
end x_euclid;

/*************************************************************************************************************************************************/

function y_euclid (p_n in integer, p_m in integer) return integer result_cache
is
begin
  return (1 - p_n * x_euclid (p_n,p_m)) / p_m;
  
exception when others then
  util.show_error ('Error in function y_euclid for pair: ' || p_n || ', ' || p_m || '.', sqlerrm);
  return null;
end y_euclid;

/*************************************************************************************************************************************************/

--
-- Initialisation routine for primes
--
procedure init_primes (p_max in integer default 1000000)
is
l_sqrt        integer(19) := 3;
l_sqr         integer(38) := 9;
l_count       integer(8)  := 2;
l_divisor     boolean;
begin
  p_prime_tab := prime_ty (1 => 2, 2 => 3);
  
  for n in 5 .. p_max
  loop
  if n > l_sqr
  then
    l_sqrt := l_sqrt + 1;
    l_sqr  := l_sqrt * l_sqrt;
  end if;

  <<done>>
  for m in 1 .. l_count
  loop
    exit done when p_prime_tab (m) > l_sqrt;
    l_divisor := mod (n, p_prime_tab(m)) = 0;
    exit done when l_divisor;
  end loop;

  if not l_divisor
  then
    l_count              := l_count + 1;
    p_prime_tab(l_count) := n;
  end if;
  end loop;
  dbms_output.put_line ('# Primes generated: ' || l_count);

exception when others then
  util.show_error ('Error in procedure init_primes. Max: ' || p_max || '.', sqlerrm);
end init_primes;

/*************************************************************************************************************************************************/

procedure init_primes2 (p_max in integer default 1000000)
is
l_sqrt       integer(18) := 4;
l_prime_idx  integer(6)  := 2;
l_count      integer(6)  := 6;
l_divisor    boolean;
l_number     integer(38) := 17;
l_max_number integer(38) := 24;
begin
  p_prime_tab := prime_ty (1 => 2, 2 => 3, 3=> 5, 4 => 7, 5 => 11, 6 => 13);
  --
  <<outer_loop>>
  loop
    while l_number < l_max_number
    loop
     <<inner_loop>>
      for m in 2 .. l_prime_idx
      loop
        l_divisor := mod(l_number, p_prime_tab(m)) = 0;
        exit inner_loop when l_divisor;
      end loop;
    
      if not l_divisor
      then
        l_count := l_count + 1;
        p_prime_tab(l_count) := l_number;
      end if;
    
      l_number := l_number + 2;
      exit outer_loop when l_number > p_max;
    end loop;
  
    l_sqrt    := l_sqrt + 1;
    l_max_number := l_sqrt * l_sqrt + 2 * l_sqrt;
  
    if p_prime_tab(l_prime_idx + 1) <= l_sqrt
    then
      l_prime_idx := l_prime_idx + 1;
    end if;
  end loop;
  dbms_output.put_line ('# Primes generated: ' || l_count);

exception when others then
  util.show_error ('Error in procedure init_primes2. Max: ' || p_max || '.', sqlerrm);
end init_primes2;

/*************************************************************************************************************************************************/

procedure check_init
is
begin
  if maths.p_prime_tab.count = 0 then maths.init_primes; end if;

exception when others then
  util.show_error ('Error in function check_init.' , sqlerrm);
end check_init;

/*************************************************************************************************************************************************/

--
-- Function to check whether a certain integer is a prime returning a boolean
--
function is_prime (p_integer in integer) return boolean
is
l_divisor boolean;
begin
  check_init;

  if p_integer = 2 then return true; end if;
  <<done>>
  for n in 1 .. p_prime_tab.count
  loop
    l_divisor := mod (p_integer, p_prime_tab(n)) = 0;
    exit done when l_divisor or p_prime_tab(n) * p_prime_tab(n) > p_integer;
  end loop;
  return not l_divisor;

exception when others then
  util.show_error ('Error in function is_prime for: ' || p_integer || '.', sqlerrm);
  return null;
end is_prime;

/*************************************************************************************************************************************************/

--
-- Function to check whether a certain integer is a prime returning an integer
--
function is_prime_n (p_integer in integer) return integer
is
begin
  if is_prime (p_integer) then return 1; else return 0; end if;

exception when others then
  util.show_error ('Error in function is_prime_n for: ' || p_integer || '.', sqlerrm);
  return null;
end is_prime_n;

/*************************************************************************************************************************************************/

--
-- Function returns the n-th prime
--
function get_prime (p_integer in integer) return integer
is
begin
  check_init;
  return maths.p_prime_tab(p_integer);

exception when others then
  util.show_error ('Error in function get_prime for: ' || p_integer || '.', sqlerrm);
end get_prime;

/*************************************************************************************************************************************************/

function get_smallest_divisor (p_integer in integer) return integer
is
b_divisor boolean;
l_divisor integer := p_integer;
begin
  check_init;

  <<done>>
  for n in 1 .. p_prime_tab.count
  loop
    b_divisor := mod(p_integer, p_prime_tab(n)) = 0;
    if b_divisor then l_divisor := p_prime_tab(n); end if;
    exit done when b_divisor or p_prime_tab(n) * p_prime_tab(n) > p_integer;
  end loop;
  return l_divisor;

exception when others then
  util.show_error ('Error in function get_smallest_divisor for: ' || p_integer || '.', sqlerrm);
  return null;
end get_smallest_divisor;

/*************************************************************************************************************************************************/

--
-- Prime factorisation
--
function pfo (p_integer in integer) return varchar2
is
l_number  integer;
begin
  l_number := get_smallest_divisor (p_integer);
  if l_number = p_integer
  then return to_char (l_number);
  else return to_char (l_number) || ' *  ' || pfo (p_integer/l_number);
  end if;

exception when others then
  util.show_error ('Error in function pfo for ' || p_integer || '.', sqlerrm);
  return null;
end pfo;

/*************************************************************************************************************************************************/

--
-- Outputs the number of divisors
--
procedure get_divisors (p_integer in integer)
is
l_sqrt        integer(19);
l_sqr         integer(38);
l_no_divisors integer(6) := 0;
begin
  l_sqrt := sqrt (p_integer) - 2;
  <<done>>
  loop
    l_sqrt := l_sqrt + 1;
    l_sqr  := l_sqrt * l_sqrt;
    exit done when l_sqr > p_integer;
  end loop;

  for m in 1 .. l_sqrt - 1
  loop
    if mod (p_integer, m) = 0
    then
      dbms_output.put_line (to_char(p_integer) || ' = ' || to_char(m) || ' *  ' ||  to_char(p_integer / m));
      if p_integer = m * m
      then
        l_no_divisors := l_no_divisors + 1;
      else
        l_no_divisors := l_no_divisors + 2;
      end if;
    end if;
  end loop;
  dbms_output.put_line ('Number of divisors for: ' || to_char(p_integer) || ' is: ' || to_char(l_no_divisors));

exception when others then
  util.show_error ('Error in procedure get_divisors for: ' || p_integer ||'.', sqlerrm);
end get_divisors;

/*************************************************************************************************************************************************/

function get_divisors (p_integer in integer) return integer_tab pipelined
is
l_sqrt        integer(19);
l_sqr         integer(38);
begin
  l_sqrt := sqrt(p_integer) - 2;
  <<done>>
  loop
    l_sqrt := l_sqrt + 1;
    l_sqr  := l_sqrt * l_sqrt;
    exit done when l_sqr > p_integer;
  end loop;

  for m in 1 .. l_sqrt - 1
  loop
    if mod (p_integer, m) = 0
    then
      pipe row (integer_row (m));
      if p_integer != m * m
      then
        pipe row (integer_row (p_integer / m));
      end if;
    end if;
  end loop;

exception when others then
  util.show_error ('Error in function get_divisors for: ' || p_integer || '.', sqlerrm);
end get_divisors;

/*************************************************************************************************************************************************/

--
-- Prime factorisation with table function
--
function get_pfo_rows (p_integer in integer) return pfo_tab pipelined
is
l_integer     integer(38) := abs(p_integer);
l_occurence   integer(8)  := 0;
l_divisor     boolean     := false;
begin
  check_init;

  <<done>>
  for n in 1 .. p_prime_tab.count
  loop
    while mod(l_integer, p_prime_tab(n)) = 0
    loop
      l_divisor   := true;
      l_occurence := l_occurence + 1;
      l_integer   := l_integer / p_prime_tab(n);
    end loop;
    if l_divisor
    then
      pipe row (pfo_row (p_prime_tab (n), l_occurence));
      l_occurence := 0;
      l_divisor   := false;
    end if;
    exit done when l_integer = 1;
  end loop;

exception when others then
  util.show_error ('Error in function get_pfo_rows for: ' || p_integer || '.', sqlerrm);
end get_pfo_rows;

/*************************************************************************************************************************************************/

--
-- Number of divisors
--
function get_no_divisors (p_integer in integer) return integer
is
l_tot   integer(38) := 1;
begin
  for j in (select occurences from table (maths.get_pfo_rows (p_integer)))
  loop
    l_tot := l_tot * (j.occurences + 1);
  end loop;
  return l_tot;

exception when others then
  util.show_error ('Error in function get_no_divisors for: ' || p_integer || '.', sqlerrm);
end get_no_divisors;

/*************************************************************************************************************************************************/

--
-- Last digit of a number
--
function last_digit (p_integer in integer, p_base in integer default 10) return integer
is
begin
  return abs (mod (p_integer, p_base));

exception when others then
  util.show_error ('Error in function last_digit. Integer: ' || p_integer || '. Base: ' || p_base || '.', sqlerrm);
end last_digit;

/*************************************************************************************************************************************************/

--
-- Total sum digits
--
function sum_digits (p_integer in integer, p_base in integer default 10) return integer
is
l_integer integer := abs (p_integer);
begin
  if l_integer between 0 and p_base - 1 or l_integer is null
  then return l_integer;
  else return last_digit (l_integer) + sum_digits (trunc (l_integer/p_base));
  end if;

exception when others then
  util.show_error ('Error in function sum_digits. Integer: ' || p_integer || '. Base: ' || p_base || '.', sqlerrm);
end sum_digits;

/*************************************************************************************************************************************************/

--
-- Recursive
--
function total_sum_digits (p_integer in integer, p_base in integer default 10) return integer
is
l_integer integer := abs (p_integer);
begin
  if l_integer between 0 and p_base - 1 or l_integer is null
    then return l_integer;
  else
    return total_sum_digits (sum_digits (l_integer, p_base), p_base);
  end if;

exception when others then
  util.show_error ('Error in function total_sum_digits. Integer: ' || p_integer || '. Base: ' || p_base || '.', sqlerrm);
  return null;
end total_sum_digits;

/*************************************************************************************************************************************************/

--
-- Primality test for large numbers. Function is alwayd correct ifitreturns that it is not a prime.
-- There is a very small probability that the function is wrong if it returns that an integer is a prime (Carmichael numbers).
--
function f_miller_rabin (p_prime_candidate in integer, p_iterations in integer default 20) return integer
is 
l_random   integer;
begin 
  if    p_prime_candidate in (2, 3, 5, 7) then return 1;
  elsif p_prime_candidate <= 10           then return 0;
  else
    for j in 1 .. p_iterations
    loop
      l_random := trunc (dbms_random.value (2, p_prime_candidate));
      if    maths.gcd (l_random, p_prime_candidate) != 1                             then return 0;
      elsif maths.powermod (l_random, p_prime_candidate - 1, p_prime_candidate) != 1 then return 0;
      end if;
    end loop;
  end if;
  return 1;

exception when others then
  util.show_error ('Error in function f_miller_rabin. Integer: ' || p_prime_candidate || '. Iterations: ' || p_iterations || '.', sqlerrm);
  return null;
end f_miller_rabin;

/*************************************************************************************************************************************************/

--
-- Odd numbers are male, even numbers are female
--
function odd (p_integer in integer) return boolean
is
begin
  return abs (mod (p_integer, 2)) = 1;

exception when others then
  util.show_error ('Error in function odd for: ' || p_integer || '.', sqlerrm);
  return null;
end odd;

/*************************************************************************************************************************************************/

--
-- Fermat numbers:  power(2, power(2, p_integer)) + 1. Fermat conjectured in 1650 that every Fermat number is prime. This is wrong.
--
function fermat (p_integer in integer) return integer
is
begin
  return power (2, power (2, p_integer)) + 1;

exception when others then
  util.show_error ('Error in function fermat for: ' || p_integer || '.', sqlerrm);
end fermat;

/*************************************************************************************************************************************************/

--
-- Mersenne numbers: power(2, p_integer) - 1. P = prime. Often, but not always a prime
--
function mersenne (p_integer in integer) return integer
is
begin
  return power (2, p_integer) - 1;

exception when others then
  util.show_error ('Error in function mersenne for: ' || p_integer || '.', sqlerrm);
end mersenne;

/*************************************************************************************************************************************************/

--
-- Euler's totient function: Number of numbers coprime to (and not bigger than) a given one.
--
function totient (p_integer in integer) return integer
is
l_prod integer(30) := 1;
begin
  if p_integer <= 1 then return 1;
  else
    for j in (select (prime - 1) * power (prime, occurences - 1) phi  from table (maths.get_pfo_rows (p_integer)))
    loop
       l_prod := l_prod * j.phi;
    end loop;
  end if;
  return l_prod;

exception when others then
  util.show_error ('Error in function totient for: ' || p_integer || '.' , sqlerrm);
end totient;

/*************************************************************************************************************************************************/

function phi (p_integer in integer) return integer
is
begin
 return totient (p_integer);
 
exception when others then
  util.show_error ('Error in function phi for: ' || p_integer || '.' , sqlerrm);
end phi;

/*************************************************************************************************************************************************/

--
-- Calculate the number of primes <= p_integer
--
function pi (p_integer in integer) return integer
is
l_count number(10) := 0;
begin
  check_init;
  <<done>>
  for n in 1 .. p_prime_tab.count
  loop
    if p_prime_tab (n) <= p_integer
    then
      l_count := l_count + 1;
    else exit done;
    end if;
  end loop;
  return l_count;

exception when others then
  util.show_error ('Error in function pi for ' || p_integer || '.' , sqlerrm);
  return null;
end pi;

/*************************************************************************************************************************************************/

--
-- Primorial is the product of all primes ≤ p_integer, e.g.: 10# = 2 · 3 · 5 · 7
--
function k# (p_integer in integer) return integer
is
l_product integer(30) := 1;
begin
  check_init;
  <<done>>
  for n in 1 .. p_prime_tab.count
  loop
    if p_prime_tab (n) <= p_integer
    then
      l_product := l_product * p_prime_tab(n);
    else exit done;
    end if;
  end loop;
  return l_product;

exception when others then
  util.show_error ('Error in function k# for ' || p_integer || '.' , sqlerrm);
  return null;
end k#;

/*************************************************************************************************************************************************/

--
-- No explanation needed 
--
function reverse (p_integer in integer) return integer
is
l_return integer := mod(p_integer, 10);
l_rest   integer;
begin
  l_rest := trunc (p_integer / 10);
  while l_rest != 0
  loop
    l_return := 10 * l_return + mod (l_rest, 10);
    l_rest   := trunc (l_rest / 10);
  end loop;
  return l_return;

exception when others then
  util.show_error ('Error in function reverse.' , sqlerrm);
end reverse;

/*************************************************************************************************************************************************/

--
-- Fbonacci numbers
--
function fibonacci (p_n in integer) return integer result_cache
is
begin
  if p_n <= 2 then return 1; else return fibonacci (p_n - 2) + fibonacci (p_n - 1); end if;

exception when others then
  util.show_error ('Error in function fibonacci.' , sqlerrm);
end fibonacci;

/*************************************************************************************************************************************************/

--
-- Euler e
--
function e return number
is
begin
  return constants_pkg.g_e;

exception when others then
  util.show_error ('Error in function e.' , sqlerrm);
end e;

/*************************************************************************************************************************************************/

--
-- Pi. Discoverer: Archimedes (287-212 BC)
--
function pi return number
is
begin
  return constants_pkg.g_pi;

exception when others then
  util.show_error ('Error in function pi.' , sqlerrm);
end pi;

/*************************************************************************************************************************************************/

function powermod (p_n in integer, p_power in integer, p_mod in integer) return integer result_cache
is
begin
  if    p_power <= 0 then return 1;
  elsif p_power  = 1 then return mod (p_n, p_mod);
  else return mod (powermod (p_n, trunc (p_power/2), p_mod) * powermod (p_n, ceil (p_power/2), p_mod), p_mod);
  end if;
  
exception when others then
  util.show_error ('Error in function powermod for: ' || p_n || ', ' || p_power || ', ' || p_mod || '.', sqlerrm);
  return null;
end powermod;

/*************************************************************************************************************************************************/

--
-- Calculates the number of positive divisors
--
function d (p_n in integer) return integer
is
l_d     integer(10) := 1;
begin
  for j in 2 .. p_n
  loop
    if mod (p_n, j) = 0 then l_d := l_d + 1; end if;
  end loop;
  return l_d;

exception when others then
  util.show_error ('Error in function d for: ' || p_n, sqlerrm);
end d;

/*************************************************************************************************************************************************/

--
-- Calculate the sum of the positive divisors
--
function sigma (p_n in integer) return integer
is
l_d     integer(10) := 1;
begin
  for j in 2 .. p_n
  loop
    if mod (p_n, j) = 0 then l_d := l_d + j; end if;
  end loop;
  return l_d;

exception when others then
  util.show_error ('Error in function sigma for: ' || p_n, sqlerrm);
end sigma;

/*************************************************************************************************************************************************/

--
-- Returns a random prime number
--
function random_prime (p_low in integer default 100, p_high in integer default 75000) return integer
is
begin
  check_init;  
  return maths.p_prime_tab (trunc (dbms_random.value (p_low, p_high)));
 
exception when others then
  util.show_error ('Error in function random_prime. Low:' || p_low || '. High:' || p_high, sqlerrm);
end random_prime;

/*************************************************************************************************************************************************/

-- Legendre
-- (A/P) = 0 if mod (a,p) = 0
--       = 1 if A is QR (mod p) Quadratic Residue
--       =-1 if A is not QR (mod p)
--
function legendre (p_a in integer, p_prime in integer) return integer
is
l_legendre integer := 1;
begin
  if    not maths.is_prime (p_prime)
  then  raise_application_error (-20001, 'Second parameter ' || p_prime || ' is not a prime.');
  elsif mod (p_a, p_prime) = 0 then l_legendre := 0;
  elsif p_a = 1 then null;
  elsif p_a = p_prime - 1 then if maths.odd ((p_prime - 1) / 2) then l_legendre := -1; end if;
  elsif p_a = 2 then if mod (p_prime, 8) in (3, 5) then l_legendre := -1; end if; -- mod (p_prime, 8) in (1, 7) --> 1
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

/*************************************************************************************************************************************************/

--
-- An integer A (1 <= A <= P - 1) is a primitive root of unity (mod P)
-- if A ** K != 1 (mod P) for 1 <= K <= P - 2
-- There are phi (p-1) primitive roots of unity.
--
function is_primitive_root (a in integer, p_prime in integer) return boolean
is
l_primitive_root boolean := TRUE;
begin
  if not maths.is_prime (p_prime)    -- if maths.gcd(a,p_prime) != 1
  then
    raise_application_error (-20001, 'Second parameter ' || p_prime || ' is not a prime.');
  end if;

  <<done>>
  for j in 2 .. ceil (p_prime / 2)
  loop
    l_primitive_root := l_primitive_root and maths.powermod (a, j, p_prime) != 1;
    exit done when not l_primitive_root;
  end loop;  
  return l_primitive_root;

exception when others then
  util.show_error ('Error in function is_primitive_root. A=' || a ||', Prime=' || p_prime, sqlerrm);
end is_primitive_root;

/*************************************************************************************************************************************************/

--
-- Check order of an integer
--
function order_of (p_a in integer, p_prime in integer) return integer
is
l_count integer(6) := 1;
begin
-- if not maths.is_prime (p_prime)
  if maths.gcd(p_a,p_prime) != 1
  then
    raise_application_error (-20001, 'Parameters ' || p_a || ' and ' || p_prime || ' have a common divisor.');
  end if;

  <<done>>
  for j in 1 .. p_prime - 1
  loop
    l_count := l_count + 1;
    exit done when powermod (p_a, j, p_prime) = 1;
  end loop;  
  return l_count;

exception when others then
  util.show_error ('Error in function order_of. A=' || p_a ||', Prime=' || p_prime, sqlerrm);
end order_of;

/*************************************************************************************************************************************************/

--
-- Asymmetric encryption algorithm. Ron Rivest, Adi Shamir en Len Adleman.
--
procedure rsa_keygen (p_private in out integer, p_public in out integer, p_product in out integer)
is
l_prime1 integer(30);
l_prime2 integer(30);
l_phi    integer(30);
begin
  l_prime1 := random_prime;
  l_prime2 := random_prime;
  p_private:= random_prime;
  p_product:= l_prime1 * l_prime2;
  l_phi    := (l_prime1 - 1) * (l_prime2 - 1);
  
  p_public := maths.xgcd_first(p_private, l_phi);  
  if p_public < 0 then p_public := p_public + maths.lcm (p_private, l_phi); end if;
  
  g_public_key := p_public;
  g_private_key:= p_private;
  g_product    := p_product;
  
exception when others then
  util.show_error ('Error in procedure rsa_keygen for: ' || p_private || '. ' || p_public || '. ' || p_product || '.', sqlerrm);
end rsa_keygen;

/*************************************************************************************************************************************************/

--
-- encrypt = decrypt
--
function rsa_encrypt (p_message in integer, p_key in integer, p_product in integer) return integer
is
begin
  return maths.powermod (p_message, p_key, p_product);
  
exception when others then
  util.show_error ('Error in function rsa_encrypt. Msg=' || p_message ||', Key=' || p_key ||', Prod=' || p_product, sqlerrm);
  return null;
end rsa_encrypt;

/*************************************************************************************************************************************************/

--
-- x = a mod (n) = b mod (m).  (n, m) = 1
--
function chinese_remainder (p_a in integer, p_mod_n in integer, p_b in integer, p_mod_m in integer) return integer
is
l_result integer;
l_lcm    integer;
begin
  if mod(abs(p_b - p_a), gcd(p_mod_n, p_mod_m)) != 0
  then raise_application_error (-20001, 'invalid values: ' || p_a || ', '|| p_mod_n || ' and ' || p_b || ', ' || p_mod_m || '.');
  else
    l_result := p_a + (p_b - p_a) / maths.gcd (p_mod_n, p_mod_m) *  maths.xgcd_first (p_mod_n, p_mod_m)   * p_mod_n;
    l_lcm := maths.lcm (p_mod_n, p_mod_m);
    if l_result < 0
    then
      l_result := l_result + trunc (abs (l_result) / l_lcm + 1) * l_lcm;
    else
      l_result := l_result - trunc (l_result / l_lcm) * l_lcm;
    end if;
  end if;  
  return l_result;

exception when others then
  util.show_error ('Error in function chinese_remainder for ' || p_a || ', ' || p_mod_n || ' and ' || p_b || ', ' || p_mod_m || '.', sqlerrm);
  return null;
end chinese_remainder;

/*************************************************************************************************************************************************/

--
-- Binomial coefficients according to Newton
--
function n_over (p_n in integer, p_k in integer) return integer result_cache
is
begin
  if p_k <= 0 or p_k >= p_n     then return 1;
  elsif p_k =1 or p_k = p_n - 1 then return p_n;
  elsif 2 * p_k > p_n
  then return n_over (p_n, p_n - p_k);
  else return n_over (p_n, p_k - 1) * (p_n - p_k + 1) / p_k;
  end if;

exception when others then
  util.show_error ('Error in function n_over for ' || p_n || ' and ' || p_k || '.', sqlerrm);
  return null;
end n_over;

/*************************************************************************************************************************************************/

--
-- Provides correct results for negative numbers. Orace mod function does not!
--
function mod (p_n in integer, p_m in integer) return integer
is
l_m   integer := abs(p_m);
begin
  if p_n < 0
  then return (1 - trunc((p_n + 1)/l_m)) * l_m  +  p_n;
  elsif p_n > 0
  then return p_n - trunc(p_n/l_m) * l_m;
  else return p_n;
  end if;
  
exception when others then
  util.show_error ('Error in function mod for ' || p_n || ' and ' || p_m || '.', sqlerrm);
  return null;  
end mod;

/*************************************************************************************************************************************************/

-- Integer is abundant  if sigma (n) - n > n
--            perfect   if sigma (n) = 2 * n
--            deficient if sigma (n) - n < n
function classify (p_n in integer) return varchar2
is
l_sigma   integer := sigma (p_n);
begin
  if    l_sigma  < 2 * p_n then return 'deficient';
  elsif l_sigma  = 2 * p_n then return 'perfect';
  elsif l_sigma  > 2 * p_n then return 'abundant';
  else return '';
  end if;

exception when others then
  util.show_error ('Error in function classify for ' || p_n || '.', sqlerrm);
end classify;

/*************************************************************************************************************************************************/

--
-- 1 x ** 2 + b x + c = 0. Only works for positive solutions
--
function  quadratic_equation (p_b number, p_c number) return number_tab pipelined
is
l_sqrt number := p_b * p_b - 4  * p_c;
begin
  if l_sqrt = 0
  then
     pipe row (number_row (- p_b / 2));
  elsif l_sqrt > 0
  then
    l_sqrt := sqrt(l_sqrt);
    pipe row (number_row ((-p_b + l_sqrt)/ 2));
    pipe row (number_row ((-p_b - l_sqrt)/ 2));
  end if;

exception when others then
  util.show_error ('Error in function quadratic_equation for:' || p_b || ', ' || p_c || '.', sqlerrm);
end quadratic_equation;

/*************************************************************************************************************************************************/

--
-- a x ** 2 + b x + c = 0. Only positive solutions
--
function quadratic_equation (p_a number, p_b number, p_c number) return number_tab pipelined
is
l_sqrt number := p_b * p_b - 4 * p_a * p_c;
l_a    number := 2 * p_a;
begin
  if l_sqrt = 0
  then
     pipe row (number_row ( -p_b / l_a));
  elsif l_sqrt > 0
  then
    l_sqrt := sqrt(l_sqrt);
    pipe row (number_row ((-p_b + l_sqrt)/ l_a));
    pipe row (number_row ((-p_b - l_sqrt)/ l_a));
  end if;

exception when others then
  util.show_error ('Error in function quadratic_equation for:' || p_a || ', ' || p_b || ', ' || p_c || '.', sqlerrm);
end quadratic_equation;

/*************************************************************************************************************************************************/

--
-- Used to create a view on primes
--
function  show_primes return prime_tab pipelined
is
begin
  check_init;
  for j in 1 ..  maths.p_prime_tab.count
  loop
    pipe row (prime_row (j, p_prime_tab (j)));
  end loop;

exception when no_data_needed then null;
          when others then  
  util.show_error ('Error in function show_primes.', sqlerrm);
end show_primes;

/*************************************************************************************************************************************************/

--
-- Mobius function
--
function mu (p_integer in integer) return integer
is
l_primes   integer;
l_max      integer;
begin
  select count(prime), max(occurences) into l_primes, l_max from table (maths.get_pfo_rows (p_integer));
  if l_max >= 2  then return 0;
  elsif maths.odd (l_primes) then return -1;
  else return 1;
  end if;

exception when others then
  util.show_error ('Error in function mu for:' || p_integer || '.', sqlerrm);
  return null;
end mu;

/*************************************************************************************************************************************************/

--
-- Tau function. Check explanation below
--
function tau (p_integer in integer) return integer
is
l_result   integer := 1;
begin
  if maths.odd (p_integer)
  then
    for j in (select prime from table(maths.show_primes) where prime <= p_integer and mod (p_integer -1, prime -1) = 0)
    loop
      l_result := l_result * j.prime;
    end loop;
  else
    raise_application_error(-20001, 'Function Tau only defined for odd integers.');
  end if;
  return l_result;

exception when others then
  util.show_error ('Error in function tau for:' || p_integer || '.', sqlerrm);
  return null;
end tau;

/*************************************************************************************************************************************************/

--
-- Calculate SQRT with high precision
--
function sqrtx (p_value in number, p_precision in integer) return number 
is 
l_to_calculate  number     := p_value;
l_result        number;
l_between       number     := 0;
l_difference    integer;
l_comma         number(2, 0) := 0;
l_digit         number(2, 0) := 0;
function        f_get_digit (p_between integer, p_difference integer) return integer
is 
l_digit1         number(2, 0) := 0;
begin
  while (10 * p_between + l_digit1 + 1) * (l_digit1 + 1) <= p_difference and l_digit1 <= 10
  loop 
    l_digit1 := l_digit1 + 1;
  end loop;
  return l_digit1;
end f_get_digit;
begin 
  if    l_to_calculate < 0 then raise_application_error (-20001, 'Square root not defined for negative value: ' || l_to_calculate);
  elsif l_to_calculate = 0 then l_result := 0;
  else 
  -- Normalise 1 < value < 100
    while l_to_calculate >= 100
    loop 
      l_to_calculate := l_to_calculate / 100;
      l_comma        := l_comma + 1;
    end loop;
    while l_to_calculate < 1
    loop 
      l_to_calculate := l_to_calculate * 100;
      l_comma        := l_comma - 1;
    end loop;

    -- First digit
    l_difference     := trunc(l_to_calculate);
    l_result         := f_get_digit (l_between, l_difference);
    l_difference     := l_difference - l_result * l_result;
    l_between        := 2 * l_result;
    l_to_calculate   := (l_to_calculate- trunc(l_to_calculate))  * 100;
    l_difference     := l_difference * 100 + trunc(l_to_calculate);
  
    for d in 1 .. p_precision - 1
    loop 
      l_digit        := f_get_digit (l_between, l_difference);	
      l_result       := 10 * l_result + l_digit;
      l_difference   := l_difference - (10 * l_between + l_digit) * l_digit; 
      l_between      := 10 * l_between + 2 * l_digit;
      l_to_calculate := (l_to_calculate- trunc (l_to_calculate))  * 100;	
      l_difference   := l_difference * 100 - trunc (l_to_calculate * 100);	
    end loop;
  end if;
  return l_result * power (10, 1 - p_precision + l_comma);
  
exception when others then
  util.show_error ('Error in function sqrtx for: ' || p_value || '. Precision: ' || p_precision  || '.', sqlerrm);
  return null;
end sqrtx;

/*************************************************************************************************************************************************/

--
-- Heron's formula to calculate the area of a triangle
-- 3 edges / lengths known
--
function heron_triangle_area (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number
is
l_s number := (p_edge1 + p_edge2 + p_edge3) / 2; -- Semiperimeter
begin 
  return sqrt (l_s * (l_s - p_edge1) * (l_s - p_edge2) * (l_s - p_edge3));
  
exception when others 
then 
  util.show_error ('Error in function heron_triangle_area E1: ' || to_char (p_edge1) || '. E2: ' || to_char (p_edge2) || '. E3: ' ||to_char (p_edge3), sqlerrm);
  return null;
end heron_triangle_area;

/*************************************************************************************************************************************************/

--
-- Heron's formula is a special case of Brahmagupta's formula for the area of a cyclic quadrilateral,
-- both of which are special cases of Bretschneider's formula for the area of a quadrilateral.
-- Input of opposite angles are in radians.
--
function bretschneider_quadrilateral_area (p_a in number, p_b in number, p_c in number, p_d in number, l_angle1 in number, l_angle2 in number) return number
is 
l_semiperimeter number := (p_a + p_b + p_c + p_d) / 2;
l_part1         number;
l_part2         number;
begin 
  l_part1 := (l_semiperimeter - p_a) * (l_semiperimeter - p_b) * (l_semiperimeter - p_c) * (l_semiperimeter - p_d);
  l_part2 := p_a * p_b * p_c * p_d * cos ((l_angle1 + l_angle2) / 2);
  return sqrt (l_part1 + l_part2);

exception when others 
then 
  util.show_error ('Error in function bretschneider_quadrilateral_area E1: ' || to_char (p_a) || '. E2: ' || to_char (p_b) ||
           '. E3: ' ||to_char (p_c)  || '. E4: ' || to_char (p_d)  || '. a1: ' || to_char (l_angle1)  || '. a3: ' || to_char (l_angle2), sqlerrm);
  return null;
end bretschneider_quadrilateral_area;

/*************************************************************************************************************************************************/

-- Reciprocal prime numbers. After how many digits will the digits of a fraction repeat?
function digits_order (p_prime in integer, p_base in integer default 10) return integer
is 
l_one    integer;
l_result integer := 0;
l_count  integer := 1;
l_prime  integer := p_prime;
begin
  while mod (l_prime, 2) = 0 loop l_prime := l_prime / 2; end loop;
  while mod (l_prime, 5) = 0 loop l_prime := l_prime / 5; end loop;
  l_one := mod (p_base, l_prime);
  while l_result != l_one and l_count <= l_prime + 1
  loop 
    l_count  := l_count + 1;
    l_result := powermod (p_base, l_count, l_prime);
  end loop;
--
  if l_count <= l_prime
  then return l_count - 1;
  else return null;
  end if;

exception when others 
then 
  util.show_error ('Error in function digits_order for Prime: ' || to_char (p_prime) || '. Base: ' || to_char (p_base), sqlerrm);
  return null;
end digits_order;

end maths;
/

-- select * from table(maths.show_primes);


/*
 Alternative code for binomial coefficients
	function n_over (p_n in integer, p_k in integer) return integer
	is
	l_result integer := 1;
	begin
	for j in p_n - p_k + 1 .. p_n
	loop
	  l_result := l_result * j;
	end loop;

	for j in 1 .. p_k
	loop
	  l_result := l_result / j;
	end loop;

	return l_result;

	exception when others then
	  util.show_error ('Error in function n_over for ' || p_n || ' and ' || p_k || '.', sqlerrm);
	end n_over;


exec maths.init_primes
set serveroutput on size unlimited

select maths.gcd(11181, 6327) gcd,  maths.lcm(11181, 6327) lcm from dual;

select maths.is_prime_n (53) from dual;
select maths.get_smallest_divisor(6327) from dual;

select maths.pfo(11181) from dual;

exec maths.get_divisors(11181)
exec maths.get_divisors(96)
exec maths.get_divisors(6327)

select nr from table(maths.get_divisors(11181)) order by nr;

select * from table (maths.get_pfo_rows(96));

select rank() over(partition BY prime order by prime), 
prime, count(*) cnt from (select * from table (maths.get_pfo_rows(96))) group by prime;

-- Prime numbers that differ 2 values.
declare
l_count number(6) := 0;
begin
for j in 2 .. maths.p_prime_tab.last
loop
if maths.p_prime_tab (j) -  maths.p_prime_tab (j - 1) = 2
then
   l_count := l_count + 1;
   dbms_output.put_line (rpad(to_char(l_count, '99999'), 8) || ' #    ' || to_char(maths.p_prime_tab (j - 1)) || ' -  ' || to_char(maths.p_prime_tab (j)));
end if;
end loop;
end; 
/

-- Largest prime <= 1000
select  max(id) from (select level id  from dual connect by level <= 1000) where maths.is_prime_n(id) = 1;

select maths.last_digit(123) from dual;

begin
for i in 1 .. 9
loop
  for j in 1 .. 50
  loop
    dbms_output.put(maths.last_digit(power(i , j)));
  end loop;
  for k in 1 .. 9
  loop
    dbms_output.put(maths.total_sum_digits(power(i , k)));
  end loop;
  dbms_output.new_line;
end loop;
end;
/

select maths.gcd(9012,120) gcd, maths.xgcd_first(9012,120) one, maths.xgcd_last(9012,120) two from dual;

declare
l_a    integer(20) := 3310613;
l_b    integer(20) := 2937794;
begin
  if maths.gcd(l_a, l_b) != 1
  then raise_application_error (-20001, 'Numbers must be relatively prime!');
  end if;
  
  dbms_output.put_line( maths.x_euclid (l_a, l_b) || ' * ' || l_a || '  ' || maths.y_euclid (l_a, l_b) || ' * ' || l_b || ' = ' || to_char(maths.x_euclid (l_a, l_b) * l_a + maths.y_euclid (l_a, l_b) * l_b));
  dbms_output.put_line( maths.x_euclid (l_b, l_a) || ' * ' || l_b || '  ' || maths.y_euclid (l_b, l_a) || ' * ' || l_a || ' = ' || to_char(maths.x_euclid (l_b, l_a) * l_b + maths.y_euclid (l_b, l_a) * l_a));
end;
/
-- mod(power(a, [p/2], p) in (1, -1)
set serveroutput on size unlimited
declare
l_mod number(20);
begin
-- maths.init_primes;
for j in 1 .. 200
loop
  for a in 2 .. maths.p_prime_tab (j) - 1
  loop
  l_mod := maths.powermod (a, trunc(maths.p_prime_tab (j)/2), maths.p_prime_tab (j));
  if l_mod != 1 and l_mod != maths.p_prime_tab (j) -1
  then
    dbms_output.put_line(maths.p_prime_tab (j) || '  ' || a|| '  ' || maths.powermod (a, trunc(maths.p_prime_tab (j)/2), maths.p_prime_tab (j)));
  end if;
  end loop;
end loop;
end;
/

col nr1 for 999999999999999D999999999999999999999999
select * from table(maths.quadratic_equation(1,-7,10));

Tau: Consequence of Fermat.

Let P be an odd number. Define: N = P - 1. If P is a prime, then N is φ(P) where φ is Eulers totient function.
Define V = {p1, p2, .. , pn} as the set of prime numbers so that p<i> - 1 divides N, so φ(p<i>) / N for each i.
Each prime in the set V should only be present once!
Then, for any non-empty subset S of V it is true, that for the product of members of set S,
call this M and for any integer A:
A ** P is congruent to A mod M. A **P ≡ A (mod M) 

Example:
Suppose P =  13. Then N = 12 and V = { 2, 3, 5, 7, 13}.
So A ** P is congruent to A (mod M) for M in  { 2, 6, 30, 910, 2730, …}
A ** 13 ≡ A (mod 2730)

*/
