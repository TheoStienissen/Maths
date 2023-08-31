
-- Examples
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
set lines 200 pages 100

declare
matrix_b  matrix_pkg.matrix_ty;
point     matrix_pkg.point_ty := matrix_pkg.to_point (4, 3, 2);
begin
matrix_b := matrix_pkg.to_matrix (1,4,2,3,-1,-1,1,2,2);

matrix_pkg.print_point(point);
dbms_output.put_line('Determinant: ' || matrix_pkg.determinant(matrix_b));

matrix_pkg.print_matrix(matrix_b);
matrix_b := matrix_pkg.invert(matrix_b);
dbms_output.put_line('Inverse');
matrix_pkg.print_matrix(matrix_b);
matrix_b := matrix_pkg.invert(matrix_b);
dbms_output.put_line('Inverse ** 2');
matrix_pkg.print_matrix(matrix_b);

matrix_b := matrix_pkg.multiply(matrix_b, matrix_b);
dbms_output.put_line('B * B');
matrix_pkg.print_matrix(matrix_b);
matrix_b := matrix_pkg.multiply( 1/-70,matrix_b);
dbms_output.put_line('1/D * M');
matrix_pkg.print_matrix(matrix_b);

--matrix_b := matrix_pkg.multiply(matrix_a, matrix_b);
--matrix_pkg.print_matrix(matrix_b);

point :=  matrix_pkg.multiply (matrix_b, point);
matrix_pkg.print_point(point);
end;
/

declare
l_dim integer := 10;
begin
matrix_pkg.print_matrix(matrix_pkg.I(l_dim));
end;
/

declare
matrix_a  matrix_pkg.matrix_ty;
matrix_b  matrix_pkg.matrix_ty;
begin
matrix_b := matrix_pkg.to_matrix (2,0,0,1,0,2,4,2,4);
matrix_pkg.print_matrix(matrix_b);
matrix_pkg.save_matrix (matrix_b, 3);
matrix_pkg.print_matrix(matrix_b);
matrix_b := matrix_pkg.load_matrix(3);
matrix_pkg.print_matrix(matrix_b);
matrix_a := matrix_pkg.invert (matrix_b);
matrix_pkg.print_matrix(matrix_a);
matrix_pkg.print_matrix(matrix_pkg.transpose(matrix_a));
matrix_b := matrix_pkg.multiply(matrix_b, matrix_a);
matrix_pkg.print_matrix(matrix_b);
if  matrix_pkg.is_equal(matrix_b, matrix_pkg.I)
then dbms_output.put_line('Matrix B is identity matrix');
else dbms_output.put_line('Matrix B is NOT identity matrix');
end if;
end;
/

declare
matrix_a  matrix_pkg.matrix_ty;
matrix_b  matrix_pkg.matrix_ty;
begin
--matrix_b := matrix_pkg.to_matrix (2,0,0,1,0,2,4,2,4);
matrix_b := matrix_pkg.to_matrix (2,3,4,1);
matrix_pkg.print_matrix(matrix_b);
matrix_pkg.print_matrix(matrix_pkg.invert (matrix_b));
dbms_output.put_line('Det 1: ' || matrix_pkg.determinant(matrix_b));
matrix_a := matrix_pkg.invert(matrix_b);
matrix_pkg.print_matrix(matrix_a);
end;
/

declare 
matrix_a  matrix_pkg.matrix_ty;
matrix_b  matrix_pkg.matrix_ty;
l_array   matrix_pkg.line_ty;
l_a       number(8, 4) := 712;
l_b       number(8, 4) := 91;
l_a_save  number(8, 4);
l_b_save  number(8, 4);
l_dummy   number(8, 4);
l_idx     number(8) := 0;
begin
l_a_save := l_a;
l_b_save := l_b;
while l_a != 0
loop
  l_dummy        := l_a;
  l_idx          := l_idx + 1;
  l_array(l_idx) := trunc(l_b/l_a);
  l_a            := mod(l_b, l_a);
  l_b            := l_dummy;
end loop;
--
matrix_b := matrix_pkg.to_matrix_2D (1, 0, 0, 1);
for j in reverse 1 .. l_idx
loop
  matrix_a := matrix_pkg.to_matrix_2D (0, 1, 1, l_array(j));
  matrix_b := matrix_pkg.multiply(matrix_a, matrix_b);
end loop;
matrix_b := matrix_pkg.invert(matrix_b);
dbms_output.put_line('Product GCD: ' || matrix_b(2)(1) || ' * ' || l_a_save || ' + ' ||  matrix_b(2)(2) || ' * ' || l_b_save || ' = ' || to_char(matrix_b(2)(1)*l_a_save+matrix_b(2)(2)*l_b_save));
end;
/

==

declare 
l_matrix  matrix_pkg.matrix_ty;
l_array   matrix_pkg.line_ty;
l_a       matrix_pkg.point_ty := 767218;
l_b       matrix_pkg.point_ty := 4922;
l_a_save  matrix_pkg.point_ty;
l_b_save  matrix_pkg.point_ty;
l_dummy   matrix_pkg.point_ty;
l_idx     number(6) := 0;
begin
l_a_save := l_a;
l_b_save := l_b;
while l_a != 0
loop
  l_idx          := l_idx + 1;
  l_array(l_idx) := trunc(l_b / l_a);
  l_dummy        := l_a;
  l_a            := mod(l_b, l_a);
  l_b            := l_dummy;
