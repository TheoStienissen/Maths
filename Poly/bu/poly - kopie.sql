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

create table polynomes
( id        number (8)  not null
, factor    number      not null
, ppower    number (3)  not null);

-- Only used as scratchpad
create global temporary table polynomes_temp
( id       number (8)
, factor   number
, ppower   number (3))
on commit preserve rows;

create or replace package polynome_pkg
is
type polynome_element_ty is record (id number (8), factor number, ppower number (3));
type polynome_row_ty     is table of polynome_element_ty index by pls_integer;

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

procedure save_polynome (p_polynome in polynome_row_ty);

procedure save_temp_polynome (p_polynome in polynome_row_ty);

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

end polynome_pkg;
/

create or replace package body polynome_pkg
is
-- Local utility to beautify the output.
procedure print_sign (p_factor in integer, p_first in boolean)
is
begin
  if p_first
  then if p_factor >= 0 then dbms_output.put ('+');   else dbms_output.put ('-');   end if;
  else if p_factor >= 0 then dbms_output.put (' + '); else dbms_output.put (' - '); end if;
  end if;

exception when others then
  util.show_error ('Error in procedure print_sign.' , sqlerrm);
end print_sign;

/******************************************************************************************************/

-- Local utility to beautify the output.
procedure print_power (p_power in integer)
is
begin
  if    p_power = 1 then dbms_output.put (' * X ');
  elsif p_power > 1 then dbms_output.put (' * X ** ' || to_char (p_power));
  end if;

exception when others then
  util.show_error ('Error in procedure print_power.' , sqlerrm);
end print_power;

/******************************************************************************************************/

-- Local utility to beautify the output.
procedure print_factor (p_factor in number)
is
begin
  dbms_output.put (to_char (abs (p_factor)));
  
exception when others then
  util.show_error ('Error in procedure print_factor.' , sqlerrm);
end print_factor;

/******************************************************************************************************/

function new_id (p_id in integer default null) return integer
is
l_id     integer (8);
l_count  integer (8);
begin
  if p_id is null then select max(id) + 1 into l_id from polynomes; end if;
  return nvl (l_id, p_id);

exception when others then
  util.show_error ('Error in function new_id.' , sqlerrm);
end new_id;

/******************************************************************************************************/

--
-- Print polynome from a memory collection
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
        print_sign (p_polynome (j).factor, l_first);
	    if l_first then l_first := FALSE; end if;
        print_factor (p_polynome (j).factor);
        print_power (p_polynome (j).ppower);
      end if;
    end loop;
    dbms_output.new_line;
  end if;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************/

--
-- Print polynome from the table
--
procedure print_polynome (p_id in integer, p_print_zero in boolean default true)
is
l_first  boolean := TRUE;
begin
  for j in (select sum (factor) factor, ppower from polynomes where id = p_id group by ppower order by ppower desc)
  loop
    if p_print_zero or j.factor != 0
	then
      print_sign (j.factor, l_first);
	  if l_first then l_first := FALSE; end if;
      print_factor (j.factor);
      print_power (j.ppower);
    end if;
  end loop;
  dbms_output.new_line;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************/

--
-- Delete n-th element from the table
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
  return l_polynome;

exception when others then
  util.show_error ('Error in function delete_element.' , sqlerrm);
  return l_polynome;
end delete_element;

/******************************************************************************************************/

--
-- Delete n-th element from an array
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
	  if not is_empty (l_polynome)
      then
	    save_temp_polynome (l_polynome);
	    l_polynome := load_temp_polynome (l_polynome (1).id, l_id);
	  end if;
    end if;
  end if;
  return l_polynome;
	
exception when others then
  util.show_error ('Error in function delete_element.' , sqlerrm);
  return l_polynome;
end delete_element;

/******************************************************************************************************/

--
-- Delete n-th power from an array
--
function  delete_power (p_id in integer, p_power in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_id)
  then
    l_polynome := load_polynome (p_id, l_id);
	save_temp_polynome (l_polynome);
	delete polynomes_temp where id = l_polynome (1).id and ppower = p_power;
	commit;
	l_polynome := load_temp_polynome (l_polynome (1).id, l_id);
  end if;
  return l_polynome;
  
exception when others then
  util.show_error ('Error in function delete_power.' , sqlerrm);
  return l_polynome;
end delete_power;


/******************************************************************************************************/

--
-- Delete n-th power from an array
--
function  delete_power (p_polynome in polynome_row_ty, p_power in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8) := new_id (p_return);
begin
  if not is_empty (p_polynome)
  then
    save_temp_polynome (p_polynome);
    delete polynomes_temp where id = p_polynome (1).id and ppower = p_power;
    commit;
    l_polynome := load_temp_polynome (p_polynome (1).id, l_id);
  end if;
  return l_polynome;
 
exception when others then
  util.show_error ('Error in function delete_power.' , sqlerrm);
  return l_polynome;
end delete_power;

/******************************************************************************************************/

