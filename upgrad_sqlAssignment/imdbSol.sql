USE imdb;

/* Now that you have imported the data sets, let’s explore some of the tables. 
 To begin with, it is beneficial to know the shape of the tables and whether any column has null values.
 Further in this segment, you will take a look at 'movies' and 'genre' tables.*/



-- Segment 1:




-- Q1. Find the total number of rows in each table of the schema?
-- Type your code below:
	 SELECT table_name, table_rows
	 FROM INFORMATION_SCHEMA.TABLES
	 WHERE TABLE_SCHEMA = 'imdb';
     


-- Q2. Which columns in the movie table have null values?
-- Type your code below:
SELECT *
FROM movie
WHERE title+ year+ date_published+ duration+ country+ worlwide_gross_income+ languages+ production_company IS NULL;


-- Now as you can see four columns of the movie table has null values. Let's look at the at the movies released each year. 
-- Q3. Find the total number of movies released each year? How does the trend look month wise? (Output expected)

/* Output format for the first part:

+---------------+-------------------+
| Year			|	number_of_movies|
+-------------------+----------------
|	2017		|	2134			|
|	2018		|		.			|
|	2019		|		.			|
+---------------+-------------------+


Output format for the second part of the question:
+---------------+-------------------+
|	month_num	|	number_of_movies|
+---------------+----------------
|	1			|	 134			|
|	2			|	 231			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT year, count(id) as number_of_movies
from movie 
group by year;

SELECT month(date_published) as num_month, count(id)
FROM movie
GROUP BY num_month
ORDER BY num_month;








/*The highest number of movies is produced in the month of March.
So, now that you have understood the month-wise trend of movies, let’s take a look at the other details in the movies table. 
We know USA and India produces huge number of movies each year. Lets find the number of movies produced by USA or India for the last year.*/
  
-- Q4. How many movies were produced in the USA or India in the year 2019??
-- Type your code below:

SELECT count(id)
from movie
WHERE year = 2019 and country = 'USA' or country = 'INDIA' ;





/* USA and India produced more than a thousand movies(you know the exact number!) in the year 2019.
Exploring table Genre would be fun!! 
Let’s find out the different genres in the dataset.*/

-- Q5. Find the unique list of the genres present in the data set?
-- Type your code below:

SELECT DISTINCT genre
FROM genre;


/* So, RSVP Movies plans to make a movie of one of these genres.
Now, wouldn’t you want to know which genre had the highest number of movies produced in the last year?
Combining both the movie and genres table can give more interesting insights. */

-- Q6.Which genre had the highest number of movies produced overall?
-- Type your code below:

SELECT g.genre, count(m.id) as number_of_movies
FROM movie as m
	INNER JOIN 
    genre as g
ON m.id= g.movie_id
GROUP BY g.genre
ORDER BY number_of_movies DESC;







/* So, based on the insight that you just drew, RSVP Movies should focus on the ‘Drama’ genre. 
But wait, it is too early to decide. A movie can belong to two or more genres. 
So, let’s find out the count of movies that belong to only one genre.*/

-- Q7. How many movies belong to only one genre?
-- Type your code below:
WITH countG as
(
	SELECT movie_id, count(genre) as genreCount
	FROM genre
	GROUP BY movie_id
)
SELECT count(movie_id)
FROM countG
WHERE genreCount= 1;




/* There are more than three thousand movies which has only one genre associated with them.
So, this figure appears significant. 
Now, let's find out the possible duration of RSVP Movies’ next project.*/

-- Q8.What is the average duration of movies in each genre? 
-- (Note: The same movie can belong to multiple genres.)


/* Output format:

+---------------+-------------------+
| genre			|	avg_duration	|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:


SELECT g.genre, 
	   AVG(m.duration) as avg_duration
FROM movie as m
	INNER JOIN 
    genre as g
ON m.id= g.movie_id
GROUP BY g.genre;






/* Now you know, movies of genre 'Drama' (produced highest in number in 2019) has the average duration of 106.77 mins.
Lets find where the movies of genre 'thriller' on the basis of number of movies.*/

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
-- (Hint: Use the Rank function)


/* Output format:
+---------------+-------------------+---------------------+
| genre			|		movie_count	|		genre_rank    |	
+---------------+-------------------+---------------------+
|drama			|	2312			|			2		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:


SELECT g.genre, count(m.id) as movie_count,
	   RANK() OVER(ORDER BY count(m.id) DESC) as genre_rank
FROM movie as m
	INNER JOIN 
    genre as g
ON m.id= g.movie_id
GROUP BY g.genre;








/*Thriller movies is in top 3 among all genres in terms of number of movies
 In the previous segment, you analysed the movies and genres tables. 
 In this segment, you will analyse the ratings table as well.
To start with lets get the min and max values of different columns in the table*/




