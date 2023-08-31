declare
type         int_array_ty is table of integer index by pls_integer;
l_digit      int_array_ty;
l_rest       integer;
l_save       integer;
-- Faculty of primes
function pfac (n in integer) return integer
is
begin
if n   <= 0 then return 1;
elsif n = 1 then return 2;
else return maths.p_prime_tab(n) * pfac(n-1);
end if;
end pfac;
-- 
procedure print (p_array in int_array_ty)
is
begin
for j in reverse 0 .. p_array.count -2
loop
  if j = p_array.count -2 then dbms_output.put('('); end if;
  dbms_output.put(l_digit(j));
  if j = 0 then dbms_output.put(')'); else dbms_output.put(', '); end if;
end loop;
dbms_output.new_line;
end print;
--
procedure print_formula (p_array in int_array_ty)
is
begin
for j in reverse 0 .. p_array.count -2
loop
  dbms_output.put(l_digit(j) || ' * ' || pfac(j));
  if j != 0 then dbms_output.put(' + '); end if;
end loop;
dbms_output.new_line;
end print_formula;
--
function to_pfac (p_in in integer) return int_array_ty
is 
l_index       integer := 0;
l_prime_digit int_array_ty;
l_remain      integer := p_in;
begin
while l_remain > pfac(l_index)
loop
  l_index := l_index + 1;
end loop;

for j in reverse 1 .. l_index
loop
  l_prime_digit(j) := trunc(l_remain/pfac(j));
  l_remain  := l_remain - l_prime_digit(j) * pfac(j);
end loop;
if l_remain = 0 then l_prime_digit(0) := 0; else l_prime_digit(0) := 1; end if;

return l_prime_digit;
end to_pfac;
--
function to_integer (p_digits int_array_ty) return integer
is
l_result integer := 0;
begin
for j in 0 .. p_digits.count - 2
loop
  l_result := l_result + p_digits(j) * pfac(j);
end loop;
  return l_result;
end to_integer;
--
begin
l_save  := dbms_random.value(100, 1000);

for j in 1 .. 10
loop
  l_rest := power(l_save, j);
  dbms_output.put('Power = '  || j || '.  ' || l_rest || ' = ');
  l_digit := to_pfac(l_rest);
--  print_formula(l_digit);
  print(l_digit);
end loop;

-- dbms_output.put_line('Result: ' || to_integer(l_digit));
end;
/



