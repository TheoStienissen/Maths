create or replace function f_to_base (p_n in number, p_base in number) return number
is
begin
if p_n < p_base then return to_char(p_n);
else
  return f_to_base (trunc(p_n / p_base), p_base) || mod(p_n, p_base);
end if;
end;
/


select level,  lpad(f_to_base(level, 3), 4, '0') from dual connect by level <= 80;

select level,  lpad(f_to_base(level, 3), 4, '0') from dual
where substr(lpad(f_to_base(level, 3), 4, '0'), 4,1) = '1'
 connect by level <= 80;

select level from dual
where substr(lpad(f_to_base(level, 3), 4, '0'), 3,1) = '2'
 connect by level <= 80;

-- Total # Cards = (base - 1) * depth
-- Max cards per number = depth
-- Range 1 .. power (base, l_depth) - 1
-- Numbers per card = power (base, depth - 1)
--

set serveroutput on size unlimited
declare
l_depth number(4) := 4;
l_base  number(2) := 4;
l_max   number(4);
l_count number(4);
l_card  number(2) := 0;
begin
l_max := power (l_base, l_depth) - 1;

for pos in 1 .. l_depth
loop
  for dig in 1 .. l_base - 1
  loop
    l_card := l_card + 1;
    dbms_output.put_line('--');
--    dbms_output.put_line('Card:  ' || to_char(l_card) || '. Pos:  ' || to_char(pos) || '. Dig:  ' || to_char(dig) || '.');
    l_count := 0;
    for val in (select level ind from dual
                 where substr(lpad(f_to_base(level, l_base), l_depth, '0'), pos,1) = to_char(dig) connect by level <= l_max)
    loop
       l_count := l_count + 1;
       dbms_output.put (to_char(val.ind));
       if mod (l_count,5) = 0 then dbms_output.new_line; else  dbms_output.put (';'); end if;
    end loop;
--    dbms_output.put_line('*++  '||to_char(l_count));
  dbms_output.new_line;
  dbms_output.new_line;
  end loop;
end loop;
end;
/

====

create table eggs
( depth         number(2)
, base          number(2)
, card          number(5)
, ind           number(5));

create or replace procedure calculate_egg (p_base in number, p_depth in number)
is
l_max   number(10);
l_card  number(5) := 0;
begin
delete eggs where depth = p_depth and base = p_base;
l_max := power (p_base, p_depth) - 1;

for pos in 1 .. p_depth
loop
  for dig in 1 .. p_base - 1
  loop
    l_card := l_card + 1;
    for val in (select level ind from dual where substr(lpad(f_to_base(level, p_base), p_depth, '0'), pos,1) = to_char(dig) connect by level <= l_max)
    loop
       insert into eggs (depth, base, card, ind) values (p_depth, p_base, l_card, val.ind);
    end loop;
  end loop;
end loop;
commit;
end;
/

exec calculate_egg (3, 4)


create or replace procedure show_egg (p_base in number, p_depth in number)
is
l_cards  number(5) := 0;
l_count  number(6);
begin
dbms_output.put_line('-- '|| to_char(p_base) || '  ' ||  to_char(p_depth));
select max(card) into l_cards from eggs where depth = p_depth and base = p_base;
for card_no in 1 .. l_cards
loop
dbms_output.new_line;
dbms_output.put_line('-- ');
dbms_output.put_line('--  Card: '|| to_char(card_no));
dbms_output.put_line('-- ');
l_count := 0;
  for j in (select ind from eggs where  depth = p_depth and base = p_base and card = card_no order by ind)
  loop
    l_count := l_count + 1;
    dbms_output.put (lpad(to_char(j.ind), 4, '-'));
    if mod (l_count, power(p_base, floor(p_depth/2))) = 0 then dbms_output.new_line; else  dbms_output.put (' | '); end if;
  end loop;
   dbms_output.new_line;
   dbms_output.put_line('--');
end loop;
end;
/

set serveroutput on size unlimited
exec show_egg  (3, 4)

truncate table eggs;

declare
l_base  number(2) := 3;
l_depth number(4) := 3;
begin
  calculate_egg (l_base, l_depth);
  show_egg  (l_base, l_depth);
  check_egg (l_base, l_depth);
end;
/

create or replace procedure check_egg (p_base in number, p_depth in number)
is
l_sum  number(6);
begin
for j in 1 .. power (p_base, p_depth) - 1
loop
select sum(min(ind))  into l_sum from eggs where card in (select  card from eggs where  depth = p_depth and base = p_base and ind = j group by card)
and   depth = p_depth and base = p_base
group by card;
if l_sum != j
then
  raise_application_error(-20000, 'Error. Sum = ' || to_char(l_sum) || ' for value  ' || to_char(j));
end if;
end loop;
end;
/


select sum(min(ind))  from eggs where card in (select  card from eggs where  depth = 3 and base = 4 and ind = 18 group by card) group by card;


