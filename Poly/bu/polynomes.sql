/*

Author : Theo Stienissen
Date   : May 2021
Contact: theo.stienissen@gmail.com

*/

drop  table    polynomes;
drop  table    polynomes_temp;
drop  sequence polynome_seq;
drop  package  polynome_pkg;

create table polynomes
( id           number (8)
, factor       number (38, 15)
, poly_power   number (3));

alter  table polynomes add constraint  polynomes_pk primary key (id, poly_power) using index;

-- Only used as scratchpad
create global temporary table polynomes_temp
( id           number (8)
, factor       number (38, 15)
, poly_power   number (3))
on commit preserve rows;

create sequence polynome_seq;

create or replace package polynome_pkg
is
type polynome_row_ty is table of polynomes%rowtype index by pls_integer;

function  get_sequence (p_id in integer) return integer;

procedure poly_field (p_poly_power in integer, p_poly_field in varchar2 default 'X');

procedure print_factor (p_factor in number);

procedure print_polynome (p_polynome in polynome_row_ty);

procedure print_polynome (p_id in integer);

function  is_empty (p_id in integer) return boolean;

function  is_empty (p_polynome in polynome_row_ty) return boolean;

function  is_equal (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty) return boolean;

function  is_equal (p_id1 in integer, p_id2 in integer) return boolean;

function  poly_result (p_polynome in polynome_row_ty, p_value in number) return number;

function  poly_result (p_id in integer, p_value in number) return number;

function  poly_degree (p_polynome in polynome_row_ty) return integer;

function  poly_degree (p_id in integer) return integer;

procedure save_polynome (p_polynome in polynome_row_ty);

procedure save_temp_polynome (p_polynome in polynome_row_ty);

function  load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty;

function  add_polynome_elt (p_id in integer, p_factor in integer, p_power in integer) return polynome_row_ty;

function  add_polynome_elt (p_polynome in polynome_row_ty, p_factor in integer, p_power in integer) return polynome_row_ty;

function  add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty;

function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty;

function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty;

function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty;

function  multiply (p_polynome in polynome_row_ty, p_factor in number, p_power integer default null) return polynome_row_ty;

function  multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty;

function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty;

function  divide_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_zero_divisor out boolean) return polynome_row_ty;

function poly_shift (p_polynome in polynome_row_ty, p_value in integer, p_id in integer) return polynome_row_ty;

function cantor (p_polynome in polynome_row_ty, p_lower_bound in number, p_upper_bound in number, p_iterations in integer default 100) return number;

end polynome_pkg;
/

create or replace package body polynome_pkg
is
function  get_sequence (p_id in integer) return integer
is
begin
  if p_id is null
  then return polynome_seq.nextval;
  else return p_id;
  end if;
  
exception when others then
  util.show_error ('Error in function get_sequence.' , sqlerrm);
end get_sequence;

/******************************************************************************************************************************/

procedure poly_field (p_poly_power in integer, p_poly_field in varchar2 default 'X')
is
begin
--  dbms_output.put (p_factor);
  if    p_poly_power = 1 then dbms_output.put (' * ' || p_poly_field || ' ');
  elsif p_poly_power > 1 then dbms_output.put( ' * ' || p_poly_field || ' ** ' || p_poly_power);
  end if;

exception when others then
  util.show_error ('Error in procedure poly_field.' , sqlerrm);
end poly_field;

/******************************************************************************************************************************/

procedure print_factor (p_factor in number)
is
begin
  if sign (p_factor) < 0 then dbms_output.put (' - '); elsif sign (p_factor) > 0 then dbms_output.put (' + '); end if;
  dbms_output.put (to_char (abs (p_factor)));

exception when others then
  util.show_error ('Error in procedure print_factor.' , sqlerrm);
end print_factor;

/******************************************************************************************************************************/
--
-- Print polynome from a memory collection
--
procedure print_polynome (p_polynome in polynome_row_ty)
is
begin
for j in 1 .. p_polynome.count
loop
  print_factor (p_polynome(j).factor);
  poly_field (p_polynome(j).poly_power);
