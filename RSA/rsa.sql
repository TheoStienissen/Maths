DOC

  Author   :  Theo Stienissen
  Date     :  2017 / 2018 / 2019 / 2020 / 2021 / 2023
  Purpose  :  Implement numeric functions
  Status   :  Not yet ready!!
  Contact  :  theo.stienissen@gmail.com
  @C:\Users\Theo\OneDrive\Theo\Project\Maths\RSA\rsa.sql

RSA 1024 bits = 300 digits
1. Take 2 prime numbers and multiply them.
   select rsa.random_prime from dual;
   E.G.: p=999773 q=999961
   N = p * q = 999734008853
 
   p and q are determined with the Rabin-Miller primality tester. Normally, the test is performed by iterating 64 times and
   produces a result on a number that has a 1 / 2 ** 128 chance of not being prime.
 
2. phi is the Euler Totient function. For prime numbers phi(p) = p - 1
   phi (pq) = phi(p) * phi(q) = 999772 * 999960 = 999732009120

   col x for 99999999999999999999
   select maths.totient(999773) * maths.totient(999961) phi from dual;
   Totient := 999732009120
 
   Fermat:
   m ** ed = m (mod p) ^ m ** ed = m (mod q)
   Chinese remainder theorem:
   m ** ed = m (mod pq)
 
   So:
   c ** d = m (mod n)
 
3. Search for E with gcd(E,phi(pq)) = 1 en 1 < E < phi (pq)
   There are multiple possibilities. Popular choice is E = 2 ** 16 + 1 = 65537.
   E is part of the public key 

4. Search for a value D which is the inverse of E relative to the Totient. D is part of the private key. 
   Find D with: ED = 1 mod (phi(pq)) =>  DE = k * phi(pq) + 1
   If D is negative then use the totient plus D: 2268 + D
   Euclidian algorithm to calculate gcd.
   Extended Euclidian Algorithm. Backward routine to calculate factors.
  
   select maths.xggd_first(65537, 999732009120) from dual;
   D=54656755553
 
5. Public keys:
   E= 65537 N=999734008853
 
   Private key:
   D = 54656755553
 
6. Characters: A=0, .. Z=25 Space=26 Use the ASCII characterset that contains 256 characters.
   Choose a blocksize. Blocksize can be 2, 4, 8, ..
   Suppose blocksize = 2: (first char * number of chars) + second char
 
7. Encrypt the word ADCD. Only E and N are needed. M ** E (mod N) = C     M=message C=cypertext
   C1 = AB = 65 * 256 + 66 = 16706; 16706 ** 65537 (mod 999734008853) = 746729466394
   C2 = CD = 67 * 256 + 68 = 17220; 17220 ** 65537 (mod 999734008853) = 109348647695

   select  rsa.ascii_to_num ('AB') from dual;
   select  rsa.ascii_to_num ('CD') from dual;

   select rsa.power_mod (16706, 65537, 999734008853) from dual;
   select rsa.power_mod (17220, 65537, 999734008853) from dual;

8. Decrypt. C ** D (mod N) = M
   Encrypted test ** D (mod N) = temp
   temp / # chars = INT (first char)
 
  select rsa.power_mod (746729466394, 54656755553, 999734008853) from dual;
  select rsa.power_mod (109348647695, 54656755553, 999734008853) from dual;

Fermat:
a ** p = a mod (p)

Eeuler totient function: phi(n)
     m ** phi (N) = 1 mod (N)

m ** (k * phi(N)) is also 1
So:
m ** (k * phi (N) + 1) = m mod (N)

m ** (e * d) = m mod (N)

So ed = k * phi(N) + 1 <=> ed - k * phi(N) = 1
 
--

Blocksize = 2
Message = ABCD = 65 66 67 68 = 256 * 65 + 66, 256 * 67 + 68 = 16706 , 17220
C1 = 16706 ** 25 mod (247) = rsa.power_mod (16706, 25, 247)
C2 = 17220 ** 25 mod (247)

#
--

create or replace package rsa
as
p_first_prime   integer;
p_secondprime   integer;
p_public_key_N  integer;
p_public_key_E  integer;
p_private_key_D integer;
p_totient       integer;

p_char_set_size integer(6) := 256;

function  power_mod (p_base in integer, p_power in integer, p_mod in integer) return integer result_cache;

function  random_prime return integer;

function  ascii_to_num (p_text in varchar2, p_blocksize in integer default 2) return integer;

function  num_to_ascii(p_num in integer, p_blocksize in integer default 2) return varchar2;

