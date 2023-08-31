/*************************************************************************************************************************************************

Name:        matrix_pkg.sql

Created      October 2014
Last update  January 2016

Author:      Theo stienissen

E-mail:      theo.stienissen@gmail.com

-- Matrix:
-- ( 11   ...    1n )
--        ...
-- ( m1   ...    mn )
--

*************************************************************************************************************************************************/

set serveroutput on size unlimited

create table matrix
( id   number(6) not null
, n    number(6) not null
, m    number(6) not null
, val  number  not null);

alter table matrix add constraint matrix_pk primary key(id, n, m) using index;

create sequence matrix_seq;

create or replace package matrix_pkg
as

type line_ty          is table of  number index by pls_integer;
type matrix_ty        is table of line_ty index by pls_integer;
type point_ty         is record (x_c number(6, 4), y_c number(6, 4), z_c number(6, 4));

procedure init_matrix (p_matrix in out matrix_ty, p_horizontal_size in number default 3, p_vertical_size in number default 3);

function  to_point (p_x in number, p_y in number, p_z in number default null) return point_ty;

function  to_matrix (p_x11 in number, p_x12 in number, p_x21 in number, p_x22 in number) return matrix_ty;

function  to_matrix (p_x11 in number, p_x12 in number, p_x13 in number, p_x21 in number, p_x22 in number, p_x23 in number, p_x31 in number, p_x32 in number, p_x33 in number) return matrix_ty;

function  multiply (p_matrix_a in matrix_ty, p_matrix_b in matrix_ty) return matrix_ty;

function  multiply (p_matrix in matrix_ty, p_point in point_ty) return point_ty;

function  multiply (p_n in number, p_matrix in matrix_ty) return matrix_ty;

function  mirror_xy (p_matrix in matrix_ty) return matrix_ty;

function  mirror_xy (p_point in point_ty) return point_ty;

function  invert (p_matrix in matrix_ty) return matrix_ty;

function  transform_to_3D (p_point in point_ty) return point_ty;

function transpose (p_matrix in matrix_ty) return matrix_ty;

function is_equal  (p1_matrix matrix_ty, p2_matrix matrix_ty) return boolean;

function  determinant (p_matrix in matrix_ty) return number;

procedure print_matrix (p_matrix in matrix_ty);

procedure print_point (p_point point_ty);

function horizontal (p_matrix_id in integer) return integer;

function vertical (p_matrix_id in integer) return integer;

function load_matrix(p_id in number) return matrix_ty;

procedure save_matrix (p_matrix in matrix_ty, p_id in number default null);

function I (p_dimension in integer default 3)return matrix_ty;

function cofactor (p_matrix in matrix_ty, p_row_y in integer, p_column_x in integer) return matrix_ty;

end matrix_pkg;
/

/*************************************************************************************************************************************************/

create or replace package body matrix_pkg
as

--
-- Reset all values to 0
--
procedure init_matrix (p_matrix in out matrix_ty, p_horizontal_size in number default 3, p_vertical_size in number default 3)
is
begin
  for m in 1 .. p_horizontal_size
  loop
    for n in 1 .. p_vertical_size
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
-- Fill 2 * 2 Matrix
--
function to_matrix (p_x11 in number, p_x12 in number, p_x21 in number, p_x22 in number) return matrix_ty
is
l_matrix matrix_ty;
begin
  l_matrix(1)(1) := p_x11;
  l_matrix(1)(2) := p_x12;
  l_matrix(2)(1) := p_x21;
  l_matrix(2)(2) := p_x22;

return l_matrix;

exception when others then
  util.show_error('Error in function to_matrix. 2D' , sqlerrm);
end to_matrix;

/*************************************************************************************************************************************************/

--
-- Fill 3 * 3 Matrix
--
function to_matrix (p_x11 in number, p_x12 in number, p_x13 in number, p_x21 in number, p_x22 in number, p_x23 in number, p_x31 in number, p_x32 in number, p_x33 in number) return matrix_ty
is
l_matrix matrix_ty;
begin
  l_matrix(1)(1) := p_x11;
  l_matrix(1)(2) := p_x12;
  l_matrix(1)(3) := p_x13;
  l_matrix(2)(1) := p_x21;
  l_matrix(2)(2) := p_x22;
  l_matrix(2)(3) := p_x23;
  l_matrix(3)(1) := p_x31;
  l_matrix(3)(2) := p_x32;
  l_matrix(3)(3) := p_x33;

return l_matrix;

exception when others then
  util.show_error('Error in function to_matrix. 3D' , sqlerrm);
end to_matrix;

/*************************************************************************************************************************************************/