end loop;
dbms_output.new_line;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************************************/
--
-- Print polynome from the table
--
procedure print_polynome (p_id in integer)
is
begin
for j in (select sum(factor) factor, poly_power from polynomes where id = p_id group by poly_power order by poly_power)
loop
  print_factor (j.factor);
  poly_field (j.poly_power);
end loop;
dbms_output.new_line;

exception when others then
  util.show_error ('Error in procedure print_polynome.' , sqlerrm);
end print_polynome;

/******************************************************************************************************************************/
--
-- Checks if a polynome exists in the permanent table.
--
function  is_empty (p_id in integer) return boolean
is
l_count integer;
begin
  select count(*) into l_count from polynomes where id = p_id;
  return l_count = 0;

exception when others then
  util.show_error ('Error in function is_empty.' , sqlerrm);
end is_empty;

/******************************************************************************************************************************/
--
-- Checks if a polynome has no elements.
--
function  is_empty (p_polynome in polynome_row_ty) return boolean
is
begin
  return p_polynome.count = 0;

exception when others then
  util.show_error ('Error in function is_empty.' , sqlerrm);
end is_empty;

/******************************************************************************************************************************/
--
-- Checks if 2 polynomes are equal.
--
function  is_equal (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty) return boolean
is
l_identical boolean := TRUE;
begin
  if    is_empty (p1_polynome) and is_empty (p2_polynome) then return TRUE;
  elsif is_empty (p1_polynome)  or is_empty (p2_polynome) then return FALSE;
  elsif poly_degree (p1_polynome) != poly_degree (p2_polynome) then return FALSE;
  end if;
  <<done>>
  for j in 1 .. poly_degree (p1_polynome)
  loop
    l_identical := p1_polynome(j).poly_power = p2_polynome(j).poly_power and p1_polynome(j).factor = p2_polynome(j).factor;
    exit done when not l_identical;
  end loop;
  return l_identical;

exception when others then
  util.show_error ('Error in function is_equal. Memory comparison.' , sqlerrm);
end is_equal;

/******************************************************************************************************************************/
--
-- Checks if 2 polynomes are equal.
--
function  is_equal (p_id1 in integer, p_id2 in integer) return boolean
is
l_count integer(6);
begin
  select count(*) into l_count from (select id, factor from polynomes where id = p_id1 minus select id, factor from polynomes where id = p_id2);
  if l_count != 0 then return FALSE; end if;

  select count(*) into l_count from (select id, factor from polynomes where id = p_id2 minus select id, factor from polynomes where id = p_id1);
  return l_count = 0;

exception when others then
  util.show_error ('Error in function is_equal. Table comparison.' , sqlerrm);
end is_equal;

/******************************************************************************************************************************/
--
-- Calculate function result of a value
--
function  poly_result (p_polynome in polynome_row_ty, p_value in number) return number
is
l_value number := 0;
begin
  for j in 1 .. p_polynome.count
  loop
    l_value := nvl (l_value, 0) + p_polynome(j).factor * power (p_value, p_polynome(j).poly_power);
  end loop;
  return l_value;

exception when others then
  util.show_error ('Error in function poly_result.' , sqlerrm);
end poly_result;

/******************************************************************************************************************************/
--
-- Calculate function result of a value
--
function  poly_result (p_id in integer, p_value in number) return number
is
l_result number;
begin
  select sum (factor * power (p_value, poly_power)) into l_result from polynomes where id = p_id;
  return l_result;

exception when others then
  util.show_error ('Error in function poly_result.' , sqlerrm);
end poly_result;

/******************************************************************************************************************************/
--
-- Returns the degree of a polynome
--
function  poly_degree (p_polynome in polynome_row_ty) return integer
is
l_result integer(4);
begin
  for j in 1 .. p_polynome.count
  loop
    l_result := greatest (nvl (l_result, 0), p_polynome(j).poly_power);
  end loop;
  return l_result;

exception when others then
  util.show_error ('Error in function poly_degree for polynome_row_ty.' , sqlerrm);
end poly_degree;

/******************************************************************************************************************************/

function  poly_degree (p_id in integer) return integer
is
l_result integer(4);
begin
  select max (poly_power) into l_result from polynomes where id = p_id;
  return l_result;

exception when others then
  util.show_error ('Error in function poly_degree for table value.' , sqlerrm);