-- Segment 2:




-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
| min_avg_rating|	max_avg_rating	|	min_total_votes   |	max_total_votes 	 |min_median_rating|min_median_rating|
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+
|		0		|			5		|	       177		  |	   2000	    		 |		0	       |	8			 |
+---------------+-------------------+---------------------+----------------------+-----------------+-----------------+*/
-- Type your code below:

SELECT min(avg_rating) as min_avg_rating,
	   max(avg_rating) as max_avg_rating, 
       min(total_votes) as min_avg_rating,
       max(total_votes) as max_avg_rating,
       min(median_rating) as min_median_rating, 
       max(median_rating) as max_median_rating
	FROM ratings;


/* So, the minimum and maximum values in each column of the ratings table are in the expected range. 
This implies there are no outliers in the table. 
Now, let’s find out the top 10 movies based on average rating.*/

-- Q11. Which are the top 10 movies based on average rating?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		movie_rank    |
+---------------+-------------------+---------------------+
| Fan			|		9.6			|			5	  	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:
-- It's ok if RANK() or DENSE_RANK() is used too

WITH rankAvgR AS
	(
	SELECT m.title,
		   r.avg_rating,
		   DENSE_RANK() OVER(ORDER BY r.avg_rating DESC) as movie_rank
		FROM movie as m
		INNER JOIN 
		ratings as r
	ON m.id = r.movie_id
)
SELECT title,
	   avg_rating,
       movie_rank
FROM rankAvgR
WHERE movie_rank <= 10;


/* Do you find you favourite movie FAN in the top 10 movies with an average rating of 9.6? If not, please check your code again!!
So, now that you know the top 10 movies, do you think character actors and filler actors can be from these movies?
Summarising the ratings table based on the movie counts by median rating can give an excellent insight.*/

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
/* Output format:

+---------------+-------------------+
| median_rating	|	movie_count		|
+-------------------+----------------
|	1			|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:
-- Order by is good to have

SELECT r.median_rating, 
	   count(id) as movie_count
FROM  movie as m
		INNER JOIN 
		ratings as r
	ON m.id = r.movie_id
GROUP BY r.median_rating
ORDER BY r.median_rating;
    





/* Movies with a median rating of 7 is highest in number. 
Now, let's find out the production house with which RSVP Movies can partner for its next project.*/

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
/* Output format:
+------------------+-------------------+---------------------+
|production_company|movie_count	       |	prod_company_rank|
+------------------+-------------------+---------------------+
| The Archers	   |		1		   |			1	  	 |
+------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT m.production_company,
	   count(m.id) as movie_count,
       RANK() OVER(ORDER BY  count(m.id) DESC) as prod_company_rank
 FROM  movie as m
		INNER JOIN 
		ratings as r
	ON m.id = r.movie_id
WHERE r.avg_rating > 8
GROUP BY production_company;



-- It's ok if RANK() or DENSE_RANK() is used too
-- Answer can be Dream Warrior Pictures or National Theatre Live or both

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
/* Output format:

+---------------+-------------------+
| genre			|	movie_count		|
+-------------------+----------------
|	thriller	|		105			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT g.genre,
	   count(m.id) as movie_count
	FROM movie as m
		 inner join
         ratings as r
         ON m.id= r.movie_id
         inner join 
         genre as g
         ON m.id= g.movie_id
WHERE month(m.date_published) = 3 and m.year= 2017 and r.total_votes > 1000
GROUP BY g.genre
ORDER BY movie_count DESC;



-- Lets try to analyse with a unique problem statement.
-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
/* Output format:
+---------------+-------------------+---------------------+
| title			|		avg_rating	|		genre	      |
+---------------+-------------------+---------------------+
| Theeran		|		8.3			|		Thriller	  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
|	.			|		.			|			.		  |
+---------------+-------------------+---------------------+*/
-- Type your code below:

SELECT 
    m.title, r.avg_rating, g.genre
FROM
    movie AS m
        INNER JOIN
    ratings AS r ON m.id = r.movie_id
        INNER JOIN
    genre AS g 
    ON m.id = g.movie_id
WHERE r.avg_rating > 8 and m.title LIKE 'The%';
	



-- You should also try your hand at median rating and check whether the ‘median rating’ column gives any significant insights.
-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
-- Type your code below:
SELECT count(m.id)
FROM movie as m
	inner join
    ratings as r
    ON m.id = r.movie_id
