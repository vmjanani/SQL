/* Welcome to the SQL mini project. You will carry out this project partly in
the PHPMyAdmin interface, and partly in Jupyter via a Python connection.

This is Tier 2 of the case study, which means that there'll be less guidance for you about how to setup
your local SQLite connection in PART 2 of the case study. This will make the case study more challenging for you: 
you might need to do some digging, aand revise the Working with Relational Databases in Python chapter in the previous resource.

Otherwise, the questions in the case study are exactly the same as with Tier 1. 

PART 1: PHPMyAdmin
You will complete questions 1-9 below in the PHPMyAdmin interface. 
Log in by pasting the following URL into your browser, and
using the following Username and Password:

URL: https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

In this case study, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */


/* QUESTIONS 
/* Q1: Some of the facilities charge a fee to members, but some do not.
Write a SQL query to produce a list of the names of the facilities that do. */
SELECT name FROM Facilities 
where membercost>0

/* Q2: How many facilities do not charge a fee to members? */
SELECT count(name) FROM Facilities
where membercost=0

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
Select facid,name, membercost,monthlymaintenance from Facilities
where membercost < .2 * (monthlymaintenance) and membercost >0

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

Select * from Facilities 
where facid IN(1,5)

/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */
SELECT `facid`, `name`, `membercost`, `guestcost`, `initialoutlay`, `monthlymaintenance`
, (case when monthlymaintenance >100 then 'Expensive'
	else 'Cheap'
end) as category
FROM `Facilities` 

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */
Select 
firstname,surname
from Members 
where joindate=(
SELECT 
MAX(joindate)
FROM `Members` )


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */
Select name ,
CONCAT (M.firstname,M.surname) as membername
from Members as M
inner join Bookings as B 
on M.memid= B.memid
inner join Facilities as F
on F.facid= B.facid
GROUP BY M.firstname
Having F.name like 'Tennis%'




/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost,but using a subquery.  and do not use any subqueries. */
SELECT 
F.name AS Facility, 
CONCAT (M.firstname,M.surname) AS membername,
(CASE
WHEN M.memid =0
THEN B.slots * F.guestcost
ELSE B.slots * F.membercost
END
) AS Cost
FROM Bookings AS B
INNER JOIN Members AS M ON M.memid = B.memid
INNER JOIN Facilities AS F ON B.facid = F.facid
WHERE 
starttime > '2012-09-14'
AND starttime < '2012-09-15'
AND (
(M.memid =0
AND B.slots * F.guestcost >30)

OR 
(M.memid !=0
AND B.slots * F.membercost >30)

)
ORDER BY Cost DESC


    
/* Q9: This time, produce the same result as in Q8, but using a subquery. */

	SELECT 
			s.Facility,
			s.membername,
	s.Cost 
	from (


	SELECT F.name as Facility,
	CONCAT (M.firstname,M.surname) as membername
	, (
	CASE
	WHEN M.memid =0
	THEN B.slots*F.guestcost
	ELSE B.slots*F.membercost
	END
	) AS Cost from
	Bookings as B
	inner join Members as M
	on M.memid= B.memid
	inner join Facilities F
	on B.facid=F.facid
	 WHERE (starttime >='2012-09-14 00:00:00' and starttime<'2012-09-15 00:00:00'
			
			)
	) as s
	where Cost >30 
	order by Cost desc

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
Select name ,
SUM(CASE
WHEN M.memid =0
THEN B.slots * F.guestcost
ELSE B.slots * F.membercost
END
) AS Total_Revenue
from Members as M
inner join Bookings as B 
on M.memid= B.memid
inner join Facilities as F
on F.facid= B.facid
GROUP BY name
HAVING Total_Revenue<1000



/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
SELECT 
	 --m.recommendedby,
    --r.memid,
	--m.memid,
	CONCAT (m.firstname,m.surname) as membername,
	CONCAT (r.firstname,r.surname) as recommendedby
FROM Members m 
join Members r
on m.recommendedby = r.memid
order by r.surname,r.firstname
----In case when i have it in the jupyter notebook it will be just 21 , guest are not being shown

/* Q12: Find the facilities with their usage by member, but not guests */
SELECT F.facid ,COUNT(F.facid) as Facility_Usage , F.name as Facility_Name
FROM Facilities F
INNER JOIN Bookings B ON F.facid = B.facid
INNER JOIN Members M ON B.memid = M.memid
where M.memid !=0
GROUP BY F.facid
ORDER BY  F.facid,COUNT( F.facid )


/* Q13: Find the facilities usage by month, but not guests */
select B.Months as Months, count(F.facid)as Facility_Usage_Month FROM(
SELECT facid, EXTRACT(MONTH FROM starttime) as Months from Bookings 
where memid !=0) as B
inner join Facilities F 
on B.facid=F.facid
GROUP BY B.Months
ORDER BY B.Months


select B.Months as Months, count(F.facid)as Facility_Usage_Month FROM(
SELECT facid, DATE_FORMAT(starttime, "%c") as Months from Bookings 
where memid !=0) as B
inner join Facilities F 
on B.facid=F.facid
GROUP BY B.Months
ORDER BY B.Months