--
-- Multiply 2 matrices. To be checked!!
--
function multiply (p_matrix_a in matrix_ty, p_matrix_b in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
l_val    number(4);
begin
if p_matrix_a(1).count != p_matrix_b.count
then
  raise_application_error(-20004, 'Dimensions do not match. First horizontal: ' ||  p_matrix_a(1).count || '. Second vertical: '|| p_matrix_b.count);
end if;
for x in 1 .. p_matrix_a.count
loop
  for y in 1 .. p_matrix_b(1).count
  loop
    l_val := 0;    
    for p in 1 .. p_matrix_a(1).count
    loop
      l_val := l_val +  p_matrix_a (x)(p) *  p_matrix_b (p)(y);
    end loop;
    l_matrix(x)(y) := l_val;
  end loop;
end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function multiply 2 matrices.' , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- Multiply matrix with a vector
--
function multiply (p_matrix in matrix_ty, p_point in point_ty) return point_ty
is
l_point point_ty := to_point (0, 0, 0);
begin
if p_matrix(1).count = 2
then
  l_point.x_c := p_matrix (1)(1) * p_point.x_c + p_matrix (2)(1) * p_point.y_c;
  l_point.y_c := p_matrix (1)(2) * p_point.x_c + p_matrix (2)(2) * p_point.y_c;
elsif p_matrix(1).count = 3
then
  l_point.x_c := p_matrix (1)(1) * p_point.x_c + p_matrix (2)(1) * p_point.y_c + p_matrix (3)(1) * p_point.z_c;
  l_point.y_c := p_matrix (1)(2) * p_point.x_c + p_matrix (2)(2) * p_point.y_c + p_matrix (3)(2) * p_point.z_c;
  l_point.z_c := p_matrix (1)(3) * p_point.x_c + p_matrix (2)(3) * p_point.y_c + p_matrix (3)(3) * p_point.z_c;
else
  raise_application_error(-20005, 'Multiplication only defined for 2 and 3 dimensional vectors. Matrix has ' ||  p_matrix(1).count || ' columns');
end if;

  return l_point;

exception when others then
  util.show_error('Error in function multiply matrix with vector.' , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- Multiply matrix with a scalar
--
function  multiply (p_n in number, p_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
for n in 1 .. p_matrix(1).count
loop
  for m in 1 .. p_matrix.count
  loop
    l_matrix(m)(n) := p_n *  p_matrix(m)(n);
   end loop;
end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function multiply matrix with scalar.' , sqlerrm);
end multiply;

/*************************************************************************************************************************************************/

--
-- 2 Dimensional mirror in x = y plane. z = 0.
--
function mirror_xy (p_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix(1).count
    loop
      l_matrix (m)(n) := p_matrix (n)(m);
    end loop;
  end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function mirror_xy 1.' , sqlerrm);
end mirror_xy;

/*************************************************************************************************************************************************/

--
-- Mirror point in XY-plane
--
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

function  invert (p_matrix in matrix_ty) return matrix_ty
is
l_determinant number := determinant(p_matrix);
l_matrix matrix_ty;
begin
if p_matrix(1).count != p_matrix.count
then
  raise_application_error(-20004, 'Inverse not defined for a ' || p_matrix(1).count || ' * '|| p_matrix.count || ' matrix.');
end if;

for n in 1 .. p_matrix(1).count
loop
  for m in 1 .. p_matrix.count
  loop
    l_matrix(n)(m) := power(-1, n + m) * determinant(cofactor(p_matrix, n, m)) / l_determinant;
  end loop;
end loop;

  return transpose(l_matrix);

exception when others then
  util.show_error('Error in function invert.' , sqlerrm);
end invert;

/*************************************************************************************************************************************************/

--
-- Move from 2D plane to 3D plane
--
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

--
-- Transpose a matrix. Mirror in diagonal axis
--
function transpose (p_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
for n in 1 .. p_matrix(1).count
loop
  for m in 1 .. p_matrix.count
  loop
    l_matrix(n)(m) := p_matrix(m)(n);
  end loop;
end loop;

return l_matrix;

exception when others then
  util.show_error('Error in function transpose.' , sqlerrm);
end transpose;

/*************************************************************************************************************************************************/

--
-- Compare 2 matrices
--
function is_equal  (p1_matrix matrix_ty, p2_matrix matrix_ty) return boolean
is
l_equal boolean := true;
begin
if p1_matrix.count != p2_matrix.count or p1_matrix(1).count != p2_matrix(1).count
then
  return false;
end if;

<<differ>>
for n in 1 .. p1_matrix(1).count
loop
  for m in 1 .. p2_matrix.count
  loop
    l_equal := p1_matrix(n)(m) = p2_matrix(n)(m);
    exit differ when not l_equal;
  end loop;
end loop;

return l_equal;

exception when others then
  util.show_error('Error in function is_equal.' , sqlerrm);
end is_equal;

/*************************************************************************************************************************************************/

--
-- Calculate determinant of a matrix
--
function  determinant (p_matrix in matrix_ty) return number
is
l_det  number := 0;
begin
if p_matrix(1).count != p_matrix.count
then
  raise_application_error(-20004, 'Determinant not defined for a ' || p_matrix(1).count || ' * '|| p_matrix.count || ' matrix.');
end if;

if    p_matrix(1).count = 1 then  return p_matrix(1)(1);
else
  for j in 1 .. p_matrix(1).count
  loop
    l_det := l_det + power(-1, j + 1) * p_matrix(1)(j) * determinant(cofactor(p_matrix, 1, j));
  end loop;

  return l_det;
end if;

exception when others then
  util.show_error('Error in function determinant.' , sqlerrm);
end determinant;

/*************************************************************************************************************************************************/

--
-- Print a matrix using dbms_output package
--
procedure print_matrix (p_matrix in matrix_ty)
is
l_format varchar2(10) := '990D99';
l_cel    varchar2(10);
procedure line
is
begin
  dbms_output.new_line;
  dbms_output.put_line(rpad ('+', p_matrix(1).count * (length(l_format) + 3) + 1,  rpad('-', length(l_format) + 2, '-') || '+'));
end line;
begin
for m in 1 .. p_matrix(1).count
loop
  line;
  for n in 1 .. p_matrix.count
  loop
    if p_matrix (m)(n) = trunc(p_matrix (m)(n))
    then l_cel := rpad('   ' || lpad(to_char(p_matrix (m)(n)), 3), 8);
    else l_cel := to_char(p_matrix (m)(n), l_format) || ' ';
    end if;
    dbms_output.put('|' || l_cel);
  end loop;
  dbms_output.put('|');
end loop;
line;

exception when others then
  util.show_error('Error in procedure print_matrix.' , sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

--
-- Show coordinates of a point on the screen
--
procedure print_point (p_point point_ty)
is
begin
  dbms_output.put_line ('Point x: ' || to_char (p_point.x_c) || ', y: ' ||  to_char (p_point.y_c) || ', z: ' || to_char (p_point.z_c) || '.');

exception when others then
  util.show_error('Error in procedure print_point.' , sqlerrm);
end print_point;

/*************************************************************************************************************************************************/

--
-- Horizontal size. Number of matrix columns
--
function horizontal (p_matrix_id in integer) return integer
is
l_max matrix.n%type;
begin
select max(n) into l_max from matrix where id = p_matrix_id;

return l_max;

exception when others then
  util.show_error('Error in function horizontal.' , sqlerrm);
end horizontal;

/*************************************************************************************************************************************************/

--
-- Vertical size. Number of matrix rows
--
function vertical (p_matrix_id in integer) return integer
is
l_max matrix.m%type;
begin
select max(m) into l_max from matrix where id = p_matrix_id;

return l_max;

exception when others then
  util.show_error('Error in function vertical.' , sqlerrm);
end vertical;

/*************************************************************************************************************************************************/

--
-- Load matrix from a table
--
function load_matrix(p_id in number) return matrix_ty
is
l_matrix matrix_ty;
begin
for j in (select n, m, val from matrix where id = p_id)
loop
  l_matrix(j.n)(j.m) := j.val;
end loop;

return l_matrix;

exception when others then
  util.show_error('Error in function load_matrix.' , sqlerrm);
end load_matrix;

/*************************************************************************************************************************************************/

--
-- Store matrix in a table
--
procedure save_matrix (p_matrix in matrix_ty, p_id in number default null)
is
l_id  matrix.id%type;
begin
if p_id is null
then l_id := matrix_seq.nextval;
else l_id := p_id;
end if;

for n1 in 1 .. p_matrix(1).count
loop
  for m1 in 1 .. p_matrix.count
  loop
    begin
      insert into matrix values (l_id, n1, m1, p_matrix(n1)(m1));
    exception when dup_val_on_index
    then
      update matrix set val =  p_matrix(n1)(m1) where id = l_id and n = n1 and m = m1;
    end;
  end loop;
end loop;
commit;

exception when others then
  util.show_error('Error in procedure save_matrix.' , sqlerrm);
end save_matrix;

/*************************************************************************************************************************************************/

--
-- Function return Unitary matrix or Identity matrix
--
function I (p_dimension in integer default 3) return matrix_ty
is
l_matrix matrix_ty;
begin
for n in 1 .. p_dimension
loop
  for m in 1 .. p_dimension
  loop
    if n = m
    then l_matrix(n)(m) := 1;
    else l_matrix(n)(m) := 0;
    end if;
  end loop;
end loop;

return l_matrix;

exception when others then
  util.show_error('Error in Identity matrix function I.' , sqlerrm);
end I;

/*************************************************************************************************************************************************/

--
-- Reduce 1 line and 1 column from the matrix
--
function cofactor (p_matrix in matrix_ty, p_row_y in integer, p_column_x in integer) return matrix_ty
is
l_matrix matrix_ty;
l_y      integer(4) :=0;
l_x      integer(4);
begin
for y in 1 .. p_matrix.count
loop
  if y != p_row_y
  then l_y := l_y + 1;
       l_x := 0;
    for x in 1 .. p_matrix(1).count
    loop
      if x != p_column_x
      then
        l_x := l_x + 1;
        l_matrix(l_y)(l_x) := p_matrix(y)(x);
      end if;
    end loop;
  end if;
end loop;

  return l_matrix;

exception when others then
  util.show_error('Error in function cofactor.' , sqlerrm);
end cofactor;

end matrix_pkg;
/

