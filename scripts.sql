-- SQL Scripts

create table pkg_scripts
( id             number(6)     generated always as identity
, script_name    varchar2(30)  not null
, script_version number(2)     not null
, creator        number(6)     not null
, purpose        varchar2(200)
, script_code    clob
, created        date default sysdate
, last_update    date);

alter table pkg_scripts add constraint pkg_scripts_pk primary key (id) using index;
create unique index pkg_scripts_uk1 on pkg_scripts (script_name);

create table pkg_scripts_hist
( id             number(6)
, script_name    varchar2(30)
, script_version number(2)
, creator        number(6)
, purpose        varchar2(200)
, script_code    clob
, created        date
, last_update    date);

create or replace trigger pkg_scripts_trg
for insert or update or delete on pkg_scripts
compound trigger
   -- declarative section (optional)
   -- variables declared here have firing-statement duration.
      
     -- executed before dml statement
     before statement is
     begin
       null;
     end before statement;
    
     -- executed before each row change- :new, :old are available. if inserting then
     before each row is
     begin
	   if updating or deleting
	   then 
	     insert into pkg_scripts_hist (id, script_name, script_version, creator, purpose, script_code, created, last_update)
		    values (:old.id, :old.script_name, :old.script_version, :old.creator, :old.purpose, :old.script_code, :old.created, :old.last_update);
	   end if;
	   if updating
	   then 
	     :new.last_update := sysdate;
	   end if;
	   if inserting
	   then 
	     :new.created     := sysdate;
	   end if;
     end before each row;
    
     -- executed after each row change- :new, :old are available
     after each row is
     begin
       null;
     end after each row;
    
     -- executed after dml statement
     after statement is
     begin
       null;
     end after statement;
 
end pkg_scripts_trg;
/