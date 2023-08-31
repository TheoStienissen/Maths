/*

-- Target      : Basic group functions / symmetries
-- Contents    : Metadata + examples
-- Location    : C:\Users\Theo\OneDrive\Theo\Project\Maths\Groups\groups1.6.sql

-- Creator     : Theo Stienissen
-- Date        : August 2021
-- Last update : August 2021

ToDo : Kernel / Abelian subgroups / Center / Save group / load group
     : modulo groups /

Three types of groups:
R  : Rotations
RF : Rotate and flips. R < RF
MM : Modulo Multiply. E.g.: U10 = { 1, 3, 7, 9}
MA : Modulo Add. E.g.: Z12 = { 0, 1, 2, .., 11} (Zahlen or all whole numbers)
P  : Permutation group ASCII
S  : Symmeties
I  : integer values from 0 until p_order - 1

*/

drop table cayley_ref_lookup cascade constraints;
drop table cayley_lookup;
create table cayley_lookup
( g_order     number(3, 0)
, string_code varchar2(200)
, int_code    number(38,0));

create unique index cayley_lookup_uk1 on cayley_lookup (string_code, int_code);
create unique index cayley_lookup_uk2 on cayley_lookup (g_order, string_code);

drop type MyPermutations_row;
drop type MyPermutations_ty;

create or replace type MyPermutations_ty as object (permutation varchar2(30));
/

create or replace type MyPermutations_row as table of MyPermutations_ty;
/


create or replace package group_pkg
is
type group_ty is table of integer  index by binary_integer;
type cycle_ty is table of varchar2(200) index by binary_integer;
g_group group_ty;
g_cycle cycle_ty;

function  show_permutations (p_order in integer, p_type in varchar2) return MyPermutations_row pipelined;

procedure rf_init (p_group in out group_ty, p_corners in integer);

procedure rf_print (p_group in group_ty);

function  rf_rotate (p_group in group_ty, p_order in integer default 1) return group_ty;

function  rf_flip   (p_group in group_ty) return group_ty;

function  rf_group_to_integer (p_group in group_ty) return integer;

function  rf_integer_to_group (p_int_code in integer) return group_ty;

function  rf_string_to_group (p_string in varchar2, p_order in integer default null) return group_ty;

function  rf_group_to_string (p_group in group_ty) return varchar2;

function  rf_string_order (p_string in varchar2, p_order in integer) return integer;

procedure rf_fill_cayley_lookup_table (p_order in integer, p_empty boolean default true);

function  rf_inverse (p_value in varchar2, p_order in integer) return varchar2;

procedure rf_show_cayley_table (p_order in integer);

function  mm_multiply (p_value1 in integer, p_value2 in integer, p_modulo in integer) return integer;

function  mm_order (p_value in integer, p_modulo in integer) return integer;

function  mm_inverse (p_value in integer, p_modulo in integer) return integer;

procedure mm_show_cayley_table (p_order in integer);

function  ma_add (p_value1 in integer, p_value2 in integer, p_modulo in integer) return integer;

function  ma_order (p_value in integer, p_modulo in integer) return integer;

function  ma_inverse (p_value in integer, p_modulo in integer) return integer;

procedure ma_show_cayley_table (p_order in integer);

function  cell_padding (p_val in varchar2, p_order in integer, p_marker in varchar2, p_pad_char in varchar2 default ' ') return varchar2;

procedure print_cel (p_val in varchar2, p_order in integer, p_pad_char in varchar2 default '|');

procedure print_line (p_fields in integer, p_order in integer, p_pad_char in varchar2 default '+');

procedure print_cycles (p_cycle in cycle_ty);

function  present_in_cycle (p_value in varchar2, p_cycle in cycle_ty) return boolean;

function  permutation_to_cycles (p_permutation in varchar2) return cycle_ty;

function  cycle_to_permutation (p_cycle in cycle_ty) return varchar2;

end group_pkg;
/

create or replace package body group_pkg
is

function  show_permutations (p_order in integer, p_type in varchar2) return MyPermutations_row pipelined
is 
l_char   varchar2(2);
begin 
if upper (p_type) = 'R'
then
  for r in (select nvl (substr (rpad ('R', level, 'R'), 2), 1) val from dual connect by level <= p_order)
  loop 
    pipe row (MyPermutations_ty (r.val));
  end loop;
