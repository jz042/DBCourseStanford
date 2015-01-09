/* Delete the tables if they already exist */
drop table if exists Movie;
drop table if exists Reviewer;
drop table if exists Rating;

/* Create the schema for our tables */
create table Movie(mID int, title text, year int, director text);
create table Reviewer(rID int, name text);
create table Rating(rID int, mID int, stars int, ratingDate date);

/* Populate the tables with our data */
insert into Movie values(101, 'Gone with the Wind', 1939, 'Victor Fleming');
insert into Movie values(102, 'Star Wars', 1977, 'George Lucas');
insert into Movie values(103, 'The Sound of Music', 1965, 'Robert Wise');
insert into Movie values(104, 'E.T.', 1982, 'Steven Spielberg');
insert into Movie values(105, 'Titanic', 1997, 'James Cameron');
insert into Movie values(106, 'Snow White', 1937, null);
insert into Movie values(107, 'Avatar', 2009, 'James Cameron');
insert into Movie values(108, 'Raiders of the Lost Ark', 1981, 'Steven Spielberg');

insert into Reviewer values(201, 'Sarah Martinez');
insert into Reviewer values(202, 'Daniel Lewis');
insert into Reviewer values(203, 'Brittany Harris');
insert into Reviewer values(204, 'Mike Anderson');
insert into Reviewer values(205, 'Chris Jackson');
insert into Reviewer values(206, 'Elizabeth Thomas');
insert into Reviewer values(207, 'James Cameron');
insert into Reviewer values(208, 'Ashley White');

insert into Rating values(201, 101, 2, '2011-01-22');
insert into Rating values(201, 101, 4, '2011-01-27');
insert into Rating values(202, 106, 4, null);
insert into Rating values(203, 103, 2, '2011-01-20');
insert into Rating values(203, 108, 4, '2011-01-12');
insert into Rating values(203, 108, 2, '2011-01-30');
insert into Rating values(204, 101, 3, '2011-01-09');
insert into Rating values(205, 103, 3, '2011-01-27');
insert into Rating values(205, 104, 2, '2011-01-22');
insert into Rating values(205, 108, 4, null);
insert into Rating values(206, 107, 3, '2011-01-15');
insert into Rating values(206, 106, 5, '2011-01-19');
insert into Rating values(207, 107, 5, '2011-01-20');
insert into Rating values(208, 104, 3, '2011-01-02');


-- PART 1: MOVIE-RATING QUERY EXERCISES --

/* Q1: Find the titles of all movies directed by Steven Spielberg. */

SELECT title
FROM Movie
WHERE director = "Steven Spielberg";


/* Q2: Find all years that have a movie that received a rating of 4 or 5, and sort them in increasing order. */

SELECT DISTINCT year
FROM Movie
INNER JOIN Rating
ON Movie.mID = Rating.MID
WHERE Rating.stars > 3;


/* Q3: Find the titles of all movies that have no ratings. */

SELECT DISTINCT title
FROM Movie
LEFT JOIN Rating
ON Movie.mID = Rating.MID
WHERE Rating.stars IS NULL;


/* Q4: Some reviewers didn't provide a date with their rating. Find the names of all reviewers who have ratings with a NULL value for the date. */

SELECT name
FROM Reviewer
INNER JOIN Rating
ON Reviewer.rID = Rating.rID
WHERE Rating.ratingdate IS NULL;


/* Q5: Write a query to return the ratings data in a more readable format: reviewer name, movie title, stars, and ratingDate. Also, sort the data, first by reviewer name, then by movie title, and lastly by number of stars. */

SELECT name, title, stars, ratingdate
FROM Movie
INNER JOIN Rating
ON Movie.mID = Rating.mID
INNER JOIN Reviewer
ON Reviewer.rID = Rating.rID
ORDER BY name, title, stars;


/* Q6: For all cases where the same reviewer rated the same movie twice and gave it a higher rating the second time, return the reviewer's name and the title of the movie. */

SELECT DISTINCT name, title
FROM Movie
INNER JOIN Rating
ON Movie.mID = Rating.mID
INNER JOIN Reviewer
ON Rating.rID = Reviewer.rID
WHERE Movie.mID = (SELECT mID
FROM Rating M1
WHERE EXISTS (SELECT * FROM Rating M2 WHERE 
M1.mID = M2.mID AND M1.rID = M2.rID
AND M1.ratingdate > M2.ratingdate
AND M1.stars > M2.stars))
AND Rating.rID = (SELECT rID
FROM Rating M1
WHERE EXISTS (SELECT * FROM Rating M2 WHERE 
M1.mID = M2.mID AND M1.rID = M2.rID
AND M1.ratingdate > M2.ratingdate
AND M1.stars > M2.stars));


/* Q7: For each movie that has at least one rating, find the highest number of stars that movie received. Return the movie title and number of stars. Sort by movie title. */

SELECT DISTINCT Movie.title, stars AS MaxStars
FROM Rating M1
INNER JOIN Movie
ON Movie.mID = M1.mID
WHERE NOT EXISTS (SELECT * FROM Rating M2
WHERE M1.stars<M2.stars AND M1.mID = M2.mID);


