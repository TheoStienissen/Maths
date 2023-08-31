Doc

  Author   :  Theo Stienissen
  Date     :  July / August 2022
  Purpose  :  Polynome operations with fractions as co-efficients
  Contact  :  theo.stienissen@gmail.com
  Script   :  @C:\Users\Theo\OneDrive\Theo\Project\Maths\Poly\poly_Q.sql

#

set serveroutput on size unlimited

alter session set plsql_warnings = 'ENABLE:ALL'; 

drop table     polynomes_Q;
truncate table polynomes_Q_temp;
drop table     polynomes_temp_Q;
drop package   polynome_Q_pkg;
drop sequence  polynomes_Q_seq;


create table polynomes_Q
( id            number (8)   not null
, numerator     integer      not null
, denominator   integer      not null
, poly_power    number (6)   not null);

alter table polynomes_Q add constraint polynomes_Q_ck1 check (denominator != 0);

create or replace trigger polynomes_Q_briu
before insert or update on polynomes_Q
for each row
declare
l_gcd  integer (38);
begin
  if :new.denominator = 0 then raise zero_divide;
  elsif :new.denominator < 0
  then
    :new.numerator   := - :new.numerator;
    :new.denominator := - :new.denominator;
  end if;
  l_gcd            := maths.gcd (:new.numerator, :new.denominator);
  :new.numerator   := :new.numerator / l_gcd;
  :new.denominator := :new.denominator / l_gcd;

exception when others then
  util.show_error ('Error in trigger: polynomes_Q_briu.', sqlerrm);
end polynomes_Q_briu;
/

-- Only used as scratchpad
create global temporary table polynomes_temp_Q
( id           number  (8)
, numerator    integer
, denominator  integer
, poly_power   number  (6))
on commit delete rows;

create or replace trigger polynomes_temp_Q_briu
before insert or update on polynomes_temp_Q
for each row
declare
l_gcd  integer (38);
begin
  if :new.denominator = 0 then raise zero_divide;
  elsif :new.denominator < 0
  then
    :new.numerator   := - :new.numerator;
    :new.denominator := - :new.denominator;
  end if;
  l_gcd            := maths.gcd (:new.numerator, :new.denominator);
  :new.numerator   := :new.numerator / l_gcd;
  :new.denominator := :new.denominator / l_gcd;

exception when others then
  util.show_error ('Error in trigger: polynomes_temp_Q_briu.', sqlerrm);
end polynomes_temp_Q_briu;
/

create sequence  polynomes_Q_seq start with 10000;

create or replace package polynome_Q_pkg
is
type polynome_element_ty is record (id integer (8), numerator integer (38), denominator integer (38), poly_power integer (6));
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

function  result_for_x (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer) return types_pkg.fraction_ty;

function  result_for_x (p_id in integer, p_numerator in integer, p_denominator in integer) return types_pkg.fraction_ty;

function  save_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer;

function  save_temp_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer;

function  load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  add_polynome_elt (p_id in integer, p_numerator in integer, p_denominator in integer, p_power in integer) return polynome_row_ty;

function  add_polynome_elt (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer, p_power in integer) return polynome_row_ty;

function  add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  multiply_polynome (p_id in integer, p_numerator in integer, p_denominator in integer, p_power in integer default 0, p_result in integer) return polynome_row_ty;

function  multiply_polynome (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer, p_power in integer default 0, p_result in integer) return polynome_row_ty;

function  multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer) return polynome_row_ty;

function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty;

function  divide_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_remainder in out integer, p_result in integer default null) return integer;

function  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder in out integer, p_result in integer default null) return integer;

function  move_x_axis  (p_polynome in polynome_row_ty, p_distance in number, p_result in integer default null) return polynome_row_ty;

function  random_polynome (p_result in integer default null, p_elements in integer default 10, p_min_max_factor in integer default 100, p_power in integer default 10) return polynome_row_ty;

end polynome_Q_pkg;
/

