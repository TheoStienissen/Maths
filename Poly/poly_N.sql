Doc

  Author   :  Theo Stienissen
  Date     :  2021 / 2022
  Purpose  :  Polynome operations
  Contact  :  theo.stienissen@gmail.com
  Script   :  @C:\Users\Theo\OneDrive\Theo\Project\Maths\Poly\poly.sql

#

set serveroutput on size unlimited

alter session set plsql_warnings = 'ENABLE:ALL'; 

drop table     polynomes;
truncate table polynomes_temp;
drop table     polynomes_temp;
drop package   polynome_pkg;
drop sequence  polynomes_seq;

create table polynomes
( id            number (8)  not null
, factor        number      not null
, poly_power    number (6)  not null);

-- Only used as scratchpad
create global temporary table polynomes_temp
( id           number (8)
, factor       number
, poly_power   number (6))
on commit delete rows;

create sequence  polynomes_seq start with 10000;

create or replace package polynome_pkg
is
type polynome_element_ty is record (id integer (8), factor number, poly_power integer (6));
type polynome_row_ty     is table of polynome_element_ty index by pls_integer;

function  new_id (p_id in integer default null) return integer;

procedure print_polynome (p_polynome in polynome_row_ty, p_print_zero in boolean default true);

procedure print_polynome (p_id in integer, p_print_zero in boolean default true);

function  degree (p_id in integer) return integer;

function  degree (p_polynome in polynome_row_ty) return integer;

function  is_empty (p_id in integer) return boolean;

function  is_empty (p_polynome in polynome_row_ty) return boolean;

function  delete_element (p_id in integer, p_position in integer default 1, p_return in integer default null) return polynome_row_ty;

function  delete_element (p_polynome in polynome_row_ty, p_position in integer default 1, p_return in integer default null) return polynome_row_ty;

function  delete_power (p_id in integer, p_power in integer, p_return in integer default null) return polynome_row_ty;

function  delete_power (p_polynome in polynome_row_ty, p_power in integer, p_return in integer default null) return polynome_row_ty;

function  result_for_x (p_polynome in polynome_row_ty, p_value in number) return number;

function  result_for_x (p_id in integer, p_value in number) return number;

function  save_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer;

function  save_temp_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer;

function  load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  add_polynome_elt (p_id in integer, p_factor in number, p_power in integer) return polynome_row_ty;

function  add_polynome_elt (p_polynome in polynome_row_ty, p_factor in number, p_power in integer) return polynome_row_ty;