end poly_degree;

/******************************************************************************************************************************/
--
-- Save a polynome in a permanent table. Overwrites any existing polys with the same ID.
--
procedure save_polynome (p_polynome in polynome_row_ty)
is
begin
if is_empty (p_polynome)
then
  raise_application_error (-20005, 'Empty polynome entered in procedure: save_polynome');
else
  delete polynomes where id = p_polynome(1).id;
  forall j in 1 .. p_polynome.count
  insert into polynomes (id, factor, poly_power) values (p_polynome(j).id, p_polynome(j).factor, p_polynome(j).poly_power);
  commit;
end if;

exception when others then
  util.show_error ('Error in procedure save_polynome.' , sqlerrm);
end save_polynome;

/******************************************************************************************************************************/
--
-- Save a polynome in a temporary table. Scratchpad. Overwrites any existing polys with the same ID.
--
procedure save_temp_polynome (p_polynome in polynome_row_ty)
is
begin
if not is_empty (p_polynome)
then
  delete polynomes_temp where id = p_polynome(1).id;
  forall j in 1 .. p_polynome.count
  insert into polynomes_temp (id, factor, poly_power) values (p_polynome(j).id, p_polynome(j).factor, p_polynome(j).poly_power);
  commit;
end if;

exception when others then
  util.show_error ('Error in procedure save_temp_polynome.' , sqlerrm);
end save_temp_polynome;

/******************************************************************************************************************************/
--
-- Load a polynome from the table
--
function load_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome  polynome_row_ty;
begin
  select nvl(p_return, p_id), sum(factor), poly_power bulk collect into l_polynome from polynomes where id = p_id
  group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_polynome.' , sqlerrm);
end load_polynome;

/******************************************************************************************************************************/
--
-- Load a polynome from the temp table
--
function  load_temp_polynome (p_id in integer, p_return in integer default null) return polynome_row_ty
is
l_polynome  polynome_row_ty;
begin
  select nvl(p_return, p_id), sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id = p_id
  group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;

exception when others then
  util.show_error ('Error in function load_temp_polynome.' , sqlerrm);
end load_temp_polynome;

/******************************************************************************************************************************/
--
-- Add polynome element to a collection
--
function  add_polynome_elt (p_id in integer, p_factor in integer, p_power in integer) return polynome_row_ty
is
begin
  if p_factor != 0
  then
    insert into polynomes (id, factor, poly_power) values (p_id, p_factor, p_power);
    commit;
  end if;
  return load_polynome (p_id);

exception when others then
  util.show_error ('Error in function add_polynome_elt.' , sqlerrm);
end add_polynome_elt;

/******************************************************************************************************************************/
--
-- Add polynome element to a collection
--
function  add_polynome_elt (p_polynome in polynome_row_ty, p_factor in integer, p_power in integer) return polynome_row_ty
is
l_polynome    polynome_row_ty;
l_sequence    integer(8);
begin
  if is_empty (p_polynome)
  then
    l_sequence := polynome_seq.nextval;
  else
    l_sequence := p_polynome(1).id;
  end if;

  if p_factor != 0
  then
    delete polynomes_temp where id = l_sequence;
    save_temp_polynome (p_polynome);
    insert into polynomes_temp (id, factor, poly_power) values (l_sequence, p_factor, p_power);
    select l_sequence, sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id = l_sequence
    group by poly_power having sum(factor) != 0 order by poly_power desc;
  end if;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynome_elt.' , sqlerrm);
end add_polynome_elt;

/******************************************************************************************************************************/
--
-- Add 2 polynomes from a table
--
function add_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_result   integer(8) := get_sequence (p_result);
begin
  select l_result, sum(factor), poly_power bulk collect into l_polynome from polynomes where id in (p_id1, p_id2)
  group by poly_power having sum(factor) != 0 order by poly_power desc;
  return l_polynome;
  
exception when others then
  util.show_error ('Error in function add_polynomes.' , sqlerrm);
end add_polynomes;

/******************************************************************************************************************************/
--
-- Add 2 polynomes from polynome_row_ty
--
function  add_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_result   integer(8);
begin
if is_empty(p1_polynome) or is_empty(p2_polynome)
then
  raise_application_error(-20005, 'Empty polynome entered in procedure: add_polynomes');
