/*************************************************************************************************************************************************

Name:        matrix_pkg.sql

Created      October 2014
Last update  January 2016

Author:      Theo stienissen

E-mail:      theo.stienissen@gmail.com


*************************************************************************************************************************************************/

set serveroutput on size unlimited

create or replace package matrix_pkg
as

-- Matrix:
-- ( 11   ...    1n )
--        ...
-- ( m1   ...    mn )
--

type line_ty          is table of  number index by pls_integer;
type matrix_ty        is table of line_ty index by pls_integer;
type point_ty         is record (x_c number(6, 4), y_c number(6, 4), z_c number(6, 4));

pkg_dimensions        number(2) := 3;

procedure init_matrix (p_matrix in out matrix_ty);

function  to_point (p_x in number, p_y in number, p_z in number default null) return point_ty;

function  multiply (p_matrix_a in matrix_ty, p_matrix_b in matrix_ty) return matrix_ty;

function  multiply (p_matrix in matrix_ty, p_point in point_ty) return point_ty;

function  mirror_xy (p_matrix in matrix_ty) return matrix_ty;

function  mirror_xy (p_point in point_ty) return point_ty;

function  transform_to_3D (p_point in point_ty) return point_ty;

function  determinant (p_matrix in matrix_ty) return number;

procedure print_matrix (p_matrix in matrix_ty);

procedure print_point (p_point point_ty);

end matrix_pkg;
/

/*************************************************************************************************************************************************/

create or replace package body matrix_pkg
as

--
-- Reset all values to 0
--
procedure init_matrix (p_matrix in out matrix_ty)
is
begin
  for m in 1 .. pkg_dimensions
  loop
    for n in 1 .. pkg_dimensions
    loop
      p_matrix (m)(n) := 0;
    end loop;
  end loop;

exception when others then
  util.show_error('Error in procedure init_matrix.' , sqlerrm);
end init_matrix;

/*************************************************************************************************************************************************/

--
-- Converts co-ordinates to a point type
--
function to_point (p_x in number, p_y in number, p_z in number default null) return point_ty
is
l_point point_ty;
begin
  l_point.x_c := p_x;
  l_point.y_c := p_y;
  l_point.z_c := p_z;
return l_point;

exception when others then
  util.show_error('Error in function to_point.' , sqlerrm);
end to_point;

/*************************************************************************************************************************************************/

