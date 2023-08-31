/*

Author  : Theo Stienissen
Date    : November 2021
Modified: April    2022
Purpose : Basic triangle calculations for getting edges and vertexes
Contact : theo.stienissen@gmail.com

Dependencies: util error handling and conversion_pkg
The vertex (plural: vertices) is a corner of the trivertex.
Base functions work with radians. Conversion to degrees or decimal possible with function complete_triangle 

cos a = (b * b + a * a - c * c) / 2 * b * c
sin a / a = sin b / b
*/

create or replace type triangle_row as object (solution integer(2), vertex number, edge number);
/

create or replace type triangle_tab as table of triangle_row;
/

create or replace package triangle_pkg
is 

function cosine_v (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number;

function cosine_e (p_edge2 in number, p_edge3 in number, p_vertex1 in number) return number;

function sine_v (p_edge1 in number, p_vertex1 in number, p_edge2 in number) return number;

function sine_e (p_edge1 in number, p_vertex1 in number, p_vertex2 in number) return number;

function vertex_vv  (p_vertex1 in number, p_vertex2 in number) return number;

function validate_triangle (p_edge1 in number, p_edge2 in number, p_edge3 in number, p_vertex1 in number, p_vertex2 in number, p_vertex3 in number) return boolean;

function triangle_eee (p_edge1 in number, p_edge2 in number, p_edge3 in number)  return triangle_tab pipelined;

function triangle_eev (p_edge1 in number, p_edge2 in number, p_vertex1 in number) return triangle_tab pipelined;

function triangle_eve (p_edge1 in number, p_vertex3 in number, p_edge2 in number) return triangle_tab pipelined;

function triangle_vee (p_vertex3 in number, p_edge2 in number, p_edge3 in number) return triangle_tab pipelined;

function triangle_vve (p_vertex2 in number, p_vertex3 in number, p_edge2 in number) return triangle_tab pipelined;

function triangle_vev (p_vertex2 in number, p_edge1 in number, p_vertex3 in number) return triangle_tab pipelined;

function triangle_evv (p_edge1 in number, p_vertex3 in number, p_vertex1 in number) return triangle_tab pipelined;

function complete_triangle (p_type in varchar2, p_value1 in number, p_value2 in number, p_value3 in number, p_format in varchar2 default 'DM') return triangle_tab pipelined;

function triangle_area (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number;

end triangle_pkg;
/

create or replace package body triangle_pkg
is 

-- Square function
function sqr (p_number in number) return number 
is 
begin 
  return p_number * p_number;

exception when others 
then 
  util.show_error ('Error in function sqr for: ' || to_char (p_number), sqlerrm);
  return null;
end sqr; 

/************************************************************************************************************************************/

-- Cosine rule. Function returns opposite angle of the first edge in radians
function cosine_v (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number 
is 
begin 
  return acos ((sqr (p_edge2) + sqr (p_edge3) - sqr (p_edge1)) / (2 * p_edge2 * p_edge3));

exception when others 
then 
  util.show_error ('Error in function cosine_v for: ' || to_char (p_edge1) || ', ' || to_char (p_edge2) || ', ' || to_char (p_edge3), sqlerrm);
  return null;
end cosine_v; 

/************************************************************************************************************************************/

-- Cosine rule. Function returns the edge opposite the first angle
function cosine_e (p_edge2 in number, p_edge3 in number, p_vertex1 in number) return number 
is 
begin 
    return sqrt (sqr (p_edge2) + sqr (p_edge3) - 2 * p_edge2 * p_edge3 * cos (p_vertex1));

exception when others 
then 
  util.show_error ('Error in function cosine_v for  E2: ' || to_char (p_edge2) || ', E3: ' || to_char (p_edge3) || ', V1: ' || to_char (p_vertex1), sqlerrm);
  return null;
end cosine_e;

/************************************************************************************************************************************/

-- Sine rule. Function returns the angle opposite the second edge
function sine_v (p_edge1 in number, p_vertex1 in number, p_edge2 in number) return number 
is 
begin 
    return asin (p_edge2 * sin (p_vertex1) / p_edge1);

exception when others 
then 
  util.show_error ('Error in function sine_v for  E1: ' || to_char (p_edge1) || ', E2: ' || to_char (p_edge2) || ', V1: ' || to_char (p_vertex1), sqlerrm);
  return null;
end sine_v;

/************************************************************************************************************************************/

-- Sine rule. Function returns the edge opposite the second angle
function sine_e (p_edge1 in number, p_vertex1 in number, p_vertex2 in number) return number 
is 
begin 
    return p_edge1 * sin (p_vertex2) / sin (p_vertex1);

exception when others 
then 
  util.show_error ('Error in function sine_e for  E1: ' || to_char (p_edge1) || ', V1: ' || to_char (p_vertex1) || ', V2: ' || to_char (p_vertex2), sqlerrm);
  return null;
end sine_e;

/************************************************************************************************************************************/

-- Sum of the angles is pi or 180 degrees. Returns third angle in radians
function vertex_vv  (p_vertex1 in number, p_vertex2 in number) return number
is 
begin
  return constants_pkg.g_pi - p_vertex1 - p_vertex2;
 
exception when others 
then 
  util.show_error ('Error in function vertex_vv for: ' || to_char (p_vertex1) || ', ' || to_char (p_vertex2), sqlerrm);
  return null;
end vertex_vv;

/************************************************************************************************************************************/

function validate_triangle (p_edge1 in number, p_edge2 in number, p_edge3 in number, p_vertex1 in number, p_vertex2 in number, p_vertex3 in number) return boolean
is 
begin 
  return p_edge1 > 0 and p_edge2 > 0 and p_edge3 > 0
     and p_vertex1 > 0 and p_vertex2 > 0 and p_vertex3 > 0
     and p_vertex1 between 0 and constants_pkg.g_pi
	 and p_vertex2 between 0 and constants_pkg.g_pi
	 and p_vertex3 between 0 and constants_pkg.g_pi
	 and p_edge1 < p_edge2 + p_edge3
	 and p_edge2 < p_edge1 + p_edge3  
	 and p_edge3 < p_edge1 + p_edge2;
  
exception when others 
then 
  util.show_error ('Error in function validate_triangle', sqlerrm);
  return null;
end validate_triangle;

/************************************************************************************************************************************/

-- Returns details of a triangle when all 3 edges are known
function triangle_eee (p_edge1 in number, p_edge2 in number, p_edge3 in number) return triangle_tab pipelined
is
begin
if p_edge1 + p_edge2 + p_edge3 > 2 * greatest (p_edge1, p_edge2, p_edge3)
then 
  pipe row (triangle_row (1, cosine_v (p_edge1, p_edge2, p_edge3), p_edge1));
  pipe row (triangle_row (1, cosine_v (p_edge2, p_edge3, p_edge1), p_edge2));
  pipe row (triangle_row (1, cosine_v (p_edge3, p_edge1, p_edge2), p_edge3));
end if;
  
exception when others 
then 
  util.show_error ('Error in function triangle_eee for: ' || to_char (p_edge1) || ', ' || to_char (p_edge2) || ', ' || to_char (p_edge3), sqlerrm);
end triangle_eee;

/************************************************************************************************************************************/

-- 2 Solutions for vertices: phi and pi - phi
function triangle_eev (p_edge1 in number, p_edge2 in number, p_vertex1 in number) return triangle_tab pipelined
is
l_vertex2 number;
l_vertex3 number;
l_edge3   number;
l_save    number;
begin
if p_edge2 * sin (p_vertex1) / p_edge1 between 0 and 1
then
-- First case
  l_vertex2 := sine_v (p_edge1, p_vertex1, p_edge2);
  l_vertex3 := vertex_vv  (p_vertex1, l_vertex2);
  l_edge3   := sine_e (p_edge1, p_vertex1, l_vertex3);
  l_save    := l_edge3;
--
  if validate_triangle (p_edge1, p_edge2, l_edge3, p_vertex1, l_vertex2, l_vertex3)
  then
    pipe row (triangle_row (1, p_vertex1, p_edge1));
    pipe row (triangle_row (1, l_vertex2, p_edge2));
    pipe row (triangle_row (1, l_vertex3, l_edge3));
  end if;
  
-- Second case
  l_vertex2 := constants_pkg.g_pi - l_vertex2;
  l_vertex3 := vertex_vv (p_vertex1, l_vertex2);
  l_edge3   := sine_e (p_edge1, p_vertex1, l_vertex3);
--
  if round(l_save, 4) != round(l_edge3, 4) and validate_triangle (p_edge1, p_edge2, l_edge3, p_vertex1, l_vertex2, l_vertex3)
  then
    pipe row (triangle_row (2, p_vertex1, p_edge1));
    pipe row (triangle_row (2, l_vertex2, p_edge2));
    pipe row (triangle_row (2, l_vertex3, l_edge3));
  end if;
end if;

exception when others 
then 
  util.show_error ('Error in function triangle_eev for: ' || to_char (p_edge1) || ', ' || to_char (p_edge2) || ', ' || to_char (p_vertex1), sqlerrm);
end triangle_eev;

/************************************************************************************************************************************/

function triangle_eve (p_edge1 in number, p_vertex3 in number, p_edge2 in number) return triangle_tab pipelined
is
l_vertex1 number;
l_vertex2 number;
l_edge3   number;
begin
  l_edge3 := cosine_e (p_edge1, p_edge2, p_vertex3);  
  l_vertex1 := sine_v (l_edge3, p_vertex3, p_edge1);
  l_vertex2 := sine_v (l_edge3, p_vertex3, p_edge2);
--
  pipe row (triangle_row (1, l_vertex1, p_edge1));
  pipe row (triangle_row (1, l_vertex2, p_edge2));
  pipe row (triangle_row (1, p_vertex3, l_edge3));

exception when others 
then 
  util.show_error ('Error in function triangle_eve for: E1: ' || to_char (p_edge1) || ', E2: ' || to_char (p_edge2) || ', V3: ' || to_char (p_vertex3), sqlerrm);
end triangle_eve;

/************************************************************************************************************************************/

function triangle_vee (p_vertex3 in number, p_edge2 in number, p_edge3 in number) return triangle_tab pipelined
is
l_vertex1 number;
l_vertex2 number;
l_edge1   number;
l_save    number;
begin
if p_edge2 * sin (p_vertex3) / p_edge3 between 0 and 1
then
-- First case
  l_vertex2 := sine_v (p_edge3, p_vertex3, p_edge2);
  l_vertex1 := vertex_vv  (l_vertex2, p_vertex3);
  l_edge1   := sine_e (p_edge3, p_vertex3, l_vertex1);
  l_save    := l_edge1;
--
  if validate_triangle (l_edge1, p_edge2, p_edge3, l_vertex1, l_vertex2, p_vertex3)
  then
    pipe row (triangle_row (1, l_vertex1, l_edge1));
    pipe row (triangle_row (1, l_vertex2, p_edge2));
    pipe row (triangle_row (1, p_vertex3, p_edge3));
  end if;
  
-- Second case
  l_vertex2 := constants_pkg.g_pi - l_vertex2;
  l_vertex1 := vertex_vv (l_vertex2, p_vertex3);
  l_edge1   := sine_e (p_edge3, p_vertex3, l_vertex1);
--
  if round(l_save, 4) != round(l_edge1, 4) and validate_triangle (l_edge1, p_edge2, p_edge3, l_vertex1, l_vertex2, p_vertex3)
  then
    pipe row (triangle_row (2, l_vertex1, l_edge1));
    pipe row (triangle_row (2, l_vertex2, p_edge2));
    pipe row (triangle_row (2, p_vertex3, p_edge3));
  end if;
end if;

exception when others 
then 
  util.show_error ('Error in function triangle_vee for V2: ' || to_char (p_vertex3) || ', E2: ' || to_char (p_edge2) || ', E3: ' || to_char (p_edge3), sqlerrm);
end triangle_vee;

/************************************************************************************************************************************/

function triangle_vve (p_vertex2 in number, p_vertex3 in number, p_edge2 in number) return triangle_tab pipelined
is
l_vertex1 number;
l_edge1   number;
l_edge3   number;
begin
  l_vertex1 := vertex_vv (p_vertex2, p_vertex3);
  l_edge1   := sine_e (p_edge2, p_vertex2, l_vertex1);
  l_edge3   := sine_e (p_edge2, p_vertex2, p_vertex3);
--
  pipe row (triangle_row (1, l_vertex1, l_edge1));
  pipe row (triangle_row (1, p_vertex2, p_edge2));
  pipe row (triangle_row (1, p_vertex3, l_edge3));

exception when others 
then 
  util.show_error ('Error in function triangle_vve for V2: ' || to_char (p_vertex2) || ', V3: ' || to_char (p_vertex3) || ', E2: ' || to_char (p_edge2), sqlerrm);
end triangle_vve;

/************************************************************************************************************************************/

function triangle_vev (p_vertex2 in number, p_edge1 in number, p_vertex3 in number) return triangle_tab pipelined
is
l_vertex1 number;
l_edge2   number;
l_edge3   number;
begin
  l_vertex1 := vertex_vv (p_vertex2, p_vertex3);
  l_edge2   := sine_e (p_edge1, l_vertex1, p_vertex2);
  l_edge3   := sine_e (p_edge1, l_vertex1, p_vertex3);
--
  pipe row (triangle_row (1, l_vertex1, p_edge1));
  pipe row (triangle_row (1, p_vertex2, l_edge2));
  pipe row (triangle_row (1, p_vertex3, l_edge3));

exception when others 
then 
  util.show_error ('Error in function triangle_vev for V2: ' || to_char (p_vertex2) || ', E1: ' || to_char (p_edge1) || ', V3: ' || to_char (p_vertex3), sqlerrm);
end triangle_vev;

/************************************************************************************************************************************/

function triangle_evv (p_edge1 in number, p_vertex3 in number, p_vertex1 in number) return triangle_tab pipelined
is
l_vertex2 number;
l_edge2   number;
l_edge3   number;
begin
  l_vertex2 := vertex_vv  (p_vertex1, p_vertex3);
  l_edge2   := sine_e (p_edge1, p_vertex1, l_vertex2);
  l_edge3   := sine_e (p_edge1, p_vertex1, p_vertex3);
--
  pipe row (triangle_row (1, p_vertex1, p_edge1));
  pipe row (triangle_row (1, l_vertex2, l_edge2));
  pipe row (triangle_row (1, p_vertex3, l_edge3));

exception when others 
then 
  util.show_error ('Error in function triangle_evv for E1: ' || to_char (p_edge1) || ', V1: ' ||to_char (p_vertex1) || ', V3: ' || to_char (p_vertex3), sqlerrm);
end triangle_evv;

/************************************************************************************************************************************/

function complete_triangle (p_type in varchar2, p_value1 in number, p_value2 in number, p_value3 in number, p_format in varchar2 default 'DM') return triangle_tab pipelined
is
begin
  if    upper (p_format)  not in ('DD', 'DM', 'R')
  then  raise_application_error (-20001, 'Invalid input format: ' || p_format);
  end if;
--
  if upper (p_type) in ('EEE', 'ZZZ')
  then
    for j in (select solution, vertex, edge from table (triangle_eee (p_value1, p_value2, p_value3)))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
--
  elsif upper (p_type) in ('EEV', 'ZZH')
  then
    for j in (select solution, vertex, edge from table (triangle_eev (p_value1, p_value2, conversion_pkg.convert_radians_degrees (p_value3, p_format, 'R'))))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
--
  elsif upper (p_type) in ('EVE', 'ZHZ')
  then
    for j in (select solution, vertex, edge from table (triangle_eve (p_value1, conversion_pkg.convert_radians_degrees (p_value2, p_format, 'R'), p_value3)))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
--
  elsif upper (p_type) in ('VEE', 'HZZ')
  then
    for j in (select solution, vertex, edge from table (triangle_vee (conversion_pkg.convert_radians_degrees (p_value1, p_format, 'R'), p_value2, p_value3)))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;  
--
   elsif upper (p_type) in ('VVE', 'HHZ')
  then
    for j in (select solution, vertex, edge from table (triangle_vve (conversion_pkg.convert_radians_degrees (p_value1, p_format, 'R'), conversion_pkg.convert_radians_degrees (p_value2, p_format, 'R'), p_value3)))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
--
  elsif upper (p_type) in ('VEV', 'HZH')
  then 
    for j in (select solution, vertex, edge from table (triangle_vev (conversion_pkg.convert_radians_degrees (p_value1, p_format, 'R'), p_value2, conversion_pkg.convert_radians_degrees (p_value3, p_format, 'R'))))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
--
  elsif upper (p_type) in ('EVV', 'ZHH')
  then
      for j in (select solution, vertex, edge from table (triangle_evv ( p_value1, conversion_pkg.convert_radians_degrees (p_value2, p_format, 'R'), conversion_pkg.convert_radians_degrees (p_value3, p_format, 'R'))))
	loop 
	   pipe row (triangle_row (j.solution, conversion_pkg.convert_radians_degrees (j.vertex, 'R', p_format), j.edge)); 
	end loop;
  end if; 

exception when others 
then 
  util.show_error ('Error in function complete_triangle Format: ' || p_format || '. Val1: ' || to_char (p_value1) ||
                  ', Val2: ' || to_char (p_value2)  || ', Val3: ' || to_char (p_value3), sqlerrm);
end complete_triangle;

/************************************************************************************************************************************/

-- Heron's formula to calculate the area of a triangle

function triangle_area (p_edge1 in number, p_edge2 in number, p_edge3 in number) return number
is
l_s number := (p_edge1 + p_edge2 + p_edge3) / 2;
begin 
  return sqrt (l_s * (l_s - p_edge1) * (l_s - p_edge2) * (l_s - p_edge3));
  
exception when others 
then 
  util.show_error ('Error in function triangle_area E1: ' || to_char (p_edge1) || '. E2: ' || to_char (p_edge2) || '. E3: ' ||to_char (p_edge3), sqlerrm);
  return null;
end triangle_area;

end triangle_pkg;
/

/* Error:
select * from table(triangle_pkg.complete_triangle('ZZH',7,7,130));
select * from table (triangle_pkg.complete_triangle('EEV',5,4,90));
*/

-- Example
set serveroutput on size unlimited
declare 
type t_tab_ty is record (solution integer(2), vertex number, edge number);
type t_tab_array is table of t_tab_ty index by pls_integer;
l_triangle_save t_tab_array;
l_triangle_tab  t_tab_array;
l_format        varchar2(3);
procedure print (p_format in varchar2, p_aray in t_tab_array)
is 
begin
dbms_output.put_line('--  '  || p_format);
for j in 1 .. p_aray.count
loop 
  dbms_output.put_line (to_char(p_aray(j).solution, '90') || '  V:  ' || to_char(round (p_aray(j).vertex, 6), '0D999999')  || '  E:  ' || round (p_aray(j).edge, 6));
end loop;
end print;
begin 
l_format := 'ZZZ';
select * bulk collect into l_triangle_save from table (triangle_pkg.complete_triangle(l_format,3,4,5, 'R'));
print (l_format, l_triangle_save);
l_format := 'EEV';
begin
dbms_output.put_line ('Before ' || l_format);
-- dbms_output.put_line ('Values: '|| l_triangle_save(1).edge || '   ' || l_triangle_save(2).edge || '   ' || l_triangle_save(1).vertex);
select * bulk collect into l_triangle_tab from table (triangle_pkg.complete_triangle(l_format,l_triangle_save(1).edge,l_triangle_save(2).edge,l_triangle_save(1).vertex, 'R'));
print (l_format, l_triangle_tab);
exception when others then null;
end;
l_format := 'EVE';
begin
dbms_output.put_line ('Before ' || l_format);
select * bulk collect into l_triangle_tab from table (triangle_pkg.complete_triangle (l_format,l_triangle_save(1).edge,l_triangle_save(3).vertex,l_triangle_save(2).edge, 'R'));
print (l_format, l_triangle_tab);
exception when others then null;
end;
l_format := 'VEE';
begin
dbms_output.put_line ('Before ' || l_format);
select * bulk collect into l_triangle_tab from table (triangle_pkg.complete_triangle (l_format,l_triangle_save(3).vertex,l_triangle_save(2).edge,l_triangle_save(3).edge, 'R'));
print (l_format, l_triangle_tab);
exception when others then null;
end;
l_format := 'VVE';
begin
dbms_output.put_line ('Before ' || l_format);
select * bulk collect into l_triangle_tab from table (triangle_pkg.complete_triangle (l_format,l_triangle_save(3).vertex,l_triangle_save(2).vertex,l_triangle_save(3).edge, 'R'));
print (l_format, l_triangle_tab);
exception when others then null;
end; 
l_format := 'EVV';
begin
dbms_output.put_line ('Before ' || l_format);
select * bulk collect into l_triangle_tab from table (triangle_pkg.complete_triangle (l_format,l_triangle_save(1).edge,l_triangle_save(3).vertex,l_triangle_save(1).vertex, 'R'));
print (l_format, l_triangle_tab);
exception when others then null;
end;
end;
