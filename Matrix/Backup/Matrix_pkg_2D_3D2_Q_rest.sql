/*************************************************************************************************************************************************

Name:        matrix_Q_pkg.sql

Created      October  2014
Last update  October  2022

Author:      Theo stienissen

E-mail:      theo.stienissen@gmail.com

Link:   @C:\Users\Theo\OneDrive\Theo\Project\Maths\Matrix\Matrix_pkg_2D_3D2.sql
-- N x M Matrix:
-- ( 11   ...    1m )
--        ...
-- ( n1   ...    nm )
--

Todo: eigenvalues

Documents:
	https://www.math.ru.nl/~souvi/la1_07/hs1.pdf
	https://www.math.ru.nl/~souvi/la1_07/hs2.pdf
	
	https://www.math.ru.nl/~souvi/la2_07/hs1.pdf
	
Todo: Matrices with fractions
      Adujated matrices
*************************************************************************************************************************************************/

set serveroutput on size unlimited

drop table matrix_Q;
create table matrix_Q
( id   number(6)      not null
, name varchar2(20)
, n    number(36) not null
, m    number(36) not null
, val_numerator     number(36) not null
, val_denominator   number(36) not null);

create or replace trigger matrix_Q_briu
before insert or update on matrix_Q
for each row
declare
l_gcd    integer;
begin
  :new.id := nvl (:new.id, matrix_seq.nextval);
  if :new.val_denominator < 0 then :new.val_denominator := - :new.val_denominator; :new.val_numerator := - :new.val_numerator; end if;
  l_gcd := maths.gcd (abs (:new.val_numerator), :new.val_denominator);
  :new.val_numerator   := :new.val_numerator / l_gcd;
  :new.val_denominator := :new.val_denominator / l_gcd;
end;
/

alter table matrix_Q add constraint matrix_Q_pk primary key (id, n, m) using index;
alter table matrix_Q add constraint matrix_Q_ck1 check (val_denominator != 0);

drop sequence   matrix_seq;
create sequence matrix_seq;

create or replace type my_Q_point as object(val_numerator number(36), val_denominator number(36));
/

create or replace package matrix_Q_pkg
as

function adjugate    (p_matrix in matrix_ty) return matrix_ty;

function  invert      (p_matrix in matrix_ty) return matrix_ty;

function  is_equal    (p1_matrix matrix_ty, p2_matrix matrix_ty) return boolean;

procedure print_matrix (p_matrix in matrix_ty);

procedure print_point_2D (p_point point_ty_2D);

procedure print_point_3D (p_point point_ty_3D);

procedure print_vector (p_vector vector_ty);

function  horizontal_dim (p_matrix_id in integer) return integer;

function  vertical_dim (p_matrix_id in integer) return integer;

function  load_matrix (p_id in number) return matrix_ty;

function  load_matrix (p_name in varchar2) return matrix_ty;

procedure save_matrix (p_matrix in matrix_ty, p_id in out nocopy integer);


function  add_row (p_matrix in matrix_ty, p_row in pls_integer, p_vector in vector_ty) return matrix_ty;

function  add_column (p_matrix in matrix_ty, p_column in pls_integer, p_vector in vector_ty) return matrix_ty;

function  multiply_column (p_matrix in matrix_ty, p_column in pls_integer, p_factor in number) return matrix_ty;

function  multiply_row (p_matrix in matrix_ty, p_row in pls_integer, p_factor in number) return matrix_ty;

function  swap_columns (p_matrix in matrix_ty, p_column1 in pls_integer, p_column2 in pls_integer) return matrix_ty;

function  swap_rows (p_matrix in matrix_ty, p_row1 in pls_integer, p_row2 in pls_integer) return matrix_ty;

function  is_zero_matrix (p_matrix in matrix_ty) return boolean;

function  is_symmetric (p_matrix in matrix_ty) return boolean;

function  is_diagonal (p_matrix in matrix_ty) return boolean;

function  add_matrix (p1_matrix in matrix_ty, p2_matrix in matrix_ty) return matrix_ty;

function  substract_matrix (p1_matrix in matrix_ty, p2_matrix in matrix_ty) return matrix_ty;

function  dotproduct (p_vector1 in vector_ty, p_vector2 in vector_ty) return number;

function  crossproduct (p_vector1 in vector_ty, p_vector2 in vector_ty) return vector_ty;

function  trace (p_matrix in matrix_ty) return number;

end matrix_Q_pkg;
/


