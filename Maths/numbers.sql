create or replace package numbers
as

function prime_range (p_start in integer, p_stop in integer) return integer_tab pipelined;

function not_prime_range (p_start in integer, p_stop in integer) return integer_tab pipelined;

end numbers;
/

create or replace package body numbers
as

-- select * from table( numbers.prime_range(20,550));
function prime_range (p_start in integer, p_stop in integer) return integer_tab pipelined
is
begin
if maths.p_prime_tab.count = 0 then maths.init_primes(greatest(1e6,p_stop)); end if;
<<ready>>
for j in 1 .. maths.p_prime_tab.count
loop
  if maths.p_prime_tab(j) between p_start and p_stop
  then
    pipe row (integer_row(maths.p_prime_tab(j)));
  end if;
  exit ready when maths.p_prime_tab(j) > p_stop;
end loop;

exception when others then
  util.show_error('Error in function prime_range.' , sqlerrm);
end prime_range;

/*************************************************************************************************************************************************/

-- select * from table( numbers.not_prime_range(20,550));
function not_prime_range (p_start in integer, p_stop in integer) return integer_tab pipelined
is
begin
for j in p_start .. p_stop
loop
  if not maths.is_prime(j)
  then
    pipe row (integer_row(j));
  end if;
end loop;

exception when others then
  util.show_error('Error in function not_prime_range.' , sqlerrm);
end not_prime_range;

end numbers;
/