--
-- Calculate the degree of a polynome in the table
--
function degree (p_id in integer) return integer
is
l_max_degree integer (8);
begin
  select max (ppower) into l_max_degree from polynomes where id = p_id;
  return l_max_degree;

exception when others then
  util.show_error ('Error in function degree.' , sqlerrm);
  return null;
end degree;

/******************************************************************************************************/

--
-- Calculate the degree of a polynome in memory
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
      l_max_degree := greatest (nvl (l_max_degree, 0), p_polynome (l_index).ppower);
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
  util.show_error ('Error in function is_empty.' , sqlerrm);
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
-- Calculate function result of a value
--
function  result_for_x (p_polynome in polynome_row_ty, p_value in number) return number
is
l_value number := 0;
begin
  if is_empty (p_polynome)
  then
    raise_application_error (-20005, 'Empty polynome entered in function: result_for_x');
  else
    for j in 1 .. p_polynome.count
    loop
      l_value := l_value + p_polynome (j).factor * power (p_value, p_polynome (j).ppower);
    end loop;
  end if;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x.' , sqlerrm);
  return null;
end result_for_x;

/******************************************************************************************************/
--
-- Calculate function result of a value
--
function  result_for_x (p_id in integer, p_value in number) return number
is
l_value number;
begin
  if is_empty (p_id)
  then
    raise_application_error (-20005, 'Empty polynome entered in function: result_for_x');
  end if;

  select sum (factor * power (p_value, ppower)) into l_value from polynomes where id = p_id;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x.' , sqlerrm);
  return null;
end result_for_x;

/******************************************************************************************************/
--
-- Save a polynome in a permanent table. Overwrites any existing polys with the same ID.
--
procedure save_polynome (p_polynome in polynome_row_ty)
is
l_count  integer (8);
begin
  if is_empty (p_polynome)
  then
    raise_application_error (-20005, 'Empty polynome entered in procedure: save_polynome');
  else
    delete polynomes where id = p_polynome(1).id;
    l_count := p_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes values (p_polynome (l_count).id, p_polynome (l_count).factor, p_polynome (l_count).ppower);
	  l_count := p_polynome.next (l_count);
	end loop;
    commit;  
  end if;

exception when others then
  util.show_error ('Error in procedure save_polynome.' , sqlerrm);
end save_polynome;

/******************************************************************************************************/
--
-- Save a polynome in a temporary table. Scratchpad. Overwrites any existing polys with the same ID.
--
procedure save_temp_polynome (p_polynome in polynome_row_ty)
is
l_count  integer (8);
begin
  if is_empty (p_polynome)
  then
    raise_application_error(-20005, 'Empty polynome entered in procedure: save_temp_polynome');
  else
    delete polynomes_temp where id = p_polynome(1).id;
    l_count := p_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_temp values (p_polynome (l_count).id, p_polynome (l_count).factor, p_polynome (l_count).ppower);
	  l_count := p_polynome.next (l_count);
	end loop;
    commit;
  end if;

exception when others then
  util.show_error ('Error in procedure save_temp_polynome.' , sqlerrm);
end save_temp_polynome;

/******************************************************************************************************/
--
-- Load a polynome from the table
--
function load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select nvl (p_return, p_id), sum (factor) factor, ppower bulk collect into l_polynome
    from polynomes where id = p_id group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_polynome.' , sqlerrm);
  return l_polynome;
end load_polynome;

/******************************************************************************************************/

--
-- Load a polynome from the temp table
--
function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select nvl (p_return, p_id), sum (factor) factor, ppower bulk collect into l_polynome
    from polynomes_temp where id = p_id group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_temp_polynome.' , sqlerrm);
  return l_polynome;
end load_temp_polynome;

/******************************************************************************************************/

--
-- Add polynome element to a collection
--
function  add_polynome_elt (p_id in integer, p_factor in number, p_power in integer) return polynome_row_ty
is
begin
  insert into polynomes (id, factor, ppower) values (p_id, p_factor, p_power);
  commit;
  return load_polynome (p_id);

exception when others then
  util.show_error ('Error in function add_polynome_elt.' , sqlerrm);
end add_polynome_elt;

