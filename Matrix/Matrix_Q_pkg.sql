/*************************************************************************************************************************************************

Name:        matrix_Q_pkg.sql

Author:     : Theo stienissen
E-mail      : theo.stienissen@gmail.com

Created     : October  2022
Last update : May      2023

Link:   @C:\Users\Theo\OneDrive\Theo\Project\Maths\Matrix\Matrix_Q_pkg.sql
-- N x M Matrix:
-- ( 11   ...    1m )
--        ...
-- ( n1   ...    nm )
--

Documents:
	https://www.math.ru.nl/~souvi/la1_07/hs1.pdf
	https://www.math.ru.nl/~souvi/la1_07/hs2.pdf
	https://www.math.ru.nl/~souvi/la1_07/hs3.pdf
	https://www.math.ru.nl/~souvi/la1_07/hs4.pdf
	
	https://www.math.ru.nl/~souvi/la2_07/hs1.pdf
	https://www.math.ru.nl/~souvi/la2_07/hs2.pdf
	https://www.math.ru.nl/~souvi/la2_07/hs3.pdf
	
	https://netlib.org/blas/       Basic Linear Algebra Subprograms
	https://netlib.org/lapack/     Linear Algebra PACKage
	
Todo: Eigenvalues
	  Complex routines
	

*************************************************************************************************************************************************/


set serveroutput on size unlimited

alter session set plsql_warnings = 'ENABLE:ALL'; 

--drop table matrix_Q;
create table matrix_Q
( id          number (6)  not null
, name        varchar2 (20)
, n           number (10) not null
, m           number (10) not null
, numerator   number (38) not null
, denominator number (38) not null);

--drop sequence   matrix_seq;
--create sequence matrix_seq;

create or replace trigger matrix_Q_briu
before insert or update on matrix_Q
for each row
declare
l_gcd    integer;
begin
  :new.id := nvl (:new.id, matrix_seq.nextval);
  if :new.denominator < 0 then :new.denominator := - :new.denominator; :new.numerator := - :new.numerator; end if;
  l_gcd := maths.gcd (abs (:new.numerator), :new.denominator);
  :new.numerator   := :new.numerator / l_gcd;
  :new.denominator := :new.denominator / l_gcd;
end;
/

alter table matrix_Q add constraint matrix_Q_pk primary key (id, n, m) using index;
alter table matrix_Q add constraint matrix_Q_ck1 check (denominator != 0);

create or replace type my_Q_point as object(numerator number(36), denominator number(36));
/

create or replace package matrix_Q_pkg
as

procedure init_matrix (p_matrix in out nocopy types_pkg.matrix_Q_ty, p_horizontal_size in integer default 3, p_vertical_size in integer default 3);

function  I (p_dimension in integer default 3) return types_pkg.matrix_Q_ty;

function  to_point_2D (p_x in integer, p_y in integer) return types_pkg.point_Q_ty_2D;
function  to_point_2D (p_x in types_pkg.fraction_ty, p_y in types_pkg.fraction_ty) return types_pkg.point_Q_ty_2D;

function  to_point_3D (p_x in number, p_y in number, p_z in number) return types_pkg.point_Q_ty_3D;
function  to_point_3D (p_x in types_pkg.fraction_ty, p_y in types_pkg.fraction_ty, p_z in types_pkg.fraction_ty) return types_pkg.point_Q_ty_3D;

function  to_vector (p_x1  in integer, p_x2 in integer default null, p_x3 in integer default null, p_x4 in integer default null,
                     p_x5  in integer default null, p_x6  in integer default null, p_x7  in integer default null,
					 p_x8  in integer default null, p_x9  in integer default null, p_x10 in integer default null,
					 p_x11 in integer default null, p_x12 in integer default null, p_x13 in integer default null,
					 p_x14 in integer default null, p_x15 in integer default null, p_x16 in integer default null) return types_pkg.vector_Q_ty;					 

function  to_vector (p_x1  in types_pkg.fraction_ty, p_x2 in types_pkg.fraction_ty default null, p_x3 in types_pkg.fraction_ty default null, p_x4 in types_pkg.fraction_ty default null,
                     p_x5  in types_pkg.fraction_ty default null, p_x6  in types_pkg.fraction_ty default null, p_x7  in types_pkg.fraction_ty default null,
					 p_x8  in types_pkg.fraction_ty default null, p_x9  in types_pkg.fraction_ty default null, p_x10 in types_pkg.fraction_ty default null,
					 p_x11 in types_pkg.fraction_ty default null, p_x12 in types_pkg.fraction_ty default null, p_x13 in types_pkg.fraction_ty default null,
					 p_x14 in types_pkg.fraction_ty default null, p_x15 in types_pkg.fraction_ty default null, p_x16 in types_pkg.fraction_ty default null) return types_pkg.vector_Q_ty;

