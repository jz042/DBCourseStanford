-- Part 0: Table creation and set up --

/* Delete the tables if they already exist */
drop table if exists Highschooler;
drop table if exists Friend;
drop table if exists Likes;
 
/* Create the schema for our tables */
create table Highschooler(ID int, name text, grade int);
create table Friend(ID1 int, ID2 int);
create table Likes(ID1 int, ID2 int);
 
/* Populate the tables with our data */
insert into Highschooler values (1510, 'Jordan', 9);
insert into Highschooler values (1689, 'Gabriel', 9);
insert into Highschooler values (1381, 'Tiffany', 9);
insert into Highschooler values (1709, 'Cassandra', 9);
insert into Highschooler values (1101, 'Haley', 10);
insert into Highschooler values (1782, 'Andrew', 10);
insert into Highschooler values (1468, 'Kris', 10);
insert into Highschooler values (1641, 'Brittany', 10);
insert into Highschooler values (1247, 'Alexis', 11);
insert into Highschooler values (1316, 'Austin', 11);
insert into Highschooler values (1911, 'Gabriel', 11);
insert into Highschooler values (1501, 'Jessica', 11);
insert into Highschooler values (1304, 'Jordan', 12);
insert into Highschooler values (1025, 'John', 12);
insert into Highschooler values (1934, 'Kyle', 12);
insert into Highschooler values (1661, 'Logan', 12);
 
insert into Friend values (1510, 1381);
insert into Friend values (1510, 1689);
insert into Friend values (1689, 1709);
insert into Friend values (1381, 1247);
insert into Friend values (1709, 1247);
insert into Friend values (1689, 1782);
insert into Friend values (1782, 1468);
insert into Friend values (1782, 1316);
insert into Friend values (1782, 1304);
insert into Friend values (1468, 1101);
insert into Friend values (1468, 1641);
insert into Friend values (1101, 1641);
insert into Friend values (1247, 1911);
insert into Friend values (1247, 1501);
insert into Friend values (1911, 1501);
insert into Friend values (1501, 1934);
insert into Friend values (1316, 1934);
insert into Friend values (1934, 1304);
insert into Friend values (1304, 1661);
insert into Friend values (1661, 1025);
insert into Friend select ID2, ID1 from Friend;
 
insert into Likes values(1689, 1709);
insert into Likes values(1709, 1689);
insert into Likes values(1782, 1709);
insert into Likes values(1911, 1247);
insert into Likes values(1247, 1468);
insert into Likes values(1641, 1468);
insert into Likes values(1316, 1304);
insert into Likes values(1501, 1934);
insert into Likes values(1934, 1501);
insert into Likes values(1025, 1101);
 
-- PART 1: SQL Social Network Query Exercises --
 
/* Q1: Find the names of all students who are friends with someone named Gabriel. */
 
select name
from highschooler join friend
on highschooler.id = friend.id1
where friend.id2 in (select id
from highschooler join friend
on highschooler.id = friend.id1
where name like "Gabriel");
 
/* Q2: For every student who likes someone 2 or more grades younger than themselves, return that student's name and grade, and the name and grade of the student they like. */
 
select H1.name, H1.grade, H2.name, H2.grade
from (likes join highschooler H1
on Likes.id1 = H1.id) join highschooler H2
on Likes.id2 = H2.id
WHERE (H1.grade - H2.grade > 1);
 
/* Q3: For every pair of students who both like each other, return the name and grade of both students. Include each pair only once, with the two names in alphabetical order. */
 
select distinct H1.name, H1.grade, H2.name, H2.grade
from likes L1, likes L2, highschooler H1, highschooler H2
where L1.id1 = L2.id2 and L2.id1 = L1.id2
and L1.id1 = H1.id and L2.id1 = H2.id
and H1.name <> H2.name;
 
/* Q4: Find all students who do not appear in the Likes table (as a student who likes or is liked) and return their names and grades. Sort by grade, then by name within each grade. */
 
select distinct name, grade
from highschooler left join
(select distinct id
from highschooler join likes
on highschooler.id = likes.id1
where likes.id1 is not null
union
select distinct id
from highschooler join likes
on highschooler.id = likes.id2
where likes.id2 is not null) as likes2
on highschooler.id = likes2.id
where likes2.id is null
order by grade, name;
 
/* Q5: For every situation where student A likes student B, but we have no information about whom B likes (that is, B does not appear as an ID1 in the Likes table), return A and B's names and grades. */
 
select distinct H1.name, H1.grade, H2.name, H2.grade
from highschooler H1, highschooler H2,
(select L1.id1, L1.id2
from likes L1 left join likes L2
on L1.id2 = L2.id1
where L2.id1 is null) as nolike
where H1.id = nolike.id1 and H2.id = nolike.id2;
 
/* Q6: Find names and grades of students who only have friends in the same grade. Return the result sorted by grade, then by name within each grade. */
 
