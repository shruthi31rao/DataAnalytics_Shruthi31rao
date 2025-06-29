use crowdfunddatabase;
select * from creator;
select * from category;
select * from location;
select * from calendar;
select * from projects;

-- CHANGE COLUMN NAME IN THE TABLE
alter table calendar rename column Created_Date TO created_Date;
alter table maindata rename column ï»¿id TO project_id;

-- CONVERT EPOCH TIME TO NORMAL TIME
alter table projects add column created_date datetime after created_at;
update projects set created_date =from_unixtime(created_at);

alter table projects add column updated_date datetime after updated_at;
update projects set updated_date =from_unixtime(updated_at);

alter table projects add column state_changed_date datetime after state_changed_at;
update projects set  state_changed_date =from_unixtime( state_changed_at);

alter table projects add column launched_date datetime after launched_at;
update projects set  launched_date =from_unixtime(launched_at);

alter table projects add column successful_date datetime after successful_at;
update projects set successful_date =from_unixtime(cast(successful_at as unsigned), '%Y-%m-%d') where successful_at regexp '^[0-9]+$';


-- 5 TOTAL NUMBER OF PROJECTS BASED ON OUTCOME
select state, count(ProjectID) as outcome from projects
group by state;

-- 5 TOTAL NUMBER OF PROJECTS BASED ON LOCATION
select country, count(ProjectID) as outcome from projects
group by country
limit 10;

-- 5 TOTAL NUMBER OF PROJECTS BASED ON CATEGORY
select C.name, count(P.ProjectID) as TotalProjects from projects P
inner join  category C on P.category_id =C.category_id 
group by  C.name
order by TotalProjects desc
limit 20;

-- 5 TOTAL NUMDER OF PROJECTS  CREATED BY YEAR,MONTH,QUARTER
select YEAR (created_date) as YEAR,
MONTH(created_date) as MONTH,
QUARTER(created_date) as QUARTER,
count(ProjectID) as TOTAL_PROJECTS
FROM projects
GROUP BY YEAR (created_date) ,
MONTH (created_date) ,
QUARTER(created_date)
ORDER BY count(ProjectID) desc,
YEAR ,MONTH
LIMIT 10;


-- 6 AMOUNT RAISED
SELECT state,sum(goal*static_usd_rate) As TOTALRAISEDAMOUNT FROM projects
where state='successful';

-- 6 TOTAL NUMBER OF BACKERS COUNT;
select state,sum(backers_count) As TOTALBACKERSCOUNT FROM projects
where state='successful';

-- 6 TOTAL AVG NUMBER OF DAYS FOR SUCCESSFUL PROJECTS
select state,avg(datediff(successful_date, created_date)) as AvgDays from projects
where state = 'successful'
group by state;


-- 7 TOP SUCCESSFUL PROJECTS BASED ON NUMBER OF BACKERS
select name,sum(backers_count) AS TOTALBACKERS from projects
where state ='successful'
group by name
order by sum(backers_count)desc
limit 10;

-- 7 TOP SUCCESSFUL PROJECTS BASED ON AMOUNT RAISED
select name,sum(goal*static_usd_rate)as Total from projects
where state ='successful'
group by name
order by sum(goal*static_usd_rate) desc
limit 10;


-- 8 PERCENTAGE OF  SUCCESSFUL PROJECTS OVERALL
SELECT 
    concat(round((sum(state = 'successful') * 100.0) / COUNT(*)),'%') AS success_rate
FROM projects;


-- 8 PERCENTAGE OF  SUCCESSFUL PROJECTS BY CATEGORY
SELECT C.name,concat(cast(round((sum(P.state = 'successful') * 100.0) / COUNT(*),2) as decimal(5,2)),'%') AS success_rate
FROM projects P right join category C on P.category_id =  C.category_id
group by name
order by success_rate desc ;

SELECT C.name,sum(P.state = 'successful') * 100.0 / COUNT(*) AS success_rate
FROM projects P right join category C on P.category_id =  C.category_id
group by name
order by  success_rate desc;

-- 8 PERCENTAGE OF  SUCCESSFUL PROJECTS  Year , Month etc..
SELECT YEAR (created_date) as YEAR,
MONTH(created_date) as MONTH,
QUARTER(created_date) as QUARTER,
    concat(round((sum(state = 'successful') * 100.0) / COUNT(*)),'%') AS success_rate
FROM projects
GROUP BY YEAR (created_date) ,
MONTH (created_date) ,
QUARTER(created_date)
ORDER BY count(ProjectID) desc,
YEAR ,MONTH
LIMIT 10;

SELECT YEAR (created_date) as YEAR,
MONTH(created_date) as MONTH,
QUARTER(created_date) as QUARTER,
    (sum(state = 'successful') * 100.0) / COUNT(*) AS success_rate
FROM projects
GROUP BY YEAR (created_date) ,
MONTH (created_date) ,
QUARTER(created_date)
ORDER BY count(ProjectID) desc,
YEAR ,MONTH
LIMIT 10;



-- 8 PERCENTAGE OF  SUCCESSFUL PROJECTS OVERALL BY GOAL RANGE
ALTER TABLE projects ADD COLUMN goal_amount NUMERIC;
UPDATE projects SET goal_amount = (goal*static_usd_rate);

 
SELECT 
    CASE 
        WHEN goal_amount <= 5000 THEN '0–5k'
        WHEN goal_amount <= 10000 THEN '5k–10k'
        WHEN goal_amount <= 20000 THEN '10k–20k'
        ELSE '20k+'
    END AS goal_range,
	concat(round((sum(state = 'successful') * 100.0) / COUNT(*)),'%') AS success_rate
FROM projects
GROUP BY goal_range;