/*************************************************************************************************************************************************/

create or replace package body matrix_Q_pkg
as


/*************************************************************************************************************************************************/

--
-- Calculate the inverse of a matrix
--
function  invert (p_matrix in matrix_ty) return matrix_ty
is
l_determinant number := determinant (p_matrix);
l_matrix matrix_ty;
begin
if p_matrix (1).count != p_matrix.count
then
  raise_application_error(-20004, 'Inverse not defined for a ' || p_matrix.count || ' * '|| p_matrix (1).count || ' matrix.');
elsif l_determinant = 0
then
  raise_application_error(-20005, 'Matrix is singular.');
else
  for n in 1 .. p_matrix (1).count
  loop
    for m in 1 .. p_matrix.count
    loop
      l_matrix(n)(m) := power(-1, n + m) * determinant (cofactor (p_matrix, n, m)) / l_determinant;
    end loop;
  end loop;
end if;

  return transpose (l_matrix);

exception when others then
  util.show_error ('Error in function invert.' , sqlerrm);
end invert;


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
  util.show_error ('Error in function is_equal.' , sqlerrm);
end is_equal;



/*************************************************************************************************************************************************/

--
-- Print a matrix using dbms_output package
--
procedure print_matrix (p_matrix in matrix_ty)
is
l_format varchar2(15) := '9990D9999';
l_cel    varchar2(15);
l_m      pls_integer;
l_n      pls_integer;
procedure show_line
is
begin
  dbms_output.new_line;
  dbms_output.put_line(rpad ('+', p_matrix (1).count * (length(l_format) + 3) + 1,  rpad('-', length(l_format) + 2, '-') || '+'));
end show_line;
begin
for m in 1 .. p_matrix.count
loop
  show_line;
  for n in 1 .. p_matrix (1).count
  loop
    l_m := m; l_n := n;
    if p_matrix (m)(n) = trunc (p_matrix (m)(n))
    then l_cel := rpad ('   ' || lpad(to_char (p_matrix (m)(n)), 3), 8);
    else l_cel := to_char (p_matrix (m)(n), l_format) || ' ';
    end if;
    dbms_output.put('|' || l_cel);
  end loop;
  dbms_output.put('|');
end loop;
show_line;

