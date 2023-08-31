/*************************************************************************************************************************************************

Name:        utl_nla.sql
Created      October  2021
Last update  October  2022

Author:      Theo stienissen

E-mail:      theo.stienissen@gmail.com

Link:   @C:\Users\Theo\OneDrive\Theo\Project\Maths\Matrix\utl_nla.sql
-- N x M Matrix:
-- ( 11   ...    1m )
--        ...
-- ( n1   ...    nm )
--


-- Blas1 vector --> vector
-- Blas2 Matrix-Vector Operations
-- Blas3 Matrix-Matrix Operations

Todo:

*************************************************************************************************************************************************/

set serveroutput on size unlimited

create or replace package nla_pkg
is 
g_format  constant varchar2(10) := '9990.99999';

procedure print_heading (p_text in varchar2);

function I_flt (p_with in integer default 3) return utl_nla_array_flt;
function I_dbl (p_with in integer default 3) return utl_nla_array_dbl;

procedure print_matrix (p_array in utl_nla_array_flt, p_with in integer default 3, p_show_index in boolean default true);
procedure print_matrix (p_array in utl_nla_array_dbl, p_with in integer default 3, p_show_index in boolean default true);
procedure print_matrix (p_array in utl_nla_array_int, p_with in integer default 3, p_show_index in boolean default true);

procedure print_debug (p_array in utl_nla_array_flt);  -- type utl_nla_array_flt is varray(1000000) of binary_float
procedure print_debug (p_array in utl_nla_array_dbl);  -- type utl_nla_array_dbl is varray(1000000) of binary_double
procedure print_debug (p_array in utl_nla_array_int);  -- type utl_nla_array_int is varray(1000000) of integer

function inverse (p_array in utl_nla_array_flt, p_with in integer) return utl_nla_array_flt;
function inverse (p_array in utl_nla_array_dbl, p_with in integer) return utl_nla_array_dbl;
-- function inverse (p_array in utl_nla_array_int, p_with in integer) return utl_nla_array_int;

function solve_equation (p_matrix in utl_nla_array_flt, p_vector in utl_nla_array_flt) return utl_nla_array_flt;
function solve_equation (p_matrix in utl_nla_array_dbl, p_vector in utl_nla_array_dbl) return utl_nla_array_dbl;
end nla_pkg;
/

create or replace package body nla_pkg
is 
procedure print_heading (p_text in varchar2)
is
begin
  dbms_output.put_line (chr(10));
  dbms_output.put_line ('--');
  dbms_output.put_line ('-- ' || p_text);
  dbms_output.put_line ('--');

exception when others then
  util.show_error ('Error in procedure print_heading.' , sqlerrm);
end print_heading;

/*************************************************************************************************************************************************/

function I_flt (p_with in integer default 3) return utl_nla_array_flt
is 
l_I utl_nla_array_flt := utl_nla_array_flt ();
begin 
  for n in 1 .. p_with
  loop 
    for m in 1 .. p_with
	loop 
	  l_I.extend;
	  l_I ((n - 1) * p_with + m) := case when n = m then 1 else 0 end;
	end loop;  
  end loop;
  return l_I;

exception when others then
  util.show_error ('Error in function I 1.' , sqlerrm);
end I_flt;

/*************************************************************************************************************************************************/

function I_dbl (p_with in integer default 3) return utl_nla_array_dbl
is
l_I utl_nla_array_dbl := utl_nla_array_dbl ();
begin 
  for n in 1 .. p_with
  loop 
    for m in 1 .. p_with
	loop 
	  l_I.extend;
	  l_I ((n - 1) * p_with + m) := case when n = m then 1 else 0 end;
	end loop;  
  end loop;
  return l_I;

exception when others then
  util.show_error ('Error in function I 2.' , sqlerrm);
end I_dbl;

/*************************************************************************************************************************************************/

procedure show_linebreak (p_padding in varchar2 default '*', p_with in integer default 40)
is 
begin 
   dbms_output.put_line (rpad (p_padding, p_with, p_padding));

