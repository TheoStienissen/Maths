create or replace package collections_pkg
is

procedure print_field_array (in_array in t_field_table, in_position in simple_integer default 1,in_text in varchar2 default null);

procedure print_integer_array (in_array in t_field_table, in_position in integer);

procedure add_array (io_array in out t_field_table, in_field1 in integer default 0, in_field2 in integer default 0, in_field3 in integer default 0);

function sort_array_fields  (in_array in t_field_table, in_position in integer default 1) return t_field_table;

function element_exists (in_array in t_field_table, in_value in integer) return boolean;

function index_value (in_array in t_field_table, in_value in integer) return integer;

function sort_unique (in_array in t_field_table, in_position in integer default 1) return t_field_table;
end collections_pkg;
/

create or replace package body collections_pkg
is
--
-- Print 3 elements from field array
--
procedure print_field_array (in_array in t_field_table, in_position in simple_integer default 1,in_text in varchar2 default null)
is
l_index   pls_integer;
begin
  dbms_output.put_line ('--+ ' || nvl (in_text, 'field1 array:'));
  l_index := in_array.first;
  while l_index is not null
  loop 
    dbms_output.put_line ('INDEX: ' || lpad (l_index, 3) || '   ' ||
	  case in_position
      when 1 then 'F1: ' || lpad (in_array (l_index).field1, 5) || '. F2: ' || lpad (in_array (l_index).field2, 5) || '. F3: ' || lpad (in_array (l_index).field3, 5)
      when 2 then 'F2: ' || lpad (in_array (l_index).field2, 5) || '. F1: ' || lpad (in_array (l_index).field1, 5) || '. F3: ' || lpad (in_array (l_index).field3, 5)
      when 3 then 'F3: ' || lpad (in_array (l_index).field3, 5) || '. F1: ' || lpad (in_array (l_index).field1, 5) || '. F2: ' || lpad (in_array (l_index).field2, 5) end);
      l_index := in_array.next (l_index);
  end loop print_loop;

exception when others
then
  util.show_error ('Error in procedure print_field_array. Position: ' || in_position, sqlerrm);
end print_field_array;

/****************************************************************************************************************************/
--
-- Only one column of integers printed
--
procedure print_integer_array (in_array in t_field_table, in_position in integer)
is
l_product integer := 1;
l_index   pls_integer;
begin
  dbms_output.put_line ('--+ Integer array:');
  l_index    := in_array.first;
  while l_index is not null 
  loop 
    dbms_output.put ('INDEX: ' || lpad (l_index, 3) ||
	case in_position
    when 1 then 'F1: ' || lpad (in_array (l_index).field1, 5)
    when 2 then 'F2: ' || lpad (in_array (l_index).field2, 5)
    when 3 then 'F3: ' || lpad (in_array (l_index).field3, 5) end);
	l_product := l_product * case in_position when 1 then in_array (l_index).field1 when 2 then in_array (l_index).field2 when 3 then in_array (l_index).field3 end;
    l_index := in_array.next (l_index);
  end loop print_loop; 
  dbms_output.new_line;
  dbms_output.put_line ('--+ Total product: ' || l_product || '. PHI: ' || maths.phi (l_product));

exception when others
then
  util.show_error ('Error in procedure print_integer_array. Position: ' || in_position, sqlerrm);
end print_integer_array;

/****************************************************************************************************************************/
--
-- Add element to t_field_table type array
--
procedure add_array (io_array in out t_field_table, in_field1 in integer default 0, in_field2 in integer default 0, in_field3 in integer default 0)
is
begin
  io_array.extend;
  io_array (io_array.last) := t_field_type (field1 => in_field1, field2 => in_field2, field3 => in_field3);

exception when others
then
  util.show_error ('Error in procedure add_array. F1: ' || in_field1 || ' F2: ' || in_field2 || ' F3: ' || in_field3, sqlerrm);
end add_array;

/****************************************************************************************************************************/
--
-- Testing new sorting method
--
function sort_array_fields  (in_array in t_field_table, in_position in integer default 1) return t_field_table
is
l_array t_field_table := t_field_table ();
begin
  for j in (select field1, field2, field3 from table (in_array) order by in_position)
  loop
    add_array (l_array, j.field1, j.field2, j.field3);
  end loop;
  return l_array;

exception when others
then
  util.show_error ('Error in function sort_array_fields. Position: ' || in_position, sqlerrm);
  return t_field_table ();
end sort_array_fields;

/****************************************************************************************************************************/
--
-- Checks if a value is present in an array
--
function element_exists (in_array in t_field_table, in_value in integer) return boolean 
is
l_found   boolean := FALSE;
l_index   pls_integer;
begin
  l_index    := in_array.first;
  <<done>>
  while l_index is not null
  loop
    l_found := in_array (l_index).field1 = in_value;
    exit done when l_found;
	l_index := in_array.next (l_index);
  end loop;
  return l_found;

exception when others
then
  util.show_error ('Error in function element_exists for value: ' || in_value, sqlerrm);
  return null;
end element_exists;

/****************************************************************************************************************************/
--
-- Retrieve the index value of a field1 in an array
--
function index_value (in_array in t_field_table, in_value in integer) return integer 
is
l_return  integer;
l_index   pls_integer;
begin
  l_index    := in_array.first;
  <<done>>
  while l_index is not null
  loop
    if  in_array (l_index).field1 = in_value
	then
	  l_return := l_index;
	  exit done;
	end if;
    l_index := in_array.next (l_index);
  end loop;
  return l_return;

exception when others
then
  util.show_error ('Error in function index_value for value: ' || in_value, sqlerrm);
  return null;
end index_value;

/****************************************************************************************************************************/
--
-- Get the unique values of the first column
--
function sort_unique (in_array in t_field_table, in_position in integer default 1) return t_field_table
is
l_return t_field_table := t_field_table ();
begin
  case in_position
  when 1
  then
    for j in (select field1, max (field2) field2, max (field3) field3 from table (in_array) group by field1 order by field1)
    loop
      add_array (l_return, j.field1, j.field2, j.field3);
    end loop;
  when 2
  then
    for j in (select field2, max (field1) field1, max (field3) field3 from table (in_array) group by field2 order by field2)
    loop
      add_array (l_return, j.field1, j.field2, j.field3);
    end loop;
  when 3
  then
    for j in (select field3, max (field2) field2, max (field1) field1 from table (in_array) group by field3 order by field3)
    loop
      add_array (l_return, j.field1, j.field2, j.field3);
    end loop;
  end case;
  return l_return;

exception when others
then
  util.show_error ('Error in function sort_unique. Position: ' || in_position, sqlerrm);
  return t_field_table ();
end sort_unique;

end collections_pkg;
/