select distinct name, grade
from highschooler
where id not in (select distinct H1.id
from highschooler H1, highschooler H2, friend
where H1.id = friend.id1 and H2.id = friend.id2 and H2.grade <> H1.grade)
order by grade, name;
 
/* Q7: For each student A who likes a student B where the two are not friends, find if they have a friend C in common (who can introduce them!). For all such trios, return the name and grade of A, B, and C. */
 
select distinct H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from likes, friend F1, friend F2, highschooler H1, highschooler H2, highschooler H3
where likes.id1 = h1.id and likes.id2 = H2.id and 
	likes.id2 not in (select id2 from friend where id1 = likes.id1) and 
	likes.id1 = F1.id1 and H3.id = F1.id2 and
	H3.id = F2.id1 and likes.id2 = F2.id2;
	
 
/* Q8: Find the difference between the number of students in the school and the number of different first names. */
 
select (numstudents - numnames) as diff from 
(select count(distinct id) as numstudents from highschooler h1) as students, 
(select count(distinct name) as numnames from highschooler h2) as names;
 
/* Q9: Find the name and grade of all students who are liked by more than one other student. */
 
select name, grade from highschooler, 
(select id2 from likes group by id2 having count(id2) > 1) as popular
where id = id2;
 
 
-- PART 2: SQL Social Network Query Exercises Extras --
 
/* Q1: For every situation where student A likes student B, but student B likes a different student C, return the names and grades of A, B, and C.  */
 
select H1.name, H1.grade, H2.name, H2.grade, H3.name, H3.grade
from likes L3, likes L4, highschooler H1, highschooler H2, highschooler H3
where L3.id1 not in
(select L2.id1 from likes L1, likes L2 where L1.id2 = L2.id1 and L2.id2=L1.id1)
and L3.id2 = L4.id1
and L3.id1 = H1.id
and L3.id2 = H2.id
and L4.id2 = H3.id;
 
/* Q2: Find those students for whom all of their friends are in different grades from themselves. Return the students' names and grades. */
 
select distinct H3.name, H3.grade
from highschooler H3
where H3.id not in
(select distinct F1.id1
from Friend F1, highschooler H1, highschooler H2
where F1.id1 = H1.id
and F1.id2 = H2.id
and H1.grade = H2.grade);

 
/* Q3: What is the average number of friends per student? (Your result should be just one number.) */
 
select avg(numfriends)
from (select id1, count(id2) as numfriends
from friend
group by id1) as friendcount;
 
/* Q4: Find the number of students who are either friends with Cassandra or are friends of friends of Cassandra. Do not count Cassandra, even though technically she is a friend of a friend.  */
 
select count(id2)
from (select id2 
from (select distinct id2
from friend, highschooler
where name like "cassandra"
and friend.id1 = highschooler.id) as cassfriends
union
select id2 
from (select distinct id2
from friend, highschooler H2
where id1 in (select id2
from friend, highschooler
where name like "cassandra"
and friend.id1 = highschooler.id)
and friend.id2 = H2.id
and H2.name not like "cassandra") as friendsoffriends) as allfriends;
 
/* Q5: Find the name and grade of the student(s) with the greatest number of friends. */
 
select name, grade
from friend, highschooler
where id=id1
group by id1
having count(id2) = (select max(numfriends) from
(select id1, count(id2) as numfriends
from friend
group by id1) as friendcount);

-- Part 3: Modification Exercises --

/* Q1: It's time for the seniors to graduate. Remove all 12th graders from Highschooler. */

delete from Highschooler
where grade = 12;

select * from Highschooler order by ID;

/* Q2: If two students A and B are friends, and A likes B but not vice-versa, remove the Likes tuple. */

delete from likes
where id1 in
(select l1.id1 from likes L1 left join likes L2 on L2.id1 = L1.id2
where (L1.id1 <> L2.id2 or L2.id1 is null)
and L1.id2 in (select id2 from friend where friend.id1 = L1.id1));

select H1.name, H1.grade, H2.name, H2.grade from Likes L, Highschooler H1, Highschooler H2 where L.ID1 = H1.ID and L.ID2 = H2.ID order by H1.name, H1.grade;

/* Q3: For all cases where A is friends with B, and B is friends with C, add a new friendship for the pair A and C. Do not add duplicate friendships, friendships that already exist, or friendships with oneself. (This one is a bit challenging; congratulations if you get it right.) */

-- note: this only works in MySQL and not in SQLite...

insert into friend
select distinct * from 
(select f1.id1, f2.id2
from friend f1, friend f2
where f1.id2 = f2.id1
and f2.id2 <> f1.id1) as newadd
where (newadd.id1, newadd.id2) not in
(select distinct allnew.id1, allnew.id2 from 
(select f1.id1, f2.id2
from friend f1, friend f2
where f1.id2 = f2.id1
and f2.id2 <> f1.id1) as allnew
inner join friend f3
on f3.id1 = allnew.id1
and f3.id2 = allnew.id2);

select ID, name, grade, (select count(*) from Friend where id1 = H.id) from Highschooler H order by ID;