exception when others then
  util.show_error ('Error in procedure show_linebreak.' , sqlerrm);
end show_linebreak;

/*************************************************************************************************************************************************/

procedure print_debug (p_array in utl_nla_array_flt)
is
begin
   show_linebreak;
   for i in 1 .. p_array.count
   loop
     dbms_output.put_line ('Array(' || i ||') = ' || to_char (p_array(i), g_format));
   end loop;
   show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_debug 1.' , sqlerrm);
end print_debug;

/*************************************************************************************************************************************************/

procedure print_debug (p_array in utl_nla_array_dbl)
is
begin
   show_linebreak;
   for i in 1 .. p_array.count
   loop
     dbms_output.put_line ('Array(' || i ||') = ' || to_char (p_array(i), g_format));
   end loop;
   show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_debug 2.' , sqlerrm);
end print_debug;

/*************************************************************************************************************************************************/

procedure print_debug (p_array in utl_nla_array_int)
is
begin
   show_linebreak;
   for i in 1 .. p_array.count
   loop
     dbms_output.put_line ('Array(' || i ||') = ' || to_char (p_array(i), g_format));
   end loop;
   show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_debug 3.' , sqlerrm);
end print_debug;

/*************************************************************************************************************************************************/

procedure print_matrix (p_array in utl_nla_array_dbl, p_with in integer default 3, p_show_index in boolean default true)
is
i pls_integer;
j pls_integer;
begin
  show_linebreak;
  for p in 1 .. p_array.count
  loop
    i := ceil (p / p_with);
    j := p - (i - 1) * p_with;
	if p_show_index	then dbms_output.put ('i[' || i || '][' || j || ']= '); end if;
	dbms_output.put (to_char (p_array(p), g_format));
	if mod (p, p_with) = 0 then dbms_output.new_line; else dbms_output.put ('   '); end if;
  end loop;
  show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_matrix 1.' , sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

procedure print_matrix (p_array in utl_nla_array_flt, p_with in integer default 3, p_show_index in boolean default true)
is
i pls_integer;
j pls_integer;
begin
  show_linebreak;
  for p in 1 .. p_array.count
  loop
    i := ceil (p / p_with);
    j := p - (i - 1) * p_with;
	if p_show_index	then dbms_output.put ('i[' || i || '][' || j || ']= '); end if;
	dbms_output.put (to_char (p_array(p), g_format));
	if mod (p, p_with) = 0 then dbms_output.new_line; else dbms_output.put ('   '); end if;
  end loop;
  show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_matrix 2.' , sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

procedure print_matrix (p_array in utl_nla_array_int, p_with in integer default 3, p_show_index in boolean default true)
is
i pls_integer;
j pls_integer;
begin
  show_linebreak;
  for p in 1 .. p_array.count
  loop
    i := ceil (p / p_with);
    j := p - (i - 1) * p_with;
	if p_show_index	then dbms_output.put ('i[' || i || '][' || j || ']= '); end if;
	dbms_output.put (to_char (p_array(p), g_format));
    if mod (p, p_with) = 0 then dbms_output.new_line; else dbms_output.put ('   '); end if;
  end loop;
  show_linebreak;

exception when others then
  util.show_error ('Error in procedure print_matrix 3.' , sqlerrm);
end print_matrix;

/*************************************************************************************************************************************************/

function inverse  (p_array in utl_nla_array_flt, p_with in integer) return utl_nla_array_flt
is 
  l_return utl_nla_array_flt := utl_nla_array_flt ();  -- Identity matrix
  l_ipiv   utl_nla_array_int := utl_nla_array_int ();
  l_array  utl_nla_array_flt := p_array;
  l_info   integer;
  l_dim    pls_integer := sqrt (p_array.count);