--
-- Multiplies 2 matrices
--
function multiply (p_matrix_a in matrix_ty, p_matrix_b in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
l_val    number(4);
begin
for n in 1 .. pkg_dimensions
loop
  for m in 1 .. pkg_dimensions
  loop
    l_val := 0;    
    for p in 1 .. pkg_dimensions
    loop
      l_val := l_val +  p_matrix_a (m)(p) *  p_matrix_b (p)(n);
    end loop;
    l_matrix(m)(n) := l_val;
  end loop;
end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function multiply 1.' , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

function multiply (p_matrix in matrix_ty, p_point in point_ty) return point_ty
is
l_point point_ty := to_point (0, 0, 0);
begin
if pkg_dimensions = 2
then
  l_point.x_c := p_matrix (1)(1) * p_point.x_c + p_matrix (2)(1) * p_point.y_c;
  l_point.y_c := p_matrix (1)(2) * p_point.x_c + p_matrix (2)(2) * p_point.y_c;
elsif pkg_dimensions = 3
then
  l_point.x_c := p_matrix (1)(1) * p_point.x_c + p_matrix (2)(1) * p_point.y_c + p_matrix (3)(1) * p_point.z_c;
  l_point.y_c := p_matrix (1)(2) * p_point.x_c + p_matrix (2)(2) * p_point.y_c + p_matrix (3)(2) * p_point.z_c;
  l_point.z_c := p_matrix (1)(3) * p_point.x_c + p_matrix (2)(3) * p_point.y_c + p_matrix (3)(3) * p_point.z_c;
end if;
return l_point;

exception when others then
  util.show_error('Error in function multiply 2.' , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- 2 Dimensional mirror in x = y plane. z = 0.
--
function mirror_xy (p_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
  for m in 1 .. pkg_dimensions
  loop
    for n in 1 .. pkg_dimensions
    loop
      l_matrix (m)(n) := p_matrix (n)(m);
    end loop;
  end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function mirror_xy 1.' , sqlerrm);
end mirror_xy;

/*************************************************************************************************************************************************/

function  mirror_xy (p_point in point_ty) return point_ty
is
l_point point_ty;
begin
  l_point.x_c := p_point.y_c;
  l_point.y_c := p_point.x_c;
  l_point.z_c := p_point.z_c;

  return l_point;

exception when others then
  util.show_error('Error in function mirror_xy 2.' , sqlerrm);
end mirror_xy;

/*************************************************************************************************************************************************/

function  transform_to_3D (p_point in point_ty) return point_ty
is
l_point point_ty;
begin
  l_point.x_c := p_point.x_c / 2 - p_point.y_c / 2;
  l_point.y_c := p_point.x_c / 2 - p_point.y_c / 2 + p_point.z_c / 2;
  l_point.z_c := p_point.x_c / 2 + p_point.y_c / 2 - p_point.z_c / 2;

  return l_point;

exception when others then
  util.show_error('Error in function transform_to_3D.' , sqlerrm);
end transform_to_3D;

/*************************************************************************************************************************************************/

function  determinant (p_matrix in matrix_ty) return number
is
begin
if    pkg_dimensions = 2
then return p_matrix(1)(1) * p_matrix(2)(2) - p_matrix(2)(1) * p_matrix(1)(2);
elsif pkg_dimensions = 3
then return
   p_matrix(1)(1) * p_matrix(2)(2) * p_matrix(3)(3) + p_matrix(1)(2) * p_matrix(2)(3) * p_matrix(3)(1)
 + p_matrix(1)(3) * p_matrix(2)(1) * p_matrix(3)(2) - p_matrix(1)(3) * p_matrix(2)(2) * p_matrix(3)(1)
 - p_matrix(1)(2) * p_matrix(2)(1) * p_matrix(3)(3) - p_matrix(1)(1) * p_matrix(2)(3) * p_matrix(3)(2);
else
  raise_application_error(-20001, 'Determinant not yet defined for this dimension.');
end if;

exception when others then
  util.show_error('Error in function determinant.' , sqlerrm);
end determinant;

/*************************************************************************************************************************************************/

procedure print_matrix (p_matrix in matrix_ty)
is
l_format varchar2(10) := '990D99';
procedure line
is
begin
  dbms_output.new_line;
--  dbms_output.put_line(rpad ('+', 2 * pkg_dimensions * length(l_format) -5,  rpad('-', length(l_format) + 2, '-') || '+'));
  dbms_output.put_line(rpad ('+', pkg_dimensions * (length(l_format) + 3) + 1,  rpad('-', length(l_format) + 2, '-') || '+'));
end line;
begin
for m in 1 .. pkg_dimensions
loop
  line;
  for n in 1 .. pkg_dimensions
  loop
    dbms_output.put('|' || to_char(p_matrix (m)(n), l_format) || ' ');
  end loop;
  dbms_output.put('|');
end loop;
line;

exception when others then
  util.show_error('Error in procedure print_matrix.' , sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

procedure print_point (p_point point_ty)
is
begin
  dbms_output.put_line ('Point x: ' || to_char (p_point.x_c) || ', y: ' ||  to_char (p_point.y_c) || ', z: ' || to_char (p_point.z_c) || '.');

exception when others then
  util.show_error('Error in procedure print_point.' , sqlerrm);
end print_point;

end matrix_pkg;
/

-- Examples
/*
set serveroutput on size unlimited
declare
matrix_a  matrix_pkg.matrix_ty;
matrix_b  matrix_pkg.matrix_ty;
point     matrix_pkg.point_ty := matrix_pkg.to_point (4, 3, 2);
point2    matrix_pkg.point_ty;
begin
matrix_pkg.print_point(point);

matrix_pkg.init_matrix(matrix_a);
dbms_output.put_line('Matrix to rotate 90 degrees counter clockwise');
matrix_a (2)(1) := -1;
matrix_a (1)(2) :=  1;
matrix_a (3)(3) :=  1;
matrix_pkg.print_matrix(matrix_a);

-- Apply matrix to a point
point2 :=  matrix_pkg.multiply (matrix_a, point);
matrix_pkg.print_point(point2);

-- Rotate a point 90 degrees
dbms_output.put_line('Matrix to rotate 180 degrees counter clockwise');
matrix_b := matrix_pkg.multiply (matrix_a, matrix_a);
matrix_pkg.print_matrix(matrix_b);
point2 :=  matrix_pkg.multiply (matrix_b, point);
matrix_pkg.print_point(point2);

dbms_output.put_line('Mirror in xy-plane. z = 0.');
point2 := matrix_pkg.mirror_xy (point);
matrix_pkg.print_point(point2);

dbms_output.put_line('To 3D:');
point2 := matrix_pkg.transform_to_3D (matrix_pkg.to_point (2, 0, 0));
matrix_pkg.print_point(point2);

point2 := matrix_pkg.transform_to_3D (matrix_pkg.to_point (0, 2, 0));
matrix_pkg.print_point(point2);

point2 := matrix_pkg.transform_to_3D (matrix_pkg.to_point (2, 2, 0));
matrix_pkg.print_point(point2);

end;
/

set serveroutput on size unlimited
declare
matrix_a  matrix_pkg.matrix_ty;
matrix_b  matrix_pkg.matrix_ty;
point     matrix_pkg.point_ty := matrix_pkg.to_point (4, 3, 2);
begin
matrix_pkg.pkg_dimensions :=2;
matrix_pkg.init_matrix(matrix_a);
matrix_pkg.init_matrix(matrix_b);

matrix_a (1)(1) :=  1;
matrix_a (1)(2) :=  2;
matrix_a (1)(3) :=  7;
matrix_a (2)(1) :=  3;
matrix_a (2)(2) :=  4;
matrix_a (2)(3) :=  5;
matrix_a (3)(1) :=  8;
matrix_a (3)(2) :=  5;
matrix_a (3)(3) :=  3;


matrix_pkg.print_point(point);
matrix_pkg.print_matrix(matrix_a);
dbms_output.put_line('Determinant: ' || matrix_pkg.determinant(matrix_a));

matrix_b := matrix_pkg.multiply (matrix_a, matrix_a);
matrix_pkg.print_matrix(matrix_b);
dbms_output.put_line('Determinant: ' || matrix_pkg.determinant(matrix_b));

point :=  matrix_pkg.multiply (matrix_a, point);
-- matrix_pkg.print_point(point);
end;
/


*/
