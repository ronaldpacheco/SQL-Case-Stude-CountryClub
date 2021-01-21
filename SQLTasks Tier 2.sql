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

	A1: SELECT * 
	    FROM `Facilities` 
	    WHERE `membercost` > 0;


/* Q2: How many facilities do not charge a fee to members? */
	
    A2: SELECT COUNT( * )
	FROM `Facilities`
	WHERE `membercost` = 0   #There are 4 facilities that do no charge a fee to their members.

/* Q3: Write an SQL query to show a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost.
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
    A3: SELECT `facid` , `name` , `membercost` , `monthlymaintenance`
	FROM `Facilities`
	WHERE `membercost` < `monthlymaintenance` * 0.2

/* Q4: Write an SQL query to retrieve the details of facilities with ID 1 and 5.
Try writing the query without using the OR operator. */

    A4: SELECT *
	FROM `Facilities`
	WHERE `facid`
	IN ( 1, 2 )


/* Q5: Produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100. Return the name and monthly maintenance of the facilities
in question. */

    A5: SELECT `name` , `monthlymaintenance` ,
	CASE
	WHEN `monthlymaintenance` >100
	THEN 'Expensive'
	ELSE 'Cheap'
	END AS 'Category'
	FROM `Facilities`


/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Try not to use the LIMIT clause for your solution. */

    A6: SELECT `firstname` , `surname`
	FROM `Members`
	WHERE `joindate` = (
	SELECT MAX( `joindate` )
	FROM `Members` )


/* Q7: Produce a list of all members who have used a tennis court.
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

    A7: SELECT DISTINCT (
	CONCAT( `firstname` , ' ', `surname` )) AS MemberName, f.name
	FROM Members AS m
	INNER JOIN Bookings AS b ON m.memid = b.memid
	INNER JOIN Facilities AS f ON b.facid = f.facid
	WHERE f.name LIKE '%ennis Cou%'
	ORDER BY MemberName


/* Q8: Produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30. Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */

    A8: SELECT f.name AS FacilityName, CONCAT( m.firstname, ' ', m.surname ) AS MemberName,
	CASE
	WHEN f.guestcost * b.slots >30
	THEN f.guestcost * b.slots
	WHEN f.membercost * b.slots >30
	THEN f.membercost * b.slots
	END AS cost
	FROM Facilities AS f
	INNER JOIN Bookings AS b ON f.facid = b.facid
	INNER JOIN Members AS m ON b.memid = m.memid
	WHERE b.starttime LIKE '2012-09-14%' AND f.membercost * b.slots >0 AND f.guestcost * b.slots >0
	ORDER BY cost DESC

/* Q9: This time, produce the same result as in Q8, but using a subquery. */
    A9: SELECT f.name AS FacilityName, CONCAT( firstname, ' ', surname ) AS MemberName,
	CASE
	WHEN f.guestcost * slots >30
	THEN f.guestcost * slots
	WHEN f.membercost * slots >30
	THEN f.membercost * slots
	END AS cost
	FROM (
		SELECT firstname, surname, b.slots, b.facid
		FROM Members AS m
		INNER JOIN Bookings AS b ON b.memid = m.memid
		WHERE b.starttime LIKE '2012-09-14%') AS Cost
	INNER JOIN Facilities AS f ON f.facid = Cost.facid
	WHERE f.membercost * slots >0
	AND f.guestcost * slots >0
	ORDER BY cost DESC

/* PART 2: SQLite

Export the country club data from PHPMyAdmin, and connect to a local SQLite instance from Jupyter notebook 
for the following questions.  

QUESTIONS:
/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
    A10: 
rs = con.execute('''SELECT f.name AS FacilityName,
                 CASE
	WHEN f.guestcost*slots >0
	THEN f.guestcost*slots
	WHEN f.membercost*slots >0
	THEN f.membercost*slots
	END AS cost
	
	From (select firstname, surname, b.slots, b.facid from Members as m inner join Bookings as b on b.memid= m.memid
          WHERE b.starttime LIKE '2012-09-14%' ) as Cost
    inner join Facilities AS f on f.facid = Cost.facid
	 
                 ''')
                 
df= pd.DataFrame(rs.fetchall())
df.columns = rs.keys()
df=df.groupby('FacilityName').sum()
df[df.cost < 1000].sort_values(by='cost', ascending=False)


/* Q11: Produce a report of members and who recommended them in alphabetic surname,firstname order */
    A11: 
rs = con.execute('''SELECT m1.surname, m1.firstname, m2.surname || ' ' || m2.firstname as RecommendedBy
                    FROM Members as m1
                    INNER JOIN Members as m2 
                    ON m1.recommendedby = m2.memid
                    ORDER BY m1.surname, m1.firstname
                 ''')
                 
df= pd.DataFrame(rs.fetchall())
df.columns = rs.keys()

/* Q12: Find the facilities with their usage by member, but not guests */
    12: 
rs = con.execute('''SELECT u.name as facility, u.surname || ' ' || u.firstname as MemberUsage
                    FROM (SELECT f.name as name, m.surname as surname, m.firstname as firstname 
                            FROM Members as m
                            INNER JOIN Bookings as b
                            ON b.memid = m.memid
                            
                            INNER JOIN Facilities as f
                            ON b.facid = f.facid
                            WHERE b.facid <> 0) as u
                   ''')
                 
df= pd.DataFrame(rs.fetchall())
df.columns = rs.keys()
df = df.groupby('facility')['MemberUsage'].count()

/* Q13: Find the facilities usage by month, but not guests */
    A13: 
rs = con.execute('''SELECT u.name as facility, u.surname || ' ' || u.firstname as MemberUsage, u.starttime
                    FROM (SELECT f.name as name, m.surname as surname, m.firstname as firstname, b.starttime  as starttime
                            FROM Members as m
                            INNER JOIN Bookings as b
                            ON b.memid = m.memid
                            
                            INNER JOIN Facilities as f
                            ON b.facid = f.facid
                            WHERE b.facid <> 0) as u
                   ''')
                 
df= pd.DataFrame(rs.fetchall())
df.columns = rs.keys()
df.starttime = pd.to_datetime(df.starttime)
df.starttime = df.starttime.dt.month
df.rename(columns={'starttime': 'month'}, inplace=True)
df.columns
df.groupby(['facility','month']).count()