function  public_key_N (p_prime1 in integer, p_prime2 in integer) return integer;

function  public_key_E (p_prime1 in integer, p_prime2 in integer) return integer;

function  private_key_D (p_public_key_E in integer, p_prime1 in integer, p_prime2 in integer) return integer;

function  rsa_encrypt (p_text in varchar2, p_key_N in integer, p_key_E in integer, p_blocksize in integer default 2) return integer_tab pipelined;

function  rsa_decrypt (p_num in integer, p_key_N in integer, p_key_D in integer, p_blocksize in integer default 2) return varchar2;

procedure generate_keys (p_prime1 in integer default null, p_prime2 in integer default null);

function  prime_test (p_candidate in integer, p_trials in integer default 64) return number;

end rsa;
/

create or replace package body rsa
as

--
-- mod (p_base ** p_power, p_mod)
--
function power_mod (p_base in integer, p_power in integer, p_mod in integer) return integer result_cache
is
begin
  if p_power = 1 then return mod (p_base, p_mod);
  elsif mod (p_power, 2) = 0
  then return mod (power_mod (p_base, p_power / 2, p_mod) * power_mod (p_base, p_power / 2, p_mod), p_mod) ;
  else return mod (p_base * power_mod (p_base, (p_power - 1) / 2, p_mod) * power_mod (p_base, (p_power - 1) / 2, p_mod), p_mod);
  end if;

exception when others then
  util.show_error ('Error in function power_mod. Base: ' || p_base || '. Power: ' || p_power || '. Mod: ' || p_mod, sqlerrm);
  return null;
end power_mod;

/*************************************************************************************************************************************************/

--
-- Returns a random prime
--
function random_prime return integer
is
begin
  maths.check_init;
  return maths.p_prime_tab (round (dbms_random.value (1000, maths.p_prime_tab.count)));

exception when others then
  util.show_error ('Error in function random_prime.', sqlerrm);
  return null;
end random_prime; 

/*************************************************************************************************************************************************/

--
-- Convert the message to an integer 
--
function ascii_to_num (p_text in varchar2, p_blocksize in integer default 2) return integer
is
l_return integer := 0;
l_text   varchar2 (16) := rpad (p_text, p_blocksize);
begin
  if length (p_text) > p_blocksize
  then
    raise_application_error (-20001, 'Text '|| ' larger than blocksize:' || p_blocksize);
  end if;
  for j in 1 .. p_blocksize
  loop
    l_return := p_char_set_size * l_return + ascii (substr (l_text, j, 1));
  end loop;
  return l_return;

exception when others then
  util.show_error ('Error in function ascii_to_num. Text: ' || p_text || '. Blocksize: ' || p_blocksize , sqlerrm);
  return null;
end ascii_to_num;

/*************************************************************************************************************************************************/

--
-- Convert the integer back to a message
--
function num_to_ascii (p_num in integer, p_blocksize in integer default 2) return varchar2
is
l_return varchar2 (20) := '';
l_rest   integer       := p_num;
begin
  for j in 1 .. p_blocksize
  loop
    l_return := chr (mod (l_rest, p_char_set_size)) || l_return ;
    l_rest   := trunc (l_rest / p_char_set_size); 
  end loop;
  return l_return;

exception when others then
  util.show_error ('Error in function ascii_to_num. Num: ' || p_num || '. Blocksize: ' || p_blocksize, sqlerrm);
  return null;
end num_to_ascii;

/*************************************************************************************************************************************************/

--
-- Generate the public key for RSA
--
function public_key_N (p_prime1 in integer, p_prime2 in integer) return integer
is
begin
  return p_prime1 * p_prime2;

exception when others then
  util.show_error ('Error in function public_key_N. Prime 1: ' || p_prime1 || ', Prime 2: ' || p_prime2, sqlerrm);
  return null;
end public_key_N;

/*************************************************************************************************************************************************/

--
-- Generate the encryption key 
--
function public_key_E (p_prime1 in integer, p_prime2 in integer) return integer
is
l_totient integer := (p_prime1 -1) * (p_prime2 - 1);
l_key     integer;
begin
  l_key := round (dbms_random.value(10000, l_totient));
  while maths.gcd (l_totient, l_key) != 1
  loop
   l_key := round (dbms_random.value (10000, l_totient));
  end loop;
  return l_key;

exception when others then
  util.show_error ('Error in function public_key_E. Prime 1: ' || p_prime1 || ', Prime 2: ' || p_prime2, sqlerrm);
  return null;