create or replace package body polynome_Q_pkg
is
--
-- Local utility to beautify the output.
--
procedure print_power (p_power in integer)
is
begin
  if    p_power = 1 then dbms_output.put (' * X ');
  elsif p_power > 1 then dbms_output.put (' * X ** ' || to_char (p_power) || ' ');
  end if;

exception when others then
  util.show_error ('Error in procedure print_power for power: ' || p_power || '.', sqlerrm);
end print_power;

/******************************************************************************************************/

--
-- Generate new sequence number if needed.
--
function new_id (p_id in integer default null) return integer
is
begin
  return  nvl (p_id, polynomes_Q_seq.nextval);

exception when others then
  util.show_error ('Error in function new_id.' , sqlerrm);
end new_id;

/******************************************************************************************************/

--
-- Elimate gaps and add fractions of the same power.
--
function resequence  (p_polynome in polynome_row_ty) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8);
begin
  if not is_empty (p_polynome)
  then
	l_id       := save_temp_polynome (p_polynome);
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
-- Print a polynome from a memory collection.
--
procedure print_polynome (p_polynome in polynome_row_ty, p_print_zero in boolean default true)
is
l_count    integer (8);
begin
  if not is_empty (p_polynome)
  then
    l_count := p_polynome.first;
    while l_count is not null
    loop
	  if p_print_zero or p_polynome (l_count).numerator != 0
	  then
        fractions_pkg.print (fractions_pkg.to_fraction (p_polynome (l_count).numerator, p_polynome (l_count).denominator), false);
        print_power  (p_polynome (l_count).poly_power);
      end if;
      l_count      := p_polynome.next (l_count);
    end loop;
    dbms_output.new_line;
  end if;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************/

--
-- Print a polynome stored in a table.
--
procedure print_polynome (p_id in integer, p_print_zero in boolean default true)
is
begin
  for j in (select sum (numerator) numerator, denominator, poly_power
                   from polynomes_Q
                   where id = p_id
                   group by denominator, poly_power
                   order by poly_power desc)
  loop
    if p_print_zero or j.numerator != 0
	then
      fractions_pkg.print (fractions_pkg.to_fraction (j.numerator, j.denominator), false);
      print_power (j.poly_power);
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
	  if l_polynome.exists (p_position) then l_polynome.delete (p_position); end if;
    end if;
  end if;
  return resequence (l_polynome);
	
exception when others then
  util.show_error ('Error in function delete_element for position: ' || p_position || '. Return: ' || p_return, sqlerrm);
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
	delete polynomes_temp_Q where id = l_id and poly_power = p_power;
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
    delete polynomes_temp_Q where id = l_id and poly_power = p_power;
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
  select max (poly_power) into l_max_degree from polynomes_Q where id = p_id;
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
l_count      integer (8);
begin
  if not is_empty (p_polynome)
  then
    l_count := p_polynome.first;
    while l_count is not null
    loop
      l_max_degree := greatest (nvl (l_max_degree, 0), p_polynome (l_count).poly_power);
	  l_count      := p_polynome.next (l_count);
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
  select count(*) into l_count from polynomes_Q where id = p_id;
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
function  result_for_x (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer) return types_pkg.fraction_ty
is
l_value  types_pkg.fraction_ty;
l_count  integer (8);
begin
  if is_empty (p_polynome) then return l_value;
  else
    l_count := p_polynome.first;
    l_value := fractions_pkg.to_fraction (0, 1);
    while l_count is not null
    loop
      l_value := fractions_pkg.add (l_value, 
	   fractions_pkg.to_fraction (p_polynome (l_count).numerator   * power (p_numerator  , p_polynome (l_count).poly_power),
                                  p_polynome (l_count).denominator * power (p_denominator, p_polynome (l_count).poly_power)));
	  l_count := p_polynome.next (l_count);
    end loop;
  end if;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x.' , sqlerrm);
  return l_value;
end result_for_x;

/******************************************************************************************************/