begin  
if p_with = l_dim
then
  for n in 1 .. l_dim
  loop 
    l_ipiv.extend;
    l_ipiv (n) := 0;
  end loop;
  l_return := I_flt (l_dim);
  
  utl_nla.lapack_gels (
    trans  => 'N',      -- solve for A instead of A'
    m      => l_dim,    -- a number of rows 
    n      => l_dim,    -- a number of columns
    nrhs   => l_dim,    -- b number of columns
    a      => l_array,  -- matrix a
    lda    => l_dim,    -- max(1, m)
    b      => l_return, -- matrix b
    ldb    => l_dim,    -- ldb >= max(1, m, n)
    info   => l_info,   -- operation status (0 = sucess)
    pack   => 'R');     -- how the matrices are stored (C=column-wise)

  if l_info = 0
  then return l_return;
  else raise_application_error (-20001, 'Procecure returned error: ' || l_info);
  end if;
end if;
  return null;

exception when others then
  util.show_error ('Error in function inverse 1.' , sqlerrm);
end inverse;

/*************************************************************************************************************************************************/

function inverse  (p_array in utl_nla_array_dbl, p_with in integer) return utl_nla_array_dbl
is 
  l_return utl_nla_array_dbl := utl_nla_array_dbl (); -- Identity matrix
  l_ipiv   utl_nla_array_int := utl_nla_array_int ();
  l_array  utl_nla_array_dbl := p_array;
  l_info   integer;
  l_dim    pls_integer := sqrt (p_array.count);
begin  
if p_with = l_dim
then  
  for n in 1 .. l_dim
  loop 
    l_ipiv.extend;
    l_ipiv (n) := 0;
  end loop;
  l_return := I_dbl (l_dim);
  
  utl_nla.lapack_gels (
    trans  => 'N',      -- solve for A instead of A'
    m      => l_dim,    -- a number of rows 
    n      => l_dim,    -- a number of columns
    nrhs   => l_dim,    -- b number of columns
    a      => l_array,  -- matrix a
    lda    => l_dim,    -- max(1, m)
    b      => l_return, -- matrix b
    ldb    => l_dim,    -- ldb >= max(1, m, n)
    info   => l_info,   -- operation status (0 = sucess)
    pack   => 'R');     -- how the matrices are stored (C=column-wise)

  if l_info = 0
  then return l_return;
  else raise_application_error (-20001, 'Procecure returned error: ' || l_info);
  end if;
end if;
  return null;	

exception when others then
  util.show_error ('Error in function inverse 2.' , sqlerrm);
end inverse;

/*************************************************************************************************************************************************/

-- This procedure computes the solution to a real system of linear equations A*X=B where A is an n by n matrix
-- and X and B are n by 1 matrices.
function solve_equation (p_matrix in utl_nla_array_flt, p_vector in utl_nla_array_flt) return utl_nla_array_flt
is 
  l_dim    integer := sqrt (p_matrix.count);
  l_info   integer;
  l_ipiv   utl_nla_array_int := utl_nla_array_int ();
  l_matrix utl_nla_array_flt := p_matrix;
  l_vector utl_nla_array_flt := p_vector;
begin 
if p_matrix.count = l_dim * l_dim
then
  for n in 1 .. l_dim
  loop 
    l_ipiv.extend;
    l_ipiv (n) := 0;
  end loop;
  
  utl_nla.lapack_gesv (
    n      => l_dim,       -- a number of rows and columns
    nrhs   => 1,           -- b number of columns
    a      => l_matrix,    -- matrix a
    lda    => l_dim,       -- max(1, n)
    ipiv   => l_ipiv,      -- pivot indices (set to zeros)
    b      => l_vector,    -- matrix b
    ldb    => l_dim,       -- ldb >= max(1,n)
    info   => l_info,      -- operation status (0 = sucess)
    pack   => 'C');        -- how the matrices are stored (C=column-wise)

  if l_info = 0
  then return l_vector;
  else raise_application_error (-20001, 'Procecure returned error: ' || l_info);
  end if;
end if;
  return null;	

exception when others then
  util.show_error ('Error in function solve_equation 1.' , sqlerrm);
end solve_equation;

/*************************************************************************************************************************************************/