else
  save_temp_polynome(p1_polynome);
  save_temp_polynome(p2_polynome);
  l_result := get_sequence (p_result);  
  select l_result, sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id in (p1_polynome(1).id, p2_polynome(1).id)
  group by poly_power having sum(factor) != 0 order by poly_power desc;
end if;
  return l_polynome;

exception when others then
  util.show_error ('Error in function add_polynomes.' , sqlerrm);
end add_polynomes;

/******************************************************************************************************************************/
--
-- Substract 2 polynomes from a table
--
function  subtract_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty
is
l_poly1  polynome_row_ty := load_polynome (p_id1);
l_poly2  polynome_row_ty := load_polynome (p_id2);
begin
  if is_empty(l_poly1) or is_empty(l_poly2)
  then
    raise_application_error(-20005, 'Empty polynome entered in procedure: subtract_polynomes');
  end if;
  return add_polynomes (l_poly1, multiply (l_poly2, -1), get_sequence (p_result));
 
exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
end subtract_polynomes;

/******************************************************************************************************************************/
--
-- Substract 2 polynomes from polynome_row_ty: p1_polynome - p2_polynome
--
function  subtract_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty
is
begin
  return add_polynomes (p1_polynome, multiply (p2_polynome, -1), get_sequence (p_result));

exception when others then
  util.show_error ('Error in function subtract_polynomes.' , sqlerrm);
end subtract_polynomes;