exception when others then
  util.show_error ('Error in procedure print_matrix for co-ordinates: (' || l_m || ', '|| l_n || ').', sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

--
-- Show coordinates of a 2D point on the screen
--
procedure print_point_2D (p_point point_ty_2D)
is
begin
  dbms_output.put_line ('Point x: ' || to_char (p_point.x_c) || ', y: ' ||  to_char (p_point.y_c) || '.');

exception when others then
  util.show_error ('Error in procedure print_point_2D.' , sqlerrm);
end print_point_2D;

/*************************************************************************************************************************************************/

--
-- Show coordinates of a 3D point on the screen
--
procedure print_point_3D (p_point point_ty_3D)
is
begin
  dbms_output.put_line ('Point x: ' || to_char (p_point.x_c) || ', y: ' ||  to_char (p_point.y_c) || ', z: ' || to_char (p_point.z_c) || '.');

exception when others then
  util.show_error ('Error in procedure print_point_3D.' , sqlerrm);
end print_point_3D;

/*************************************************************************************************************************************************/
--
-- Print horizontal
--
procedure print_vector (p_vector vector_ty)
is
l_first boolean := TRUE;
begin
  dbms_output.put ('(');
  for j in 1 .. p_vector.count
  loop
    if l_first
	then dbms_output.put (to_char (p_vector(j))); l_first := FALSE;
	else dbms_output.put (', ' || to_char (p_vector(j)));
	end if;
  end loop;
  dbms_output.put_line (')');

exception when others then
  util.show_error ('Error in procedure print_vector.' , sqlerrm);
end print_vector;

/*************************************************************************************************************************************************/

--
-- Horizontal size. Number of matrix columns for a saved matrix
--
function horizontal_dim (p_matrix_id in integer) return integer
is
l_max matrix.n%type;
begin
select max(n) into l_max from matrix where id = p_matrix_id;

return l_max;

exception when others then
  util.show_error ('Error in function horizontal_dim.' , sqlerrm);
end horizontal_dim;

/*************************************************************************************************************************************************/

--
-- Vertical size. Number of matrix rows for a saved matrix
--
function vertical_dim (p_matrix_id in integer) return integer
is
l_max matrix.m%type;
begin
select max(m) into l_max from matrix where id = p_matrix_id;

return l_max;

exception when others then
  util.show_error ('Error in function vertical_dim.' , sqlerrm);
end vertical_dim;

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
  l_matrix (j.n)(j.m) := j.val;
end loop;

return l_matrix;

exception when others then
  util.show_error ('Error in function load_matrix.' , sqlerrm);
end load_matrix;

/*************************************************************************************************************************************************/

--
-- Load matrix from a table
--
function  load_matrix (p_name in varchar2) return matrix_ty
is
l_matrix matrix_ty;
begin
for j in (select n, m, val from matrix where name = p_name)
loop
  l_matrix (j.n)(j.m) := j.val;
end loop;

return l_matrix;

exception when others then
  util.show_error ('Error in function load_matrix.' , sqlerrm);
end load_matrix;

/*************************************************************************************************************************************************/

--
-- Store the matrix in a table
--
procedure save_matrix (p_matrix in matrix_ty, p_id in out nocopy integer)
is
begin
if p_id is null then p_id := matrix_seq.nextval; end if;

for n1 in 1 .. p_matrix (1).count
loop
  for m1 in 1 .. p_matrix.count
  loop
    begin
      insert into matrix (id, n, m, val) values (p_id, n1, m1, p_matrix (n1)(m1));
    exception when dup_val_on_index
    then
      update matrix set val =  p_matrix (n1)(m1) where id = p_id and n = n1 and m = m1;
    end;
  end loop;
end loop;
commit;

exception when others then
  util.show_error ('Error in procedure save_matrix.' , sqlerrm);
end save_matrix;

/*************************************************************************************************************************************************/

--
-- Add a row to a matrix on line "p_row" the other rows move down one line
--
function add_row (p_matrix in matrix_ty, p_row in pls_integer, p_vector in vector_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
if p_matrix.count = 0 -- Empty matrix. First row of new matrix becomes the vector.
then
  for n in 1 .. p_vector.count
  loop
    l_matrix(1)(n) := p_vector(n);
  end loop;
else
  if p_matrix (1).count != p_vector.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Columns matrix: ' || p_matrix (1).count || '. Dimension vector: '|| p_vector.count || '.');
  elsif p_row not between 1 and p_matrix (1).count + 1
  then
    raise_application_error(-20004, 'Row position is wrong. Rows matrix: ' || p_matrix.count || '. Dimension vector: '|| p_vector.count || '.');
  end if; 

  for m in 1 .. p_matrix.count + 1
  loop
    for n in 1 .. p_matrix (1).count
    loop
      if    m < p_row then l_matrix(m)(n) := p_matrix (m)(n);
      elsif m = p_row then l_matrix(m)(n) := p_vector(n);
      else  l_matrix(m)(n) := p_matrix (m - 1)(n);
      end if;
     end loop;
   end loop;
end if;
  return l_matrix; 

exception when others then
  util.show_error ('Error in function add_row. Rows: ' || p_matrix.count, sqlerrm);

end add_row;

/*************************************************************************************************************************************************/

--
-- Add a column to a matrix on column "p_column" the other columns move one position to the right
--
function add_column (p_matrix in matrix_ty, p_column in pls_integer, p_vector in vector_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
if p_matrix.count = 0 -- Empty matrix. First column of new matrix becomes the vector.
then
  for n in 1 .. p_vector.count
  loop
    l_matrix(n)(1) := p_vector(n);
  end loop;
else
  if p_matrix.count != p_vector.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Rows matrix: ' || p_matrix.count || '. Dimension Vector: '|| p_vector.count || '.');
  elsif p_column not between 1 and p_matrix (1).count + 1
  then
    raise_application_error(-20004, 'Column position is wrong. Columns matrix: ' || p_matrix (1).count || '. Request for position: '|| p_column || '.');
  end if;

  print_vector(p_vector);
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count + 1
    loop
      if    n < p_column then l_matrix(m)(n) := p_matrix (m)(n);
      elsif n = p_column then l_matrix(m)(n) := p_vector(m);
      else  l_matrix(m)(n) := p_matrix (m)(n - 1);
	  end if;
    end loop;
  end loop;
end if;
  return l_matrix;

exception when others then
  util.show_error ('Error in function add_column. Columns: ' || p_matrix (1).count , sqlerrm);
end add_column;


/*************************************************************************************************************************************************/

--
-- Check if matrix contains only zero's
--
function is_zero_matrix (p_matrix in matrix_ty) return boolean
is
l_is_zero boolean := TRUE;
begin
<<done>>
for m in 1 .. p_matrix.count
loop
  for n in 1 .. p_matrix (1).count
  loop
    l_is_zero := p_matrix (m)(n) = 0;
	exit done when not l_is_zero;  
  end loop;
end loop;

  return l_is_zero;
  
exception when others then
  util.show_error ('Error in function is_zero_matrix.' , sqlerrm);
end is_zero_matrix;

/*************************************************************************************************************************************************/

--
-- Check if matrix is symmetric a(i,j) = a(j,i)
--
function is_symmetric (p_matrix in matrix_ty) return boolean
is
l_is_symmetric boolean := TRUE;
begin
if p_matrix.count != p_matrix (1).count
then
  raise_application_error(-20004, 'Dimensions do not match. Rows: ' || p_matrix.count || '. Columns: '|| p_matrix (1).count || '.');
end if;

<<done>>
for m in 1 .. p_matrix.count
loop
  for n in 1 .. m - 1
  loop
    l_is_symmetric := p_matrix (m)(n) = p_matrix (n)(m);
	exit done when not l_is_symmetric;  
  end loop;
end loop;
 return l_is_symmetric;
  
exception when others then
  util.show_error ('Error in function is_symmetric.' , sqlerrm);
end is_symmetric;

/*************************************************************************************************************************************************/

--
-- Check if matrix is diagonal a(i,j) = 0 for all (i, j) with i != j.
--
function  is_diagonal (p_matrix in matrix_ty) return boolean
is
l_is_diagonal boolean := TRUE;
begin
  <<done>>
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      if m != n
	  then
        l_is_diagonal := p_matrix (m)(n) = 0;
	    exit done when not l_is_diagonal;
	  end if;
    end loop;
  end loop;
 return l_is_diagonal;
  
exception when others then
  util.show_error ('Error in function l_is_diagonal.' , sqlerrm);
end is_diagonal;

/*************************************************************************************************************************************************/

--
-- Multiply one column of a matrix
--
function  multiply_column (p_matrix in matrix_ty, p_column in pls_integer, p_factor in number) return matrix_ty
is
l_matrix matrix_ty := p_matrix;
begin
  for m in 1 .. p_matrix.count
  loop
    l_matrix (m)(p_column) := l_matrix (m)(p_column) * p_factor;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function multiply_column.' , sqlerrm);
end multiply_column;

/*************************************************************************************************************************************************/

--
-- Multiply one row of a matrix
--
function  multiply_row (p_matrix in matrix_ty, p_row in pls_integer, p_factor in number) return matrix_ty
is
l_matrix matrix_ty := p_matrix;
begin
  for n in 1 .. p_matrix (1).count
  loop
    l_matrix (p_row)(n) := l_matrix (p_row)(n) * p_factor;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function multiply_row.' , sqlerrm);
end multiply_row;

/*************************************************************************************************************************************************/

--
-- Swap 2 columns of a matrix
--
function  swap_columns (p_matrix in matrix_ty, p_column1 in pls_integer, p_column2 in pls_integer) return matrix_ty
is
l_matrix matrix_ty := p_matrix;
l_dummy  number;
begin
  for m in 1 .. p_matrix.count
  loop
    l_dummy := l_matrix (m)(p_column1);
    l_matrix (m)(p_column1) := l_matrix (m)(p_column2);
    l_matrix (m)(p_column2) := l_dummy;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function swap_columns.' , sqlerrm);
end swap_columns;

/*************************************************************************************************************************************************/

--
-- Swap 2 rows of a matrix
--
function  swap_rows (p_matrix in matrix_ty, p_row1 in pls_integer, p_row2 in pls_integer) return matrix_ty
is
l_matrix matrix_ty := p_matrix;
l_dummy  number;
begin
  for n in 1 .. p_matrix (1).count
  loop
    l_dummy := l_matrix (p_row1)(n);
    l_matrix (p_row1)(n) := l_matrix (p_row2)(n);
    l_matrix (p_row2)(n) := l_dummy;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function swap_rows.' , sqlerrm);
end swap_rows;

/*************************************************************************************************************************************************/

--
-- Add 2 matrices together
--
function  add_matrix (p1_matrix in matrix_ty, p2_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
  if p1_matrix.count != p2_matrix.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Rows first: ' || p1_matrix.count || '. Rows second: '|| p2_matrix.count || '.');
  elsif p1_matrix(1).count != p2_matrix(1).count
  then
    raise_application_error(-20004, 'Dimensions do not match. Columns first: ' || p1_matrix(1).count || '. Columns second: '|| p2_matrix(1).count || '.');
  end if;

  for m in 1 .. p1_matrix.count
  loop
    for n in 1 .. p1_matrix(1).count
    loop
      l_matrix(m)(n) := p1_matrix(m)(n) + p2_matrix(m)(n);
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function add_matrix.' , sqlerrm);
end add_matrix;


/*************************************************************************************************************************************************/

--
-- Matrices A - B
--
function  substract_matrix (p1_matrix in matrix_ty, p2_matrix in matrix_ty) return matrix_ty
is
l_matrix matrix_ty;
begin
  if p1_matrix.count != p2_matrix.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Rows first: ' || p1_matrix.count || '. Rows second: '|| p2_matrix.count || '.');
  elsif p1_matrix(1).count != p2_matrix(1).count
  then
    raise_application_error(-20004, 'Dimensions do not match. Columns first: ' || p1_matrix(1).count || '. Columns second: '|| p2_matrix(1).count || '.');
  end if;

  for m in 1 .. p1_matrix.count
  loop
    for n in 1 .. p1_matrix(1).count
    loop
      l_matrix(m)(n) := p1_matrix(m)(n) - p2_matrix(m)(n);
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function substract_matrix.' , sqlerrm);
end substract_matrix;

/*************************************************************************************************************************************************/

--
-- NL: inproduct
-- dotproduct(a,b) = ||a|| * ||b|| cos (c)
--
function dotproduct (p_vector1 in vector_ty, p_vector2 in vector_ty) return number
is
l_dotproduct number := 0;
begin
  if p_vector1.count != p_vector2.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Dimension vector 1: ' || p_vector1.count || '. Dimension vector 2: '|| p_vector2.count || '.');
  end if; 

  for n in 1 .. p_vector1.count
  loop
    l_dotproduct := l_dotproduct + p_vector1(n) * p_vector2(n);
  end loop;
  return l_dotproduct;

exception when others then
  util.show_error ('Error in function dotproduct.' , sqlerrm);
end dotproduct;

/*************************************************************************************************************************************************/

--
-- NL: Uitproduct - kruisproduct
-- crossproduct(a,b) || = || a || * || b || * sin (c)
--
function crossproduct (p_vector1 in vector_ty, p_vector2 in vector_ty) return vector_ty
is
l_vector vector_ty;
begin
  if p_vector1.count != 3 or p_vector2.count != 3
  then
    raise_application_error(-20004, 'Crossproduct only defined for dimension 3. Dimension vector 1 ' || p_vector1.count || '. Dimension vector 2: '|| p_vector2.count || '.');
  end if;

  l_vector(1) := p_vector1(2) * p_vector2(3) - p_vector1(3) * p_vector2(2);
  l_vector(2) := p_vector1(3) * p_vector2(1) - p_vector1(1) * p_vector2(3);
  l_vector(3) := p_vector1(1) * p_vector2(2) - p_vector1(2) * p_vector2(1);
  return l_vector; 

exception when others then
  util.show_error ('Error in function crossproduct.' , sqlerrm);
end crossproduct;

/*************************************************************************************************************************************************/

--
-- Sum of diagonal elements
--
function  trace (p_matrix in matrix_ty) return number
is
l_sum  number := 0;
begin
  if p_matrix (1).count != p_matrix.count
  then
    raise_application_error (-20004, 'Dimensions do not match. Columns: ' || p_matrix (1).count || '. Rows: '|| p_matrix (1).count || '.');
  end if;

  for j in 1 .. p_matrix.count
  loop
    l_sum := l_sum + p_matrix (j)(j);
  end loop;
  return l_sum;

exception when others then
  util.show_error ('Error in function trace.' , sqlerrm);
end trace;

end matrix_Q_pkg;
/

---------------------- Constants
-- 1. Dihedron matrices.

set serveroutput on size unlimited
declare
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Dihedron 1 (one)');
dbms_output.put_line('--');
matrix_Q_pkg.save_matrix(matrix_Q_pkg.to_matrix_2D (1,0,0,1), l_id);
matrix_Q_pkg.print_matrix(matrix_Q_pkg.load_matrix(l_id));
update matrix set name = 'Dihedron 1' where id = l_id;
commit;
end;
/

declare
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Dihedron I');
dbms_output.put_line('--');
matrix_Q_pkg.save_matrix(matrix_Q_pkg.to_matrix_2D (0,1,-1,0), l_id);
matrix_Q_pkg.print_matrix(matrix_Q_pkg.load_matrix(l_id));
update matrix set name = 'Dihedron I' where id = l_id;
commit;
end;
/

declare
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Dihedron J');
dbms_output.put_line('--');
matrix_Q_pkg.save_matrix(matrix_Q_pkg.to_matrix_2D (0,1,1,0), l_id);
matrix_Q_pkg.print_matrix(matrix_Q_pkg.load_matrix(l_id));
update matrix set name = 'Dihedron J' where id = l_id;
commit;
end;
/

declare
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Dihedron K');
dbms_output.put_line('--');
matrix_Q_pkg.save_matrix(matrix_Q_pkg.to_matrix_2D (1,0,0,-1), l_id);
matrix_Q_pkg.print_matrix(matrix_Q_pkg.load_matrix(l_id));
update matrix set name = 'Dihedron K' where id = l_id;
commit;
end;
/

-- 2. Quaternions

-- 1 one:
set serveroutput on size unlimited
declare
l_matrix        matrix_Q_pkg.matrix_ty;
l_vector        matrix_Q_pkg.vector_ty;
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Quaternion 1 (one)');
dbms_output.put_line('--');
l_matrix := matrix_Q_pkg.add_row(l_matrix, 1, matrix_Q_pkg.to_vector(1,0,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 2, matrix_Q_pkg.to_vector(0,1,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 3, matrix_Q_pkg.to_vector(0,0,1,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 4, matrix_Q_pkg.to_vector(0,0,0,1));
matrix_Q_pkg.save_matrix(l_matrix, l_id);
update matrix set name = 'Quaternion 1' where id = l_id;
matrix_Q_pkg.print_matrix(l_matrix);
commit;
end;
/

set serveroutput on size unlimited
declare
l_matrix        matrix_Q_pkg.matrix_ty;
l_vector        matrix_Q_pkg.vector_ty;
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Quaternion I');
dbms_output.put_line('--');
l_matrix := matrix_Q_pkg.add_row(l_matrix, 1, matrix_Q_pkg.to_vector(0,-1,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 2, matrix_Q_pkg.to_vector(1,0,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 3, matrix_Q_pkg.to_vector(0,0,0,-1));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 4, matrix_Q_pkg.to_vector(0,0,1,0));
matrix_Q_pkg.save_matrix(l_matrix, l_id);
update matrix set name = 'Quaternion I' where id = l_id;
matrix_Q_pkg.print_matrix(l_matrix);
commit;
end;
/

-- J:
declare
l_matrix        matrix_Q_pkg.matrix_ty;
l_vector        matrix_Q_pkg.vector_ty;
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Quaternion J');
dbms_output.put_line('--');
l_matrix := matrix_Q_pkg.add_row(l_matrix, 1, matrix_Q_pkg.to_vector(0,0,-1,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 2, matrix_Q_pkg.to_vector(0,0,0,1));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 3, matrix_Q_pkg.to_vector(1,0,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 4, matrix_Q_pkg.to_vector(0,-1,0,0));
matrix_Q_pkg.save_matrix(l_matrix, l_id);
update matrix set name = 'Quaternion J' where id = l_id;
matrix_Q_pkg.print_matrix(l_matrix);
commit;
end;
/

-- K:
declare
l_matrix        matrix_Q_pkg.matrix_ty;
l_vector        matrix_Q_pkg.vector_ty;
l_id integer := matrix_seq.nextval;
begin
dbms_output.put_line('--');
dbms_output.put_line('-- Quaternion K');
dbms_output.put_line('--');
l_matrix := matrix_Q_pkg.add_row(l_matrix, 1, matrix_Q_pkg.to_vector(0,0,0,-1));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 2, matrix_Q_pkg.to_vector(0,0,-1,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 3, matrix_Q_pkg.to_vector(0,1,0,0));
l_matrix := matrix_Q_pkg.add_row(l_matrix, 4, matrix_Q_pkg.to_vector(1,0,0,0));
matrix_Q_pkg.save_matrix(l_matrix, l_id);
update matrix set name = 'Quaternion K' where id = l_id;
matrix_Q_pkg.print_matrix(l_matrix);
commit;
end;
/

