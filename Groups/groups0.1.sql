doc

-- Target      : Basic group functions / sysmmetries
-- Contents    : Metadata + examples

-- Creator     : Theo Stienissen
-- Date        : August 2021
-- Last update : August 2021

ToDo : Kernel / Abelian subgroups / Center / Save group / load group
     : modulo groups /

#

create table cayley_lookup
( g_order     number(3, 0)
, string_code varchar2(200)
, int_code    number(38,0));

create unique index cayley_lookup_uk1 on cayley_lookup (string_code, int_code);
create unique index cayley_lookup_uk2 on cayley_lookup (g_order, string_code);


create or replace package group_pkg
is
type group_ty is table of integer index by binary_integer;
g_group group_ty;

procedure init (p_group in out group_ty, p_corners in integer);

procedure print (p_group in group_ty);

function  rotate (p_group in group_ty, p_order in integer default 1) return group_ty;

function  flip   (p_group in group_ty) return group_ty;

function  group_to_integer (p_group in group_ty) return integer;

function  integer_to_group (p_int_code in integer) return group_ty;

function  string_to_group (p_string in varchar2, p_order in integer default null) return group_ty;

function  group_to_string (p_group in group_ty) return varchar2;

function  string_order (p_string in varchar2, p_order in integer) return integer;

procedure fill_cayley_table (p_order in integer, p_empty boolean default true);

procedure show_cayley_table (p_order in integer);

function  cell_padding (p_val in varchar2, p_order in integer, p_marker in varchar2, p_pad_char in varchar2 default ' ') return varchar2;

procedure print_cel (p_val in varchar2, p_order in integer, p_pad_char in varchar2 default '|');

procedure print_line (p_order in integer, p_pad_char in varchar2 default '+');

end group_pkg;
/

create or replace package body group_pkg
is

procedure init (p_group in out group_ty, p_corners in integer)
is
begin
  p_group.delete;
  for j in 1 .. p_corners
  loop 
    p_group(j) := j;
  end loop;
  
exception when others 
then 
  util.show_error ('Error in procedure init', sqlerrm);
end init;

/***************************************************************************************************/

procedure print (p_group in group_ty)
is
begin
  for j in 1 .. p_group.count
  loop 
    dbms_output.put(to_char(p_group(j), '990'));
  end loop;
  dbms_output.new_line;
  
exception when others 
then 
  util.show_error ('Error in procedure print', sqlerrm);
end print;

/***************************************************************************************************/
-- Clockwise rotation
function rotate (p_group in group_ty, p_order in integer default 1) return group_ty
is
  l_group  group_ty := p_group;
  l_result group_ty;
begin
  for n in 1 .. p_order
  loop
    l_result(1) := l_group (p_group.count);
    for j in  1 .. l_group.count - 1
    loop 
      l_result(j + 1) := l_group(j);
    end loop;
    l_group := l_result;  
  end loop;
  return l_result;

exception when others 
then 
  util.show_error ('Error in function rotate', sqlerrm);
end rotate;

/***************************************************************************************************/

function flip   (p_group in group_ty) return group_ty
is
l_result  group_ty;
begin
  for j in 1 .. p_group.count
  loop 
    l_result (j) := p_group(p_group.count + 1 - j);
  end loop;
  return l_result;

exception when others 
then 
  util.show_error ('Error in function flip', sqlerrm);
end flip;

/***************************************************************************************************/

function group_to_integer (p_group in group_ty) return integer
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
  util.show_error ('Error in function group_to_integer', sqlerrm);
end group_to_integer;

/***************************************************************************************************/

function  integer_to_group (p_int_code in integer) return group_ty
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
  util.show_error ('Error in function integer_to_group', sqlerrm);
end integer_to_group;

/***************************************************************************************************/

-- RRRFR ..
function string_to_group (p_string in varchar2, p_order in integer default null) return group_ty
is
l_group group_ty;
l_order integer := nvl(p_order, length(p_string));
begin
  group_pkg.init(l_group, l_order);
  for j in 1 .. length(p_string)
  loop
    if    upper(substr(p_string, j, 1)) = 'R'
    then  l_group := group_pkg.rotate (l_group);
    elsif upper(substr(p_string, j, 1)) = 'F'
    then  l_group := group_pkg.flip (l_group);
    end if;
  end loop;
  return l_group;

exception when others 
then 
  util.show_error ('Error in function string_to_group', sqlerrm);
end string_to_group;

/***************************************************************************************************/

function  group_to_string (p_group in group_ty) return varchar2
is
l_string   varchar2(200);
l_int_code integer;
begin
  l_int_code := group_to_integer (p_group);
  select string_code into l_string from cayley_lookup where int_code = l_int_code;
  return l_string;

exception when others 
then 
  util.show_error ('Error in function group_to_string', sqlerrm);
end group_to_string;

/***************************************************************************************************/