end loop;
--
l_matrix := matrix_pkg.to_matrix_2D (1, 0, 0, 1);
for j in reverse 1 .. l_idx
loop
  l_matrix := matrix_pkg.multiply (matrix_pkg.to_matrix_2D (0, 1, 1, l_array(j)), l_matrix);
end loop;
--
l_matrix := matrix_pkg.invert(l_matrix);
dbms_output.put_line('Product LCM: ' || l_matrix(1)(1) || ' * ' || l_a_save || ' + ' || l_matrix(1)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(1)(1) * l_a_save + l_matrix(1)(2) * l_b_save) || '  (' ||
                     to_char(abs(l_matrix(1)(1)) * l_a_save) || ').');
dbms_output.put_line('Product GCD: ' || l_matrix(2)(1) || ' * ' || l_a_save || ' + ' || l_matrix(2)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(2)(1) * l_a_save + l_matrix(2)(2) * l_b_save));
end;
/

===

-- Coefficients of Bézout''s

a(n+1) := b(n) - [b(n) / a(n)] * a(n)
b(n+1) := a(n)

(a(n+1))  ( -[b(n) / a(n)]    1 )(a(n))
(b(n+1))  (   1               0 )(b(n))

declare 
l_matrix  matrix_pkg.matrix_ty := matrix_pkg.I(2); -- 2 * 2 Unitary matrix
l_a       matrix_pkg.point_ty  := 118011;
l_b       matrix_pkg.point_ty  := 4823199;
l_a_save  matrix_pkg.point_ty;
l_b_save  matrix_pkg.point_ty;
l_dummy   matrix_pkg.point_ty;
begin
l_a_save := l_a;
l_b_save := l_b;
while l_a != 0
loop
  l_matrix       := matrix_pkg.multiply (l_matrix, matrix_pkg.to_matrix_2D (0, 1, 1, trunc(l_b / l_a)));
  l_dummy        := l_a;
  l_a            := mod(l_b, l_a);
  l_b            := l_dummy;
end loop;
--
l_matrix := matrix_pkg.invert(l_matrix);
dbms_output.put_line('LCM : ' || l_matrix(1)(1) || ' * ' || l_a_save || ' + ' || l_matrix(1)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(1)(1) * l_a_save + l_matrix(1)(2) * l_b_save) || '  (' ||
                     to_char(abs(l_matrix(1)(1)) * l_a_save) || ').');
dbms_output.put_line('GCD : ' || l_matrix(2)(1) || ' * ' || l_a_save || ' + ' || l_matrix(2)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(2)(1) * l_a_save + l_matrix(2)(2) * l_b_save));
end;
/


==


create or replace function matrix_ggd_kgv(n in integer, m in integer) return matrix_pkg.matrix_ty
is
  l_matrix  matrix_pkg.matrix_ty := matrix_pkg.I(2); -- 2 * 2 Unitary matrix
  l_a       integer  := n;
  l_b       integer  := m;
  l_dummy   integer;
begin
while l_a != 0
loop
  l_matrix       := matrix_pkg.multiply (l_matrix, matrix_pkg.to_matrix_2D (0, 1, 1, trunc(l_b / l_a)));
  l_dummy        := l_a;
  l_a            := mod(l_b, l_a);
  l_b            := l_dummy;
end loop;
--
return matrix_pkg.invert(l_matrix);
end;
/


declare
l_matrix  matrix_pkg.matrix_ty;
l_gcd  integer;
l_lcm  integer;
begin
for n in 1 .. 1000
loop
  for m in n + 1 .. 1000
  loop
    l_matrix := matrix_ggd_kgv(n, m);
    l_gcd := l_matrix(2)(1) * n + l_matrix(2)(2) * m;
    l_lcm := abs(l_matrix(1)(1)) * n;
    if l_gcd != ggd(n,m)
    then
      matrix_pkg.print_matrix(l_matrix);
      dbms_output.put_line('GCD:  ' ||n || '  ' || m ||  '  ' || l_gcd || '  ' || l_lcm);
    end if;
    if l_lcm != kgv(n,m)
    then
      matrix_pkg.print_matrix(l_matrix);
      dbms_output.put_line('LCM:  ' || n || '  ' || m ||  '  ' || l_gcd || '  ' || l_lcm);
    end if;
  end loop;
end loop;
end;
/


dbms_output.put_line('LCM : ' || l_matrix(1)(1) || ' * ' || l_a_save || ' + ' || l_matrix(1)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(1)(1) * l_a_save + l_matrix(1)(2) * l_b_save) || '  (' ||
                     to_char(abs(l_matrix(1)(1)) * l_a_save) || ').');
dbms_output.put_line('GCD : ' || l_matrix(2)(1) || ' * ' || l_a_save || ' + ' || l_matrix(2)(2) || ' * ' || l_b_save || ' = ' || to_char(l_matrix(2)(1) * l_a_save + l_matrix(2)(2) * l_b_save));
