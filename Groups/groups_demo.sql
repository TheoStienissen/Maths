

======================================================================================================================


-- Demo's

set serveroutput on size unlimited

declare
l_group  group_pkg.group_ty;
l_poly   integer(2) := 7;
begin
group_pkg.init(l_group, l_poly);
--group_pkg.print(l_group);
for j in 1 .. l_poly
loop
  l_group := group_pkg.rotate(l_group);
  dbms_output.put('R:  ');
  group_pkg.print(l_group);
  dbms_output.put('F:  ');
  group_pkg.print(group_pkg.flip(l_group));
end loop;
--group_pkg.print(l_group);
end;
/

declare
l_group  group_pkg.group_ty;
l_poly   integer(2) := 8;
begin
l_group := group_pkg.string_to_group('F', l_poly);
group_pkg.print(l_group);
end;
/


declare
l_group  group_pkg.group_ty;
l_poly   integer(2) := 7;
l_dummy  integer;
begin
delete from cayley_lookup where g_order = l_poly;
group_pkg.rf_init (l_group, l_poly);
-- Rotations
for j in 1 .. l_poly
loop
  l_dummy := group_pkg.rf_group_to_integer (l_group);
  insert into cayley_lookup (g_order, string_code, int_code) values (l_poly, nvl(substr (rpad ('R', j, 'R'), 2), 1), l_dummy);
  l_group := group_pkg.rotate (l_group);
end loop;

-- Flip + Rotations
l_group := group_pkg.rf_flip (l_group);
for j in 1 .. l_poly
loop
  l_dummy := group_pkg.rf_group_to_integer (l_group);
  insert into cayley_lookup (g_order, string_code, int_code) values (l_poly, rpad('F', j, 'R'), l_dummy);
  l_group := group_pkg.rf_rotate(l_group);
end loop;
--group_pkg.rf_print(l_group);
end;
/

begin
  group_pkg.rf_fill_cayley_lookup_table(7);
end;
/

begin
  group_pkg.rf_show_cayley_table(7);
end;
/

select group_pkg.rf_string_order('FR', 7) from dual;

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


-- Conversion of groups into cycles and reverse cycles into groups.
set serveroutput on size unlimited
declare
l_group group_pkg.group_ty;
l_cycle group_pkg.cycle_ty;
begin
l_group := group_pkg.rf_init(13);
l_group := group_pkg.rf_string_to_group ('RRR', 13);
group_pkg.rf_print(l_group);
--
l_cycle := group_pkg.permutation_to_cycles(l_group);
group_pkg.print_cycles(l_cycle);
l_group := group_pkg.cycles_to_group(l_cycle, 13);
group_pkg.rf_print(l_group);
end;
/
