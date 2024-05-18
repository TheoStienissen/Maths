Doc
  Bytewise logical operations demo
  Implementation of boolean array
  
  INTEGERS IN REVERSE ORDER. So index 1 comes at the end.
  
function bitvalue (p_array in word_ty, p_position in integer) return integer; -- boolean?

/


#




-- Bitwise logical operations

create or replace package bit_ops_pkg
is
type word_ty is table of number(36) index by pls_integer;

function bitand         (p_x in integer, p_y in integer) return integer;
function bitand         (p_x in word_ty, p_y in word_ty) return word_ty;

function bitor          (p_x in integer, p_y in integer) return integer;
function bitor          (p_x in word_ty, p_y in word_ty) return word_ty;

function bitxor         (p_x in integer, p_y in integer) return integer;
function bitxor         (p_x in word_ty, p_y in word_ty) return word_ty;

function bitnot         (p_x in integer)                 return integer;
function bitnot         (p_x in word_ty)                 return word_ty;

function bitshift_left  (p_x in integer, p_y in integer) return integer;
function bitshift_left  (p_x in word_ty, p_y in word_ty) return word_ty;

function bitshift_right (p_x in integer, p_y in integer) return integer;
function bitshift_right (p_x in word_ty, p_y in word_ty) return word_ty;
end bit_ops_pkg;
/


create or replace package body bit_ops_pkg
is
function bitand  (p_x in integer, p_y in integer) return integer
is
begin
  return sys.standard.bitand(p_x, p_y);
end bitand;

/*************************************************************************************************************************************************/

function bitand (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. least (p_x.count, p_y.count)
  loop 
    l_array (j) := sys.standard.bitand (p_x (j), p_y (j));
  end loop;
  return l_array;

end bitand;

/*************************************************************************************************************************************************/

function bitor (p_x in integer, p_y in integer) return integer
is
begin
  return p_x + p_y - bitand(p_x, p_y);
end bitor;

/*************************************************************************************************************************************************/

function bitor (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. greatest (p_x.count, p_y.count)
  loop
    if p_x.count <=	p_y.count
	then 
	  if j > p_x.count then l_array (j) := p_y (j); else l_array (j) := p_x (j) + p_y (j) - sys.standard.bitand (p_x (j), p_y (j)); end if;	
	else 
	  if j > p_y.count then l_array (j) := p_x (j); else l_array (j) := p_x (j) + p_y (j) - sys.standard.bitand (p_x (j), p_y (j)); end if;	
	end if;  
  end loop;
  return l_array;

end bitor;

/*************************************************************************************************************************************************/

function bitxor (p_x in integer, p_y in integer) return integer
is
begin
  return bitor(p_x, p_y) - bitand(p_x, p_y);
end bitxor;

/*************************************************************************************************************************************************/

function bitxor (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array1  word_ty := bitor (p_x, p_y);
l_array2  word_ty := bitor (p_x, p_y);
begin
  for j in 1 .. least (p_x.count, p_y.count)
  loop
    l_array2 (j) := l_array1 (j) - bitand (p_x (j), p_y (j));
  end loop;
  return l_array2;
  
end bitxor;

/*************************************************************************************************************************************************/

function bitnot (p_x in integer) return integer
is
begin
  return - p_x - 1;
end bitnot;

/*************************************************************************************************************************************************/

function bitnot (p_x in word_ty) return word_ty
is
l_array  word_ty;
begin
  for j in 1 .. p_x.count
  loop
    l_array (j) := - p_x (j) - 1;
  end loop;
  return l_array;
  
end bitnot;

/*************************************************************************************************************************************************/

function bitshift_left (p_x in integer, p_y in integer) return integer
is
begin
  return p_x * power(2, p_y);
end bitshift_left;

/*************************************************************************************************************************************************/

function bitshift_left (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
--  return p_x * power(2, p_y);
  return l_array;
end bitshift_left;

/*************************************************************************************************************************************************/

function bitshift_right (p_x in integer, p_y in integer) return integer
is
begin
  return trunc(p_x / power(2, p_y));
end bitshift_right;

/*************************************************************************************************************************************************/

function bitshift_right (p_x in word_ty, p_y in word_ty) return word_ty
is
l_array  word_ty;
begin
--  return trunc(p_x / power(2, p_y));
  return l_array;
end bitshift_right;

end bit_ops_pkg;
/