elsif upper (p_type) = 'RF'
then
  for rf in (select nvl (substr (rpad ('R', level, 'R'), 2), 1) val from dual connect by level <= p_order
             union all
             select rpad ('F', level , 'R') from dual connect by level <= p_order)
  loop 
    pipe row (MyPermutations_ty (rf.val));
  end loop;
elsif upper (p_type) = 'I'
then 
  for j in 0 .. p_order - 1
  loop 
    pipe row (MyPermutations_ty (to_char (j)));
  end loop;
elsif upper (p_type) = 'P'
then 
  if    p_order = 1
  then
    pipe row (MyPermutations_ty ('A'));
  elsif p_order = 2
  then
    pipe row (MyPermutations_ty ('AB'));
    pipe row (MyPermutations_ty ('BA'));
  elsif p_order >= 3
  then
    l_char := chr (ascii ('A') - 1 + p_order);
    for pm in (select permutation from table (show_permutations (p_order - 1, 'P')))
    loop
      for j in 1 .. p_order
      loop
        pipe row (MyPermutations_ty (substr (pm.permutation, 1, j - 1) || l_char || substr (pm.permutation, j )));
      end loop;
    end loop;
  end if;
elsif upper (p_type) = 'S'
then
  if    p_order = 1
  then
    pipe row (MyPermutations_ty ('1'));
  elsif p_order = 2
  then
    pipe row (MyPermutations_ty ('12'));
    pipe row (MyPermutations_ty ('21'));
  elsif p_order >= 3
  then
    l_char := p_order;
    for pm in (select permutation from table (show_permutations (p_order - 1, 'S')))
    loop
      for j in 1 .. p_order
      loop
        pipe row (MyPermutations_ty (substr (pm.permutation, 1, j - 1) || l_char || substr (pm.permutation, j )));
      end loop;
    end loop;
  end if; 
end if;
  
exception when others 
then 
  util.show_error ('Error in function  show_permutations', sqlerrm);
end show_permutations;

/***************************************************************************************************/

-- Self explanatory
procedure rf_init (p_group in out group_ty, p_corners in integer)
is
begin
  p_group.delete;
  for j in 1 .. p_corners
  loop 
    p_group (j) := j;
  end loop;
  
exception when others 
then 
  util.show_error ('Error in procedure rf_init', sqlerrm);
end rf_init;

/***************************************************************************************************/

-- Print array of values to the screen
procedure rf_print (p_group in group_ty)
is
begin
  for j in 1 .. p_group.count
  loop 
    dbms_output.put (to_char (p_group (j), '990'));
  end loop;
  dbms_output.new_line;
  
exception when others 
then 
  util.show_error ('Error in procedure rf_print', sqlerrm);
end rf_print;

/***************************************************************************************************/

-- Clockwise rotation
function rf_rotate (p_group in group_ty, p_order in integer default 1) return group_ty
is
  l_group  group_ty := p_group;
  l_result group_ty;
begin
  for n in 1 .. p_order
  loop
    l_result(1) := l_group (p_group.count);
    for j in  1 .. l_group.count - 1
    loop 
      l_result (j + 1) := l_group (j);
    end loop;
    l_group := l_result;  
  end loop;
  return l_result;

exception when others 
then 
  util.show_error ('Error in function rf_rotate', sqlerrm);
end rf_rotate;

/***************************************************************************************************/

-- Mirror
function rf_flip   (p_group in group_ty) return group_ty
is
l_result  group_ty;
begin
  for j in 1 .. p_group.count
  loop 
    l_result (j) := p_group (p_group.count + 1 - j);
  end loop;
  return l_result;

exception when others 
then 
  util.show_error ('Error in function rf_flip', sqlerrm);
end rf_flip;

/***************************************************************************************************/

-- Automorphism: symmetries <-> integers
function rf_group_to_integer (p_group in group_ty) return integer
is
l_result integer := 0;
begin
  for j in 1 .. p_group.count
  loop
    l_result := 10 * l_result + p_group (j);
  end loop;
  return l_result;
  
exception when others 
then 
  util.show_error ('Error in function rf_group_to_integer', sqlerrm);
end rf_group_to_integer;

/***************************************************************************************************/

