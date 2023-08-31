set serveroutput on size unlimited
declare
l_matrix     matrix_Q_pkg.matrix_Q_ty;
l_point_2d   matrix_Q_pkg.point_Q_ty_2D;
l_point_3d   matrix_Q_pkg.point_Q_ty_3D;
l_vector     matrix_Q_pkg.vector_Q_ty;
l_fraction1  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 25);
l_fraction2  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction3  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction4  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction5  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 25);
l_fraction6  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction7  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction8  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction9  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
begin
-- Init matrix
dbms_output.put_line ('-- Matrix with zeros');
matrix_Q_pkg.I (8);
matrix_Q_pkg.print_matrix (l_matrix);
-- Identity matrix
dbms_output.put_line ('-- Identity matrix');
l_matrix := matrix_Q_pkg.I;
matrix_Q_pkg.print_matrix (l_matrix);
-- 2D point
dbms_output.put_line ('-- Two dimensional point');
l_point_2d := matrix_Q_pkg.to_point_Q_2D (l_fraction1,l_fraction2);
matrix_Q_pkg.print_point_2D (l_point_2d);
-- 3D point
dbms_output.put_line ('-- Three dimensional point');
l_point_3d := matrix_Q_pkg.to_point_Q_3D (l_fraction1,l_fraction2, l_fraction3);
matrix_Q_pkg.print_point_3D (l_point_3d);
-- Vector conversion and print
dbms_output.put_line ('-- Vector management');
l_vector := matrix_Q_pkg.to_vector (l_fraction1,l_fraction2, l_fraction3);
matrix_Q_pkg.print_vector (l_vector);
-- Two dimensional matrix
dbms_output.put_line ('-- Two dimensional matrix');
l_matrix :=  matrix_Q_pkg.to_matrix_Q_2D  (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
matrix_Q_pkg.print_matrix (l_matrix);
-- Three dimensional matrix
dbms_output.put_line ('-- Three dimensional matrix');
l_matrix :=  matrix_Q_pkg.to_matrix_Q_3D (l_fraction1,l_fraction2, l_fraction3, l_fraction4, l_fraction5,l_fraction6, l_fraction7, l_fraction8, l_fraction9);
matrix_Q_pkg.print_matrix (l_matrix);
-- mirror xy
dbms_output.put_line ('-- Mirror xy');
l_matrix :=  matrix_Q_pkg.mirror_xy (l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
-- Add row
dbms_output.put_line ('-- Add row');
l_matrix :=  matrix_Q_pkg.add_row (l_matrix, 1, l_vector);
matrix_Q_pkg.print_matrix (l_matrix);
-- Add column
dbms_output.put_line ('-- Add column');
l_vector := matrix_Q_pkg.to_vector (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
l_matrix :=  matrix_Q_pkg.add_column (l_matrix, 3, l_vector);
matrix_Q_pkg.print_matrix (l_matrix);
-- Remove row
dbms_output.put_line ('-- Remove row');
l_matrix :=  matrix_Q_pkg.remove_row (l_matrix, 2);
matrix_Q_pkg.print_matrix (l_matrix);
-- Remove column
dbms_output.put_line ('-- Remove column');
l_matrix :=  matrix_Q_pkg.remove_column (l_matrix, 2);
matrix_Q_pkg.print_matrix (l_matrix);
end;
/

declare
l_fraction   types_pkg.fraction_ty;
l_matrix     matrix_Q_pkg.matrix_Q_ty;
l_matrix2    matrix_Q_pkg.matrix_Q_ty;
l_point_2d   matrix_Q_pkg.point_Q_ty_2D;
l_point_3d   matrix_Q_pkg.point_Q_ty_3D;
l_vector     matrix_Q_pkg.vector_Q_ty;
l_fraction1  types_pkg.fraction_ty := fractions_pkg.to_fraction(111, 13);
l_fraction2  types_pkg.fraction_ty := fractions_pkg.to_fraction(2, 1);
l_fraction3  types_pkg.fraction_ty := fractions_pkg.to_fraction(3, 1);
l_fraction4  types_pkg.fraction_ty := fractions_pkg.to_fraction(41, 17);
l_fraction5  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 25);
l_fraction6  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction7  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction8  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction9  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
begin
-- Two dimensional matrix
dbms_output.put_line ('-- Two dimensional matrix');
l_matrix :=  matrix_Q_pkg.to_matrix_Q_2D  (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
matrix_Q_pkg.print_matrix (l_matrix);
-- Determinant
dbms_output.put_line ('-- Determinant');
l_fraction := matrix_Q_pkg.determinant (l_matrix);
fractions_pkg.print (l_fraction);
-- Inverse 
dbms_output.put_line ('-- Inverse');
l_matrix2 := matrix_Q_pkg.invert (l_matrix);
matrix_Q_pkg.print_matrix (matrix_Q_pkg.invert (l_matrix));
-- Adjugate
dbms_output.put_line ('-- Adjugate:  ');
l_matrix :=  matrix_Q_pkg.adjugate (l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
-- Matrix multiplication
dbms_output.put_line ('-- Matrix multiplication');
l_matrix :=  matrix_Q_pkg.multiply (l_matrix, l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
-- Transpose
dbms_output.put_line ('-- Transpose');
l_matrix :=  matrix_Q_pkg.to_matrix_Q_3D (l_fraction1,l_fraction2, l_fraction3, l_fraction4, l_fraction5,l_fraction6, l_fraction7, l_fraction8, l_fraction9);
matrix_Q_pkg.print_matrix (l_matrix);
l_fraction := matrix_Q_pkg.determinant (l_matrix);
dbms_output.put ('-- Determinant:  '); fractions_pkg.print (l_fraction);
l_matrix :=  matrix_Q_pkg.transpose (l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
l_fraction := matrix_Q_pkg.determinant (l_matrix);
dbms_output.put ('-- Determinant:  '); fractions_pkg.print (l_fraction);
end;
/

set serveroutput on size unlimited
declare
l_fraction   types_pkg.fraction_ty;
l_matrix     matrix_Q_pkg.matrix_Q_ty;
l_matrix2    matrix_Q_pkg.matrix_Q_ty;
l_point_2d   matrix_Q_pkg.point_Q_ty_2D;
l_point_3d   matrix_Q_pkg.point_Q_ty_3D;
l_vector     matrix_Q_pkg.vector_Q_ty;
l_fraction1  types_pkg.fraction_ty := fractions_pkg.to_fraction(111, 13);
l_fraction2  types_pkg.fraction_ty := fractions_pkg.to_fraction(2, 1);
l_fraction3  types_pkg.fraction_ty := fractions_pkg.to_fraction(3, 1);
l_fraction4  types_pkg.fraction_ty := fractions_pkg.to_fraction(41, 17);
l_fraction5  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 25);
l_fraction6  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction7  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction8  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction9  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
begin
-- Two dimensional matrix
dbms_output.put_line ('-- Two dimensional matrix');
l_matrix :=  matrix_Q_pkg.to_matrix_Q_2D  (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
matrix_Q_pkg.print_matrix (l_matrix);
-- Adjugate
dbms_output.put_line ('-- Adjugate:  ');
l_matrix :=  matrix_Q_pkg.adjugate (l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
-- Determinant
dbms_output.put_line ('-- Determinant');
l_fraction := matrix_Q_pkg.determinant (l_matrix);
fractions_pkg.print (l_fraction);
l_fraction := fractions_pkg.divide (fractions_pkg.to_fraction(1, 1), l_fraction);
fractions_pkg.print (l_fraction);
l_matrix := matrix_Q_pkg.multiply (l_fraction, l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
end;
/

declare
l_fraction   types_pkg.fraction_ty;
l_matrix     types_pkg.matrix_Q_ty;
l_matrix2    types_pkg.matrix_Q_ty;
l_fraction1  types_pkg.fraction_ty := fractions_pkg.to_fraction(111, 13);
l_fraction2  types_pkg.fraction_ty := fractions_pkg.to_fraction(2, 19);
l_fraction3  types_pkg.fraction_ty := fractions_pkg.to_fraction(3, 1);
l_fraction4  types_pkg.fraction_ty := fractions_pkg.to_fraction(41, 17);
l_fraction5  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 41);
l_fraction6  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction7  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction8  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction9  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 17);
begin
-- Two dimensional matrix
dbms_output.put_line ('-- Three dimensional matrix');
-- l_matrix :=  matrix_Q_pkg.to_matrix_Q_2D  (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
l_matrix :=  matrix_Q_pkg.to_matrix_Q_3D (l_fraction1,l_fraction2, l_fraction3, l_fraction4, l_fraction5,l_fraction6, l_fraction7, l_fraction8, l_fraction9);
matrix_Q_pkg.print_matrix (l_matrix);
-- Determinant
dbms_output.put_line ('-- Determinant');
l_fraction := matrix_Q_pkg.determinant (l_matrix);
fractions_pkg.print (l_fraction);
l_fraction := fractions_pkg.divide (fractions_pkg.to_fraction(1, 1), l_fraction);
fractions_pkg.print (l_fraction);
-- Inverse 
dbms_output.put_line ('-- Inverse');
l_matrix2 := matrix_Q_pkg.invert (l_matrix);
dbms_output.put_line ('-- LCM:  ' || matrix_Q_pkg.lcm_denominator (l_matrix2));
dbms_output.put_line ('-- Greatest N:  ' || matrix_Q_pkg.greatest_numerator (l_matrix2));
dbms_output.put_line ('-- Greatest L:  ' || length(matrix_Q_pkg.greatest_numerator (l_matrix2)));
dbms_output.put_line ('-- Greatest D:  ' || matrix_Q_pkg.greatest_denominator (l_matrix2));
dbms_output.put_line ('-- Greatest I:  ' || matrix_Q_pkg.greatest_integer (l_matrix2));
matrix_Q_pkg.print_matrix (l_matrix2);
-- Adjugate
--dbms_output.put_line ('-- Adjugate:  ');
--l_matrix :=  matrix_Q_pkg.adjugate (l_matrix);
--matrix_Q_pkg.print_matrix (l_matrix);
--l_matrix :=  matrix_Q_pkg.multiply (l_fraction, l_matrix);
--matrix_Q_pkg.print_matrix (l_matrix);
l_matrix := matrix_Q_pkg.multiply (l_matrix2, l_matrix);
matrix_Q_pkg.print_matrix (l_matrix);
end;
/

-- Chemistry
declare
l_fraction   types_pkg.fraction_ty;
l_matrix     types_pkg.matrix_Q_ty;
l_matrix2    types_pkg.matrix_Q_ty;
l_vector     types_pkg.vector_Q_ty;
l_factor     integer;
begin
l_matrix :=  chemistry_pkg.convert_to_matrix (1);
matrix_Q_pkg.print_matrix (l_matrix);
for j in 1 .. 1
loop
  l_vector := matrix_Q_pkg.column_to_vector (l_matrix, 1);
  matrix_Q_pkg.print_vector (l_vector);
--
  l_vector := matrix_Q_pkg.scalar_times_vector (fractions_pkg.to_fraction(-1, 1), l_vector);
  matrix_Q_pkg.print_vector (l_vector);
  dbms_output.put_line ('-- Index:  ' || j);
  l_matrix2 := matrix_Q_pkg.remove_column (l_matrix, j);
  matrix_Q_pkg.print_matrix (l_matrix2);

  l_matrix2 := matrix_Q_pkg.invert (l_matrix2);
  matrix_Q_pkg.print_matrix (l_matrix2);
--
  l_vector := matrix_Q_pkg.matrix_times_vector (l_matrix2, l_vector);
  matrix_Q_pkg.print_vector (l_vector);
  l_factor := matrix_Q_pkg.lcm_denominator (l_vector);
  dbms_output.put_line ('a: ' || l_factor);
  l_vector := matrix_Q_pkg.scalar_times_vector (fractions_pkg.to_fraction(l_factor, 1), l_vector);
  matrix_Q_pkg.print_vector (l_vector);
end loop;
end;
/


declare
l_fraction   types_pkg.fraction_ty;
l_matrix     types_pkg.matrix_Q_ty;
l_matrix2    types_pkg.matrix_Q_ty;
l_fraction1  types_pkg.fraction_ty := fractions_pkg.to_fraction(111, 13);
l_fraction2  types_pkg.fraction_ty := fractions_pkg.to_fraction(2, 19);
l_fraction3  types_pkg.fraction_ty := fractions_pkg.to_fraction(3, 1);
l_fraction4  types_pkg.fraction_ty := fractions_pkg.to_fraction(41, 17);
l_fraction5  types_pkg.fraction_ty := fractions_pkg.to_fraction(15, 41);
l_fraction6  types_pkg.fraction_ty := fractions_pkg.to_fraction(17, 31);
l_fraction7  types_pkg.fraction_ty := fractions_pkg.to_fraction(-3, 4);
l_fraction8  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 7);
l_fraction9  types_pkg.fraction_ty := fractions_pkg.to_fraction(-6, 17);
l_id integer;
begin
-- Two dimensional matrix
dbms_output.put_line ('-- Three dimensional matrix');
-- l_matrix :=  matrix_Q_pkg.to_matrix_Q_2D  (l_fraction1,l_fraction2, l_fraction3, l_fraction4);
l_matrix :=  matrix_Q_pkg.to_matrix_Q_3D (l_fraction1,l_fraction2, l_fraction3, l_fraction4, l_fraction5,l_fraction6, l_fraction7, l_fraction8, l_fraction9);
matrix_Q_pkg.print_matrix (l_matrix);
matrix_Q_pkg.save_matrix (l_matrix, l_id);
l_matrix := matrix_Q_pkg.load_matrix (l_id);
matrix_Q_pkg.print_matrix (l_matrix);
end;
/