WHERE m.date_published> '2018-04-01' and m.date_published < '2019-04-01' and r.median_rating = 8 ;


-- Once again, try to solve the problem given below.
-- Q17. Do German movies get more votes than Italian movies? 
-- Hint: Here you have to find the total number of votes for both German and Italian movies.
-- Type your code below:

SELECT m.country, 
	   sum(r.total_votes) as total_votes
	FROM 
    movie as m 
    inner join 
    ratings as r
    ON m.id = r.movie_id
Group by m.country;








-- Answer is Yes

/* Now that you have analysed the movies, genres and ratings tables, let us now analyse another table, the names table. 
Let’s begin by searching for null values in the tables.*/




-- Segment 3:



-- Q18. Which columns in the names table have null values??
/*Hint: You can find null values for individual columns or follow below output format
+---------------+-------------------+---------------------+----------------------+
| name_nulls	|	height_nulls	|date_of_birth_nulls  |known_for_movies_nulls|
+---------------+-------------------+---------------------+----------------------+
|		0		|			123		|	       1234		  |	   12345	    	 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

select count(if(name is null, 1, NULL)) as name_nulls,
	   count(if(height is null, 1, NULL)) as height_nulls,
       count(if(date_of_birth is null, 1, NULL)) as date_of_birth_nulls,
       count(if(known_for_movies is null, 1, NULL)) as known_for_movies_nulls
 from names;
 





/* There are no Null value in the column 'name'.
The director is the most important person in a movie crew. 
Let’s find out the top three directors in the top three genres who can be hired by RSVP Movies.*/

-- Q19. Who are the top three directors in the top three genres whose movies have an average rating > 8?
-- (Hint: The top three genres would have the most number of movies with an average rating > 8.)
/* Output format:

+---------------+-------------------+
| director_name	|	movie_count		|
+---------------+-------------------|
|James Mangold	|		4			|
|	.			|		.			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

	SELECT g.genre, 
		   count(g.movie_id),
		   RANK() OVER(ORDER BY count(g.movie_id) DESC) as rank_genre
		FROM genre as g
		inner join 
		ratings as r 
	ON g.movie_id = r.movie_id
	where r.avg_rating > 8 
	group by g.genre;
    
    
SELECT name,
	   count(r.movie_id) as movie_count
FROM  
      ratings as r
      inner join 
      director_mapping as d
      on r.movie_id = d.movie_id
       inner join
      names as n
      ON n.id = d.name_id
      inner join 
      genre as g
      on r.movie_id = g.movie_id
	WHERE avg_rating > 8 and genre = 'Drama'+'Action'+'Comedy'
    GROUP BY n.name
    Order by movie_count desc limit 3 ;
    







/* James Mangold can be hired as the director for RSVP's next project. Do you remeber his movies, 'Logan' and 'The Wolverine'. 
Now, let’s find out the top two actors.*/

-- Q20. Who are the top two actors whose movies have a median rating >= 8?
/* Output format:

+---------------+-------------------+
| actor_name	|	movie_count		|
+-------------------+----------------
|Christain Bale	|		10			|
|	.			|		.			|
+---------------+-------------------+ */
-- Type your code below:

SELECT 
    name AS actor_name, COUNT(r.movie_id) AS movie_count
FROM
    ratings AS r
        INNER JOIN
    role_mapping AS rm ON r.movie_id = rm.movie_id
        INNER JOIN
    names AS n ON rm.name_id = n.id
WHERE
    r.median_rating >= 8
        AND rm.category = 'Actor'
GROUP BY n.name
ORDER BY movie_count DESC
LIMIT 2;

/* Have you find your favourite actor 'Mohanlal' in the list. If no, please check your code again. 
RSVP Movies plans to partner with other global production houses. 
Let’s find out the top three production houses in the world.*/

-- Q21. Which are the top three production houses based on the number of votes received by their movies?
/* Output format:
+------------------+--------------------+---------------------+
|production_company|vote_count			|		prod_comp_rank|
+------------------+--------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:
SELECT production_company, 
	   vote_count,
       prod_comp_rank
FROM
(
SELECT m.production_company,
	   r.total_votes as vote_count,
       rank() over(order by r.total_votes DESC) as prod_comp_rank 
FROM movie as m 
	 inner join 
     ratings as r
     on m.id = r.movie_id
GROUP BY m.production_company
Order by prod_comp_rank
) as topProd where prod_comp_rank <=3;






/*Yes Marvel Studios rules the movie world.
So, these are the top three production houses based on the number of votes received by the movies they have produced.

Since RSVP Movies is based out of Mumbai, India also wants to woo its local audience. 
RSVP Movies also wants to hire a few Indian actors for its upcoming project to give a regional feel. 
Let’s find who these actors could be.*/