function  add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  multiply_polynome (p_id in integer, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty;

function  multiply_polynome (p_polynome in polynome_row_ty, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty;

function  multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder out integer, p_result in integer default null) return integer;

function  move_x_axis  (p_polynome in polynome_row_ty, p_distance in number, p_result in integer default null) return polynome_row_ty;

function random_polynome (p_result in integer default null, p_elements in integer default 10, p_min_max_factor in integer default 100, p_power in integer default 10) return polynome_row_ty;
end polynome_pkg;
/

create or replace package body polynome_pkg
is
--
-- Local utility to beautify the output.
--
procedure print_sign (p_factor in integer, p_first in boolean)
is
begin
  if p_first
  then if p_factor >= 0 then dbms_output.put ('+');   else dbms_output.put ('-');   end if;
  else if p_factor >= 0 then dbms_output.put (' + '); else dbms_output.put (' - '); end if;
  end if;

exception when others then
  util.show_error ('Error in procedure print_sign for factor: ' || p_factor || '.', sqlerrm);
end print_sign;

/******************************************************************************************************/

--
-- Local utility to beautify the output.
--
procedure print_power (p_power in integer)
is
begin
  if    p_power = 1 then dbms_output.put (' * X ');
  elsif p_power > 1 then dbms_output.put (' * X ** ' || to_char (p_power));
  end if;

exception when others then
  util.show_error ('Error in procedure print_power for power: ' || p_power || '.', sqlerrm);
end print_power;

/******************************************************************************************************/

--
-- Local utility to beautify the output.
--
procedure print_factor (p_factor in number)
is
begin
  dbms_output.put (to_char (abs (p_factor)));
  
exception when others then
  util.show_error ('Error in procedure print_factor for factor: ' || p_factor || '.', sqlerrm);
end print_factor;

/******************************************************************************************************/

--
-- Generate new sequence number if needed.
--
function new_id (p_id in integer default null) return integer
is
begin
  return  nvl (p_id, polynomes_seq.nextval);

exception when others then
  util.show_error ('Error in function new_id.' , sqlerrm);
end new_id;

/******************************************************************************************************/

--
-- Elimate holes.
--
function resequence  (p_polynome in polynome_row_ty) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id      integer (8);
begin
  if not is_empty (p_polynome)
  then
	l_id       := save_temp_polynome (l_polynome);
	l_polynome := load_temp_polynome (l_id);
	commit;
  end if;
  return l_polynome;

exception when others then
  util.show_error ('Error in function resequence.' , sqlerrm);
  return l_polynome;
end resequence;

/******************************************************************************************************/

--
-- Print polynome from a memory collection.
--
procedure print_polynome (p_polynome in polynome_row_ty, p_print_zero in boolean default true)
is
l_first  boolean := TRUE;
begin
  if not is_empty (p_polynome)
  then
    for j in 1 .. p_polynome.count
    loop
	  if p_print_zero or p_polynome (j).factor != 0
	  then
        print_sign   (p_polynome (j).factor, l_first);
        print_factor (p_polynome (j).factor);
        print_power  (p_polynome (j).poly_power);
	    l_first := FALSE;
      end if;
    end loop;
    dbms_output.new_line;
  end if;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************/

--
-- Print polynome from the table.
--
procedure print_polynome (p_id in integer, p_print_zero in boolean default true)
is
l_first  boolean := TRUE;
begin
  for j in (select sum (factor) factor, poly_power from polynomes where id = p_id group by poly_power order by poly_power desc)
  loop
    if p_print_zero or j.factor != 0
	then
      print_sign   (j.factor, l_first);
      print_factor (j.factor);
      print_power  (j.poly_power);
	  l_first := FALSE;
    end if;
  end loop;
  dbms_output.new_line;

exception when others then
  util.show_error ('Error in procedure print_polynome for ID: ' || p_id || '.', sqlerrm);
end print_polynome;

/******************************************************************************************************/

--
-- Delete n-th element from the table.
--
function  delete_element (p_id in integer, p_position in integer default 1, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_id)
  then
    l_polynome := load_polynome (p_id);
	l_polynome := delete_element (l_polynome, p_position, l_polynome (1).id);
  end if;
  return resequence (l_polynome);

exception when others then
  util.show_error ('Error in function delete_element for ID: ' || p_id || ' and position: ' || p_position || '.', sqlerrm);
  return l_polynome;
end delete_element;

/******************************************************************************************************/

--
-- Delete n-th element from an array.
--
function  delete_element (p_polynome in polynome_row_ty, p_position in integer default 1, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_polynome)
  then
    if p_position between p_polynome.first and p_polynome.last
	then	
	  l_polynome := p_polynome;
	  l_polynome.delete (p_position);
    end if;
  end if;
  return resequence (l_polynome);
	
exception when others then
  util.show_error ('Error in function delete_element for position: ' || p_position || '.' , sqlerrm);
  return l_polynome;
end delete_element;

/******************************************************************************************************/

--
-- Delete n-th power from an array.
--
function  delete_power (p_id in integer, p_power in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_id)
  then
    l_polynome := load_polynome (p_id, l_id);
	l_id := save_temp_polynome (l_polynome);
	delete polynomes_temp where id = l_id and poly_power = p_power;
	l_polynome := load_temp_polynome (l_id);
	commit;
  end if;
  return l_polynome;
  
exception when others then
  util.show_error ('Error in function delete_power for ID: ' || p_id || ' and power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end delete_power;


/******************************************************************************************************/

--
-- Delete n-th power from an array.
--
function  delete_power (p_polynome in polynome_row_ty, p_power in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_polynome)
  then
    l_id := save_temp_polynome (p_polynome);
    delete polynomes_temp where id = l_id and poly_power = p_power;
    l_polynome := load_temp_polynome (l_id);
	commit;
  end if;
  return l_polynome;
 
exception when others then
  util.show_error ('Error in function delete_power for power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end delete_power;

/******************************************************************************************************/

--
-- Calculate the degree of a polynome in the table.
--
function degree (p_id in integer) return integer
is
l_max_degree integer (8);
begin
  select max (poly_power) into l_max_degree from polynomes where id = p_id;
  return l_max_degree;

exception when others then
  util.show_error ('Error in function degree for ID: ' || p_id || '.', sqlerrm);
  return null;
end degree;

/******************************************************************************************************/

--
-- Calculate the degree of a polynome in memory.
--
function degree (p_polynome in polynome_row_ty) return integer
is
l_max_degree integer (8);
l_index      integer (8);
begin
  if not is_empty (p_polynome)
  then
    l_index := p_polynome.first;
    while l_index is not null
    loop
      l_max_degree := greatest (nvl (l_max_degree, 0), p_polynome (l_index).poly_power);
	  l_index      := p_polynome.next (l_index);
	end loop;
  end if;
  return l_max_degree;

exception when others then
  util.show_error ('Error in function degree.' , sqlerrm);
  return null;
end degree;

/******************************************************************************************************/

--
-- Checks if a polynome exists in the permanent table.
--
function  is_empty (p_id in integer) return boolean
is
l_count integer (8);
begin
  select count(*) into l_count from polynomes where id = p_id;
  return l_count = 0;

exception when others then
  util.show_error ('Error in function is_empty for ID: ' || p_id || '.', sqlerrm);
  return null;
end is_empty;

/******************************************************************************************************/
--
-- Checks if a polynome has no elements.
--
function  is_empty (p_polynome in polynome_row_ty) return boolean
is
begin
  return p_polynome.count = 0;

exception when others then
  util.show_error ('Error in function is_empty.' , sqlerrm);
  return null;
end is_empty;

/******************************************************************************************************/
--
-- Calculate function result of a value.
--
function  result_for_x (p_polynome in polynome_row_ty, p_value in number) return number
is
l_value  number := 0;
l_count  integer (8);
begin
  if is_empty (p_polynome)
  then
    raise_application_error (-20005, 'Empty polynome entered in function: result_for_x');
  else
    l_count := p_polynome.first;
    while l_count is not null
    loop
      l_value := l_value + p_polynome (l_count).factor * power (p_value, p_polynome (l_count).poly_power);
	  l_count := p_polynome.next (l_count);
    end loop;
  end if;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x.' , sqlerrm);
  return null;
end result_for_x;

/******************************************************************************************************/
--
-- Calculate function result of a value.
--
function  result_for_x (p_id in integer, p_value in number) return number
is
l_value number;
begin
  if is_empty (p_id)
  then
    raise_application_error (-20005, 'Empty polynome entered in function: result_for_x');
  end if;

  select sum (factor * power (p_value, poly_power)) into l_value from polynomes where id = p_id;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x for ID: ' || p_id || '.', sqlerrm);
  return null;
end result_for_x;

/******************************************************************************************************/
--
-- Save a polynome in a permanent table. Overwrites any existing polys with the same ID.
--
function save_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer
is
l_count  integer (8);
l_id     integer (8);
begin
  if is_empty (p_polynome)
  then
    l_id := new_id (p_return);
    if p_return is null
	then
      dbms_output.put_line ('Empty polynome in procedure save_polynome and no return value. Used ' || l_id || ' instead.');
	end if;
	delete polynomes where id = l_id;
    insert into polynomes values (l_id, 0, 0);
  else
    l_id := nvl (p_return, p_polynome(1).id);
    delete polynomes where id = l_id;
    l_count := p_polynome.first;
	if l_count = 0
	then
	  insert into polynomes values (l_id, 0, 0);
	end if;
	while l_count is not null
	loop
	  insert into polynomes values (l_id, p_polynome (l_count).factor, p_polynome (l_count).poly_power);
	  l_count := p_polynome.next (l_count);
	end loop;
   end if;
   commit;
   return l_id;
   
exception when others then
  util.show_error ('Error in function save_polynome.' , sqlerrm);
  return null;
end save_polynome;

/******************************************************************************************************/
--
-- Save a polynome in a temporary table. Scratchpad. Overwrites any existing polys with the same ID.
--
function save_temp_polynome (p_polynome in polynome_row_ty, p_return in integer default null)  return integer
is
l_count  integer (8);
l_id     integer (8) := new_id (p_return);
begin
  if is_empty (p_polynome)
  then
    l_id := new_id (p_return);
    if p_return is null
	then
      dbms_output.put_line ('Empty polynome in procedure save_temp_polynome and no return value. Used ' || l_id || ' instead.');
	end if;
    insert into polynomes values (l_id, 0, 0);
  else
    commit;
	l_id := nvl (p_return, p_polynome (1).id);
    l_count := p_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_temp values (l_id, p_polynome (l_count).factor, p_polynome (l_count).poly_power);
	  l_count := p_polynome.next (l_count);
	end loop;
  end if;
  return l_id;

exception when others then
  util.show_error ('Error in function save_temp_polynome.' , sqlerrm);
  return null;
end save_temp_polynome;

/******************************************************************************************************/
--
-- Load a polynome from the table with option to assign to new ID.
--
function load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select nvl (p_return, p_id), sum (factor) factor, poly_power bulk collect into l_polynome
    from polynomes where id = p_id group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_polynome or ID: ' || p_id  || '.', sqlerrm);
  return l_polynome;
end load_polynome;

/******************************************************************************************************/

--
-- Load a polynome from the temp table with option to assign to new ID.
--
function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select nvl (p_return, p_id), sum (factor) factor, poly_power bulk collect into l_polynome
    from polynomes_temp where id = p_id group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_temp_polynome for ID: ' || p_id || '.', sqlerrm);
  return l_polynome;
end load_temp_polynome;

/******************************************************************************************************/

--
-- Add polynome element to a collection.
--
function  add_polynome_elt (p_id in integer, p_factor in number, p_power in integer) return polynome_row_ty
is
begin
  insert into polynomes (id, factor, poly_power) values (p_id, p_factor, p_power);
  commit;
  return load_polynome (p_id);

exception when others then
  util.show_error ('Error in function add_polynome_elt for ID: ' || p_id || '. Factor: ' || p_factor || '. Power: ' || p_power || '.', sqlerrm);
end add_polynome_elt;

/******************************************************************************************************/
--
-- Add polynome element to a collection.
--
function  add_polynome_elt (p_polynome in polynome_row_ty, p_factor in number, p_power in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8);
begin
  if   is_empty (p_polynome)
  then
    l_id := new_id;
	delete polynomes_temp where id = l_id;
  else
    l_id := save_temp_polynome (p_polynome, p_polynome (1).id);
  end if;
  insert into polynomes_temp (id, factor, poly_power) values (l_id, p_factor, p_power);
  
  select l_id, sum(factor) factor, poly_power bulk collect into l_polynome
  from polynomes_temp where id = l_id group by poly_power having sum (factor) != 0 order by poly_power desc;
  commit;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynome_elt for factor: ' || p_factor || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end add_polynome_elt;

/******************************************************************************************************/
--
-- Add 2 polynomes from a table.
--
function add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select id, sum(factor) factor, poly_power bulk collect into l_polynome
    from polynomes where id in (p_id1, p_id2) group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;
 
exception when others then
  util.show_error ('Error in function add_polynomes for ID1: ' || p_id1 || '. ID2: ' || p_id2 || '.', sqlerrm);
  return l_polynome;
end add_polynomes;

/******************************************************************************************************/
--
-- Add 2 polynomes from memory.
--
function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_count    integer (8);
begin
  if    is_empty (p1_polynome) then return l_polynome;
  elsif is_empty (p2_polynome) then return l_polynome;
  end if;
  commit;
    l_count := p1_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_temp values (p1_polynome(1).id, p1_polynome (l_count).factor, p1_polynome (l_count).poly_power);
	  l_count := p1_polynome.next (l_count);
	end loop;
--
    l_count := p2_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_temp values (p2_polynome(1).id, p2_polynome (l_count).factor, p2_polynome (l_count).poly_power);
	  l_count := p2_polynome.next (l_count);
	end loop;	
 
  select p_result, sum(factor) factor, poly_power bulk collect into l_polynome
    from polynomes_temp where id in (p1_polynome(1).id, p2_polynome(1).id) group by poly_power having sum(factor) != 0 order by poly_power desc;
  commit;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynomes.' , sqlerrm);
  return l_polynome;
end add_polynomes;

/******************************************************************************************************/

--
-- Subtract 2 polynomes from table.
--
function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id;
begin
  return add_polynomes (load_polynome (p_id1), multiply_polynome (p_id2, -1, 0, l_id), p_result);

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
  return l_polynome;
end subtract_polynomes;

/******************************************************************************************************/

--
-- Subtract 2 polynomes from memory.
--
function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id;
begin
  return add_polynomes (p1_polynome, multiply_polynome (p2_polynome, -1, 0, l_id), p_result);

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
  return l_polynome;
end subtract_polynomes;

/******************************************************************************************************/

--
-- Multiply a polynome with a scalar.
--
function  multiply_polynome (p_id in integer, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select p_result, sum(factor) * p_factor factor, poly_power + p_power bulk collect into l_polynome
      from polynomes where id = p_id group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynome for ID: ' || p_id || '. Factor: ' || p_factor || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end multiply_polynome;

/******************************************************************************************************/
--
-- Multiply a polynome with a scalar.
--
function  multiply_polynome (p_polynome in polynome_row_ty, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  for j in 1 .. p_polynome.count
  loop
    l_polynome (j) := polynome_element_ty (p_result, p_polynome (j).factor * p_factor, p_polynome (j).poly_power + p_power);
  end loop;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynome for factor: ' || p_factor || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end multiply_polynome;

/******************************************************************************************************/
--
-- Multiply 2  polynomes from a table.
--
function multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  if    is_empty (p_id1) then raise_application_error (-20005, 'Empty first polynome entered in function: multiply_polynomes.');
  elsif is_empty (p_id2) then raise_application_error (-20005, 'Empty second polynome entered in function: multiply_polynomes.');
  end if;
  
  select p_result, sum(p1.factor * p2.factor) factor, p1.poly_power + p2.poly_power bulk collect into l_polynome from
	 (select sum(factor) factor, poly_power from polynomes where id = p_id1) p1,
	 (select sum(factor) factor, poly_power from polynomes where id = p_id2) p2
	  group by p1.poly_power + p2.poly_power having sum (p1.factor * p2.factor) != 0 order by p1.poly_power + p2.poly_power desc;		 
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynomes for ID1: ' || p_id1 || '. ID2: ' || p_id2 || '.', sqlerrm);
  return l_polynome;
end multiply_polynomes;

/******************************************************************************************************/
--
-- Multiply 2 polynomes from a memory collection.
--
function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  if    is_empty (p1_polynome) then raise_application_error (-20005, 'Empty first polynome entered in function: multiply_polynomes.');
  elsif is_empty (p2_polynome) then raise_application_error (-20005, 'Empty second polynome entered in function: multiply_polynomes.');
  end if;
  
  for i in 1 .. p1_polynome.count
  loop
    for j in 1 .. p2_polynome.count
    loop
      insert into polynomes_temp (id, factor, poly_power)
        values (p_result, p1_polynome (i).factor * p2_polynome (j).factor, p1_polynome (i).poly_power + p2_polynome (j).poly_power);
    end loop;
  end loop;
--
  select p_result, sum(factor) factor, poly_power bulk collect into l_polynome
    from polynomes_temp where id = p_result group by poly_power having sum(factor) != 0 order by poly_power desc;
  commit;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynomes.' , sqlerrm);
  return l_polynome;
end multiply_polynomes;

/******************************************************************************************************/
--
-- Divide 2 polynomes that are stored in a table.
--
function  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder out integer, p_result in integer default null) return integer
is
l_result     polynome_row_ty;
l_remainder  polynome_row_ty;
l_divisor    polynome_row_ty;
l_tmp        polynome_row_ty;
l_tmp2       polynome_row_ty;
l_factor     number;
l_power      integer (8);
l_power_tmp  integer (8);
l_id_result  integer (8) := new_id (p_result);
l_id_remain  integer (8) := new_id;
l_id_div     integer (8) := new_id;
l_id_n1      integer (8) := new_id;
l_id_n2      integer (8) := new_id;
l_div_degree integer (8) := degree (p_id2);
begin
  if    is_empty (p_id1) then raise_application_error (-20005, 'Empty first polynome entered in function: divide_polynomes.');
  elsif is_empty (p_id2) then raise_application_error (-20005, 'Empty second polynome entered in function: divide_polynomes.');
  end if;
  
  l_div_degree  := degree (p_id2);
  l_remainder   := load_polynome (p_id1, l_id_remain);
  l_divisor     := load_polynome (p_id2, l_id_div);
  while degree (l_remainder) >= l_div_degree
  loop
  	l_power_tmp := l_remainder (1).poly_power;
    l_factor    := l_remainder (1).factor / l_divisor (1).factor;
	l_power     := l_remainder (1).poly_power - l_divisor (1).poly_power;	
    l_result    := add_polynome_elt (l_id_result, l_factor, l_power);	
	l_tmp       := multiply_polynome (l_divisor, l_factor, l_power, l_id_n1);
    l_tmp2      := multiply_polynome (l_tmp, -1, 0, l_id_n2);
	l_remainder := add_polynomes (l_remainder, l_tmp2, l_id_remain);
	l_remainder := delete_power (l_remainder, l_power_tmp);
  end loop;
--
  p_remainder   := save_polynome (l_remainder, l_id_remain);
  return l_id_result;
  
exception when others then
  util.show_error ('Error in function divide_polynomes for ID1: ' || p_id1 || '. ID2: ' || p_id2 || '.', sqlerrm);
  return null;
end divide_polynomes;

/******************************************************************************************************/
--
-- First step for implementing Eisenstein's algoritm.
--
function  move_x_axis  (p_polynome in polynome_row_ty, p_distance in number, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_pkg.polynome_row_ty;
l_id       integer (8) := new_id (p_result);
l_count    integer (8);
l_power    integer (8);
l_factor   number;
begin
  commit;
  l_count := p_polynome.first;
  while l_count is not null
  loop
    l_power := p_polynome (l_count).poly_power;
    for k in 0 .. l_power
	loop
	  l_factor := p_polynome (l_count).factor * maths.n_over (l_power, k) * power (p_distance, l_power - k);
	  insert into polynomes_temp values (l_id, l_factor, k);
	end loop;
	l_count := p_polynome.next (l_count);
  end loop;
  l_polynome := polynome_pkg.load_temp_polynome (l_id);
  return l_polynome;
 
exception when others then
  util.show_error ('Error in function move_x_axis for displacement: ' || p_distance || '.', sqlerrm);
  return l_polynome;
end move_x_axis;
/******************************************************************************************************/
--
-- Generate a random polynome.
--
function  random_polynome (p_result in integer default null, p_elements in integer default 10, p_min_max_factor in integer default 100, p_power in integer default 10) return polynome_row_ty
is
l_polynome polynome_pkg.polynome_row_ty;
l_id       integer (8) := new_id (p_result);
begin
  delete from polynomes where id = l_id;
  for j in 1 .. p_elements
  loop
    l_polynome := polynome_pkg.add_polynome_elt (l_id, round (dbms_random.value (- p_min_max_factor, p_min_max_factor)), round (dbms_random.value (0, p_power)));
  end loop;
  return l_polynome;

exception when others then
  util.show_error ('Error in function random_polynome for elements: ' || p_elements || '. Boundaries: ' || p_min_max_factor || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end random_polynome;
end polynome_pkg;
/

show error

