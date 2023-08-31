MOS: 
https://support.oracle.com/epmos/faces/DocumentDisplay?_afrLoop=282669444841898&parent=DOCUMENT&sourceId=2299564.1&id=2299484.1&_afrWindowMode=0&_adf.ctrl-state=4ayv1iqut_185


 CREATE OR REPLACE PROCEDURE process_image_files ( payload IN SYS.scheduler_filewatcher_result)
IS
    l_blob    BLOB;
    l_bfile   BFILE;
   BEGIN
      INSERT INTO images (
                file_name,
                file_size,
                file_content,
                uploaded_on)
           VALUES (
                payload.directory_path || '\' || payload.actual_file_name,
                payload.file_size,
                EMPTY_BLOB (),
                payload.file_timestamp)
        RETURNING file_content
             INTO l_blob;

     l_bfile := BFILENAME ('BLOB_DIR', payload.actual_file_name);
      DBMS_LOB.open (l_bfile, DBMS_LOB.lob_readonly);
     DBMS_LOB.open (l_blob, DBMS_LOB.lob_readwrite);
      DBMS_LOB.loadfromfile (
         dest_lob   => l_blob,
         src_lob    => l_bfile,
         amount     => DBMS_LOB.getlength (l_bfile));
      DBMS_LOB.close (l_blob);
      DBMS_LOB.close (l_bfile);
   END process_image_files;
/

SQL> BEGIN
  2     DBMS_SCHEDULER.create_program (
  3        program_name      => 'image_watcher_p',
  4        program_type      => 'stored_procedure',
  5        program_action    => 'process_image_files',
  6        number_of_arguments   => 1,
  7        enabled       => FALSE);
  8     DBMS_SCHEDULER.define_metadata_argument (
  9        program_name     => 'image_watcher_p',
 10        metadata_attribute   => 'event_message',
 11        argument_position    => 1);
 12     DBMS_SCHEDULER.enable ('image_watcher_p');
 13  END;
 14  /
 
 
 SQL> BEGIN
  2     DBMS_SCHEDULER.create_file_watcher (
  3        file_watcher_name   => 'image_watcher_fw',
  4        directory_path      => 'C:\TEMP',
  5        file_name           => '*.jpg',
  6        credential_name     => 'oracle_credential',
  7        destination         => NULL,
  8        enabled         => FALSE);
  9  END;
 10  /

QL> BEGIN
  2     DBMS_SCHEDULER.create_job (
  3        job_name      => 'image_load_j',
  4        program_name      => 'image_watcher_p',
  5        event_condition   => 'tab.user_data.file_size > 0',
  6        queue_spec        => 'image_watcher_fw',
  7        auto_drop         => FALSE,
  8        enabled       => FALSE);
  9  
 10  DBMS_SCHEDULER.set_attribute('image_load_j','parallel_instances',TRUE);
 11  END;
 12  /


BEGIN
  2     DBMS_SCHEDULER.enable ('image_watcher_fw,image_load_j');
  3  END;
  4  /
  
  

CREATE OR REPLACE DIRECTORY scott_dir AS '/usr/home/scott';
BFILENAME('SCOTT_DIR', 'afile')

DBMS_LOB.LOADFROMFILE   DBMS_LOB.LOBMAXSIZE

insert into temp_bfile(bfile_loc) values (BFILENAME('STUFF', 'WD.pdf'));


SET SERVEROUTPUT ON
DECLARE
  v_bfile BFILE;
begin
  select valor into v_bfile from TABLA_BFILE where id = 4;
  DBMS_OUTPUT.PUT_LINE('El archivo ocupa: '||DBMS_LOB.GETLENGTH(v_bfile)||' bytes.');
end;

DECLARE
  l_bfile  BFILE;
  l_blob   BLOB;

  l_dest_offset INTEGER := 1;
  l_src_offset  INTEGER := 1;
BEGIN
  INSERT INTO tab1 (id, blob_data)
  VALUES (1, empty_blob())
  RETURN blob_data INTO l_blob;

  l_bfile := BFILENAME('BLOB_DIR', 'MyImage.gif');
  DBMS_LOB.fileopen(l_bfile, DBMS_LOB.file_readonly);
  -- loadfromfile deprecated.
  -- DBMS_LOB.loadfromfile(l_blob, l_bfile, DBMS_LOB.getlength(l_bfile));
  DBMS_LOB.loadblobfromfile (
    dest_lob    => l_blob,
    src_bfile   => l_bfile,
    amount      => DBMS_LOB.lobmaxsize,
    dest_offset => l_dest_offset,
    src_offset  => l_src_offset);
  DBMS_LOB.fileclose(l_bfile);

  COMMIT;
END;
/

=============================================================

BEGIN
  DBMS_SCHEDULER.CREATE_CREDENTIAL('WATCH_CREDENTIAL', 'salesapps', 'sa324w1');
END;
/
2.  Create a file watcher

BEGIN
  DBMS_SCHEDULER.CREATE_FILE_WATCHER(
    FILE_WATCHER_NAME => 'EOD_FILE_WATCHER',
    DIRECTORY_PATH    => '?/eod_reports',
    FILE_NAME         => 'eod*.txt',
    CREDENTIAL_NAME   => 'WATCH_CREDENTIAL',
    DESTINATION       => NULL,
    ENABLED           => FALSE);
END;
/
3.  Create a program object:

