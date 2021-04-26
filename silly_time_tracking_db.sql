/* Database and Table */

create database if not exists tt;
	use tt;

CREATE TABLE if not exists tt.tt_inmemory (
  id int NOT NULL AUTO_INCREMENT,
  activity varchar(1),
  starttime datetime DEFAULT NULL,
  endtime datetime DEFAULT NULL,
  activity_detail enum('break time','meeting follow up','email','prospecting','SFDC','customer meeting','internal meeting','meeting prep','GTM','reporting','self development') DEFAULT NULL,
  PRIMARY KEY (id)
)  ENGINE=MEMORY;


create index idx_tt_id on tt.tt(id);
create index idx_tt_starttime on tt.tt(starttime);
create index idx_tt_endtime on tt.tt(endtime);
create index idx_tt_activity on tt.tt(activity);

create table tt_store as select * from tt_inmemory where 1 = 2;

create view tt as select * from tt_inmemory union all select * from tt_store;



/* Procedure to create data */
use tt;
drop procedure data_it;

DELIMITER $$

create procedure data_it(howmuch int)
	BEGIN

	declare counter int DEFAULT 0;

	declare maxID int DEFAULT 0;

	declare startID int DEFAULT 0;

	declare endID int DEFAULT 0;
	
	select max(id) into maxID from tt.tt_inmemory;
	select max(id) + 1 'endID' into startID from tt.tt_inmemory;
	set endID = startID + howmuch;

	select 'Row Count: ', count(*) from tt.tt_inmemory;

	WHILE counter <= howmuch DO
	insert into tt.tt_inmemory(starttime)
		values
		(current_timestamp());
	commit;
	set counter = counter + 1;
	END WHILE;

	select sleep(1);

	update tt.tt_inmemory set endtime = current_timestamp where id > maxID;

	select 'Row Count: ', count(*) from tt.tt_inmemory;
END$$

DELIMITER ;

call data_it(10);



/* Procedure to move from in-memory table to regular table */
DELIMITER $$
create procedure move_stores()
	begin

	declare maxID int default 0;

	select max(id) into maxID from tt_inmemory;

	select 'Before Run';
	select 'In Memory Store Count: ', count(*) from tt.tt_inmemory;
	select 'Disk Store Count: ', count(*) from tt.tt_store;

	insert into tt_store select * from tt_inmemory where id <= maxID;

	delete from tt_inmemory where id <= maxID;

	select 'After Run';
	select 'In Memory Store Count: ', count(*) from tt.tt_inmemory;
	select 'Disk Store Count: ', count(*) from tt.tt_store;

END$$

DELIMITER ;

/* Event to move data */
CREATE EVENT switch_stores
    ON SCHEDULE
      EVERY 300 SECOND
    DO
      call tt.move_stores;














