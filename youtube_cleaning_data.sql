use youtube_cleaning_task;
-- show tables;
-- -- ● Display all records 
-- select * from youtube_data;
-- Task 1: Data Exploration 
-- show all values
-- ● Identify NULL values 
-- ● Find duplicate records 
-- ● Check incorrect data types 
-- ● Identify invalid entries 


-- ● Identify NULL values 
select * from  youtube_data 
where channel_name is null 
or title is null 
 or category is null 
 or views is null
 or likes is null
 or dislikes is null
 or comments is null
 or publish_date is null
 or city  is null;
 
 -- ● Find duplicate records 
--  select * from youtube_data
--  where video_id=9001   or video_id=9011;
 
 -- select * from 
--  (select * ,
--  count(*) over(partition by  title,channel_name,category,publish_date,city) as  video_number
--  from youtube_data
--  )t
-- where video_number>1
-- ;

select count(video_id) as NO_OF_DUPLICATE_INFO,
    title,
    channel_name,
    category,
    publish_date,
    city
from youtube_data
group by 
    title,
    channel_name,
    category,
    publish_date,
    city
having count(*) >1;

-- ● Check incorrect data types 
-- ● video_id → Unique ID for each video 
-- ● channel_name → Name of the YouTube channel 
-- ● title → Video title 
-- ● category → Video category (Education / Gaming / Food / Travel / etc.) 
-- ● views → Number of views 
-- ● likes → Number of likes 
-- ● dislikes → Number of dislikes 
-- ● comments → Number of comments
select * from youtube_data ;
select *
from youtube_data where views not regexp "^[0-9]+$" or likes not regexp "^[0-9]+$" or  dislikes not regexp"^[0-9]+$" 
or comments not regexp "^[0-9]+$" or channel_name  not regexp "^[a-zA-Z0-9@_!#<$() ]+$";


-- ● Identify invalid entries 
select *
from youtube_data where views not regexp "^[0-9]+$" or likes not regexp "^[0-9]+$" or  dislikes not regexp"^[0-9]+$" 
or comments not regexp "^[0-9]+$" or channel_name  not regexp "^[a-zA-Z0-9@_!#<$() ]+$" 
   or channel_name is null or channel_name IN ('NULL', 'empty', 'unknown', '???', '','TestUser','Dummy')
   OR title        IS NULL OR title        IN ('NULL', 'empty', 'unknown', '???', '')
   OR category     IS NULL OR category     IN ('NULL', 'empty', 'unknown', '???', 'NA')
   OR views        IS NULL OR views        IN ('NULL', '???', 'NA','-2000','-1000')
   OR likes        IS NULL OR likes        IN ('NULL', '???', 'NA')
   OR dislikes     IS NULL OR dislikes     IN ('NULL', '???', 'NA','abc')
   OR comments     IS NULL OR comments     IN ('NULL', '???', 'NA')
   OR publish_date IS NULL OR publish_date IN ('NULL', '???', 'NA')
   OR city         IS NULL OR city         IN ('NULL', '???', 'NA', 'unknown')
   OR status       IS NULL OR status       IN ('NULL', '???', 'NA');
   
   
--    Task 2: Data Cleaning
--    
--    Handle Missing Values
-- Replace NULL values where possible
-- Remove rows with critical missing data
 
 create table clean_youtube_data as
select *
from youtube_data;


set sql_safe_updates=0;

-- select * from clean_youtube_data;
update clean_youtube_data
set views=0 where views not regexp"^[0-9]+$" or views is null;
update clean_youtube_data
set likes=0 where likes not regexp"^[0-9]+$" or likes is null;
update clean_youtube_data
set dislikes=0 where dislikes not regexp"^[0-9]+$" or dislikes is null;
update clean_youtube_data
set comments=0 where comments not regexp"^[0-9]+$" or comments is null;
-- select * from clean_youtube_data;
update clean_youtube_data
set status="Unkown" where status  not in ("Active","Pending","Inactive") ;
-- dealing with dates
update clean_youtube_data
set publish_date =
case
    when publish_date regexp '^[0-9]{2}-[A-Za-z]{3}-[0-9]{2}$'
        then str_to_date(publish_date,'%d-%b-%y')

    when publish_date regexp '^[0-9]{2}-[0-9]{2}-[0-9]{4}$'
        then str_to_date(publish_date,'%d-%m-%Y')
end;


-- select * from clean_youtube_data;

-- deleting the rows
delete from clean_youtube_data 
where channel_name is null or publish_date is null ;



-- Remove Duplicates
-- Identify duplicate videos using video_id
-- Keep only one valid record
-- 2.2 remove duplicates----------------

-- to identify duplicate videos using video_id---------------------------------------------------
SELECT video_id, COUNT(*)
FROM clean_youtube_data
GROUP BY video_id
HAVING COUNT(*) > 1;

-- to keep only one valid record(remove duplicate rows)------------------------------------------
SELECT video_id,channel_name,title,category,views,likes,dislikes,comments,publish_date,city,COUNT(*)
FROM clean_youtube_data
GROUP BY video_id,channel_name,title,category,views,likes,dislikes,comments,publish_date,city
HAVING COUNT(*) > 1;
-- no duplicate rows so no removal of any duplicates here------------------------------------------
-- Fix Data Types Convert columns into proper formats:----------------------------------


alter table clean_youtube_data 
modify views bigint;
alter table clean_youtube_data 
modify likes bigint;
alter table clean_youtube_data 
modify dislikes bigint;
alter table clean_youtube_data 
modify comments bigint;
alter table clean_youtube_data 
modify publish_date date;
-- ---------------------------------------------------------------------
-- Standardize Data
-- category → Proper case (Education, Gaming, Food, Travel, etc.)
-- status → (Active / Inactive / Pending)
-- city → Proper case (Hyderabad, Bangalore, Mumbai, Delhi, Chennai)
-- channel_name → Clean format
-- --------------------------------------------------->>>
update clean_youtube_data
set status =
case
when status ="active" then "Active" 
when status ="pending" then "Pending"
when status="inactive" then "Inactive"
else status
end;
update clean_youtube_data
set category=
case
when category="education" then"Education"
when category ="food " then "Food"
when category="fitness" then "Fitness" 
when category= "travel" then"Travel"
else category
end;
update clean_youtube_data
set city =
case
when city="hyd" then "Hyderabad" 
 when city ="BLR" then "Banglore" 
 else city
end;
UPDATE clean_youtube_data
SET channel_name = trim(REPLACE(channel_name, '@', '_'))
WHERE channel_name LIKE '%@%';
UPDATE clean_youtube_data
SET title = trim(REPLACE(title, '@', '_'))
WHERE title LIKE '%@%';
UPDATE clean_youtube_data
SET title = trim(REPLACE(title, '[a-zA-Z]', '_'))
WHERE title LIKE '%a-zA-Z%';



select count(*) as before_cleaning
from youtube_data;

select count(*) as after_cleaning 
from clean_youtube_data;