-- Q22. Rank actors with movies released in India based on their average ratings. Which actor is at the top of the list?
-- Note: The actor should have acted in at least five Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actor_name	|	total_votes		|	movie_count		  |	actor_avg_rating 	 |actor_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Yogi Babu	|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:
	  
SELECT a.name as actor_name, c.total_votes, COUNT(c.movie_id) as movie_count,c.avg_rating as actor_avg_rating,
RANK() OVER( PARTITION BY
            d.category = 'actor'
            ORDER BY 
            c.avg_rating DESC
            ) actor_rank
FROM names a, movie b, ratings c, role_mapping d    
where b.country = 'INDIA'
       and b.id = c.movie_id
       and b.id= d.movie_id
       and a.id = d.name_id
    
group by actor_name
having count(d.movie_id) >= 5
order by actor_avg_rating desc
;

SELECT a.name as actor_name, c.total_votes, COUNT(c.movie_id) as movie_count,c.avg_rating as actor_avg_rating,
RANK() OVER( PARTITION BY
            d.category = 'actor'
            ORDER BY 
            c.avg_rating DESC
            ) actor_rank
FROM names a, movie b, ratings c, role_mapping d    
where b.country = 'INDIA'
       and b.id = c.movie_id
       and b.id= d.movie_id
       and a.id = d.name_id
    
group by actor_name
having count(d.movie_id) >= 5
order by actor_avg_rating desc
;  


-- Top actor is Vijay Sethupathi

-- Q23.Find out the top five actresses in Hindi movies released in India based on their average ratings? 
-- Note: The actresses should have acted in at least three Indian movies. 
-- (Hint: You should use the weighted average based on votes. If the ratings clash, then the total number of votes should act as the tie breaker.)
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |	actress_avg_rating 	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Tabu		|			3455	|	       11		  |	   8.42	    		 |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.name as actor_name, r.total_votes as total_votes, count(r.movie_id) as movie_count, sum(r.avg_rating)/count(r.movie_id) as avg_rating,
	   RANK() OVER( Order by sum(r.avg_rating)/count(r.movie_id) DESC, r.total_votes DESC) as actress_rank
FROM names as n, movie as m,  ratings as r, role_mapping as rm
WHERE m.country= 'India'
	  and rm.category = 'actress'
	  and m.id = rm.movie_id
      and rm.name_id= n.id
      and rm.movie_id = r.movie_id
GROUP BY n.name 
HAVING movie_count >= 3
Order by avg_rating desc;



/* Taapsee Pannu tops with average rating 7.74. 
Now let us divide all the thriller movies in the following categories and find out their numbers.*/


/* Q24. Select thriller movies as per avg rating and classify them in the following category: 

			Rating > 8: Superhit movies
			Rating between 7 and 8: Hit movies
			Rating between 5 and 7: One-time-watch movies
			Rating < 5: Flop movies
--------------------------------------------------------------------------------------------*/
-- Type your code below:

SELECT 
    g.genre,
    r.avg_rating,
    CASE
        WHEN r.avg_rating > 8 THEN 'Superhit movies'
        WHEN r.avg_rating BETWEEN 7 AND 8 THEN 'hit movies'
        WHEN r.avg_rating BETWEEN 5 AND 7 THEN 'one-time watch'
        ELSE 'Flop movies'
    END AS movie_type
FROM
    genre AS g
        INNER JOIN
    ratings AS r ON g.movie_id = r.movie_id
WHERE
    g.genre = 'Thriller';







/* Until now, you have analysed various tables of the data set. 
Now, you will perform some tasks that will give you a broader understanding of the data in this segment.*/

-- Segment 4:

-- Q25. What is the genre-wise running total and moving average of the average movie duration? 
-- (Note: You need to show the output table in the question.) 
/* Output format:
+---------------+-------------------+---------------------+----------------------+
| genre			|	avg_duration	|running_total_duration|moving_avg_duration  |
+---------------+-------------------+---------------------+----------------------+
|	comdy		|			145		|	       106.2	  |	   128.42	    	 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
|		.		|			.		|	       .		  |	   .	    		 |
+---------------+-------------------+---------------------+----------------------+*/
-- Type your code below:

SELECT genre,
    ROUND(AVG(duration),2) AS avg_duration,
    SUM(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS UNBOUNDED 
    PRECEDING) AS running_total_duration,
    AVG(ROUND(AVG(duration),2)) OVER(ORDER BY genre ROWS 10 PRECEDING) 
    AS moving_avg_duration