/* Q8: For each movie, return the title and the 'rating spread', that is, the difference between highest and lowest ratings given to that movie. Sort by rating spread from highest to lowest, then by movie title. */

SELECT title, MAX(stars)-MIN(stars) AS Spread
FROM Rating
INNER JOIN Movie
ON MOVIE.MID = RATING.MID
GROUP BY Rating.mID
ORDER BY Spread DESC, title;


/* Q9: Find the difference between the average rating of movies released before 1980 and the average rating of movies released after 1980. (Make sure to calculate the average rating for each movie, then the average of those averages for movies before 1980 and movies after. Don't just calculate the overall average rating before and after 1980.) */

SELECT avg(A2)-avg(A1)
FROM (SELECT AVG(stars) AS A1
FROM Rating
INNER JOIN Movie
WHERE Rating.mID = Movie.mID AND year>1980
GROUP BY title) AS R1,
(SELECT AVG(stars) AS A2
FROM Rating
INNER JOIN Movie
WHERE Rating.mID = Movie.mID AND year<1980
GROUP BY title) AS R2;


-- PART 2: MOVIE-RATING QUERY EXTRAS --

/* Q1: Find the names of all reviewers who rated Gone with the Wind. */

select distinct name
FROM Reviewer, Movie, Rating
WHERE Reviewer.rID = Rating.rID and Rating.mID = Movie.mID
AND title = "Gone with the Wind";

/* Q2: For any rating where the reviewer is the same as the director of the movie, return the reviewer name, movie title, and number of stars. */

select distinct name, title, stars
FROM Reviewer, Movie, Rating
WHERE Reviewer.rID = Rating.rID and Rating.mID = Movie.mID
AND director=name;

/* Q3: Return all reviewer names and movie names together in a single list, alphabetized. (Sorting by the first name of the reviewer and first word in the title is fine; no need for special processing on last names or removing "The".) */

select distinct name
FROM Reviewer
UNION
SELECT distinct title
FROM Movie;

/* Q4: Find the titles of all movies not reviewed by Chris Jackson. */

select TITLE
FROM MOVIE
WHERE mID NOT IN (select Movie.mID
FROM Reviewer, Movie, Rating
WHERE Reviewer.rID = Rating.rID and Rating.mID = Movie.mID
AND name like "Chris Jackson");

/* Q5: For all pairs of reviewers such that both reviewers gave a rating to the same movie, return the names of both reviewers. Eliminate duplicates, don't pair reviewers with themselves, and include each pair only once. For each pair, return the names in the pair in alphabetical order. */

-- incomplete...

SELECT DISTINCT title, w1.name, w2.name
FROM Rating R1, Rating R2, movie, reviewer W1, reviewer W2
WHERE R1.rID <> R2.rID AND R1.mID = R2.mID
and R1.rID = W1.rID and R2.rID = W2.rID and R1.mID = movie.mID
order by title


/* Q6: For each rating that is the lowest (fewest stars) currently in the database, return the reviewer name, movie title, and number of stars. */

SELECT name, title, stars
FROM Rating R1 INNER JOIN Movie
ON R1.mID = Movie.mID
INNER JOIN Reviewer
ON R1.rID = Reviewer.rID
WHERE stars in (select min(stars) from rating);

/* Q7: List movie titles and average ratings, from highest-rated to lowest-rated. If two or more movies have the same average rating, list them in alphabetical order. */

SELECT title, avg(stars)
from rating, movie
where rating.mID = movie.mID
group by rating.mID
order by avg(stars) desc, title;


/* Q8: Find the names of all reviewers who have contributed three or more ratings. (As an extra challenge, try writing the query without HAVING or without COUNT.) */

select distinct name
from reviewer natural join rating
where rating.rID in (select rid 
from (select rID, count(rID) as num
from rating 
group by rID) as reviewers
where num>2);


/* Q9: Some directors directed more than one movie. For all such directors, return the titles of all movies directed by them, along with the director name. Sort by director name, then movie title. (As an extra challenge, try writing the query both with and without COUNT.) */

select title, director
from movie
where director in (
select director from (
select director, count(title) as num from movie group by director) as dirnummovies
where num > 1)
order by director, title;

/* Q10: Find the movie(s) with the highest average rating. Return the movie title(s) and average rating. (Hint: This query is more difficult to write in SQLite than other systems; you might think of it as finding the highest average rating and then choosing the movie(s) with that average rating.) */

select title, avg(stars) as s
from rating, movie
where movie.mid = rating.mid
group by rating.mID
order by avg(stars) desc
limit 1;


/* Q11: Find the movie(s) with the lowest average rating. Return the movie title(s) and average rating. (Hint: This query may be more difficult to write in SQLite than other systems; you might think of it as finding the lowest average rating and then choosing the movie(s) with that average rating.) */

select title, avg(stars)
from rating natural join movie group by mID
having avg(stars) = 
(select min(s) from (select mID, avg(stars) as s from rating group by mID) as lowestavg);


/* Q12: For each director, return the director's name together with the title(s) of the movie(s) they directed that received the highest rating among all of their movies, and the value of that rating. Ignore movies whose director is NULL. */

select director, title, max(stars) as s
from rating natural join movie
where director is not null
group by director
order by stars desc;