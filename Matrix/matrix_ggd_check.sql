set serveroutput on size unlimited

declare
l_a integer := 921;
l_b integer := 492;
l_matrix  matrix_pkg.matrix_ty := matrix_pkg.I(2); -- 2 * 2 Unitary matrix
l_matrix2 matrix_pkg.matrix_ty; 
l_point   matrix_pkg.point_ty_2D;
l_point2  matrix_pkg.point_ty_2D;
l_dummy   integer;
begin
l_point2 :=  matrix_pkg.to_point_2D(l_a, l_b);  -- Save initial pair
-- Euclid
while l_a != 0
loop
  dbms_output.put_line  ( 'Pair ' || l_a || ', ' || l_b);
  l_point :=  matrix_pkg.to_point_2D (l_a, l_b);
  matrix_pkg.print_point_2D (l_point);
--
  l_matrix2      := matrix_pkg.to_matrix_2D (-trunc(l_b / l_a), 1, 1, 0);
  l_matrix       := matrix_pkg.multiply (l_matrix2, l_matrix);
  dbms_output.put_line ( '--');
  dbms_output.put_line ( '-- Multiplied matrices. Determinant: ' || matrix_pkg.determinant(l_matrix));
  matrix_pkg.print_matrix(l_matrix);
  dbms_output.put_line( '--');
-- Switch values
  l_dummy        := l_a;
  l_a            := mod (l_b, l_a);
  l_b            := l_dummy;
end loop;

  dbms_output.put_line ( 'Final pair ' || l_a || ', ' || l_b);
  l_point2 := matrix_pkg.multiply_2D (l_matrix, l_point2);
  matrix_pkg.print_point_2D(l_point2);

-- Back to the original values
  dbms_output.put_line( '--');
  dbms_output.put_line( '--');
  l_matrix2 := matrix_pkg.invert(l_matrix);
  dbms_output.put_line( 'Inverse. Determinant: ' || matrix_pkg.determinant(l_matrix2));
  matrix_pkg.print_matrix(l_matrix2);
  l_point := matrix_pkg.multiply_2D (l_matrix2, matrix_pkg.to_point_2D (l_a, l_b));
  matrix_pkg.print_point_2D(l_point);
end;
/

-------------------------------------------------------------


create or replace function f_matrix_kgv (p_n in integer, p_m in integer) return integer
is
l_a integer := p_n;
l_b integer := p_m;
l_matrix    matrix_pkg.matrix_ty := matrix_pkg.I(2); -- 2 * 2 Unitary matrix
l_dummy     integer;
begin
-- Euclid
while l_a != 0
loop
  l_matrix       := matrix_pkg.multiply (matrix_pkg.to_matrix_2D (-trunc(l_b / l_a), 1, 1, 0), l_matrix);

-- Switch values
  l_dummy        := l_a;
  l_a            := mod (l_b, l_a);
  l_b            := l_dummy;
end loop;
  return  abs(l_matrix(1)(1) * p_n);
end f_matrix_kgv;
/


declare
l_a integer;
l_b integer;
begin
for j in 1 .. 1000000
loop
  l_a := trunc(dbms_random.value(1000, 10000000));
  l_b := trunc(dbms_random.value(1000, 10000000));
  if maths.lcm(l_a, l_b) != f_matrix_kgv(l_a, l_b)
  then
    dbms_output.put_line ( 'Pair: ' || l_a || ', ' || l_b); 
  end if;
end loop;
end;
/


