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
  
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 1);
  l_poly2 := polynome_pkg.add_polynome_elt (2, -12, 0);
 
  l_poly3 := polynome_pkg.add_polynome_elt (3, 1, 1);
  l_poly3 := polynome_pkg.add_polynome_elt (3, -18, 0);

  l_poly4 := polynome_pkg.add_polynome_elt (4, 1, 1);
  l_poly4 := polynome_pkg.add_polynome_elt (4, -24, 0);

  l_poly_r1 := polynome_pkg.multiply_polynomes(l_poly1,l_poly2, 5);
  polynome_pkg.print_polynome(l_poly_r1);

  l_poly_r2 := polynome_pkg.multiply_polynomes(l_poly3,l_poly4, 6);
  polynome_pkg.print_polynome(l_poly_r2);
  
  l_poly_r3 := polynome_pkg.multiply_polynomes(l_poly_r1,l_poly_r2, 7);
  polynome_pkg.print_polynome(l_poly_r3);  
    
  dbms_output.put_line ('F(1): '  || polynome_pkg.result_for_x(l_poly_r3, 1));
  dbms_output.put_line ('F(2): '  || polynome_pkg.result_for_x(l_poly_r3, 2));
  dbms_output.put_line ('F(3): '  || polynome_pkg.result_for_x(l_poly_r3, 3));
  dbms_output.put_line ('F(4): '  || polynome_pkg.result_for_x(l_poly_r3, 4));
  dbms_output.put_line ('F(6): '  || polynome_pkg.result_for_x(l_poly_r3, 6));
  dbms_output.put_line ('F(12): ' || polynome_pkg.result_for_x(l_poly_r3, 12));
  dbms_output.put_line ('F(22): ' || polynome_pkg.result_for_x(l_poly_r3, 22));
  dbms_output.put_line ('F(40): ' || polynome_pkg.result_for_x(l_poly_r3, 40));
  dbms_output.put_line ('F(61): ' || polynome_pkg.result_for_x(l_poly_r3, 61));
end;
/

declare
l_poly1 polynome_pkg.polynome_row_ty;
l_poly2 polynome_pkg.polynome_row_ty;
l_poly3 polynome_pkg.polynome_row_ty;
begin
delete from polynomes;
commit;
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 3);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 0);
  
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 5);
  l_poly2 := polynome_pkg.add_polynome_elt (2, -1, 4);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 3);
  l_poly2 := polynome_pkg.add_polynome_elt (2,-1, 2);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 1);
  l_poly2 := polynome_pkg.add_polynome_elt (2, -1, 0);

  polynome_pkg.print_polynome(l_poly1, false);
  polynome_pkg.print_polynome(l_poly2, false);
  
  l_poly3 := polynome_pkg.multiply_polynomes(l_poly1,l_poly2, 3);
  polynome_pkg.print_polynome(l_poly3, false);
end;
/


create or replace procedure load_polynome (p_id in integer, p_elements in integer default 10, p_min_max in integer default 100)
is
l_poly polynome_pkg.polynome_row_ty;
begin
delete from polynomes where id = p_id;
for j in 1 .. p_elements
loop
  l_poly := polynome_pkg.add_polynome_elt (p_id, trunc (dbms_random.value (- p_min_max, p_min_max)), trunc (dbms_random.value (0, p_min_max)));
end loop;
commit;
l_poly := polynome_pkg.load_polynome (p_id);
polynome_pkg.print_polynome(l_poly, false); 
end;
/

-- Degree
declare
l_poly2 polynome_pkg.polynome_row_ty;
l_poly3 polynome_pkg.polynome_row_ty;
begin
  load_polynome (2);
  l_poly2 := polynome_pkg.load_polynome (2);
  
  polynome_pkg.print_polynome(l_poly2, false); 
  polynome_pkg.save_polynome (l_poly2);
  dbms_output.put_line ('Degree1: ' || polynome_pkg.degree (l_poly2));
  dbms_output.put_line ('Degree2: ' || polynome_pkg.degree (2));
end;
/

--  delete_element
declare
l_poly2 polynome_pkg.polynome_row_ty;
l_poly3 polynome_pkg.polynome_row_ty;
begin
  load_polynome (2);
  l_poly2 := polynome_pkg.load_polynome (2);
  polynome_pkg.print_polynome(l_poly2, false);
  polynome_pkg.save_polynome (l_poly2);
--  l_poly3 := l_poly2;
  l_poly3 := polynome_pkg.delete_element (l_poly2, 2);
  polynome_pkg.print_polynome(l_poly3, false);
  l_poly3 := polynome_pkg.delete_element (2, 2, 2);
 -- l_poly3 := polynome_pkg.load_polynome (2);
  polynome_pkg.print_polynome(l_poly3, false);
end;
/

--  delete_power
declare
l_poly2 polynome_pkg.polynome_row_ty;
l_poly3 polynome_pkg.polynome_row_ty;
begin
  load_polynome (2);
  l_poly2 := polynome_pkg.load_polynome (2);
  polynome_pkg.print_polynome(l_poly2, false);
  polynome_pkg.save_polynome (l_poly2);
--  l_poly3 := l_poly2;
  l_poly3 := polynome_pkg.delete_power (l_poly2, 3, 2);
  polynome_pkg.print_polynome(l_poly3, false);
  l_poly3 := polynome_pkg.delete_power (2, 3, 2);
  polynome_pkg.print_polynome(l_poly3, false);
end;
/

-- divide_polynomes
declare
l_poly1 polynome_pkg.polynome_row_ty;
l_poly2 polynome_pkg.polynome_row_ty;
l_id1   number (8);
l_id2   number (8);
begin
  delete polynomes;
  commit;
  l_poly1 := polynome_pkg.add_polynome_elt (1, 3, 5);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 3);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 2, 2);
  l_poly1 := polynome_pkg.add_polynome_elt (1, 1, 0);
  polynome_pkg.print_polynome(l_poly1, false);
  
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 2);
  l_poly2 := polynome_pkg.add_polynome_elt (2, 1, 0);
  polynome_pkg.print_polynome(l_poly2, false);
  
  l_id1 := polynome_pkg.divide_polynomes (1, 2, l_id2, 3);
  dbms_output.put ('Result: ');
  polynome_pkg.print_polynome(l_id1, true);
  dbms_output.put ('Remainder: ');
  polynome_pkg.print_polynome(l_id2, true);
end;
/


declare
l_id integer (8) := 16;
l_poly polynome_pkg.polynome_row_ty;
begin
load_polynome (l_id, 10);
l_poly := polynome_pkg.load_polynome(l_id);
--
for j in 0 .. 5
loop
  dbms_output.put_line(rpad('-',100, '+-'));
  polynome_pkg.print_polynome(polynome_pkg.move_x_axis (l_poly, j));
end loop;
end;
/


