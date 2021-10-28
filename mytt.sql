# MySQL alternative for datetime math
create database if not exists tt;
use tt;

drop table if exists tt;

# time tracking table
create table tt
	(
		id int auto_increment primary key, 
		activity text, 
		starttime datetime, 
		endtime datetime, 
		activity_detail enum('break time', 'meeting follow up','email', 'SFDC', 'customer meeting','internal meeting','meeting prep', 'GTM','reporting','self development')
	);
# Add additional values to enum
alter table tt 
change activity_detail activity_detail 
enum('deal quality review',
	'break time', 'training',
	'meeting follow up','email', 
	'DMA pricing','prospecting','SFDC', 
	'customer meeting','internal meeting',
	'meeting prep','doc writing','GTM',
	'reporting','self development', 
	'interview','interview feedback','SOW','Poland Work');


/*# table to grab daily totals
create table daily_activity
	(
		id int auto_increment primary key,
		activity_date date,
		activity text,
		activity_duration time
	);

create table activity
	(
		id int auto_increment primary key,
		activity_date date,
		activity text,
		activity_duration time
	);
*/


drop view if exists today_work;
create view today_work as 
select *, 
(CASE
	when timediff(endtime,starttime) is NULL then timediff(now(),starttime)
	when timediff(endtime,starttime) is not NULL then timediff(endtime,starttime)
	else 'not_working'
END) as duration,
(CASE
	when timediff(endtime,starttime) is NULL then 'Work in Progress'
	when timediff(endtime,starttime) is not NULL then 'Work Complete'
	else 'not_working'
END) as status
from tt.tt 
where activity='work' and date(starttime) = curdate()
order by starttime;


drop view if exists today_break;
create view today_break as
select *, 
(CASE
	when timediff(endtime,starttime) is NULL then timediff(now(),starttime)
	when timediff(endtime,starttime) is not NULL then timediff(endtime,starttime)
	else 'not_working'
END) as duration,
(CASE
	when timediff(endtime,starttime) is NULL then 'Work in Progress'
	when timediff(endtime,starttime) is not NULL then 'Work Complete'
	else 'not_working'
END) as status
from tt.tt where activity='break' and date(starttime) = curdate()
order by starttime;

drop view if exists today;
create view today as 
select * from today_work
union all
select * from today_break
order by endtime desc;

drop view if exists activity;
create view activity as
	select * from today
	order by endtime desc;


/* All current week work  -- this works 07.2.2021 */
create view this_week as 
select *, 
(CASE
	when timediff(endtime,starttime) is NULL then timediff(now(),starttime)
	when timediff(endtime,starttime) is not NULL then timediff(endtime,starttime)
	else 'not_working'
END) as duration,
(CASE
	when timediff(endtime,starttime) is NULL then 'Work in Progress'
	when timediff(endtime,starttime) is not NULL then 'Work Complete'
	else 'not_working'
END) as status
from tt.tt where week(starttime) = week(curdate())
order by starttime;

create view this_week_activity as
select 
	activity_detail, 
	sec_to_time(sum(time_to_sec(duration))) as total 
from this_week
group by 1 order by 2 desc;

/* Roll up per date for this week */
select count(*), date(endtime) from this_week group by 2 order by 1 desc;

/* Testing */
select 
	date(endtime),
	timediff(max(endtime),min(starttime)) 
from this_week 
group by 1
;

create view all_time as 
select *, 
monthname(starttime), 
dayname(starttime),
year(starttime),
(CASE
	when timediff(endtime,starttime) is NULL then timediff(now(),starttime)
	when timediff(endtime,starttime) is not NULL then timediff(endtime,starttime)
	else 'not_working'
END) as duration,
(CASE
	when timediff(endtime,starttime) is NULL then 'Work in Progress'
	when timediff(endtime,starttime) is not NULL then 'Work Complete'
	else 'not_working'
END) as status
from tt.tt ;

select 
	activity_detail, 
	sec_to_time(sum(time_to_sec(duration))) as total 
from all_time
group by 1 order by 2 desc;