--
-- Calculate function result of a value.
--
function  result_for_x (p_id in integer, p_numerator in integer, p_denominator in integer) return types_pkg.fraction_ty
is
l_value types_pkg.fraction_ty := fractions_pkg.to_fraction (0, 1);
begin
  if is_empty (p_id) then return l_value;
  else
    l_value := fractions_pkg.to_fraction (0, 1);
    for j in (select numerator, denominator, poly_power from polynomes_Q where id = p_id)
    loop	
	  l_value := fractions_pkg.add (l_value, 
	   fractions_pkg.to_fraction (j.numerator   * power (p_numerator  , j.poly_power),
                                  j.denominator * power (p_denominator, j.poly_power)));	
    end loop;
  end if;
  return l_value;

exception when others then
  util.show_error ('Error in function result_for_x for ID: ' || p_id || '.', sqlerrm);
  return l_value;
end result_for_x;

/******************************************************************************************************/

--
-- Save a polynome in a permanent table. Overwrites any existing polys with the same ID!
--
function save_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer
is
l_count  integer (8);
l_id     integer (8);
begin
  if is_empty (p_polynome)
  then
	delete polynomes_Q where id = l_id;
	commit;
	return null;
  else
    l_id := nvl (p_return, p_polynome(1).id);
    delete polynomes_Q where id = l_id;
    l_count := p_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_Q ( id, numerator, denominator, poly_power) values (l_id, p_polynome (l_count).numerator, p_polynome (l_count).denominator, p_polynome (l_count).poly_power);
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
-- Save a polynome in a temporary table. Scratchpad. Overwrites any existing temp polys with the same ID.
--
function save_temp_polynome (p_polynome in polynome_row_ty, p_return in integer default null) return integer
is
l_count  integer (8);
l_id     integer (8);
begin
  if is_empty (p_polynome)
  then
    return null;
  else
	l_id := nvl (p_return, p_polynome (1).id);
	delete polynomes_temp_Q where id = l_id;
    l_count := p_polynome.first;
	while l_count is not null
	loop
	  insert into polynomes_temp_Q ( id, numerator, denominator, poly_power) values (l_id, p_polynome (l_count).numerator, p_polynome (l_count).denominator, p_polynome (l_count).poly_power);
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
-- Load a polynome from the table with option to assign result to a new ID.
--
function load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome   polynome_row_ty;
l_count      integer (8) := 0;
l_prev_power integer (8) := -1;
l_sum        types_pkg.fraction_ty;
l_id         integer (8) := nvl (p_return, p_id);
begin
  for j in (select sum (numerator) numerator, denominator, poly_power
            from polynomes_Q where id = p_id
	        group by denominator, poly_power
	        having sum (numerator) != 0
	        order by poly_power desc)
  loop
    if l_prev_power = j.poly_power
    then l_sum := fractions_pkg.add (l_sum, fractions_pkg.to_fraction (j.numerator, j.denominator));
    else
      if l_prev_power != -1
	  then
        l_count := l_count + 1;
		l_polynome (l_count) := polynome_element_ty (l_id, l_sum.numerator, l_sum.denominator, l_prev_power);
	  end if;
	  l_sum := fractions_pkg.to_fraction (j.numerator, j.denominator);
    end if;
    l_prev_power := j.poly_power;
  end loop;
  if l_prev_power != -1
  then
    l_count := l_count + 1;
	l_polynome (l_count) := polynome_element_ty (l_id, l_sum.numerator, l_sum.denominator, l_prev_power);
  end if;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_polynome or ID: ' || p_id  || '.', sqlerrm);
  return l_polynome;
end load_polynome;

/******************************************************************************************************/

--
-- Load a polynome from the temp table with option to assign the result to a new ID.
--
function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome   polynome_row_ty;
l_count      integer (8) := 0;
l_prev_power integer (8) := -1;
l_sum        types_pkg.fraction_ty;
l_id         integer (8) := nvl (p_return, p_id);
begin
  for j in (select sum (numerator) numerator, denominator, poly_power
            from polynomes_temp_Q where id = p_id
	        group by denominator, poly_power
	        having sum (numerator) != 0
	        order by poly_power desc)
  loop
    if l_prev_power = j.poly_power
    then l_sum := fractions_pkg.add (l_sum, fractions_pkg.to_fraction (j.numerator, j.denominator));
    else
      if l_prev_power != -1
	  then
        l_count := l_count + 1;
	    l_polynome (l_count) := polynome_element_ty (l_id, l_sum.numerator, l_sum.denominator, l_prev_power);
	  end if;
	  l_sum := fractions_pkg.to_fraction (j.numerator, j.denominator);
    end if;
    l_prev_power := j.poly_power;
  end loop;
  if l_prev_power != -1
  then
    l_count := l_count + 1;
	l_polynome (l_count) := polynome_element_ty (l_id, l_sum.numerator, l_sum.denominator, l_prev_power);
  end if;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_temp_polynome for ID: ' || p_id || '.', sqlerrm);
  return l_polynome;