end public_key_E;

/*************************************************************************************************************************************************/

--
-- Generate the decryption key 
--
function private_key_D (p_public_key_E in integer, p_prime1 in integer, p_prime2 in integer) return integer
is
l_totient integer := (p_prime1 -1) * (p_prime2 - 1);
l_key     integer;
begin
  l_key := maths.xgcd_first (p_public_key_E, l_totient);
  if l_key < 0 then l_key := l_totient + l_key; end if;
  return l_key;

exception when others then
  util.show_error ('Error in function private_key_D. Key E: ' || p_public_key_E || ', Prime 1: ' || p_prime1 || ', Prime 2: ' || p_prime2, sqlerrm);
  return null;
end private_key_D;

/*************************************************************************************************************************************************/

--
-- Encrypt the text
--
function rsa_encrypt (p_text in varchar2, p_key_N in integer, p_key_E in integer, p_blocksize in integer default 2) return integer_tab pipelined
is
begin
  for j in 1 .. ceil(length(p_text) / p_blocksize)
  loop
    pipe row( integer_row( rsa.power_mod ( ascii_to_num( substr(p_text, 2 * j - 1, 2), p_blocksize) , p_key_E, p_key_N)));
  end loop;

exception when others then
  util.show_error ('Error in function rsa_encrypt N: ' || p_key_N || ' E: ' || p_key_E || ', blocksize: ' || p_blocksize, sqlerrm);
end rsa_encrypt;

/*************************************************************************************************************************************************/

--
-- Decrypt the text
--
function rsa_decrypt (p_num in integer, p_key_N in integer, p_key_D in integer, p_blocksize in integer default 2) return varchar2
is
begin
 return num_to_ascii(rsa.power_mod (p_num, p_key_D, p_key_N), p_blocksize);

exception when others then
  util.show_error ('Error in function rsa_decrypt. num: '|| p_num || ', Key N: ' || p_key_N || ', Key D: ' || ', blocksize: ' || p_blocksize, sqlerrm);
  return null;
end rsa_decrypt;

/*************************************************************************************************************************************************/

--
-- Generate keys based on 2 primes
--
procedure generate_keys (p_prime1 in integer default null, p_prime2 in integer default null)
is
l_debug  integer;
begin
  if p_prime1 is null then p_first_prime := rsa.random_prime; else p_first_prime := p_prime1; end if;
  if p_prime2 is null then p_secondprime := rsa.random_prime; else p_secondprime := p_prime2; end if;

  p_public_key_N  := rsa.public_key_N (p_first_prime, p_secondprime);
  p_public_key_E  := rsa.public_key_E (p_first_prime, p_secondprime);
  p_private_key_D := rsa.private_key_D (p_public_key_E, p_first_prime, p_secondprime);
  p_totient       := (p_first_prime - 1) * (p_secondprime - 1);
  l_debug         := mod (p_public_key_E * p_private_key_D, p_totient);

  dbms_output.put_line ('First  prime  : ' || p_first_prime);
  dbms_output.put_line ('Second prime  : ' || p_secondprime);
  dbms_output.put_line ('Public key N  : ' || p_public_key_N);
  dbms_output.put_line ('Public Key E  : ' || p_public_key_E);
  dbms_output.put_line ('Private Key D : ' || p_private_key_D);
  dbms_output.put_line ('Totient       : ' || p_totient);
  dbms_output.put_line ('Debug         : ' || l_debug);

exception when others then
  util.show_error ('Error in procedure generate_keys for pair:' || p_first_prime || ', ' || p_secondprime, sqlerrm);
end generate_keys;

/*************************************************************************************************************************************************/

--
-- Rabin-Miller primality test
--
function prime_test (p_candidate in integer, p_trials in integer default 64) return number
is
l_remainder      integer := p_candidate - 1;
l_witness        integer;
l_power          integer := 0;
--
function witness (p_candidate in integer, p_remainder in integer, p_power in integer, p_witness in integer) return boolean
is
x integer;
b boolean;
begin
  x := rsa.power_mod (p_witness, p_remainder, p_candidate);
  if x = 1 or x = p_candidate - 1 then return false; end if;

  <<ready>>  
  for r in 0 .. p_power - 1
  loop
    x := mod (x * x, p_candidate);
    if    x = 1
    then b:= true; exit ready;
    elsif x = p_candidate - 1
    then b:= false; exit ready;
    end if;
  end loop;
  return nvl (b,true);
  end witness;