function  rf_integer_to_group (p_int_code in integer) return group_ty
is
l_group group_ty;
begin
  for j in 1 .. length(p_int_code)
  loop 
    l_group(j) := substr(p_int_code, j, 1);
  end loop;
  return l_group;

exception when others 
then 
  util.show_error ('Error in function rf_integer_to_group', sqlerrm);
end rf_integer_to_group;

/***************************************************************************************************/

-- Second automorphism: string <-> group
function rf_string_to_group (p_string in varchar2, p_order in integer default null) return group_ty
is
l_group group_ty;
l_order integer := nvl (p_order, length (p_string));
begin
  group_pkg.rf_init (l_group, l_order);
  for j in 1 .. length(p_string)
  loop
    if    upper (substr (p_string, j, 1)) = 'R'
    then  l_group := group_pkg.rf_rotate (l_group);
    elsif upper (substr (p_string, j, 1)) = 'F'
    then  l_group := group_pkg.rf_flip (l_group);
    end if;
  end loop;
  return l_group;

exception when others 
then 
  util.show_error ('Error in function rf_string_to_group', sqlerrm);
end rf_string_to_group;

/***************************************************************************************************/

function  rf_group_to_string (p_group in group_ty) return varchar2
is
l_string   varchar2(200);
l_int_code integer;
begin
  l_int_code := rf_group_to_integer (p_group);
  select string_code into l_string from cayley_lookup where int_code = l_int_code;
  return l_string;

exception when others 
then 
  util.show_error ('Error in function rf_group_to_string', sqlerrm);
end rf_group_to_string;

/***************************************************************************************************/

function  rf_string_order (p_string in varchar2, p_order in integer) return integer
is
l_string  varchar2(200) := p_string;
l_order   integer := 1;
begin
  for n in 1 .. p_order + 1
  loop
    exit when l_string = '1';
	l_string := rf_group_to_string (group_pkg.rf_string_to_group (p_string || l_string, p_order));
    l_order := l_order + 1;
  end loop;
  if l_order < p_order + 1
  then return l_order;
  else return -1;
  end if;
  
exception when others 
then 
  util.show_error ('Error in function rf_string_order', sqlerrm);
end rf_string_order;

/***************************************************************************************************/

procedure rf_fill_cayley_lookup_table (p_order in integer, p_empty boolean default true)
is
l_group  group_pkg.group_ty;
l_dummy  integer;
begin
  if p_empty then delete from cayley_lookup where g_order = p_order; end if;
  group_pkg.rf_init (l_group, p_order);

-- Rotations
  for j in 1 .. p_order
  loop
    l_dummy := group_pkg.rf_group_to_integer (l_group);
    insert into cayley_lookup (g_order, string_code, int_code) values (p_order, nvl(substr (rpad ('R', j, 'R'), 2), 1), l_dummy);
    l_group := group_pkg.rf_rotate (l_group);
  end loop;

-- Flip + Rotations
  l_group := group_pkg.rf_flip (l_group);
  for j in 1 .. p_order
  loop
    l_dummy := group_pkg.rf_group_to_integer (l_group);
    insert into cayley_lookup (g_order, string_code, int_code) values (p_order, rpad('F', j, 'R'), l_dummy);
    l_group := group_pkg.rf_rotate(l_group);
  end loop;
  commit;

exception when others 
then 
  util.show_error ('Error in procedure rf_fill_cayley_lookup_table', sqlerrm);
end rf_fill_cayley_lookup_table;

/***************************************************************************************************/

function  rf_inverse (p_value in varchar2, p_order in integer) return varchar2
is 
l_return varchar2 (200);
begin 
  <<done>>
  for j in (select string_code from cayley_lookup where g_order = p_order)
  loop 
    if group_pkg.rf_group_to_string (group_pkg.rf_string_to_group (p_value || j.string_code, p_order)) = '1'
    then
      l_return := j.string_code;
      exit done;
    end if;
  end loop;
  return l_return;

exception when others 
then 
  util.show_error ('Error in function  rf_inverse', sqlerrm);
end rf_inverse;

/***************************************************************************************************/

procedure rf_show_cayley_table (p_order in integer)
is
l_group  group_pkg.group_ty;
l_int_code integer;
l_string varchar2(200);
begin
group_pkg.rf_fill_cayley_lookup_table (p_order);