end load_temp_polynome;

/******************************************************************************************************/

--
-- Add polynome element to a collection.
--
function  add_polynome_elt (p_id in integer, p_numerator in integer, p_denominator in integer, p_power in integer) return polynome_row_ty
is
begin
  insert into polynomes_Q (id, numerator, denominator, poly_power) values (p_id, p_numerator, p_denominator, p_power);
  commit;
  return load_polynome (p_id);

exception when others then
  util.show_error ('Error in function add_polynome_elt for ID: ' || p_id || '. Numerator: ' || p_numerator || '. Denominator: ' || p_denominator || '. Power: ' || p_power || '.', sqlerrm);
end add_polynome_elt;

/******************************************************************************************************/

--
-- Add polynome element to a collection.
--
function  add_polynome_elt (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer, p_power in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_id       integer (8);
begin
  if   is_empty (p_polynome)
  then
    l_id := new_id;
	delete polynomes_temp_Q where id = l_id;
  else
    l_id := save_temp_polynome (p_polynome, p_polynome (1).id);
  end if;
  insert into polynomes_temp_Q (id, numerator, denominator, poly_power) values (l_id, p_numerator, p_denominator, p_power);  
  return load_temp_polynome (l_id);

exception when others then
  util.show_error ('Error in function add_polynome_elt for numerator: ' || p_numerator || '. Denominator: ' || p_denominator || '. Power: ' || p_power || '.', sqlerrm);
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
  select p_result, sum (numerator), denominator, poly_power
  bulk collect into l_polynome
  from polynomes_Q
  where id in (p_id1, p_id2)
  group by denominator, poly_power
  having sum (numerator) != 0;
  return resequence (l_polynome);
 
exception when others then
  util.show_error ('Error in function add_polynomes for ID1: ' || p_id1 || '. ID2: ' || p_id2 || '.', sqlerrm);
  return l_polynome;
end add_polynomes;

/******************************************************************************************************/

--
-- Add 2 polynomes from memory array. Polynomes must have a different ID!
--
function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_p1       integer (8);
l_p2       integer (8);
begin
  if    is_empty (p1_polynome) or is_empty (p2_polynome) then return l_polynome; end if;
  commit;

  l_p1 := save_temp_polynome (p1_polynome);
  l_p2 := save_temp_polynome (p2_polynome);

  select p_result, sum (numerator), denominator, poly_power
    bulk collect into l_polynome
    from polynomes_temp_Q where id in (p1_polynome(1).id, p2_polynome(1).id)
	group by denominator, poly_power
	having sum (numerator) != 0;
  commit;
  return resequence (l_polynome);

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
  return add_polynomes (load_polynome (p_id1), multiply_polynome (p_id2, -1, 1, 0, l_id), p_result);

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
  return add_polynomes (p1_polynome, multiply_polynome (p2_polynome, -1, 1, 0, l_id), p_result);

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
  return l_polynome;
end subtract_polynomes;

/******************************************************************************************************/

--
-- Multiply a polynome with a scalar in Q
--
function  multiply_polynome (p_id in integer, p_numerator in integer, p_denominator in integer, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome   polynome_row_ty;
l_count      integer (8) := 0;
l_sum        types_pkg.fraction_ty;
begin
  for j in (select sum (numerator) numerator, denominator, poly_power
            from polynomes_Q
	        where id = p_id
	        group by denominator, poly_power
	        having sum (numerator) != 0
			order by poly_power desc)
  loop
    l_count := l_count + 1;
	l_sum := fractions_pkg.multiply (fractions_pkg.to_fraction (p_numerator, p_denominator), fractions_pkg.to_fraction (j.numerator, j.denominator));
	l_polynome (l_count) := polynome_element_ty (p_result, l_sum.numerator, l_sum.denominator, j.poly_power + p_power);
  end loop;
  return resequence (l_polynome);

exception when others then
  util.show_error ('Error in function multiply_polynome for ID: ' || p_id || '. Numerator: ' || p_numerator || '. Denominator: ' || p_denominator || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end multiply_polynome;

/******************************************************************************************************/

--
-- Multiply a polynome with a scalar in Q.
--
function  multiply_polynome (p_polynome in polynome_row_ty, p_numerator in integer, p_denominator in integer, p_power in integer default 0, p_result in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_count    integer (8);
l_sum      types_pkg.fraction_ty;
begin
  if is_empty (p_polynome)
  then return l_polynome;
  else
    l_count := p_polynome.first;
    while l_count is not null
    loop
      l_sum := fractions_pkg.multiply (fractions_pkg.to_fraction (p_polynome (l_count).numerator, p_polynome (l_count).denominator), fractions_pkg.to_fraction (p_numerator, p_denominator));
      l_polynome (l_count) := polynome_element_ty (p_result, l_sum.numerator, l_sum.denominator, p_polynome (l_count).poly_power + p_power);
      l_count := p_polynome.next (l_count);
    end loop;
  end if;
  return resequence (l_polynome);

exception when others then
  util.show_error ('Error in function multiply_polynome for numerator: ' || p_numerator || '. Denominator: ' || p_denominator || '. Power: ' || p_power || '.', sqlerrm);
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
  if   is_empty (p_id1) or is_empty (p_id2)
  then return l_polynome;  
  else  
    select p_result, sum(p1.numerator * p2.numerator), p1.denominator * p2.denominator, p1.poly_power + p2.poly_power bulk collect into l_polynome from
	   (select sum(numerator) numerator, denominator, poly_power from polynomes_Q where id = p_id1 group by denominator, poly_power having sum (numerator) != 0) p1,
	   (select sum(numerator) numerator, denominator, poly_power from polynomes_Q where id = p_id2 group by denominator, poly_power having sum (numerator) != 0) p2
	 group by p1.denominator * p2.denominator, p1.poly_power + p2.poly_power order by p1.poly_power + p2.poly_power desc;
  end if;	  
  return resequence (l_polynome);

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
l_p1       integer (8);
l_p2       integer (8);
begin
  if   is_empty (p1_polynome) or is_empty (p2_polynome)
  then return l_polynome;  
  else
    l_p1 := p1_polynome.first;
    while l_p1 is not null
    loop
	  l_p2 := p2_polynome.first;
      while l_p2 is not null
      loop
        insert into polynomes_temp_Q (id, numerator, denominator, poly_power)
          values (p_result, p1_polynome (l_p1).numerator * p2_polynome (l_p2).numerator, p1_polynome (l_p1).denominator * p2_polynome (l_p2).denominator, p1_polynome (l_p1).poly_power + p2_polynome (l_p2).poly_power);
        l_p2 := p2_polynome.next (l_p2);
	 end loop;
	l_p1 := p1_polynome.next (l_p1);
    end loop;
 end if;	  
  return load_temp_polynome (p_result);

exception when others then
  util.show_error ('Error in function multiply_polynomes.' , sqlerrm);
  return l_polynome;
end multiply_polynomes;


/******************************************************************************************************/

--
-- Divide 2 polynomes that are stored in memory.
--
function  divide_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_remainder in out integer, p_result in integer default null) return integer
is
l_result      polynome_row_ty;
l_remainder   polynome_row_ty;
l_divisor     polynome_row_ty;
l_tmp         polynome_row_ty;
l_factor      types_pkg.fraction_ty;
l_power       integer (8);
l_id_result   integer (8) := new_id (p_result);
l_id_remain   integer (8) := new_id (p_remainder);
l_id_n1       integer (8) := new_id;
l_divisor_deg integer (8);
l_count integer := 0;
begin
  if   is_empty (p1_polynome) or is_empty (p2_polynome) then return null; end if;
  
  l_divisor_deg  := degree (p2_polynome);
  l_remainder   := load_temp_polynome (save_temp_polynome(p1_polynome, l_id_remain), l_id_remain);
  while degree (l_remainder) >= l_divisor_deg and l_count <= 10
  loop
    dbms_output.put_line ('Loop: ' || l_count);
    l_factor    := fractions_pkg.to_fraction (p2_polynome (1).denominator * l_remainder (1).numerator, p2_polynome (1).numerator * l_remainder (1).denominator);
	l_power     := l_remainder (1).poly_power - p2_polynome (1).poly_power;
	dbms_output.put_line ('l_power: ' || l_power || '.  Fraction: '); fractions_pkg.print (l_factor);
    l_result    := add_polynome_elt (l_id_result, l_factor.numerator, l_factor.denominator, l_power);	
	l_tmp       := multiply_polynome (p2_polynome, - l_factor.numerator, l_factor.denominator, l_power, new_id);	
	dbms_output.put_line ('After Multiply to be added: '); print_polynome (l_tmp);
	l_remainder := add_polynomes (l_remainder, l_tmp, l_id_remain);
	 dbms_output.put_line ('After Add degree should be less: '); print_polynome (l_remainder);
	l_count := l_count + 1;
  end loop;
--
  p_remainder   := save_polynome (l_remainder, l_id_remain);
  return l_id_result;

exception when others then
  util.show_error ('Error in function divide_polynomes.', sqlerrm);
  return null;
end divide_polynomes;

/******************************************************************************************************/

--
-- Divide 2 polynomes that are stored in a table.
--
function  divide_polynomes (p_id1 in integer, p_id2 in integer, p_remainder in out integer, p_result in integer default null) return integer
is
l_result      polynome_row_ty;
l_id_remain   integer (8) := new_id (p_remainder);
l_id_div      integer (8) := new_id;
l_id_result   integer (8) := new_id (p_result);
begin
  if   is_empty (p_id1) or is_empty (p_id2) then return null; end if;

  l_id_result := divide_polynomes (load_polynome (p_id1, new_id), load_polynome (p_id2, new_id), l_id_remain, l_id_result);
  p_remainder := l_id_remain;
  return l_id_result;

exception when others then
  util.show_error ('Error in function divide_polynomes for ID1: ' || p_id1 || '. ID2: ' || p_id2 || '.', sqlerrm);
  return null;
end divide_polynomes;

/******************************************************************************************************/

--
-- First step for implementing Eisenstein's algoritm.
-- ToDo. To be validated
--
function  move_x_axis  (p_polynome in polynome_row_ty, p_distance in number, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_Q_pkg.polynome_row_ty;
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
	  l_factor := p_polynome (l_count).numerator * maths.n_over (l_power, k) * power (p_distance, l_power - k);
	  insert into polynomes_temp_Q values (l_id, l_factor, p_polynome (l_count).denominator, k);
	end loop;
	l_count := p_polynome.next (l_count);
  end loop;
  l_polynome := polynome_Q_pkg.load_temp_polynome (l_id);
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
l_polynome polynome_Q_pkg.polynome_row_ty;
l_id       integer (8) := new_id (p_result);
begin
  delete from polynomes_temp_Q where id = l_id;
  for j in 1 .. p_elements
  loop
    insert into polynomes_temp_Q (id, numerator, denominator, poly_power)
	                             values (l_id, round (dbms_random.value (- 10 * p_min_max_factor, 10 * p_min_max_factor)),
                                               round (dbms_random.value (1, p_min_max_factor)),
											   round (dbms_random.value (0, p_power)));
  end loop;
  return load_temp_polynome (l_id);

exception when others then
  util.show_error ('Error in function random_polynome for elements: ' || p_elements || '. Boundaries: ' || p_min_max_factor || '. Power: ' || p_power || '.', sqlerrm);
  return l_polynome;
end random_polynome;

end polynome_Q_pkg;
/

show error