-- This procedure computes the solution to a real system of linear equations A*X=B where A is an n by n matrix
-- and X and B are n by 1 matrices.
function solve_equation (p_matrix in utl_nla_array_dbl, p_vector in utl_nla_array_dbl) return utl_nla_array_dbl
is 
  l_dim    integer := sqrt (p_matrix.count);
  l_info   integer;
  l_ipiv   utl_nla_array_int := utl_nla_array_int ();
  l_matrix utl_nla_array_dbl := p_matrix;
  l_vector utl_nla_array_dbl := p_vector;
begin 
if p_matrix.count = l_dim * l_dim
then
  for n in 1 .. l_dim
  loop 
    l_ipiv.extend;
    l_ipiv (n) := 0;
  end loop;
  
  utl_nla.lapack_gesv (
    n      => l_dim,       -- a number of rows and columns
    nrhs   => 1,           -- b number of columns
    a      => l_matrix,    -- matrix a
    lda    => l_dim,       -- max(1, n)
    ipiv   => l_ipiv,      -- pivot indices (set to zeros)
    b      => l_vector,    -- matrix b
    ldb    => l_dim,       -- ldb >= max(1,n)
    info   => l_info,      -- operation status (0 = sucess)
    pack   => 'C');        -- how the matrices are stored (C=column-wise)
	
  if l_info = 0
  then return l_vector;
  else raise_application_error (-20001, 'Procecure returned error: ' || l_info);
  end if;
end if;
  return null;

exception when others then
  util.show_error ('Error in function solve_equation 2.' , sqlerrm);
end solve_equation;
end nla_pkg;
/

-- Inverse matrix
declare
  a     utl_nla_array_dbl :=  utl_nla_array_dbl(
               5,   153,  352, 
               153, 5899, 9697,
               352, 9697, 26086);
  b utl_nla_array_dbl;
begin 
  b := nla_pkg.inverse (a, 3);
  nla_pkg.print_matrix (b, 3);
end;  
/

-- Solve linear equations		   
declare
  a     utl_nla_array_dbl := utl_nla_array_dbl (1, 300, 1, 675);
  b     utl_nla_array_dbl := utl_nla_array_dbl (7, 2850);
begin  
  b := nla_pkg.solve_equation (a, b);
  nla_pkg.print_debug (b);
end;
/


-- https://en.wikipedia.org/wiki/Polynomial_regression
-- Transpose Matrix
-- m : Specifies the number of rows of the matrix A.
-- n : Specifies the number of columns of the matrix B.
-- k : Specifies dimension of the kernel
declare
l_matrix1  utl_nla_array_dbl :=  utl_nla_array_dbl(
               5,  153, 352, 
               15,  58,  97,
               52, 967,  26);
 l_matrix2 utl_nla_array_dbl :=  utl_nla_array_dbl();
l_dim integer := 3;
l_ipiv   utl_nla_array_dbl := utl_nla_array_dbl ();
I        utl_nla_array_dbl := utl_nla_array_dbl ();
begin
  for n in 1 .. l_dim
  loop 
    l_ipiv.extend;
    l_ipiv (n) := 0;
    for m in 1 .. l_dim
	loop 
	  I.extend;
	  I ((n - 1) * l_dim + m) := case when n = m then 1 else 0 end;
	end loop;  
  end loop;
  nla_pkg.print_matrix (l_matrix1, 3);
  utl_nla.blas_gemm( transa => 'T',  transb => 'N',  m => 3, n => 3, k => 3,  alpha => 1.0,
                      a => l_matrix1, lda => 3,  b => I, ldb => 3, beta => 0.0, c => l_matrix2, ldc => 3, pack => 'R');
  nla_pkg.print_matrix (l_matrix2, 3);
end;  

-----------------
-- http://oracledmt.blogspot.com/2007/04/way-cool-linear-algebra-in-oracle.html
-- https://docs.oracle.com/database/121/ARPLS/u_nla.htm#ARPLS71276

/*subtype scalar_double is binary_double not null;
subtype scalar_float is binary_float not null;
subtype flag is char(1) not null;

LAPACK Driver Routines (Linear Equations) Subprograms. LLS and Eigenvalue Problems

-------------------------------------------------------

BLAS_ASUM Functions: This procedure computes the sum of the absolute values of the vector components.

BLAS_AXPY Procedures: This procedure copies alpha*X + Y into vector Y.
*/