-- Heading
print_cel ('Y*X', p_order + 1); 
for h in (select permutation valh from table (group_pkg.show_permutations (p_order,'RF')))
loop
  print_cel (h.valh, p_order);
end loop;
dbms_output.new_line;
print_line (2 * p_order + 1, p_order);

-- Table
for y in (select permutation valy from table (group_pkg.show_permutations (p_order,'RF')))
loop
  print_cel(y.valy, p_order);
  for x in (select permutation valx from table (group_pkg.show_permutations (p_order,'RF')))
  loop 
    l_group := group_pkg.rf_string_to_group (y.valy || x.valx, p_order); -- 2 Operations
	l_int_code := group_pkg.rf_group_to_integer (l_group);
	select string_code into l_string from cayley_lookup where int_code = l_int_code and g_order = p_order;
	print_cel (l_string, p_order);
  end loop;
  dbms_output.new_line;
  print_line (2 * p_order + 1, p_order);
end loop;

exception when others 
then 
  util.show_error ('Error in procedure rf_show_cayley_table', sqlerrm);
end rf_show_cayley_table;

/***************************************************************************************************/

function  mm_multiply (p_value1 in integer, p_value2 in integer, p_modulo in integer) return integer
is
begin 
  return mod (p_value1 * p_value2, p_modulo);

exception when others 
then 
  util.show_error ('Error in function  mm_multiply', sqlerrm);
end mm_multiply;

/***************************************************************************************************/

function  mm_order (p_value in integer, p_modulo in integer) return integer
is
l_order integer;
begin 
  <<done>>
  for j in 1 .. p_modulo + 1
  loop 
    l_order := j;
    exit done when mod (power (p_value, j), p_modulo) = 1;  
  end loop;
  if l_order < p_modulo + 1
  then return l_order;
  else return -1;
  end if;

exception when others 
then 
  util.show_error ('Error in function mm_order', sqlerrm);
end mm_order;

/***************************************************************************************************/

function  mm_inverse (p_value in integer, p_modulo in integer) return integer
is 
l_inverse integer;
begin 
  <<done>>
  for j in 1 .. p_modulo + 1
  loop 
    l_inverse := j;
    exit done when mod (p_value * j, p_modulo) = 1;  
  end loop;
  if l_inverse < p_modulo + 1
  then return l_inverse;
  else return -1;
  end if;

exception when others 
then 
  util.show_error ('Error in function mm_inverse', sqlerrm);
end mm_inverse;

/***************************************************************************************************/

procedure mm_show_cayley_table (p_order in integer)
is 
begin 
-- Heading
  print_cel ('M*', p_order + 1);
  for h in 0 .. p_order - 1
  loop
    print_cel (h, p_order);
  end loop;
  dbms_output.new_line;
  print_line (p_order + 1, p_order);

-- Table
  for y in 0 .. p_order - 1
  loop 
    print_cel (y, p_order);
    for x in 0 .. p_order - 1
    loop 
      print_cel (mm_multiply (y, x, p_order), p_order);
    end loop;
    dbms_output.new_line;
    print_line (p_order + 1, p_order);
  end loop;

exception when others 
then 
  util.show_error ('Error in procedure mm_show_cayley_table', sqlerrm);
end mm_show_cayley_table;

/***************************************************************************************************/

function  ma_add (p_value1 in integer, p_value2 in integer, p_modulo in integer) return integer
is
begin 
  return mod (p_value1 + p_value2, p_modulo);

exception when others 
then 
  util.show_error ('Error in function  ma_add', sqlerrm);
end ma_add;

/***************************************************************************************************/

function  ma_order (p_value in integer, p_modulo in integer) return integer
is 
l_order integer;
begin 
  <<done>>
  for j in 1 .. p_modulo + 1
  loop 
    l_order := j;
    exit done when mod (p_value + j, p_modulo) = 0;  
  end loop;
  if l_order < p_modulo + 1
  then return l_order;
  else return -1;
  end if;

exception when others 
then 
  util.show_error ('Error in function ma_order', sqlerrm);
end ma_order;

/***************************************************************************************************/

function  ma_inverse (p_value in integer, p_modulo in integer) return integer
is 
begin 
  return mod ( 2 * p_modulo - p_value, p_modulo);

exception when others 
then 
  util.show_error ('Error in function ma_inverse', sqlerrm);