function  to_matrix_2D (p_x11 in integer, p_x12 in integer, p_x21 in integer, p_x22 in integer) return types_pkg.matrix_Q_ty;	
function  to_matrix_2D (p_x11 in types_pkg.fraction_ty, p_x12 in types_pkg.fraction_ty, p_x21 in types_pkg.fraction_ty, p_x22 in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty;	 
 
function  to_matrix_3D (p_x11 in integer, p_x12 in integer, p_x13 in integer, p_x21 in integer, p_x22 in integer, p_x23 in integer, p_x31 in integer, p_x32 in integer, p_x33 in integer) return types_pkg.matrix_Q_ty;
function  to_matrix_3D (p_x11 in types_pkg.fraction_ty, p_x12 in types_pkg.fraction_ty, p_x13 in types_pkg.fraction_ty, p_x21 in types_pkg.fraction_ty, p_x22 in types_pkg.fraction_ty,
                          p_x23 in types_pkg.fraction_ty, p_x31 in types_pkg.fraction_ty, p_x32 in types_pkg.fraction_ty, p_x33 in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty;
						  
function  add_matrix       (p1_matrix in types_pkg.matrix_Q_ty, p2_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;
function  substract_matrix (p1_matrix in types_pkg.matrix_Q_ty, p2_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;
						  
function  multiply_column (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty;
function  multiply_row    (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty;
function  swap_columns    (p_matrix in types_pkg.matrix_Q_ty, p_column1 in pls_integer, p_column2 in pls_integer) return types_pkg.matrix_Q_ty;
function  swap_rows       (p_matrix in types_pkg.matrix_Q_ty, p_row1 in pls_integer, p_row2 in pls_integer) return types_pkg.matrix_Q_ty;

function  matrix_times_vector  (p_matrix in types_pkg.matrix_Q_ty, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty;
function  scalar_times_vector  (p_scalar in types_pkg.fraction_ty, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty;
function  integer_times_vector (p_integer in integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty;
function  multiply       (p_scalar in  types_pkg.fraction_ty, p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;					  
function  multiply_2D    (p_matrix in types_pkg.matrix_Q_ty, p_point in types_pkg.point_Q_ty_2D) return types_pkg.point_Q_ty_2D;
function  multiply_3D    (p_matrix in types_pkg.matrix_Q_ty, p_point in types_pkg.point_Q_ty_3D) return types_pkg.point_Q_ty_3D;
function  multiply       (p_matrix_a in types_pkg.matrix_Q_ty, p_matrix_b types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;		

procedure save_matrix    (p_matrix in types_pkg.matrix_Q_ty, p_id in out nocopy integer);			  
function  load_matrix    (p_id in number)     return types_pkg.matrix_Q_ty;
function  load_matrix    (p_name in varchar2) return types_pkg.matrix_Q_ty;

function  mirror_xy      (p_matrix in types_pkg.matrix_Q_ty)   return types_pkg.matrix_Q_ty;
function  mirror_xy      (p_point  in types_pkg.point_Q_ty_3D) return types_pkg.point_Q_ty_3D;

procedure print_point_2D (p_point types_pkg.point_Q_ty_2D);
procedure print_point_3D (p_point types_pkg.point_Q_ty_3D);
procedure print_vector   (p_vector types_pkg.vector_Q_ty);
procedure print_matrix   (p_matrix in types_pkg.matrix_Q_ty);
function  fraction_to_string   (p_fraction in types_pkg.fraction_ty, p_width in integer default 10) return varchar2;

function  remove_row     (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer) return types_pkg.matrix_Q_ty;
function  remove_column  (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return types_pkg.matrix_Q_ty;
function  add_row        (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.matrix_Q_ty;
function  add_column     (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.matrix_Q_ty;

function  cofactor       (p_matrix in types_pkg.matrix_Q_ty, p_row_y in integer, p_column_x in integer) return types_pkg.matrix_Q_ty;
function  transpose      (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;

function  determinant    (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.fraction_ty;
function  adjugate       (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;
function  invert         (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;

function  is_equal       (p1_matrix types_pkg.matrix_Q_ty, p2_matrix types_pkg.matrix_Q_ty) return boolean;
function  is_symmetric   (p_matrix in types_pkg.matrix_Q_ty) return boolean;
function  is_diagonal    (p_matrix in types_pkg.matrix_Q_ty) return boolean;
function  is_row_with_all_zeros    (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer)    return boolean;
function  is_column_with_all_zeros (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return boolean;
function  is_zero_matrix (p_matrix in types_pkg.matrix_Q_ty) return boolean;

function  horizontal_dimension (p_matrix_id in integer) return integer;
function  vertical_dimension (p_matrix_id in integer) return integer;
function  greatest_numerator (p_matrix in types_pkg.matrix_Q_ty) return integer;
function  greatest_denominator (p_matrix in types_pkg.matrix_Q_ty) return integer;
function  greatest_integer (p_matrix in types_pkg.matrix_Q_ty) return integer;

function  remove_all_zeros_rows    (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;
function  remove_all_zeros_columns (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;

function  dotproduct      (p_vector1 in types_pkg.vector_Q_ty, p_vector2 in types_pkg.vector_Q_ty) return types_pkg.fraction_ty;
function  crossproduct    (p_vector1 in types_pkg.vector_Q_ty, p_vector2 in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty;
function  trace           (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.fraction_ty;
function  lcm_denominator (p_matrix in types_pkg.matrix_Q_ty) return integer;
function  lcm_denominator (p_vector in types_pkg.vector_Q_ty) return integer;

function  row_to_vector    (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer) return types_pkg.vector_Q_ty;
function  column_to_vector (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return types_pkg.vector_Q_ty;

-- Gauss Jordan
function  swap_row_with_zero_down (p_matrix in types_pkg.matrix_Q_ty, p_position pls_integer) return types_pkg.matrix_Q_ty;
function  subtract_row (p_matrix in types_pkg.matrix_Q_ty, p_row1 in pls_integer, p_row2 in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty;
function  gauss_jordan_elimination (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty;

function  matrix_to_utl_nla (p_matrix in types_pkg.matrix_Q_ty) return utl_nla_array_int;
function  utl_nla_to_matrix (p_array utl_nla_array_int, p_rows in integer) return types_pkg.matrix_Q_ty;
					  					  
end matrix_Q_pkg;
/




create or replace package body matrix_Q_pkg
as
--
-- Reset / initiate all values to 0
--
procedure init_matrix (p_matrix in out nocopy types_pkg.matrix_Q_ty, p_horizontal_size in integer default 3, p_vertical_size in integer default 3)
is
begin
  for m in 1 .. p_horizontal_size
  loop
    for n in 1 .. p_vertical_size
    loop
 	  p_matrix (n)(m) :=  fractions_pkg.to_fraction (0); -- Zero
    end loop;
  end loop;

exception when others then
  util.show_error ('Error in procedure init_matrix. Horizontal: ' || p_horizontal_size || '. Vertical: ' || p_vertical_size || '.', sqlerrm);
end init_matrix;

/*************************************************************************************************************************************************/

--
-- Function returns Unitary matrix or Identity matrix
--
function  I (p_dimension in integer default 3) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for m in 1 .. p_dimension
  loop
    for n in 1 .. p_dimension
    loop
      l_matrix (n)(m) := case when n = m then fractions_pkg.to_fraction (1) else fractions_pkg.to_fraction (0) end;
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in Identity matrix function I for dimension: ' || p_dimension || '.', sqlerrm);
  return constants_pkg.empty_matrix;
end I;

/*************************************************************************************************************************************************/

--
-- Converts 2D integer co-ordinates to a point type
--
function  to_point_2D (p_x in integer, p_y in integer) return types_pkg.point_Q_ty_2D
is
begin
  return types_pkg.point_Q_ty_2D (fractions_pkg.to_fraction (p_x), fractions_pkg.to_fraction (p_y));
  
exception when others then
  util.show_error ('Error in integer function to_point_2D for coordinates: ' || p_x || ', ' || p_y || '.', sqlerrm);
  return constants_pkg.empty_point_2D;
end to_point_2D;

/*************************************************************************************************************************************************/

--
-- Converts 2D co-ordinates to a point type
--
function  to_point_2D (p_x in types_pkg.fraction_ty, p_y in types_pkg.fraction_ty) return types_pkg.point_Q_ty_2D
is
begin
  return types_pkg.point_Q_ty_2D (p_x, p_y);
  
exception when others then
  fractions_pkg.print (p_x); fractions_pkg.print (p_y);
  util.show_error ('Error in function to_point_2D.', sqlerrm);
  return constants_pkg.empty_point_2D;
end to_point_2D;

/*************************************************************************************************************************************************/

--
-- Converts 3D co-ordinates to a point type
--
function  to_point_3D (p_x in number, p_y in number, p_z in number) return types_pkg.point_Q_ty_3D
is
begin
  return types_pkg.point_Q_ty_3D (fractions_pkg.to_fraction (p_x), fractions_pkg.to_fraction (p_y), fractions_pkg.to_fraction (p_z));

exception when others then
  util.show_error ('Error in function to_point_3D for coordinates: '  || p_x || ', ' || p_y || ', ' || p_z || '.', sqlerrm);
  return constants_pkg.empty_point_3D;
end to_point_3D;

/*************************************************************************************************************************************************/

--
-- Converts 3D co-ordinates to a point type
--
function  to_point_3D (p_x in types_pkg.fraction_ty, p_y in types_pkg.fraction_ty, p_z in types_pkg.fraction_ty) return types_pkg.point_Q_ty_3D
is
begin
  return types_pkg.point_Q_ty_3D (p_x, p_y, p_z);

exception when others then
  fractions_pkg.print (p_x); fractions_pkg.print (p_y);  fractions_pkg.print (p_z);
  util.show_error ('Error in function to_point_3D.', sqlerrm);
  return constants_pkg.empty_point_3D;
end to_point_3D;

/*************************************************************************************************************************************************/

--
-- Converts 3D integer co-ordinates to a vector
--
function  to_vector (p_x1  in integer, p_x2 in integer default null, p_x3 in integer default null, p_x4 in integer default null,
                     p_x5  in integer default null, p_x6  in integer default null, p_x7  in integer default null,
					 p_x8  in integer default null, p_x9  in integer default null, p_x10 in integer default null,
					 p_x11 in integer default null, p_x12 in integer default null, p_x13 in integer default null,
					 p_x14 in integer default null, p_x15 in integer default null, p_x16 in integer default null) return types_pkg.vector_Q_ty	
is
l_vector types_pkg.vector_Q_ty;
begin
  if p_x1  is not null then l_vector(1)  := fractions_pkg.to_fraction (p_x1);  else goto done; end if;
  if p_x2  is not null then l_vector(2)  := fractions_pkg.to_fraction (p_x2);  else goto done; end if;
  if p_x3  is not null then l_vector(3)  := fractions_pkg.to_fraction (p_x3);  else goto done; end if;
  if p_x4  is not null then l_vector(4)  := fractions_pkg.to_fraction (p_x4);  else goto done; end if;
  if p_x5  is not null then l_vector(5)  := fractions_pkg.to_fraction (p_x5);  else goto done; end if;
  if p_x6  is not null then l_vector(6)  := fractions_pkg.to_fraction (p_x6);  else goto done; end if;
  if p_x7  is not null then l_vector(7)  := fractions_pkg.to_fraction (p_x7);  else goto done; end if;
  if p_x8  is not null then l_vector(8)  := fractions_pkg.to_fraction (p_x8);  else goto done; end if;
  if p_x9  is not null then l_vector(9)  := fractions_pkg.to_fraction (p_x9);  else goto done; end if;
  if p_x10 is not null then l_vector(10) := fractions_pkg.to_fraction (p_x10); else goto done; end if;
  if p_x11 is not null then l_vector(11) := fractions_pkg.to_fraction (p_x11); else goto done; end if;
  if p_x12 is not null then l_vector(12) := fractions_pkg.to_fraction (p_x12); else goto done; end if;
  if p_x13 is not null then l_vector(13) := fractions_pkg.to_fraction (p_x13); else goto done; end if;
  if p_x14 is not null then l_vector(14) := fractions_pkg.to_fraction (p_x14); else goto done; end if;
  if p_x15 is not null then l_vector(15) := fractions_pkg.to_fraction (p_x15); else goto done; end if;
  if p_x16 is not null then l_vector(16) := fractions_pkg.to_fraction (p_x16); else goto done; end if;
  <<done>>
  return l_vector;
 
exception when others then
  util.show_error ('Error in function to_vector.' , sqlerrm);
end to_vector;
 
/*************************************************************************************************************************************************/

--
-- Converts array of fractions to a vector
--
function  to_vector (p_x1  in types_pkg.fraction_ty, p_x2 in types_pkg.fraction_ty default null, p_x3 in types_pkg.fraction_ty default null, p_x4 in types_pkg.fraction_ty default null,
                     p_x5  in types_pkg.fraction_ty default null, p_x6  in types_pkg.fraction_ty default null, p_x7  in types_pkg.fraction_ty default null,
					 p_x8  in types_pkg.fraction_ty default null, p_x9  in types_pkg.fraction_ty default null, p_x10 in types_pkg.fraction_ty default null,
					 p_x11 in types_pkg.fraction_ty default null, p_x12 in types_pkg.fraction_ty default null, p_x13 in types_pkg.fraction_ty default null,
					 p_x14 in types_pkg.fraction_ty default null, p_x15 in types_pkg.fraction_ty default null, p_x16 in types_pkg.fraction_ty default null) return types_pkg.vector_Q_ty
is
l_vector types_pkg.vector_Q_ty;
begin
  if p_x1.numerator  is not null then l_vector(1)  := p_x1;  else goto done; end if;
  if p_x2.numerator  is not null then l_vector(2)  := p_x2;  else goto done; end if;
  if p_x3.numerator  is not null then l_vector(3)  := p_x3;  else goto done; end if;
  if p_x4.numerator  is not null then l_vector(4)  := p_x4;  else goto done; end if;
  if p_x5.numerator  is not null then l_vector(5)  := p_x5;  else goto done; end if;
  if p_x6.numerator  is not null then l_vector(6)  := p_x6;  else goto done; end if;
  if p_x7.numerator  is not null then l_vector(7)  := p_x7;  else goto done; end if;
  if p_x8.numerator  is not null then l_vector(8)  := p_x8;  else goto done; end if;
  if p_x9.numerator  is not null then l_vector(9)  := p_x9;  else goto done; end if;
  if p_x10.numerator is not null then l_vector(10) := p_x10; else goto done; end if;
  if p_x11.numerator is not null then l_vector(11) := p_x11; else goto done; end if;
  if p_x12.numerator is not null then l_vector(12) := p_x12; else goto done; end if;
  if p_x13.numerator is not null then l_vector(13) := p_x13; else goto done; end if;
  if p_x14.numerator is not null then l_vector(14) := p_x14; else goto done; end if;
  if p_x15.numerator is not null then l_vector(15) := p_x15; else goto done; end if;
  if p_x16.numerator is not null then l_vector(16) := p_x16; else goto done; end if;
  <<done>>
  return l_vector;
 
exception when others then
  util.show_error ('Error in function to_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end to_vector;
 
/*************************************************************************************************************************************************/

--
-- Fill 2 * 2 integer Matrix
--
function  to_matrix_2D (p_x11 in integer, p_x12 in integer, p_x21 in integer, p_x22 in integer) return types_pkg.matrix_Q_ty
is
begin
  return types_pkg.matrix_Q_ty (1 => types_pkg.vector_Q_ty (1 => fractions_pkg.to_fraction (p_x11), 2 => fractions_pkg.to_fraction (p_x12)),
                                2 => types_pkg.vector_Q_ty (1 => fractions_pkg.to_fraction (p_x21), 2 => fractions_pkg.to_fraction (p_x22))); 

exception when others then
  util.show_error ('Error in function to_matrix_2D for: ' || p_x11 || ', ' || p_x12 || ', ' || p_x21 || ', ' || p_x22 || '.', sqlerrm);
  return constants_pkg.empty_matrix; 
end to_matrix_2D;

/*************************************************************************************************************************************************/

--
-- Fill 2 * 2 Matrix
--
function  to_matrix_2D (p_x11 in types_pkg.fraction_ty, p_x12 in types_pkg.fraction_ty, p_x21 in types_pkg.fraction_ty, p_x22 in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty
is
begin
   return types_pkg.matrix_Q_ty (1 => types_pkg.vector_Q_ty (1 => p_x11, 2 => p_x12), 2 => types_pkg.vector_Q_ty (1 => p_x21, 2 => p_x22));

exception when others then
  fractions_pkg.print (p_x11); fractions_pkg.print (p_x12); fractions_pkg.print (p_x21); fractions_pkg.print (p_x22);
  util.show_error ('Error in function to_matrix_Q_2D.', sqlerrm);
  return constants_pkg.empty_matrix;
end to_matrix_2D;

/*************************************************************************************************************************************************/

--
-- Fill 3 * 3 Integer Matrix
--
function  to_matrix_3D (p_x11 in integer, p_x12 in integer, p_x13 in integer, p_x21 in integer, p_x22 in integer, p_x23 in integer, p_x31 in integer, p_x32 in integer, p_x33 in integer) return types_pkg.matrix_Q_ty
is
begin
  return types_pkg.matrix_Q_ty (1 => types_pkg.vector_Q_ty (1 => fractions_pkg.to_fraction (p_x11), 2 => fractions_pkg.to_fraction (p_x12), 3 => fractions_pkg.to_fraction (p_x13)),
                                2 => types_pkg.vector_Q_ty (1 => fractions_pkg.to_fraction (p_x21), 2 => fractions_pkg.to_fraction (p_x22), 3 => fractions_pkg.to_fraction (p_x23)),
								3 => types_pkg.vector_Q_ty (1 => fractions_pkg.to_fraction (p_x31), 2 => fractions_pkg.to_fraction (p_x32), 3 => fractions_pkg.to_fraction (p_x33))); 

exception when others then
  util.show_error ('Error in function to_matrix_3D.' , sqlerrm);
  return constants_pkg.empty_matrix; 
end to_matrix_3D;

/*************************************************************************************************************************************************/

--
-- Fill 3 * 3 Matrix
--
function  to_matrix_3D (p_x11 in types_pkg.fraction_ty, p_x12 in types_pkg.fraction_ty, p_x13 in types_pkg.fraction_ty, p_x21 in types_pkg.fraction_ty, p_x22 in types_pkg.fraction_ty,
                        p_x23 in types_pkg.fraction_ty, p_x31 in types_pkg.fraction_ty, p_x32 in types_pkg.fraction_ty, p_x33 in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty
is
begin
  return types_pkg.matrix_Q_ty (1 => types_pkg.vector_Q_ty (1 => p_x11, 2 => p_x12, 3 => p_x13),
                                2 => types_pkg.vector_Q_ty (1 => p_x21, 2 => p_x22, 3 => p_x23),
                                3 => types_pkg.vector_Q_ty (1 => p_x31, 2 => p_x32, 3 => p_x33));

exception when others then
  util.show_error ('Error in function to_matrix_3D.' , sqlerrm);
  return constants_pkg.empty_matrix;
end to_matrix_3D;

/*************************************************************************************************************************************************/


--
-- Add 2 matrices: p1_matrix + p2_matrix
--
function  add_matrix (p1_matrix in types_pkg.matrix_Q_ty, p2_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  if p1_matrix.count != p2_matrix.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Rows first matrix: ' || p1_matrix.count || '. Rows second matrix: '|| p2_matrix.count || '.');
  elsif p1_matrix(1).count != p2_matrix(1).count
  then
    raise_application_error(-20004, 'Dimensions do not match. Columns first matrix: ' || p1_matrix(1).count || '. Columns second matrix: '|| p2_matrix(1).count || '.');
  end if;

  for m in 1 .. p1_matrix.count
  loop
    for n in 1 .. p1_matrix(1).count
    loop
      l_matrix(m)(n) := fractions_pkg.add (p1_matrix(m)(n), p2_matrix(m)(n));
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function add_matrix.' , sqlerrm);
  return constants_pkg.empty_matrix;
end add_matrix;

/*************************************************************************************************************************************************/

--
-- Subtract matrices: p1_matrix - p2_matrix
--
function  substract_matrix (p1_matrix in types_pkg.matrix_Q_ty, p2_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
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
      l_matrix(m)(n) := fractions_pkg.subtract (p1_matrix(m)(n), p2_matrix(m)(n));
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function substract_matrix.' , sqlerrm);
  return constants_pkg.empty_matrix;
end substract_matrix;

/*************************************************************************************************************************************************/

--
-- Multiply one column of a matrix
--
function  multiply_column (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty := p_matrix;
begin
  for m in 1 .. p_matrix.count
  loop
    l_matrix (m)(p_column) := fractions_pkg.multiply (l_matrix (m)(p_column), p_factor);
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function multiply_column.' , sqlerrm);
  return constants_pkg.empty_matrix;
end multiply_column;

/*************************************************************************************************************************************************/

--
-- Multiply one row of a matrix
--
function  multiply_row (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty := p_matrix;
begin
  for n in 1 .. p_matrix (1).count
  loop
    l_matrix (p_row)(n) := fractions_pkg.multiply (l_matrix (p_row)(n), p_factor);
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function multiply_row.' , sqlerrm);
  return constants_pkg.empty_matrix;
end multiply_row;

/*************************************************************************************************************************************************/

--
-- Swap 2 columns of a matrix
--
function  swap_columns (p_matrix in types_pkg.matrix_Q_ty, p_column1 in pls_integer, p_column2 in pls_integer) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty := p_matrix;
l_dummy  types_pkg.fraction_ty;
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
  return constants_pkg.empty_matrix;
end swap_columns;

/*************************************************************************************************************************************************/

--
-- Swap 2 rows of a matrix
--
function  swap_rows (p_matrix in types_pkg.matrix_Q_ty, p_row1 in pls_integer, p_row2 in pls_integer) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty := p_matrix;
l_dummy  types_pkg.fraction_ty;
begin
  for n in 1 .. p_matrix (1).count
  loop
    l_dummy              := l_matrix (p_row1)(n);
    l_matrix (p_row1)(n) := l_matrix (p_row2)(n);
    l_matrix (p_row2)(n) := l_dummy;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function swap_rows.' , sqlerrm);
  return constants_pkg.empty_matrix;
end swap_rows;

/*************************************************************************************************************************************************/

--
-- Multiply matrix with a vector
--
function  matrix_times_vector (p_matrix in types_pkg.matrix_Q_ty, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty
is
l_vector types_pkg.vector_Q_ty;
begin
  if p_matrix (1).count =  p_vector.count
  then
    for i in 1 .. p_matrix.count
    loop
      l_vector (i) := fractions_pkg.to_fraction (0);    
      for j in 1 .. p_matrix (1).count
      loop
        l_vector (i) := fractions_pkg.add (l_vector (i), fractions_pkg.multiply (p_matrix (i)(j), p_vector (j)));
	  end loop;
    end loop;
  else
    raise_application_error(-20005, 'Multiplication not defined. Matrix has ' || p_matrix (1).count || ' columns. Vector has ' || p_vector.count || ' elements.');
  end if;
  return l_vector;

exception when others then
  util.show_error ('Error in function matrix_times_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end matrix_times_vector;

/*************************************************************************************************************************************************/

--
-- Multiply a scalar with a vector
--
function  scalar_times_vector (p_scalar in types_pkg.fraction_ty, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty
is
l_vector types_pkg.vector_Q_ty := p_vector;
begin
  for j in 1 .. p_vector.count
  loop
    l_vector (j) := fractions_pkg.multiply (l_vector (j), p_scalar);
  end loop;
  return l_vector;

exception when others then
  util.show_error ('Error in function scalar_times_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end scalar_times_vector;

/*************************************************************************************************************************************************/

--
-- Multiply a scalar with a vector
--

function  integer_times_vector (p_integer in integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty
is
begin
  return scalar_times_vector (fractions_pkg.to_fraction (p_integer), p_vector);

exception when others then
  util.show_error ('Error in function integer_times_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end integer_times_vector;

/*************************************************************************************************************************************************/

--
-- Multiply matrix with a scalar p_scalar
--
function  multiply    (p_scalar in types_pkg.fraction_ty, p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for n in 1 .. p_matrix (1).count
  loop
    for m in 1 .. p_matrix.count
    loop
      l_matrix(m)(n) := fractions_pkg.multiply (p_matrix (m)(n), p_scalar);
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function multiply matrix with scalar.' , sqlerrm);
  return constants_pkg.empty_matrix;
end multiply;

/*************************************************************************************************************************************************/

--
-- Multiply matrix with a point.
--
function  multiply_2D (p_matrix in types_pkg.matrix_Q_ty, p_point in types_pkg.point_Q_ty_2D) return types_pkg.point_Q_ty_2D
is
begin
  if p_matrix (1).count != 2
  then
    raise_application_error(-20005, 'Multiplication only defined for 2 dimensional vectors. Matrix has ' ||  p_matrix (1).count || ' columns');
  end if;
  return types_pkg.point_Q_ty_2D (								  
	       fractions_pkg.add (fractions_pkg.multiply (p_matrix (1)(1), p_point.x_c), fractions_pkg.multiply (p_matrix (1)(2), p_point.y_c)),
	       fractions_pkg.add (fractions_pkg.multiply (p_matrix (2)(1), p_point.x_c), fractions_pkg.multiply (p_matrix (2)(2), p_point.y_c)));

exception when others then
  util.show_error ('Error in function multiply_2D.' , sqlerrm);
  return constants_pkg.empty_point_2D;
end multiply_2D;

/*************************************************************************************************************************************************/

--
-- Multiply 3D matrix with a vector
--
function  multiply_3D (p_matrix in types_pkg.matrix_Q_ty, p_point in types_pkg.point_Q_ty_3D) return types_pkg.point_Q_ty_3D
is
begin
  if p_matrix (1).count != 3
  then
    raise_application_error(-20005, 'Multiplication only defined for 3 dimensional vectors. Matrix has ' ||  p_matrix (1).count || ' columns');
  end if;    
  return types_pkg.point_Q_ty_3D (								  
	fractions_pkg.add (fractions_pkg.add (fractions_pkg.multiply (p_matrix (1)(1), p_point.x_c), fractions_pkg.multiply (p_matrix (1)(2), p_point.y_c)), fractions_pkg.multiply (p_matrix (1)(3), p_point.z_c)),
	fractions_pkg.add (fractions_pkg.add (fractions_pkg.multiply (p_matrix (2)(1), p_point.x_c), fractions_pkg.multiply (p_matrix (2)(2), p_point.y_c)), fractions_pkg.multiply (p_matrix (2)(3), p_point.z_c)),
	fractions_pkg.add (fractions_pkg.add (fractions_pkg.multiply (p_matrix (3)(1), p_point.x_c), fractions_pkg.multiply (p_matrix (3)(2), p_point.y_c)), fractions_pkg.multiply (p_matrix (3)(3), p_point.z_c)));

exception when others then
  util.show_error ('Error in function multiply_3D.' , sqlerrm);
end multiply_3D;

/*************************************************************************************************************************************************/

--
-- Multiply 2 matrices.
--
function  multiply    (p_matrix_a in types_pkg.matrix_Q_ty, p_matrix_b types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
l_val    types_pkg.fraction_ty;
begin
  if p_matrix_a (1).count != p_matrix_b.count
  then
    raise_application_error (-20004, 'Inner dimensions do not match. First horizontal: ' ||  p_matrix_a(1).count || '. Second vertical: '|| p_matrix_b.count);
  end if;
  for x in 1 .. p_matrix_a.count
  loop
    for y in 1 .. p_matrix_b (1).count
    loop
      l_val := fractions_pkg.to_fraction (0);    
      for p in 1 .. p_matrix_a (1).count
      loop
        l_val := fractions_pkg.add (fractions_pkg.multiply (p_matrix_a (x)(p), p_matrix_b (p)(y)), l_val);
      end loop;
      l_matrix (x) (y) := l_val;
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function that multiplies 2 matrices.' , sqlerrm);
  return constants_pkg.empty_matrix;
end multiply;

/*************************************************************************************************************************************************/

--
-- Store the matrix in a table
--
procedure save_matrix (p_matrix in types_pkg.matrix_Q_ty, p_id in out nocopy integer)
is
begin
  if p_id is null then p_id := matrix_seq.nextval; end if;

  for n1 in 1 .. p_matrix (1).count
  loop
    for m1 in 1 .. p_matrix.count
    loop
      begin
        insert into matrix_Q (id, n, m, numerator, denominator) values (p_id, n1, m1, p_matrix (n1)(m1).numerator, p_matrix (n1)(m1).denominator);
      exception when dup_val_on_index
      then
        update matrix_Q set numerator =  p_matrix (n1)(m1).numerator, denominator = p_matrix (n1)(m1).denominator where id = p_id and n = n1 and m = m1;
      end;
    end loop;
  end loop;
  commit;

exception when others then
  util.show_error ('Error in procedure save_matrix.' , sqlerrm);
end save_matrix;

/*************************************************************************************************************************************************/

--
-- Load matrix from a table
--
function  load_matrix (p_id in number) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for j in (select n, m, numerator, denominator from matrix_Q where id = p_id)
  loop
    l_matrix (j.n)(j.m) := fractions_pkg.to_fraction (j.numerator, j.denominator);
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function load_matrix.' , sqlerrm);
  return constants_pkg.empty_matrix;
end load_matrix;

/*************************************************************************************************************************************************/

--
-- Load matrix from a table
--
function  load_matrix (p_name in varchar2) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for j in (select n, m, numerator, denominator from matrix_Q where name = p_name)
  loop
    l_matrix (j.n)(j.m) := fractions_pkg.to_fraction (j.numerator, j.denominator);
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function load_matrix.' , sqlerrm);
  return constants_pkg.empty_matrix;
end load_matrix;

/*************************************************************************************************************************************************/

--
-- 2 Dimensional mirror in x = y plane. z = 0.
--
function  mirror_xy   (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      l_matrix (m)(n) := p_matrix (n)(m);
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function mirror_xy 1.' , sqlerrm);
  return constants_pkg.empty_matrix;
end mirror_xy;

/*************************************************************************************************************************************************/

--
-- Mirror point in XY-plane
--
function  mirror_xy   (p_point in types_pkg.point_Q_ty_3D) return types_pkg.point_Q_ty_3D
is
begin
  return types_pkg.point_Q_ty_3D (p_point.y_c, p_point.x_c, p_point.z_c);

exception when others then
  util.show_error ('Error in function mirror_xy 2.' , sqlerrm);
  return constants_pkg.empty_point_3D;
end mirror_xy;

/*************************************************************************************************************************************************/

--
-- Show coordinates of a 2D point on the screen
--
procedure print_point_2D (p_point types_pkg.point_Q_ty_2D)
is
begin
  dbms_output.put ('Point x: ')   ; fractions_pkg.print (p_point.x_c, false);
  dbms_output.put ('.  Point y: '); fractions_pkg.print (p_point.y_c, false);
  dbms_output.put_line ( '.');

exception when others then
  util.show_error ('Error in procedure print_point_2D.' , sqlerrm);
end print_point_2D;

/*************************************************************************************************************************************************/

--
-- Show coordinates of a 3D point on the screen
--
procedure print_point_3D (p_point types_pkg.point_Q_ty_3D)
is
begin
  dbms_output.put ('Point x: ')   ; fractions_pkg.print (p_point.x_c, false);
  dbms_output.put ('.  Point y: '); fractions_pkg.print (p_point.y_c, false);
  dbms_output.put ('.  Point z: '); fractions_pkg.print (p_point.z_c, false);
  dbms_output.put_line ( '.');
  
exception when others then
  util.show_error ('Error in procedure print_point_3D.' , sqlerrm);
end print_point_3D;

/*************************************************************************************************************************************************/

--
-- Print vector horizontal
--
procedure print_vector (p_vector types_pkg.vector_Q_ty)
is
l_first boolean := true;
begin
  dbms_output.put ('(');
  for j in 1 .. p_vector.count
  loop
    if l_first
	then fractions_pkg.print (p_vector(j), false); l_first := FALSE;
	else dbms_output.put (', ' ); fractions_pkg.print (p_vector(j), false);
	end if;
  end loop;
  dbms_output.put_line (')');

exception when others then
  util.show_error ('Error in procedure print_vector.' , sqlerrm);
end print_vector;

/*************************************************************************************************************************************************/

--
-- Print a matrix using dbms_output package
--
procedure print_matrix (p_matrix in types_pkg.matrix_Q_ty)
is
l_cel    varchar2(50);
l_m      pls_integer;
l_n      pls_integer;
l_length pls_integer;
begin
  l_length := length (greatest_numerator (p_matrix)) + length (greatest_denominator (p_matrix)) + length (greatest_integer (p_matrix));
  for m in 1 .. p_matrix.count
  loop
    dbms_output.new_line;
	for p in 1 .. p_matrix (1).count loop dbms_output.put (rpad ('+', l_length + 8, '-')); end loop;
	dbms_output.put_line ('+');
    for n in 1 .. p_matrix (1).count
    loop
	  l_m := m; l_n := n;
      l_cel := matrix_Q_pkg.fraction_to_string (p_matrix (m)(n), l_length + 5);
      dbms_output.put('|' || l_cel);
    end loop;
    dbms_output.put('|');
  end loop;
  dbms_output.new_line;
  for p in 1 .. p_matrix (1).count loop dbms_output.put (rpad ('+', l_length + 8, '-')); end loop;
  dbms_output.put_line ('+');
  dbms_output.new_line;

exception when others then
  util.show_error ('Error in procedure print_matrix for co-ordinates: (' || l_m || ', '|| l_n || ').', sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

--
-- Convert fraction to a string
--
function fraction_to_string   (p_fraction in types_pkg.fraction_ty, p_width in integer default 10) return varchar2
is
l_string varchar2 (100);
l_length number(3);
begin
  if p_fraction.denominator = 0 then raise zero_divide; end if;
 
  if p_fraction.numerator is not null
  then
    if sign (p_fraction.numerator) * sign (p_fraction.denominator) = -1 -- Negative fraction
    then l_string := '- ';
	else l_string := '+ ';
    end if;

    if mod (p_fraction.numerator, p_fraction.denominator) = 0 --  Whole number
    then
	   l_string := l_string || to_char (trunc (abs (p_fraction.numerator) / abs (p_fraction.denominator)));
    else
      if abs (p_fraction.numerator) > abs (p_fraction.denominator)
      then
	   l_string := l_string || trunc (abs (p_fraction.numerator) / abs (p_fraction.denominator)) || ':' ;
      end if;
	  l_string := l_string || mod (abs (p_fraction.numerator), abs (p_fraction.denominator)) || '/' || abs (p_fraction.denominator);	  
    end if;
  end if;
  return '  ' || l_string || rpad (' ', p_width - length (l_string));

exception when others then
  util.show_error ('Error in function fraction_to_string for: ' || p_fraction.numerator || ' /  ' || p_fraction.denominator, sqlerrm);
  return null;
end fraction_to_string;

/*************************************************************************************************************************************************/

--
-- Remove a row from a matrix
--
function  remove_row (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty;
begin
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      if    m < p_row  then l_matrix (m)(n)     := p_matrix (m)(n);
      elsif m > p_row  then l_matrix (m - 1)(n) := p_matrix (m)(n);
	  end if;
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function remove_row.' , sqlerrm);
  return constants_pkg.empty_matrix;
end remove_row;

/*************************************************************************************************************************************************/

--
-- Remove a column from a matrix
--
function  remove_column (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty;
begin
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      if    n < p_column  then l_matrix (m)(n)     := p_matrix (m)(n);
      elsif n > p_column  then l_matrix (m)(n - 1) := p_matrix (m)(n);
	  end if;
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function remove_column.' , sqlerrm);
  return constants_pkg.empty_matrix;
end remove_column;

/*************************************************************************************************************************************************/

--
-- Add a row to a matrix on line "p_row" the other rows move down one line
--
function  add_row (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty;
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
      raise_application_error (-20004, 'Dimensions do not match. Columns matrix: ' || p_matrix (1).count || '. Dimension vector: '|| p_vector.count || '.');
    elsif p_row not between 1 and p_matrix (1).count + 1
    then
      raise_application_error (-20004, 'Row position is wrong. Rows matrix: ' || p_matrix.count || '. Dimension vector: '|| p_vector.count || '.');
    end if; 

    for m in 1 .. p_matrix.count + 1
    loop
      for n in 1 .. p_matrix (1).count
      loop
        if    m < p_row then l_matrix(m)(n) := p_matrix (m)(n);
        elsif m = p_row then l_matrix(m)(n) := p_vector (n);
        else  l_matrix (m)(n) := p_matrix (m - 1)(n);
        end if;
       end loop;
     end loop;
  end if;
  return l_matrix; 

exception when others then
  util.show_error ('Error in function add_row. Rows: ' || p_matrix.count, sqlerrm);
  return constants_pkg.empty_matrix;
end add_row;

/*************************************************************************************************************************************************/

--
-- Add a column to a matrix on column "p_column" the other columns move one position to the right
--
function  add_column (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer, p_vector in types_pkg.vector_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix   types_pkg.matrix_Q_ty;
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
  return constants_pkg.empty_matrix;
end add_column;

/*************************************************************************************************************************************************/

--
-- Reduce "p_row_y" line and "p_column_x" column from the matrix
--
function  cofactor (p_matrix in types_pkg.matrix_Q_ty, p_row_y in integer, p_column_x in integer) return types_pkg.matrix_Q_ty
is
begin
  return remove_column (remove_row (p_matrix, p_row_y), p_column_x);

exception when others then
  util.show_error ('Error in function cofactor.' , sqlerrm);
  return constants_pkg.empty_matrix;
end cofactor;

/*************************************************************************************************************************************************/

--
-- Calculate determinant of a matrix
--
function  determinant (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.fraction_ty
is
l_determinant types_pkg.fraction_ty := fractions_pkg.to_fraction (0);
begin
  if p_matrix (1).count != p_matrix.count
  then
    raise_application_error (-20004, 'Determinant not defined for a ' || p_matrix (1).count || ' * '|| p_matrix.count || ' matrix.');
  end if;

  if    p_matrix (1).count = 1 then return p_matrix (1)(1);
  elsif p_matrix (1).count = 2 then return fractions_pkg.subtract (fractions_pkg.multiply (p_matrix (1)(1), p_matrix (2)(2)), fractions_pkg.multiply (p_matrix (2)(1), p_matrix (1)(2)));
  else -- Generic, but slow solution
    for j in 1 .. p_matrix (1).count
    loop
 --	l_determinant + 	power (-1, j + 1) * p_matrix (1)(j) * determinant (cofactor (p_matrix, 1, j));
      l_determinant := fractions_pkg.add (
	                   l_determinant,
         				 fractions_pkg.multiply (
		  			       fractions_pkg.multiply (fractions_pkg.to_fraction (power (-1, j + 1) , 1), p_matrix (1)(j)),
     		  						determinant (cofactor (p_matrix, 1, j))));
    end loop;
  end if;
  return l_determinant;

exception when others then
  util.show_error ('Error in function determinant.' , sqlerrm);
  return constants_pkg.empty_fraction;
end determinant;

/*************************************************************************************************************************************************/

--
-- Adjugate matrix
--
function adjugate    (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_determinant types_pkg.fraction_ty := fractions_pkg.to_fraction (0);
l_matrix      types_pkg.matrix_Q_ty;
begin
  if p_matrix (1).count != p_matrix.count
  then
    raise_application_error (-20004, 'Matrix not square. Determinant not defined for a ' || p_matrix (1).count || ' * '|| p_matrix.count || ' matrix.');
  end if;
  
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  l_matrix (n)(m) := fractions_pkg.multiply (fractions_pkg.to_fraction (power (-1, n + m) , 1), determinant (cofactor (p_matrix, n, m)));
	end loop;
  end loop;
  return  transpose (l_matrix);
  
exception when others then
  util.show_error ('Error in function adjugate.' , sqlerrm);
  return constants_pkg.empty_matrix;
end adjugate;

/*************************************************************************************************************************************************/

--
-- Calculate the inverse of a matrix
--
function  invert      (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_determinant types_pkg.fraction_ty := determinant (p_matrix);
begin
  if p_matrix (1).count != p_matrix.count
  then
    raise_application_error(-20004, 'Matrix not square. Inverse not defined for a ' || p_matrix.count || ' * '|| p_matrix (1).count || ' matrix.');
  elsif l_determinant.numerator = 0
  then
    raise_application_error(-20005, 'Matrix is singular.');
  end if;
  return  multiply (fractions_pkg.divide (fractions_pkg.to_fraction (1), l_determinant), adjugate (p_matrix));

exception when others then
  util.show_error ('Error in function invert.' , sqlerrm);
  return constants_pkg.empty_matrix;
end invert;

/*************************************************************************************************************************************************/

--
-- Transpose a matrix. Mirror in diagonal axis (1,1) -- (m,m)
--
function   transpose   (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is
l_matrix types_pkg.matrix_Q_ty;
begin
  for n in 1 .. p_matrix (1).count
  loop
    for m in 1 .. p_matrix.count
    loop
      l_matrix(n)(m) := p_matrix (m)(n);
    end loop;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function transpose.' , sqlerrm);
  return constants_pkg.empty_matrix;
end transpose;

/*************************************************************************************************************************************************/

--
-- Compare 2 matrices
--
function  is_equal    (p1_matrix types_pkg.matrix_Q_ty, p2_matrix types_pkg.matrix_Q_ty) return boolean
is
l_equal boolean := true;
begin
  if p1_matrix.count != p2_matrix.count or p1_matrix (1).count != p2_matrix (1).count
  then
    return false;
  end if;

  <<differ>>
  for n in 1 .. p1_matrix (1).count
  loop
    for m in 1 .. p2_matrix.count
    loop
      l_equal := p1_matrix (n)(m).numerator * p2_matrix(n)(m).denominator =  p2_matrix (n)(m).numerator * p1_matrix(n)(m).denominator;
      exit differ when not l_equal;
    end loop;
  end loop;
  return l_equal;

exception when others then
  util.show_error ('Error in function is_equal.' , sqlerrm);
  return null;
end is_equal;

/*************************************************************************************************************************************************/

--
-- Check if matrix is symmetric a(i,j) = a(j,i)
--
function  is_symmetric (p_matrix in types_pkg.matrix_Q_ty) return boolean
is
l_is_symmetric boolean := true;
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
      l_is_symmetric := p_matrix (m)(n).numerator * p_matrix(n)(m).denominator =  p_matrix (n)(m).numerator * p_matrix(m)(n).denominator;
	  exit done when not l_is_symmetric;  
    end loop;
  end loop;
  return l_is_symmetric;
  
exception when others then
  util.show_error ('Error in function is_symmetric.' , sqlerrm);
  return null;
end is_symmetric;

/*************************************************************************************************************************************************/

--
-- Check if matrix is diagonal a(i,j) = 0 for all (i, j) with i != j.
--
function  is_diagonal (p_matrix in types_pkg.matrix_Q_ty) return boolean
is
l_is_diagonal boolean := true;
begin
  <<done>>
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      if m != n
	  then
        l_is_diagonal := p_matrix (m)(n).numerator = 0;
	    exit done when not l_is_diagonal;
	  end if;
    end loop;
  end loop;
 return l_is_diagonal;
  
exception when others then
  util.show_error ('Error in function l_is_diagonal.' , sqlerrm);
  return null;
end is_diagonal;

/*************************************************************************************************************************************************/

--
-- Check if all values in a matrix row are zero.
--
function is_row_with_all_zeros (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer) return boolean
is 
l_is_zero boolean;
begin 
  <<non_zero>>
  for m in 1 .. p_matrix (1).count -- all columns
  loop 
    l_is_zero := p_matrix (p_row) (m).numerator = 0;
    exit non_zero when not l_is_zero;
  end loop;
  return l_is_zero;

exception when others then
  util.show_error ('Error in function is_row_with_all_zeros.' , sqlerrm);
  return null;
end is_row_with_all_zeros;

/*************************************************************************************************************************************************/

--
-- Check if all values in a matrix column are zero.
--
function  is_column_with_all_zeros (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return boolean
is
l_is_zero boolean;
begin 
  <<non_zero>>
  for n in 1 .. p_matrix.count -- all columns
  loop 
    l_is_zero := p_matrix (n) (p_column).numerator = 0;
    exit non_zero when not l_is_zero;
  end loop;
  return l_is_zero;

exception when others then
  util.show_error ('Error in function is_column_with_all_zeros.' , sqlerrm);
  return null;
end is_column_with_all_zeros;

/*************************************************************************************************************************************************/

--
-- Check if matrix contains only zero's
--
function  is_zero_matrix (p_matrix in types_pkg.matrix_Q_ty) return boolean
is
l_is_zero boolean := true;
begin
  <<done>>
  for m in 1 .. p_matrix.count
  loop
    for n in 1 .. p_matrix (1).count
    loop
      l_is_zero := p_matrix (m)(n).numerator = 0;
      exit done when not l_is_zero;  
    end loop;
  end loop;
  return l_is_zero;
  
exception when others then
  util.show_error ('Error in function is_zero_matrix.' , sqlerrm);
  return null;
end is_zero_matrix;

/*************************************************************************************************************************************************/

--
-- Horizontal size. Number of matrix columns for a saved matrix
--
function horizontal_dimension (p_matrix_id in integer) return integer
is
l_max   integer (6);
begin
  select max (n) into l_max from matrix_Q where id = p_matrix_id;
  return l_max;

exception when others then
  util.show_error ('Error in function horizontal_dimension.' , sqlerrm);
  return null;
end horizontal_dimension;

/*************************************************************************************************************************************************/

--
-- Vertical size. Number of matrix rows for a saved matrix
--
function vertical_dimension (p_matrix_id in integer) return integer
is
l_max   integer (6);
begin
  select max (m) into l_max from matrix_Q where id = p_matrix_id;
  return l_max;

exception when others then
  util.show_error ('Error in function vertical_dimension.' , sqlerrm);
  return null;
end vertical_dimension;

/*************************************************************************************************************************************************/

--
-- Calculate greatest numerator
--
function greatest_numerator (p_matrix in types_pkg.matrix_Q_ty) return integer
is
l_greatest  integer := 1;
begin
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  l_greatest := greatest (mod (abs (p_matrix (n)(m).numerator), abs (p_matrix (n)(m).denominator)), l_greatest);	  
	end loop;
  end loop;
  return l_greatest;

exception when others then
  util.show_error ('Error in function greatest_numerator.' , sqlerrm);
  return null;
end greatest_numerator;

/*************************************************************************************************************************************************/

--
-- Calculate greatest denominator
--
function greatest_denominator (p_matrix in types_pkg.matrix_Q_ty) return integer
is
l_greatest  integer := 1;
begin
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  l_greatest := greatest (abs (p_matrix (n)(m).denominator), l_greatest);	  
	end loop;
  end loop;
  return l_greatest;

exception when others then
  util.show_error ('Error in function greatest_denominator.' , sqlerrm);
  return null;
end greatest_denominator;

/*************************************************************************************************************************************************/

--
-- Calculate greatest integer
--
function greatest_integer (p_matrix in types_pkg.matrix_Q_ty) return integer
is
l_greatest  integer := 1;
begin
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  l_greatest := greatest (trunc (abs (p_matrix (n)(m).numerator) / abs (p_matrix (n)(m).denominator)), l_greatest);	  
	end loop;
  end loop;
  return l_greatest;

exception when others then
  util.show_error ('Error in function greatest_integer.' , sqlerrm);
  return null;
end greatest_integer;

/*************************************************************************************************************************************************/

--
-- Tool to assist with Gauss Jordan elimination
--
function remove_all_zeros_rows (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is 
l_matrix types_pkg.matrix_Q_ty := p_matrix;
l_count  integer := 1;
begin
  while l_count <= l_matrix.count
  loop 
    if   is_row_with_all_zeros (l_matrix, l_count)
	then l_matrix := matrix_Q_pkg.remove_row (l_matrix, l_count);
	else l_count := l_count + 1;
	end if;
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function remove_all_zeros_rows.' , sqlerrm);
  return constants_pkg.empty_matrix;
end remove_all_zeros_rows;

/*************************************************************************************************************************************************/

--
-- Tool to assist with Gauss Jordan elimination
--
function remove_all_zeros_columns (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is 
l_matrix types_pkg.matrix_Q_ty := p_matrix;
l_count  integer := 1;
begin
  while l_count <= l_matrix (1).count
  loop 
    if   is_column_with_all_zeros (l_matrix, l_count)
	then l_matrix := matrix_Q_pkg.remove_column (l_matrix, l_count);
	else l_count := l_count + 1;
	end if;
  end loop;
  return l_matrix;
  
exception when others then
  util.show_error ('Error in function remove_all_zeros_columns.' , sqlerrm);
  return constants_pkg.empty_matrix;
end remove_all_zeros_columns;

/*************************************************************************************************************************************************/

--
-- NL: inproduct
-- dotproduct(a,b) = ||a|| * ||b|| cos (c)
--
function  dotproduct (p_vector1 in types_pkg.vector_Q_ty, p_vector2 in types_pkg.vector_Q_ty) return types_pkg.fraction_ty
is
l_dotproduct   types_pkg.fraction_ty := fractions_pkg.to_fraction (0);
begin
  if p_vector1.count != p_vector2.count
  then
    raise_application_error(-20004, 'Dimensions do not match. Dimension vector 1: ' || p_vector1.count || '. Dimension vector 2: '|| p_vector2.count || '.');
  end if; 

  for n in 1 .. p_vector1.count
  loop
    l_dotproduct := fractions_pkg.add (l_dotproduct, fractions_pkg.multiply(p_vector1 (n), p_vector2(n)));
  end loop;
  return l_dotproduct;

exception when others then
  util.show_error ('Error in function dotproduct.' , sqlerrm);
  return constants_pkg.empty_fraction;
end dotproduct;

/*************************************************************************************************************************************************/

--
-- NL: Uitproduct - kruisproduct
-- || crossproduct(a,b) || = || a || * || b || * sin (c)
--
function  crossproduct (p_vector1 in types_pkg.vector_Q_ty, p_vector2 in types_pkg.vector_Q_ty) return types_pkg.vector_Q_ty
is
l_vector   types_pkg.vector_Q_ty;
begin
  if p_vector1.count != 3 or p_vector2.count != 3
  then
    raise_application_error(-20004, 'Crossproduct only defined for dimension 3. Dimension vector 1 ' || p_vector1.count || '. Dimension vector 2: '|| p_vector2.count || '.');
  end if;
  l_vector(1) := fractions_pkg.subtract (fractions_pkg.multiply (p_vector1(2), p_vector2(3)), fractions_pkg.multiply (p_vector1(3), p_vector2(2)));
  l_vector(2) := fractions_pkg.subtract (fractions_pkg.multiply (p_vector1(3), p_vector2(1)), fractions_pkg.multiply (p_vector1(1), p_vector2(3)));
  l_vector(3) := fractions_pkg.subtract (fractions_pkg.multiply (p_vector1(1), p_vector2(2)), fractions_pkg.multiply (p_vector1(2), p_vector2(1)));
  return l_vector; 

exception when others then
  util.show_error ('Error in function crossproduct.' , sqlerrm);
  return constants_pkg.empty_vector;
end crossproduct;

/*************************************************************************************************************************************************/

--
-- Sum of diagonal elements
--
function  trace (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.fraction_ty
is
l_sum  types_pkg.fraction_ty := fractions_pkg.to_fraction (0);
begin
  if p_matrix (1).count != p_matrix.count
  then
    raise_application_error (-20004, 'Matrix not square. Dimensions do not match. Columns: ' || p_matrix (1).count || '. Rows: '|| p_matrix (1).count || '.');
  end if;

  for j in 1 .. p_matrix.count
  loop
    l_sum := fractions_pkg.add (l_sum, p_matrix (j)(j));
  end loop;
  return l_sum;

exception when others then
  util.show_error ('Error in function trace.' , sqlerrm);
  return constants_pkg.empty_fraction;
end trace;

/*************************************************************************************************************************************************/

--
-- Calculate least common multiple of all denominators
--
function lcm_denominator (p_matrix in types_pkg.matrix_Q_ty) return integer
is
l_lcm  integer := 1;
begin
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  l_lcm := maths.lcm (abs (p_matrix (n)(m).denominator), l_lcm);	  
	end loop;
  end loop;
  return l_lcm;

exception when others then
  util.show_error ('Error in Matrix function lcm_denominator.' , sqlerrm);
  return null;
end lcm_denominator;

/*************************************************************************************************************************************************/

--
-- Calculate least common multiple of all denominators
--
function  lcm_denominator (p_vector in types_pkg.vector_Q_ty) return integer
is
l_lcm  integer := 1;
begin
  for n in 1 .. p_vector.count
  loop
    l_lcm := maths.lcm (abs (p_vector (n).denominator), l_lcm);	  
  end loop;
  return l_lcm; 
  
exception when others then
  util.show_error ('Error in Vector function lcm_denominator.' , sqlerrm);
  return null;
end lcm_denominator;

/*************************************************************************************************************************************************/

--
-- Convert one row of a matrix to a vector
--
function  row_to_vector (p_matrix in types_pkg.matrix_Q_ty, p_row in pls_integer) return types_pkg.vector_Q_ty
is
begin
  return p_matrix (p_row);
  
exception when others then
  util.show_error ('Error in function row_to_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end row_to_vector;

/*************************************************************************************************************************************************/

--
-- Convert on column of a matrix to a vector
--
function  column_to_vector (p_matrix in types_pkg.matrix_Q_ty, p_column in pls_integer) return types_pkg.vector_Q_ty
is
begin
  return transpose (p_matrix) (p_column);
  
exception when others then
  util.show_error ('Error in function column_to_vector.' , sqlerrm);
  return constants_pkg.empty_vector;
end column_to_vector;

/*************************************************************************************************************************************************/

--
-- Gauss Jordan. Move row with zero down
--
function swap_row_with_zero_down (p_matrix in types_pkg.matrix_Q_ty, p_position pls_integer) return types_pkg.matrix_Q_ty
is 
l_matrix    types_pkg.matrix_Q_ty := p_matrix;
l_counter   pls_integer := p_position;
l_all_zero  boolean := true;
begin 
  if l_matrix (p_position) (p_position).numerator = 0
  then
    while l_counter < p_matrix.count and l_all_zero
      loop
	    l_counter  := l_counter + 1;
		if   p_matrix (l_counter)(p_position).numerator != 0
		then l_all_zero := false;
		     l_matrix   := swap_rows (p_matrix, p_position, l_counter);
		end if;
      end loop;
  end if;
  return l_matrix;

exception when others then
  util.show_error ('Error in function swap_row_with_zero_down.' , sqlerrm);
  return constants_pkg.empty_matrix;
end swap_row_with_zero_down;

/*************************************************************************************************************************************************/

--
-- Gauss Jordan.
--
function  subtract_row (p_matrix in types_pkg.matrix_Q_ty, p_row1 in pls_integer, p_row2 in pls_integer, p_factor in types_pkg.fraction_ty) return types_pkg.matrix_Q_ty
is 
l_matrix  types_pkg.matrix_Q_ty := p_matrix;
begin 
  for j in 1 .. p_matrix (1).count 
  loop
    l_matrix (p_row1)(j) :=  fractions_pkg.subtract (l_matrix (p_row1)(j), fractions_pkg.multiply (p_factor, l_matrix (p_row2)(j)));
  end loop;
  return l_matrix;

exception when others then
  util.show_error ('Error in function subtract_row.' , sqlerrm);
  return constants_pkg.empty_matrix;
end subtract_row;

/*************************************************************************************************************************************************/

--
-- Gauss Jordan.
--
function gauss_jordan_elimination (p_matrix in types_pkg.matrix_Q_ty) return types_pkg.matrix_Q_ty
is 
l_counter integer := 1;
l_matrix  types_pkg.matrix_Q_ty := p_matrix;
begin 
  -- Step 1. Convert to upper diagonal matrix
  l_matrix := matrix_Q_pkg.remove_all_zeros_rows (matrix_Q_pkg.remove_all_zeros_columns (l_matrix));
  while l_counter <= l_matrix.count  -- Run for each row in the matrix starting from that row.
  loop
	l_matrix := swap_row_with_zero_down (l_matrix, l_counter);
    if   l_matrix (l_counter) (l_counter).denominator != 0 and l_matrix (l_counter) (l_counter).numerator != 0
	then l_matrix := matrix_Q_pkg.multiply_row (l_matrix, l_counter, fractions_pkg.to_fraction ( l_matrix (l_counter) (l_counter).denominator,  l_matrix (l_counter) (l_counter).numerator));
      for j in l_counter + 1 .. l_matrix.count
	  loop
        if l_matrix (j) (l_counter).numerator != 0 then l_matrix := subtract_row (l_matrix, j, l_counter, l_matrix (j) (l_counter)); end if;
	  end loop;
	end if;
  l_matrix  := matrix_Q_pkg.remove_all_zeros_rows (matrix_Q_pkg.remove_all_zeros_columns (l_matrix));
  l_counter := l_counter + 1;
  end loop;

  -- Step 2. Remove non zero entries above the diagonal.
  l_counter := l_counter - 1;
  while l_counter >= 1
  loop
    if   l_matrix (l_counter) (l_counter).denominator != 0 and l_matrix (l_counter) (l_counter).numerator != 0
	then 
	  for j in 1 .. l_counter - 1
	  loop
	    if l_matrix (j)(l_counter).numerator != 0 then l_matrix := subtract_row (l_matrix, j, l_counter, l_matrix (j)(l_counter)); end if;
	  end loop;
  end if;
  l_counter := l_counter - 1;
  end loop;
  return l_matrix;
  
exception when others then
  util.show_error ('Error in function gauss_jordan_elimination.' , sqlerrm);
  return constants_pkg.empty_matrix;
end gauss_jordan_elimination;

/*************************************************************************************************************************************************/

--
-- Bridge to the Oracle internal package. Works only for integer values with denominator = 1.
--
function  matrix_to_utl_nla (p_matrix in types_pkg.matrix_Q_ty) return utl_nla_array_int
is 
l_counter integer := 0;
l_array   utl_nla_array_int;
begin
  for n in 1 .. p_matrix.count
  loop
    for m in 1 .. p_matrix (1).count
	loop
	  if p_matrix (n)(m).denominator != 1 then raise_application_error (-20001, 'Denominator not the UNIT value: ' || p_matrix (n)(m).denominator || '.'); end if;
	  l_counter := l_counter + 1;
	  l_array.extend;
	  l_array (l_counter) := p_matrix (n)(m).numerator;
	end loop;
  end loop;
  return l_array;

exception when others then
  util.show_error ('Error in function matrix_to_utl_nla.' , sqlerrm);
  return constants_pkg.empty_array;
end matrix_to_utl_nla;

/*************************************************************************************************************************************************/

--
-- Bridge from the Oracle internal package to this package.
--
--
function  utl_nla_to_matrix (p_array utl_nla_array_int, p_rows in integer) return types_pkg.matrix_Q_ty
is 
l_matrix  types_pkg.matrix_Q_ty;
l_cols    integer := p_array.count / p_rows;
begin
  if p_rows * l_cols != p_array.count then raise_application_error (-20001, 'Dimensions do not match. N:  ' || p_rows || '. M: ' || l_cols ||'.  #Elements: ' || p_array.count || '.'); end if;
  matrix_Q_pkg.init_matrix (l_matrix, p_rows, l_cols);
  for n in 0 .. p_rows - 1
  loop
    for m in 1 .. l_cols
	loop
	  l_matrix (n)(m) := fractions_pkg.to_fraction (p_array (n * p_rows + l_cols));
	end loop;
  end loop;
  return l_matrix;
  
exception when others then
  util.show_error ('Error in function utl_nla_to_matrix. N:  ' || p_rows || '. M: ' || l_cols ||'.' , sqlerrm);
  return constants_pkg.empty_matrix;
end utl_nla_to_matrix;

end matrix_Q_pkg;
/

SHOW ERROR

alter package matrix_Q_pkg compile;
select object_type, status from user_objects where object_name =  'MATRIX_Q_PKG';