set serveroutput on size unlimited
declare
l_matrix1  utl_nla_array_dbl   := utl_nla_array_dbl (1, 2, 3, 4, 5, 6, 7, 8, 9);
l_matrix2  utl_nla_array_dbl   := utl_nla_array_dbl (5, 6, 7, 8, 9, 6.6, 7.7, 8.8, 9.9);
l_res_matrix utl_nla_array_dbl := utl_nla_array_dbl (0, 0, 0, 0, 0, 0, 0, 0, 0);
l_result  binary_double;
begin
-- Print vector
nla_pkg.print_heading('Print vector');
nla_pkg.print_debug(l_matrix1);

-- BLAS_COPY Procedures: This procedure copies the first 6 positions of vector X to vector Y.
utl_nla.blas_copy ( 6, l_matrix1, 1, l_res_matrix, 1);
nla_pkg.print_heading ('Copy vector');
nla_pkg.print_debug (l_res_matrix);

-- BLAS_AXPY Procedures: This procedure copies alpha*X + Y into vector Y. #elements, factor, x-vector, incr, result
utl_nla.blas_axpy ( 6, 2, l_matrix1, 1, l_res_matrix, 1);
nla_pkg.print_heading ('y = A x. Copies alpha * X + Y');
-- nla_pkg.print_debug(l_res_matrix);
nla_pkg.print_matrix (l_res_matrix, 3);

-- BLAS_ASUM. This procedure computes the sum of the absolute values of the first 6 vector components.
l_result := utl_nla.blas_asum (6, l_matrix1, 1);
nla_pkg.print_heading ('Absolute sum: ' || to_char (l_result, '999G999G990D999999999'));

-- BLAS_DOT Functions: This function returns the dot (scalar) product of two vectors X and Y.
l_result := utl_nla.blas_dot (3, l_matrix1, 1, l_matrix2, 1);
nla_pkg.print_heading ('Dot product: ' || to_char (l_result, '999G999G990D999999999'));

-- Matrix multiplication
-- m : Specifies the number of rows of the matrix A.
-- n : Specifies the number of columns of the matrix B.
-- k : Specifies dimension of the kernel
utl_nla.blas_gemm ( transa => 'N',  transb => 'N',  m => 3, n => 3, k => 3,  alpha => 1.0,
                      a => l_matrix1, lda => 3,  b => l_matrix2, ldb => 3, beta => 0.0, c => l_res_matrix, ldc => 3, pack => 'R');
nla_pkg.print_heading ('Matrix product');
nla_pkg.print_matrix (l_res_matrix, 3);

-- BLAS_SCAL Procedure This procedure scales a vector by a constant (3).
utl_nla.blas_scal(6, 3, l_matrix2, 1);
nla_pkg.print_heading ('Matrix scaling');
nla_pkg.print_matrix (l_res_matrix, 3);

-- BLAS_SWAP Procedure This procedure swaps the contents of two vectors each of size n.
nla_pkg.print_matrix (l_matrix1, 3);
nla_pkg.print_matrix (l_matrix2, 3);
utl_nla.blas_swap (9, l_matrix1, 1, l_matrix2, 1);
nla_pkg.print_matrix (l_matrix1, 3);
nla_pkg.print_matrix (l_matrix2, 3);
end;
/

-- Step 1 Fit to degree 2 polynomal. First get some data.
-- https://neutrium.net/mathematics/least-squares-fitting-of-a-polynomial/
drop table test;
create table test ( x number (6,2), y number (6,2));
insert into test values (-3, 0.9);
insert into test values (-2, 0.8);
insert into test values (-1, 0.4);
insert into test values (-0.2, 0.2);
insert into test values (1, 0.1);
insert into test values (3, 0);
commit;