/******************************************************************************************************************************/
--
-- Multiply a polynome with a scalar
--
function  multiply (p_polynome in polynome_row_ty, p_factor in number, p_power integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_seq      integer(6) := polynome_seq.nextval;
begin
  for j in 1 .. p_polynome.count
  loop
    l_polynome(j).id         := l_seq;
    l_polynome(j).factor     := p_polynome(j).factor * p_factor;
	l_polynome(j).poly_power := p_polynome(j).poly_power + nvl(p_power, 0);
  end loop;
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply.' , sqlerrm);
end multiply;

/******************************************************************************************************************************/
--
-- Multiply 2  polynomes from a table
--
function multiply_polynomes (p_id1 in integer, p_id2 in integer, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_result   integer(8) := get_sequence (p_result);
begin
if    is_empty (p_id1) then raise_application_error (-20005, 'Empty first polynome entered in procedure: multiply_polynomes.');
elsif is_empty (p_id2) then raise_application_error (-20005, 'Empty second polynome entered in procedure: multiply_polynomes.');
else
  delete polynomes_temp where id = l_result;
  insert into polynomes_temp (id, factor, poly_power) 
  select l_result, poly1.factor * poly2.factor, poly1.poly_power + poly2.poly_power from 
    (select sum (p1.factor) factor, p1.poly_power from polynomes p1 where p1.id = p_id1 group by p1.poly_power) poly1,
    (select sum (p2.factor) factor, p2.poly_power from polynomes p2 where p2.id = p_id2 group by p2.poly_power) poly2;
--
  select l_result, sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id = l_result group by poly_power order by poly_power desc;
  return l_polynome;
end if;

exception when others then
  util.show_error ('Error in function multiply_polynomes from a table.' , sqlerrm);
end multiply_polynomes;

/******************************************************************************************************************************/
--
-- Multiply 2 polynomes from a memory collection
--
function  multiply_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_result in integer default null) return polynome_row_ty
is
l_polynome polynome_row_ty;
l_count    integer(3) := 0;
l_result   integer(8) := get_sequence (p_result);
begin
if    is_empty(p1_polynome) then raise_application_error(-20005, 'Empty first polynome entered in procedure: multiply_polynomes.');
elsif is_empty(p2_polynome) then raise_application_error(-20005, 'Empty second polynome entered in procedure: multiply_polynomes.');
else
  delete polynomes_temp where id = l_result;
--
  for i in 1 .. p1_polynome.count
  loop
    for j in 1 .. p2_polynome.count
	loop
      insert into polynomes_temp (id, factor, poly_power)
	    values (l_result, p1_polynome(i).factor * p2_polynome(j).factor, p1_polynome(i).poly_power + p2_polynome(j).poly_power);
    end loop;
  end loop;
--
  select l_result, sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id = l_result group by poly_power order by poly_power desc;
end if;  
  return l_polynome;

exception when others then
  util.show_error ('Error in function multiply_polynomes.' , sqlerrm);
end multiply_polynomes;

/******************************************************************************************************************************/
--
-- Divide 2 polynomes from a memory collection. Remove zero's.
--
function  divide_polynomes (p1_polynome in polynome_row_ty, p2_polynome in polynome_row_ty, p_zero_divisor out boolean) return polynome_row_ty
is
l_polynome    polynome_row_ty;
l_result_poly polynome_row_ty;
l_factor      polynomes.factor%type;
l_power       polynomes.poly_power%type;
-- l_result      integer(8) := get_sequence (p_result);
begin
  if    is_empty(p1_polynome) then raise_application_error(-20005, 'Empty first polynome entered in function: divide_polynomes.');
  elsif is_empty(p2_polynome) then raise_application_error(-20005, 'Empty second polynome entered in function: divide_polynomes.');
  elsif poly_degree (p1_polynome) > poly_degree (p2_polynome)
  then  raise_application_error(-2000, 'Degree of first polynome must be less then or equal degree second polynome in function: divide_polynomes.');
  end if;
  
  l_polynome := p2_polynome;
  for j in 1 .. poly_degree (p2_polynome) - poly_degree (p1_polynome) + 1
  loop
    l_factor      := l_polynome(1).factor / p1_polynome(1).factor;
	l_power       := l_polynome(1).poly_power - p1_polynome(1).poly_power;
	l_polynome    := subtract_polynomes (l_polynome, multiply (p1_polynome, l_factor, l_power));
	l_result_poly := add_polynome_elt (l_result_poly, l_factor, l_power);
  end loop;
  p_zero_divisor := is_empty (l_polynome);
  return l_result_poly;

exception when others then
  util.show_error ('Error in function divide_polynomes.' , sqlerrm);
end divide_polynomes;

/******************************************************************************************************************************/
--
-- x = y + k, so shift "p_value" to the ... RIGHT
-- (y + k) ** n Use binomial coefficients
--
function poly_shift (p_polynome in polynome_row_ty, p_value in integer, p_id in integer) return polynome_row_ty
is
l_polynome polynome_row_ty;
begin
  delete polynomes_temp where id = p_id;
  for p in 1 .. p_polynome.count
  loop
    for j in 0 .. p_polynome (p).poly_power
    loop
      -- factor : p_polynome(p).factor * power (l_value, j)
      -- power  : p_polynome (p).power - j
      insert into polynomes_temp (id, factor, poly_power)
	  values (p_id, p_polynome(p).factor * maths.n_over (p_polynome(p).poly_power, j) * power (- p_value, j), p_polynome(p).poly_power - j);
    end loop;
  end loop;

  select p_id, sum(factor), poly_power bulk collect into l_polynome from polynomes_temp where id = p_id group by poly_power order by poly_power desc;
  return l_polynome;
  
exception when others then
  util.show_error ('Error in function poly_shift.' , sqlerrm);
end poly_shift;

/******************************************************************************************************************************/
--
-- Calculate estimate zero's. Only works if you know there must be a zero between the bounds and on rising interval
-- You might have to multiply the polynome with -1.
--
function cantor (p_polynome in polynome_row_ty, p_lower_bound in number, p_upper_bound in number, p_iterations in integer default 100) return number
is
l_count       integer(4)   := p_iterations;
l_lower_bound number := p_lower_bound;
l_upper_bound number := p_upper_bound;
l_result      number;
begin
  <<done>>
  for j in 1 .. p_iterations
  loop
    l_result := (l_lower_bound + l_upper_bound) / 2;
    if poly_result (p_polynome, l_result) > 0
    then l_upper_bound := l_result;
    else l_lower_bound := l_result;
    end if;
    exit done when l_upper_bound = l_lower_bound;
  end loop;
  dbms_output.put_line('Error margin: ' || to_char(l_upper_bound - l_lower_bound));
  return l_lower_bound;
 
exception when others then
  util.show_error ('Error in function cantor.' , sqlerrm);
end cantor;

end polynome_pkg;
/