--
begin
  if p_candidate <= 3 or p_candidate in (5,7) then return 1; end if;
 
  while mod (l_remainder, 2) = 0
  loop
    l_remainder := l_remainder / 2;
    l_power     := l_power + 1;
  end loop;
 
  for v in 0 .. p_trials
  loop
    l_witness := round(dbms_random.value (2, 10)); --  random number. To be checked what the range can be.
    if witness(p_candidate, l_remainder, l_power, l_witness) then return 0; end if; 
  end loop;
  return 1;

exception when others then
  util.show_error ('Error in function prime_test. Candidate: ' || p_candidate || '. Trials: ' || p_trials, sqlerrm);
  return null;
end prime_test;

end rsa;
/


create or replace procedure break_rsa
IS 


/*
-- exec maths.init_primes(10000000)

set serveroutput on size unlimited
declare
l_text varchar2(100) := 'Dit is een leuke tekst';
l_dummy varchar2(10);
l_decode_text  varchar2(100) := '';
begin
rsa.generate_keys;  -- (9954761,3895043);
for j in (select * from table( rsa.rsa_encrypt (l_text, rsa.p_public_key_N, rsa.p_public_key_E, p_blocksize => 2)))
loop
--  dbms_output.put_line ('Encode: ' || j.nr);
  l_dummy := rsa.rsa_decrypt (j.nr,  rsa.p_public_key_N, rsa.p_private_key_D, p_blocksize => 2);
--  dbms_output.put_line ('Decode: ' || l_dummy);
  l_decode_text := l_decode_text || l_dummy;
end loop;
dbms_output.put_line (l_decode_text);
end;
/

--Error for:
First  prime : 9954761
Second prime : 3895043
Public key N : 38774222149723
Public Key E :  29933814074929
Private Key D: 2303717433169
Totient      :  38774208299920

-- Todo:
-- http://www.allisons.org/ll/AlgDS/Primes/

create or replace function prime_test (p_candidate in integer, p_trials in integer default 64) return number
is
l_remainder      integer := p_candidate - 1;
l_witness        integer;
l_power          integer := 0;
function witness (p_candidate in integer, p_remainder in integer, p_power in integer, p_witness in integer) return boolean
is
x integer;
b boolean;
begin
x := rsa.power_mod (p_witness, p_remainder, p_candidate);
if x = 1 or x = p_candidate - 1 then return false; end if;
 
<<ready>>
for r in 0 .. p_power - 1
loop
  x := mod (x * x, p_candidate);
  if    x = 1
  then b:= true; exit ready;
  elsif x = p_candidate - 1
  then b:= false; exit ready;
  end if;
end loop;
 
return nvl(b,true);
end witness;
--
begin
if p_candidate <= 3 then return 1; end if;
 
while mod (l_remainder, 2) = 0
loop
  l_remainder := l_remainder / 2;
  l_power     := l_power + 1;
end loop;
 
for v in 0 .. p_trials
loop
  l_witness := round(dbms_random.value (2, 10)); --  random number. To be checked what the range can be.
  if witness(p_candidate, l_remainder, l_power, l_witness) then return 0; end if;
end loop;
 
return 1;
end prime_test;
/

*/
 

https://www.youtube.com/@MichaelPennMath




Wilson extended
m element of N
phi (m) = k
r1, r2, .. rk :   gcf (ri, m) = 1
Note phi (m - 1) = -1 mod (m). because rk and m only differ 1 they are relatively prime.
There exists an inverse s.t. x.ri = 1 mod (m)
so r1 * r2 * .. * r(k-1) = -1 mod (m)

m = 10 gives the set (1,3,7,9) 1.3.7 = 1 mod (10)
m = 12 gives the set (1,5,7,11) 5*5= 1 mod (12) en 7*7 = 1 mod (12)
m = 14 (1,3,5,9,11,13) 3*5 = 1 9*11 = 1
m = 15 (1,2,4,7,8,11,13,14)
2*8=4*4=7*13=11*11=1
 Notes to Wilson extended:
 
 if n ** 2 = 1 mod (m)
 then 
    (m-n) ** 2 = m ** 2 - 2mn + k ** 2 = 1 mod (m)
end If

--Products of squares opposites, conjugates
For every n E {1, .. , m-1 }
n * (m-n) = mn - n ** 2 = - n ** 2 mod (m)
Example
4 ** 2 = 1 mod (15) ; 11 * 2 = 1 mod 15
4 * 11 = -1 mod (15