/******************************************************************************************************/
--
-- Add polynome element to a collection
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
    l_id := p_polynome (1).id;
    save_temp_polynome (p_polynome);
  end if;
  insert into polynomes_temp (id, factor, ppower) values (l_id, p_factor, p_power);
  
  select l_id, sum(factor) factor, ppower bulk collect into l_polynome
  from polynomes_temp where id = l_id group by ppower having sum (factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynome_elt.' , sqlerrm);
  return l_polynome;
end add_polynome_elt;

/******************************************************************************************************/
--
-- Add 2 polynomes from a table
--
function add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select id, sum(factor) factor, ppower bulk collect into l_polynome
    from polynomes where id in (p_id1, p_id2) group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;
 
exception when others then
  util.show_error ('Error in function add_polynomes.' , sqlerrm);
  return l_polynome;
end add_polynomes;

/******************************************************************************************************/
--
-- Add 2 polynomes from memory
--
function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  if    is_empty (p1_polynome) then return p2_polynome;
  elsif is_empty (p2_polynome) then return p1_polynome;
  end if;
  
  save_temp_polynome(p1_polynome);
  save_temp_polynome(p2_polynome);  
  select p_result, sum(factor) factor, ppower bulk collect into l_polynome
    from polynomes_temp where id in (p1_polynome(1).id, p2_polynome(1).id) group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynomes.' , sqlerrm);
  return l_polynome;
end add_polynomes;

/******************************************************************************************************/

--
-- Subtract 2 polynomes from table
--
function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  return add_polynomes (load_polynome (p_id1), multiply_polynome (p_id2, -1, 0, p_result), p_result);

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
  return l_polynome;
end subtract_polynomes;

/******************************************************************************************************/

--
-- Subtract 2 polynomes from memory
--
function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  return add_polynomes (p1_polynome, multiply_polynome (p2_polynome, -1, 0, p_result), p_result);

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
  return l_polynome;
end subtract_polynomes;

/******************************************************************************************************/

--
-- Multiply a polynome with a scalar
--
function  multiply_polynome (p_id in integer, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  select p_result, sum(factor) * p_factor factor, ppower + p_power bulk collect into l_polynome
      from polynomes where id = p_id group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynome.' , sqlerrm);
  return l_polynome;
end multiply_polynome;

/******************************************************************************************************/
--
-- Multiply a polynome with a scalar
--
function  multiply_polynome (p_polynome in polynome_row_ty, p_factor in number, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  for j in 1 .. p_polynome.count
  loop
    l_polynome (j) := polynome_element_ty (p_result, p_polynome (j).factor * p_factor, p_polynome (j).ppower + p_power);
  end loop;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynome.' , sqlerrm);
  return l_polynome;
end multiply_polynome;

/******************************************************************************************************/
--
-- Multiply 2  polynomes from a table
--
function multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  if    is_empty (p_id1) then raise_application_error (-20005, 'Empty first polynome entered in function: multiply_polynomes.');
  elsif is_empty (p_id2) then raise_application_error (-20005, 'Empty second polynome entered in function: multiply_polynomes.');
  end if;
  
  select p_result, sum(p1.factor * p2.factor) factor, p1.ppower + p2.ppower bulk collect into l_polynome from
	 (select sum(factor) factor, ppower from polynomes where id = p_id1) p1,
	 (select sum(factor) factor, ppower from polynomes where id = p_id2) p2
	  group by p1.ppower + p2.ppower having sum (p1.factor * p2.factor) != 0 order by p1.ppower + p2.ppower desc;		 
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynomes.' , sqlerrm);
  return l_polynome;
end multiply_polynomes;

/******************************************************************************************************/
--
-- Multiply 2 polynomes from a memory collection
--
function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  if    is_empty (p1_polynome) then raise_application_error (-20005, 'Empty first polynome entered in function: multiply_polynomes.');
  elsif is_empty (p2_polynome) then raise_application_error (-20005, 'Empty second polynome entered in function: multiply_polynomes.');
  end if;
  
  delete polynomes_temp where id = p_result;
  commit;
  for i in 1 .. p1_polynome.count
  loop
    for j in 1 .. p2_polynome.count
    loop
      insert into polynomes_temp (id, factor, ppower)
        values (p_result, p1_polynome (i).factor * p2_polynome (j).factor, p1_polynome (i).ppower + p2_polynome (j).ppower);
    end loop;
  end loop;
--
  select p_result, sum(factor) factor, ppower bulk collect into l_polynome
    from polynomes_temp where id = p_result group by ppower having sum(factor) != 0 order by ppower desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynomes.' , sqlerrm);
  return l_polynome;
end multiply_polynomes;

/******************************************************************************************************/
--
-- Divide 2 polynomes from a table collection
-- Result not yet correct. Debugging needed.
--
function  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder out integer, p_result in integer default null) return integer
is
l_result     polynome_row_ty;
l_remainder  polynome_row_ty;
l_divisor    polynome_row_ty;
l_tmp        polynome_row_ty;
l_factor     number;
l_power      integer (8);
l_power_tmp  integer (8);
l_id_result  integer (8) := new_id (p_result);
l_id_remain  integer (8) := new_id;
l_id_div     integer (8) := new_id;
l_id_n       integer (8) := new_id;
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
  	l_power_tmp := l_remainder (1).ppower;
    l_factor    := l_remainder (1).factor / l_divisor (1).factor;
	l_power     := l_remainder (1).ppower - l_divisor (1).ppower;
    l_result    := add_polynome_elt (l_id_result, l_factor, l_power);
	-- subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
	l_remainder := delete_power (subtract_polynomes (l_remainder,
        	multiply_polynome (l_divisor, l_factor, l_power, l_id_n), l_id_remain), l_power_tmp);
  end loop;
  save_polynome (l_remainder);
  p_remainder   := l_id_remain;
  return l_id_result;
  
exception when others then
  util.show_error ('Error in function divide_polynomes.' , sqlerrm);
  return null;
end divide_polynomes;

end polynome_pkg;
/

show error

