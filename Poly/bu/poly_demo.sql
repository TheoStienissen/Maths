set serveroutput on size unlimited

declare
l_poly1 polynome_pkg.polynome_row_ty;
l_poly2 polynome_pkg.polynome_row_ty;
l_poly3 polynome_pkg.polynome_row_ty;
l_poly4 polynome_pkg.polynome_row_ty;
l_poly_r1 polynome_pkg.polynome_row_ty;
l_poly_r2 polynome_pkg.polynome_row_ty;
l_poly_r3 polynome_pkg.polynome_row_ty;
begin
delete from polynomes;
commit;
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 1);
  l_poly1 := polynome_pkg.add_polynome_elt (1, -6, 0);
  dbms_output.put ('First polynome:  ');
  polynome_pkg.print_polynome(l_poly1);
  dbms_output.put_line ('Degree = ' || polynome_pkg.poly_degree (l_poly1));
  dbms_output.put_line ('F(1): ' || polynome_pkg.poly_result(l_poly1, 1));
  dbms_output.put_line ('F(2): ' || polynome_pkg.poly_result(l_poly1, 2));
  
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 1);
  l_poly2 := polynome_pkg.add_polynome_elt (2, -12, 0);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 2);
  dbms_output.put ('Second polynome:  ');
  polynome_pkg.print_polynome(l_poly2);
  dbms_output.put_line ('Degree = ' || polynome_pkg.poly_degree (l_poly2));
  dbms_output.put_line ('F(3): ' || polynome_pkg.poly_result(l_poly2, 3));
  dbms_output.put_line ('F(4): ' || polynome_pkg.poly_result(l_poly2, 4));
  
  l_poly3 := polynome_pkg.add_polynome_elt (3, 1, 1);
  l_poly3 := polynome_pkg.add_polynome_elt (3, -18, 0);

  l_poly4 := polynome_pkg.add_polynome_elt (4, 1, 1);
  l_poly4 := polynome_pkg.add_polynome_elt (4, -24, 0);

  l_poly_r1 := polynome_pkg.multiply_polynomes(l_poly1,l_poly2, 5);
  dbms_output.put ('Multpily polynome:  ');
  polynome_pkg.print_polynome(l_poly_r1);

  l_poly_r2 := polynome_pkg.multiply_polynomes(l_poly3,l_poly4, 6);
  polynome_pkg.print_polynome(l_poly_r2);
  
  l_poly_r3 := polynome_pkg.multiply_polynomes(l_poly_r1,l_poly_r2, 7);
  polynome_pkg.print_polynome(l_poly_r3);    
end;
/

-- Save polynome in a table and reload
declare
l_poly1 polynome_pkg.polynome_row_ty;
begin
  delete polynomes where id = 2;
  l_poly1 := polynome_pkg.add_polynome_elt (2, 4, 1);
  l_poly1 := polynome_pkg.add_polynome_elt (2, -12, 0);
  l_poly1 := polynome_pkg.add_polynome_elt (2, 7, 2);
  dbms_output.put ('Polynome before save: ');
  polynome_pkg.print_polynome(l_poly1);
  polynome_pkg.save_polynome (l_poly1);
  l_poly1 := polynome_pkg.load_polynome (2);
    dbms_output.put ('Polynome  after save: ');
  polynome_pkg.print_polynome(l_poly1);
end;
/

-- Divide 2 polynomes
declare
l_poly1 polynome_pkg.polynome_row_ty;
l_poly2 polynome_pkg.polynome_row_ty;
l_poly_m polynome_pkg.polynome_row_ty;
l_zero  boolean;
begin
  delete polynomes where id in (1, 2, 3, 4, 5);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 2);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 1);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 2, 0);
  dbms_output.put ('Divisor:  ');polynome_pkg.print_polynome(l_poly1);
--
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 2);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 1);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 7, 0);
  l_poly_m := polynome_pkg.multiply_polynomes(l_poly1, l_poly2, 4);
  
  l_poly2 := polynome_pkg.add_polynome_elt (3, 1, 1);
  l_poly2 := polynome_pkg.add_polynome_elt (3, -5, 0);
  l_poly_m := polynome_pkg.multiply_polynomes(l_poly_m, l_poly2, 5);  
  
--  dbms_output.put ('Result after divide:  ');polynome_pkg.print_polynome(l_poly2);
  dbms_output.put ('Polynome before divide:  ');
  polynome_pkg.print_polynome(l_poly_m);
  l_poly1 := polynome_pkg.divide_polynomes(l_poly1, l_poly_m, l_zero);
  dbms_output.put ('Polynome  after divide:  ');
  polynome_pkg.print_polynome(l_poly1);
  if l_zero
  then dbms_output.put_line ('Zero divisor!');
  else dbms_output.put_line ('Not a zero divisor');
  end if;
for j in 1 .. 15
loop
  l_poly2 := polynome_pkg.poly_shift(l_poly1, -j, 1);
  polynome_pkg.print_polynome(l_poly2);
  l_poly2 := polynome_pkg.poly_shift(l_poly1, j, 1);
  polynome_pkg.print_polynome(l_poly2);
end loop;
end;
/

-- Shift to the left ot right
declare
l_poly1 polynome_pkg.polynome_row_ty;
l_poly2 polynome_pkg.polynome_row_ty;
l_poly_m polynome_pkg.polynome_row_ty;
l_zero  boolean;
begin
  delete polynomes where id in (1, 2, 3, 4, 5);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 2);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 3, 1);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 4, 0);
  polynome_pkg.print_polynome(l_poly1);
  l_poly2 := polynome_pkg.poly_shift(l_poly1, 2, 2);
  polynome_pkg.print_polynome(l_poly2);
  
--  l_poly2 := polynome_pkg.poly_shift(l_poly1, 2, 3);
--  polynome_pkg.print_polynome(l_poly2);
  
  l_poly2 := polynome_pkg.poly_shift(l_poly1, -2, 4);
  polynome_pkg.print_polynome(l_poly2);
end;
/