function  string_order (p_string in varchar2, p_order in integer) return integer
is
l_string  varchar2(200) := p_string;
l_order   integer := 1;
l_group   group_ty;
begin
  for n in 1 .. p_order + 1
  loop
    exit when l_string = '1';
	l_string := group_to_string (group_pkg.string_to_group (p_string || l_string, p_order));
    l_order := l_order + 1;
  end loop;
  return l_order;
  
exception when others 
then 
  util.show_error ('Error in function string_order', sqlerrm);
end string_order;

/***************************************************************************************************/

procedure fill_cayley_table (p_order in integer, p_empty boolean default true)
is
l_group  group_pkg.group_ty;
l_dummy  integer;
begin
  if p_empty then delete from cayley_lookup where g_order = p_order; end if;
  group_pkg.init(l_group, p_order);

-- Rotations
  for j in 1 .. p_order
  loop
    l_dummy := group_pkg.group_to_integer (l_group);
    insert into cayley_lookup (g_order, string_code, int_code) values (p_order, nvl(substr (rpad ('R', j, 'R'), 2), 1), l_dummy);
    l_group := group_pkg.rotate (l_group);
  end loop;

-- Flip + Rotations
  l_group := group_pkg.flip (l_group);
  for j in 1 .. p_order
  loop
    l_dummy := group_pkg.group_to_integer (l_group);
    insert into cayley_lookup (g_order, string_code, int_code) values (p_order, rpad('F', j, 'R'), l_dummy);
    l_group := group_pkg.rotate(l_group);
  end loop;
  commit;

exception when others 
then 
  util.show_error ('Error in procedure fill_cayley_table', sqlerrm);
end fill_cayley_table;

/***************************************************************************************************/

procedure show_cayley_table (p_order in integer)
is
l_group  group_pkg.group_ty;
l_int_code integer;
l_string varchar2(200);
begin
group_pkg.fill_cayley_table(p_order);

-- Heading
print_cel('Y*X', p_order + 1);
for h in (select nvl(substr (rpad ('R', level, 'R'), 2), 1) valh from dual connect by level <= p_order
          union all
          select rpad('F', level , 'R') from dual connect by level <= p_order)
loop
  print_cel(h.valh, p_order);
end loop;
dbms_output.new_line;
print_line (p_order);

-- Table
for y in (select nvl(substr (rpad ('R', level, 'R'), 2), 1) valy from dual connect by level <= p_order
          union all
          select rpad('F', level , 'R') from dual connect by level <= p_order)
loop
  print_cel(y.valy, p_order);
  for x in (select nvl(substr (rpad ('R', level, 'R'), 2), 1) valx from dual connect by level <= p_order
            union all
            select rpad('F', level , 'R') from dual connect by level <= p_order)
  loop 
    l_group := group_pkg.string_to_group (y.valy || x.valx, p_order); -- 2 Operations
	l_int_code := group_pkg.group_to_integer(l_group);
	select string_code into l_string from cayley_lookup where int_code = l_int_code and g_order = p_order;
	print_cel(l_string, p_order);
  end loop;
  dbms_output.new_line;
  print_line (p_order);
end loop;

exception when others 
then 
  util.show_error ('Error in procedure show_cayley_table', sqlerrm);
end show_cayley_table;

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
  dbms_output.put(cell_padding(p_val, p_order, p_pad_char));

exception when others 
then 
  util.show_error ('Error in procedure print_cel', sqlerrm);
end print_cel;

/***************************************************************************************************/

procedure print_line (p_order in integer, p_pad_char in varchar2 default '+')
is 
begin
for j in 1 .. p_order * 2 + 1
loop
  dbms_output.put(cell_padding ('-', p_order, '+', '-'));
end loop;
  dbms_output.new_line;
  
exception when others 
then 
  util.show_error ('Error in procedure print_line', sqlerrm);
end print_line;

end group_pkg;
/


======================================================================================================================


-- Demo's

set serveroutput on size UNLIMITED

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
group_pkg.init (l_group, l_poly);
-- Rotations
for j in 1 .. l_poly
loop
  l_dummy := group_pkg.group_to_integer (l_group);
  insert into cayley_lookup (g_order, string_code, int_code) values (l_poly, nvl(substr (rpad ('R', j, 'R'), 2), 1), l_dummy);
  l_group := group_pkg.rotate (l_group);
end loop;

-- Flip + Rotations
l_group := group_pkg.flip (l_group);
for j in 1 .. l_poly
loop
  l_dummy := group_pkg.group_to_integer (l_group);
  insert into cayley_lookup (g_order, string_code, int_code) values (l_poly, rpad('F', j, 'R'), l_dummy);
  l_group := group_pkg.rotate(l_group);
end loop;
--group_pkg.print(l_group);
end;
/

begin
  group_pkg.fill_cayley_table(7);
end;
/

begin
  group_pkg.show_cayley_table(7);
end;
/

select group_pkg.string_order('FR', 7) from dual;