declare
type nr_ty is table of number index by binary_integer;
l_nr_array nr_ty;
-- type nr_array 
l_matrix       matrix_pkg.matrix_ty;
l_point        matrix_pkg.point_ty_3D;
l_count integer := 3;
function power_sum (p_depth in integer) return number 
is
l_sum    number;
begin 
select sum(power(x, p_depth)) into l_sum from test;
return l_sum;
end power_sum;
--
function power_xy (p_depth in integer) return number 
is
l_sum    number;
begin 
  select sum (power (x, p_depth) * y) into l_sum from test;
  return l_sum;
end power_xy;
--
begin 
--select count(*) into l_count from test;
matrix_pkg.init_matrix (l_matrix, l_count, l_count);
for m in 1 .. l_count
loop
  l_nr_array (m) := power_xy (m - 1);
  for n in m .. l_count
  loop
    l_matrix (m)(n) := power_sum (n + m - 2);
	l_matrix (n)(m) := l_matrix (m)(n);
  end loop;
end loop;

matrix_pkg.print_matrix(l_matrix);
l_matrix := matrix_pkg.invert (l_matrix);
matrix_pkg.print_matrix(l_matrix);

l_point.x_c := l_nr_array (1);
l_point.y_c := l_nr_array (2);
l_point.z_c := l_nr_array (3);

l_point := matrix_pkg.multiply_3D (l_matrix, l_point);
matrix_pkg.print_point_3D (l_point);
end;

------------------------------------------

-- Least square
x   y   xy  x ** 2
select job_id,
regr_slope(sysdate-hire_date, salary) slope,
regr_intercept(sysdate-hire_date, salary) intercept
   from employees
   where department_id in (50,80)
   group by job_id
   order by job_id;
JOB_ID          SLOPE  INTERCEPT
---------- ---------- ----------
JOB_ID     SLOPE    INTERCEPT
---------- ----- ------------
SA_MAN      .355 -1707.030762
SA_REP      .257   404.767151
SH_CLERK    .745   159.015293
ST_CLERK    .904   134.409050
ST_MAN      .479  -570.077291


shw parameter dispatchers
select dbms_xdb_config.gethttpsport from dual;
exec dbms_xdb_config.setglobalportenabled(true)
exec dbms_xdb_config.sethttpsport(5500)


https://en.wikipedia.org/wiki/Polynomial_regression

http://www.netlib.org/blas/   (Basic Linear Algebra Subprograms) 
http://www.netlib.org/lapack/ (Linear Algebra PACKage)


BLAS Level 1 (Vector-Vector Operations) Subprograms
BLAS Level 2 (Matrix-Vector Operations) Subprograms
BLAS Level 3 (Matrix-Matrix Operations) Subprograms
LAPACK Driver Routines (Linear Equations) Subprograms
LAPACK Driver Routines (LLS and Eigenvalue Problems) Subprograms62

https://education.oracle.com/oracle-database-administration-2019-certified-professional-upgrade-from-10g-11g-12c-12cr2-ocp/trackp_DB19COCP_Upgrade

type utl_na_rec is record (nla_array utl_nla_array_dbl, columns in integer, rows in integer;

-- Also for float
-- Dimensions keep out of the conversion routine.
--
function matrix_to_utl_na (p_matrix in matrix_ty) return utl_nla_array_dbl
is 
  l_array utl_nla_array_dbl := utl_nla_array_dbl ();
  l_count integer := 0;
begin 
for m in 1 .. p_matrix.count
loop 
  for n in 1 .. p_matrix(1).count
  loop 
    l_count := l_count + 1;
    l_array.extend;
    l_array (l_count) := p_matrix (m)(n);
  end loop;
end loop;
  return l_array;
end matrix_to_utl_na;

function utl_na_to_matrix (p_array in utl_nla_array_dbl, p_columns in integer) return matrix_ty
is 
  l_matrix matrix_ty;
begin 
matrix_pkg.init_matrix(p_columns, p_array.count/p_columns);

for i in 1 .. p_array.count 
loop 
  l_matrix (ceil (i / p_columns), mod (i - 1, p_columns) + 1) := p_array (i);
end loop;
  return l_matrix;
end utl_na_to_matrix;