BEGIN
  DBMS_SCHEDULER.CREATE_PROGRAM(
    PROGRAM_NAME        => 'DSSUSER.EOD_PROGRAM',
    PROGRAM_TYPE        => 'STORED_PROCEDURE',
    PROGRAM_ACTION      => 'EOD_PROCESSOR',
    NUMBER_OF_ARGUMENTS => 1,
    ENABLED             => FALSE);
END;
/
4a.  Define the metadata argument using the event_message attribute.

BEGIN
  DBMS_SCHEDULER.DEFINE_METADATA_ARGUMENT(
    PROGRAM_NAME       => 'DSSUSER.EOD_PROGRAM',
    METADATA_ATTRIBUTE => 'event_message',
    ARGUMENT_POSITION  => 1);
END;
/
4b.  Prepare an event-based job:

BEGIN
  DBMS_SCHEDULER.CREATE_JOB(
    JOB_NAME        => 'DSSUSER.EOD_JOB',
    PROGRAM_NAME    => 'DSSUSER.EOD_PROGRAM',
    EVENT_CONDITION => NULL,
    QUEUE_SPEC      => 'EOD_FILE_WATCHER',
    AUTO_DROP       => FALSE,
    ENABLED         => FALSE);
END;
/
5.  Enable objects:

BEGIN
   DBMS_SCHEDULER.ENABLE('DSSUSER.EOD_PROGRAM,DSSUSER.EOD_JOB,EOD_FILE_WATCHER');
END;
/
You can view information about file watchers by querying dba_scheduler_file_watchers:

set linesize 100

column file_watcher_name format a20
column destination       format a15
column directory_path    format a15
column file_name         format a10
column credential_name   format a20

select
   file_watcher_name,
   destination,
   directory_path,
   file_name,
   credential_name
from   dba_scheduler_file_watchers;

-----------------------
'

grant scheduler_admin to dolly;

https://oraclefrontovik.com/2012/10/10/oracle-file-watcher-on-a-windows-pc/


1. The following example changes the interval to five minutes. Run this code as SYS
begin 
   dbms_scheduler.set_attribute ('file_watcher_schedule', 'repeat_interval', 'freq=minutely; interval=2' ); 
end;
/

2. Create the credential. Run this as Dolly
begin 
   dbms_scheduler.create_credential (credential_name => 'watch_credential', username => 'THEO', password  => 'Celeste14' ); 
end;
/

select * from dba_scheduler_credentials;

3. File Location Details. Run as Dolly
begin 
dbms_scheduler.create_file_watcher
   (
      file_watcher_name => 'the_file_watcher',
      directory_path    => 'C:\Work\Schilderijen_Dolly',
      file_name         => '*.jpg',
      credential_name   => 'watch_credential',
      destination       => NULL,
      enabled           => FALSE);
 end;
/

select * from dba_scheduler_file_watchers;

4. Specify the program unit that will be executed when the file watcher runs

begin 
   dbms_scheduler.create_program
   (  program_name        => 'file_watcher_prog',
      program_type        => 'stored_procedure',
      program_action      => 'load_pictures',
      number_of_arguments => 1,
      enabled             => FALSE);
end;
/

Step 5 Defining metadata
begin 
   dbms_scheduler.define_metadata_argument
   (  program_name       => 'file_watcher_prog',
      metadata_attribute => 'event_message',
      argument_position  => 1
   ); 
end;
/

create directory pictures as 'C:\Work\Schilderijen_Dolly';
grant read, write on directory pictures to Dolly;
grant create external job to dolly;


Step 6 Creating the supporting objects

create or replace procedure load_pictures
(pt_payload IN sys.scheduler_filewatcher_result)
is 
 lc_blob           blob;
 lt_bfile          bfile;
 li_warning        integer;
 li_dest_offset    integer := 1;
 li_src_offset     integer := 1;
 li_lang_context   integer := 0;
begin
   insert into paintings (file_name, picture, created)
   values( pt_payload.directory_path || '\' || pt_payload.actual_file_name,  empty_blob(), sysdate) returning picture into lc_blob;
   lt_bfile := bfilename(directory => 'PICTURES',  filename  => pt_payload.actual_file_name);
 
   dbms_lob.fileopen (file_loc => lt_bfile);
 
   dbms_lob.loadblobfromfile
   (
      dest_lob     => lc_blob,
      src_bfile    => lt_bfile,
      amount       => dbms_lob.getlength(file_loc => lt_bfile),
      dest_offset  => li_dest_offset,
      src_offset   => li_src_offset
   );
 
  dbms_lob.fileclose ( file_loc => lt_bfile);
 
end load_pictures;
/


Step 7: Creating a job
begin 
   dbms_scheduler.create_job
   (
      job_name        => 'file_watcher_job',
      program_name    => 'file_watcher_prog',
      event_condition => NULL,
--	  repeat_interval=>  'FREQ=MINUTELY;INTERVAL=5;',
      queue_spec      => 'The_file_watcher',
      auto_drop       => FALSE,
      enabled         => FALSE
    );
end;
/

exec dbms_scheduler.set_attribute('file_watcher_job','parallel_instances',TRUE);


Step 8: Enable All the objects

begin 
   dbms_scheduler.enable ('The_file_watcher, file_watcher_prog, file_watcher_job'); 
end;
/

Step 9: Seeing the results


exec dbms_scheduler.drop_job('file_watcher_job')
/
exec dbms_scheduler.drop_program('file_watcher_prog')
/
exec dbms_scheduler.drop_file_watcher('the_file_watcher')
/
exec dbms_scheduler.drop_credential('watch_credential')
/
drop procedure  procedure load_pictures
/