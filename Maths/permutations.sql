drop type MyPermutations_row;
drop type MyPermutations_ty;
drop function f_permutations;

create or replace type MyPermutations_ty as object (permutation varchar2(30));
/

create or replace type MyPermutations_row as table of MyPermutations_ty;
/

 
create or replace function f_permutations (p_depth in integer) return MyPermutations_row pipelined
is
l_char   varchar2(2);
begin
if    p_depth = 1
then
  pipe row (MyPermutations_ty ('A'));
elsif p_depth = 2
then
  pipe row (MyPermutations_ty ('AB'));
  pipe row (MyPermutations_ty ('BA'));
elsif p_depth >= 3
then
  l_char := chr (ascii ('A') - 1 + p_depth);
  for pm in (select permutation from table (f_permutations (p_depth - 1)))
  loop
    for j in 1 .. p_depth
    loop
      pipe row (MyPermutations_ty (substr (pm.permutation, 1, j - 1) || l_char || substr (pm.permutation, j )));
    end loop;
  end loop;
end if;
end;
/

-- Demo
select * from table( f_permutations(4)) order by 1;
 
create or replace function f_permutations2 (p_depth in integer) return MyPermutations_row pipelined
is
l_char   varchar2(2);
begin
if    p_depth = 1
then
  pipe row (MyPermutations_ty ('1'));
elsif p_depth = 2
then
  pipe row (MyPermutations_ty ('12'));
  pipe row (MyPermutations_ty ('21'));
elsif p_depth >= 3
then
  l_char := chr (ascii ('1') - 1 + p_depth);
  for pm in (select permutation from table (f_permutations2 (p_depth - 1)))
  loop
    for j in 1 .. p_depth
    loop
      pipe row (MyPermutations_ty (substr (pm.permutation, 1, j - 1) || l_char || substr (pm.permutation, j )));
    end loop;
  end loop;
end if;
end;
/

-- Demo:
select * from table( f_permutations2(4)) order by 1;