FROM movie AS m 
INNER JOIN genre AS g 
ON m.id= g.movie_id
GROUP BY genre
ORDER BY genre;









-- Round is good to have and not a must have; Same thing applies to sorting


-- Let us find top 5 movies of each year with top 3 genres.

-- Q26. Which are the five highest-grossing movies of each year that belong to the top three genres? 
-- (Note: The top 3 genres would have the most number of movies.)

/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| genre			|	year			|	movie_name		  |worldwide_gross_income|movie_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	comedy		|			2017	|	       indian	  |	   $103244842	     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

-- Top 3 Genres based on most number of movies

SELECT g.genre, m.year, m.title, m.worlwide_gross_income
FROM genre g, movie m
WHERE g.movie_id = m.id and g.genre in (Select genre from genre  group by genre order by count(movie_id) DESC limit 3);




-- Finally, let’s find out the names of the top two production houses that have produced the highest number of hits among multilingual movies.
-- Q27.  Which are the top two production houses that have produced the highest number of hits (median rating >= 8) among multilingual movies?
/* Output format:
+-------------------+-------------------+---------------------+
|production_company |movie_count		|		prod_comp_rank|
+-------------------+-------------------+---------------------+
| The Archers		|		830			|		1	  		  |
|	.				|		.			|			.		  |
|	.				|		.			|			.		  |
+-------------------+-------------------+---------------------+*/
-- Type your code below:

Select * from movie;
SELECT m.production_company ,count(m.id) as movie_count , m.languages 
from movie m, ratings r 
where languages like '%,%' and r.median_rating >= 8
	  and m.id = r.movie_id
group by m.production_company
Order by movie_count desc;


-- Multilingual is the important piece in the above question. It was created using POSITION(',' IN languages)>0 logic
-- If there is a comma, that means the movie is of more than one language


-- Q28. Who are the top 3 actresses based on number of Super Hit movies (average rating >8) in drama genre?
/* Output format:
+---------------+-------------------+---------------------+----------------------+-----------------+
| actress_name	|	total_votes		|	movie_count		  |actress_avg_rating	 |actress_rank	   |
+---------------+-------------------+---------------------+----------------------+-----------------+
|	Laura Dern	|			1016	|	       1		  |	   9.60			     |		1	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
|		.		|			.		|	       .		  |	   .	    		 |		.	       |
+---------------+-------------------+---------------------+----------------------+-----------------+*/
-- Type your code below:

SELECT n.name as actress_name, r.total_votes, count(r.movie_id) as movie_count, avg(r.avg_rating) as actress_avg_rating,
	   dense_Rank() Over( partition by rm.category = 'actress' order by count(r.movie_id)  desc, total_votes desc) as actress_rank 
from names n, ratings r, role_mapping rm, genre g
where r.avg_rating > 8 and 
      rm.category = 'actress' and 
      g.genre = 'drama' and
	  n.id = rm.name_id and
      r.movie_id = rm.movie_id and
      rm.movie_id = g.movie_id 
GROUP BY n.name 
Order by actress_rank asc
limit 3;





/* Q29. Get the following details for top 9 directors (based on number of movies)
Director id
Name
Number of movies
Average inter movie duration in days
Average movie ratings
Total votes
Min rating
Max rating
total movie durations

Format:
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
| director_id	|	director_name	|	number_of_movies  |	avg_inter_movie_days |	avg_rating	| total_votes  | min_rating	| max_rating | total_duration |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+
|nm1777967		|	A.L. Vijay		|			5		  |	       177			 |	   5.65	    |	1754	   |	3.7		|	6.9		 |		613		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
|	.			|		.			|			.		  |	       .			 |	   .	    |	.		   |	.		|	.		 |		.		  |
+---------------+-------------------+---------------------+----------------------+--------------+--------------+------------+------------+----------------+

--------------------------------------------------------------------------------------------*/
-- Type you code below:


SELECT d.name_id as director_id, n.name as director_name,count(d.movie_id) as number_of_movies, sum( m.duration)/(60*24) as avg_inter_movie_days,
	    r.avg_rating, sum(r.total_votes) as total_votes, min(r.avg_rating) as min_rating, max(r.avg_rating) as max_rating,
       sum(m.duration) as total_duration
from movie m, ratings r, director_mapping d, names n
where m.id = d.movie_id and
	  n.id = d.name_id and 
      d.movie_id = r.movie_id
group by n.name
order by number_of_movies desc;



    