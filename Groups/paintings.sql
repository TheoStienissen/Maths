create table paintings
(id				integer generated always as identity, 
name            varchar2(100)
file_name		varchar2(200 byte), 
picture			blob, 
created			date, 
inserted		date,
last_update		date, 
person1_id      integer 
person2_id      integer 
material_id     integer
surface_id      integer
info			varchar2(2000 byte));

create or replace trigger paintings_briu
before insert or update on paintings
for each row 
begin 
if inserting
then :new.inserted := sysdate;
elsif updating
then :new.last_update := sysdate;
end if;

end paintings_briu;
/

create table paintings_other_pics
( id   				integer generated always as identity
, file_name		    varchar2(200 byte)
, amount            integer
, picture   		blob
, info              varchar2(200)
, origin            varchar2(100));

create table paintings_persons
( id			  integer generated always as identity
, name            varchar2(100)
, info            varchar2(400));

alter table paintings_persons add constraint paintings_persons_pk1 primary key (id) using index;
alter table paintings add constraint paintings_persons_fk1 foreign key (person1_id) references paintings_persons(id) on delete set null;
alter table paintings add constraint paintings_persons_fk2 foreign key (person2_id) references paintings_persons(id) on delete set null;

create table paintings_materials
( id				integer generated always as identity
, material         varchar2(100));

alter table paintings_materials add constraint paintings_materials_pk1 primary key (id) using index;
alter table paintings add constraint paintings_materials_fk1 foreign key (material_id) references paintings_materials(id) on delete set null;

create table paintings_surfaces
( id				integer generated always as identity
, surface         varchar2(100));

alter table paintings_surfaces add constraint paintings_surfaces_pk1 primary key (id) using index;
alter table paintings add constraint paintings_surfaces_fk1 foreign key (surface_id) references paintings_surfaces(id) on delete set null;

create view v_get_files as select fname_krbmsft as filename from sys.x$krbmsft;

grant select on v_get_files to dolly, theo;


create or replace type file_name_ty is table of varchar2(400);
/

create or replace type file_name_tab is table of file_name_ty;
/

create or replace function f_get_filenames (p_path in varchar2 default 'C:\Work\Schilderijen_Dolly') return file_name_tab pipelined
is 
l_dirname VARCHAR2(1024) := p_path;
l_ns      VARCHAR2(1024);
begin
sys.dbms_backup_restore.searchfiles(l_dirname, l_ns);
for j in (select fname_krbmsft as filename from x$krbmsft)
loop
  pipe row (file_name_ty(j.filename));
end loop;
end;
/
-- where fname_krbmsft like '%.jpg'

grant execute on f_get_filenames to dolly, theo;

create or replace view v_pictures
as
select c.column_value path, substr(c.column_value, instr(c.column_value, '\', -1) + 1) file_name from table (sys.f_get_filenames) f, table (column_value) c;
'
create or replace procedure load_pictures
is 
 l_blob           blob;
 l_bfile          bfile;
 l_amount         integer;
 l_dest_offset    integer;
 l_src_offset     integer;
begin
for j in (select file_name from v_pictures minus select file_name from paintings_other_pics)
loop
begin 
  l_bfile := bfilename (directory => 'PICTURES', filename  => j.file_name);   
  dbms_lob.fileopen (file_loc => l_bfile, open_mode => dbms_lob.lob_readonly); 
  if dbms_lob.fileexists (l_bfile) = 1
  then 
    l_dest_offset := 1;
	l_src_offset  := 1;
    l_amount := dbms_lob.getlength (l_bfile);
	dbms_output.put_line('file ' || j.file_name || ' has ' || l_amount || ' bytes.');
    insert into paintings_other_pics (file_name, amount, picture) values (j.file_name, l_amount, empty_blob()) returning picture into l_blob;
    dbms_lob.loadblobfromfile (dest_lob => l_blob, src_bfile => l_bfile, amount => l_amount, dest_offset => l_dest_offset, src_offset => l_src_offset); 
 --   dbms_lob.loadfromfile (dest_lob => l_blob, src_bfile => l_bfile, amount => dbms_lob.getlength (l_bfile));
    dbms_lob.fileclose (file_loc => l_bfile);
  else 
    raise_application_error (-20001, 'File ' || j.file_name || ' does not exist in directory PICTURES');
  end if;
  commit;

exception when others
then raise;
end; 
end loop;
dbms_lob.filecloseall;
end load_pictures;
/

 


BFILE: select for update

file_ptr bfile;
picture      blob default empty_blob ()
document     clob default empty_clob ()

create or replace procedure write_lob
is
l_blob  blob;
...
begin
...
insert into ... returning picture into l_blob;
loadblobfrombfile(l_blob, p_file, p_dir);
...
end;

dbms_lob.substr(lob, amount, start_pos)
dbms_lob.instr(lob, pattern)

 