end ma_inverse;

/***************************************************************************************************/

procedure ma_show_cayley_table (p_order in integer)
is 
begin 
-- Heading
  print_cel ('M+', p_order + 1);
  for h in 0 .. p_order - 1
  loop
    print_cel (h, p_order);
  end loop;
  dbms_output.new_line;
  print_line (p_order + 1, p_order);

-- Table
  for y in 0 .. p_order - 1
  loop 
    print_cel(y, p_order);
    for x in 0 .. p_order - 1
    loop 
      print_cel (ma_add (y, x, p_order), p_order);
    end loop;
    dbms_output.new_line;
    print_line (p_order + 1, p_order);
  end loop;

exception when others 
then 
  util.show_error ('Error in procedure ma_show_cayley_table', sqlerrm);
end ma_show_cayley_table;

/***************************************************************************************************/

-- Output formatting. 1 Function + 2 Procedures
function cell_padding (p_val in varchar2, p_order in integer, p_marker in varchar2, p_pad_char in varchar2 default ' ') return varchar2 
is 
begin
  return p_pad_char || rpad(p_val, p_order + 1, p_pad_char) || p_marker;
  
exception when others 
then 
  util.show_error ('Error in function cell_padding', sqlerrm);
end cell_padding;

/***************************************************************************************************/

procedure print_cel (p_val in varchar2, p_order in integer, p_pad_char in varchar2 default '|')
is 
begin
  dbms_output.put (cell_padding(p_val, p_order, p_pad_char));

exception when others 
then 
  util.show_error ('Error in procedure print_cel', sqlerrm);
end print_cel;

/***************************************************************************************************/

procedure print_line (p_fields in integer, p_order in integer, p_pad_char in varchar2 default '+')
is 
begin
  for j in 1 .. p_fields
  loop
    dbms_output.put (cell_padding ('-', p_order, '+', '-'));
  end loop;
  dbms_output.new_line;
  
exception when others 
then 
  util.show_error ('Error in procedure print_line', sqlerrm);
end print_line;

/***************************************************************************************************/

procedure print_cycles (p_cycle in cycle_ty)
is 
l_found   boolean := false;
begin 
  for j in 1 .. p_cycle.count 
  loop
    dbms_output.put_line ( '(' || p_cycle (j) || ')');
  end loop;
exception when others 
then 
  util.show_error ('Error in procedure print_cycles', sqlerrm);
end print_cycles;

/***************************************************************************************************/

function  present_in_cycle (p_value in varchar2, p_cycle in cycle_ty) return boolean
is 
l_found   boolean := false;
begin
  if p_cycle.count is not null
  then
    <<done>>
    for j in 1 .. p_cycle.count 
    loop
      l_found := instr (p_cycle (j), p_value) > 0;
      exit done when l_found;
    end loop;
  end if;
  return l_found;

exception when others 
then 
  util.show_error ('Error in function present_in_cycle', sqlerrm);
end present_in_cycle;

/***************************************************************************************************/

-- ToDo
function  permutation_to_cycles (p_permutation in varchar2) return cycle_ty
is
l_cycle       cycle_ty;
l_cycle_count integer (2) := 1;
l_pos         varchar2 (10);
l_char        varchar2(1);
begin
for j in 1 .. length (p_permutation)
loop
  l_pos := substr (p_permutation, j, 1);
  if l_pos != j and not present_in_cycle (l_pos, l_cycle)
  then
    l_cycle (l_cycle_count) := to_char (j);
	while l_pos != to_char (j)
	loop
	  l_cycle (l_cycle_count) := l_cycle (l_cycle_count) || l_pos;
	  l_pos := substr (p_permutation, l_pos, 1);
	end loop;  
    l_cycle_count := l_cycle_count + 1;  
  end if;
end loop;
  return l_cycle;  
  
exception when others 
then 
  util.show_error ('Error in function permutation_to_cycles', sqlerrm);
end permutation_to_cycles;

/***************************************************************************************************/

-- ToDo
function  cycle_to_permutation (p_cycle in cycle_ty) return varchar2
is
l_cycle cycle_ty;
l_string varchar2(200);
begin
  return l_string;

exception when others 
then 
  util.show_error ('Error in function cycle_to_permutation', sqlerrm);
end cycle_to_permutation;

end group_pkg;
/

show error