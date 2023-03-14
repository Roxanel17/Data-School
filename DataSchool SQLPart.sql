--- Netflix | DisneyPlus
 
--- 1. How many distinct registrations are captured in each dataset?
--- Data have been cleaned before using Python and then imported into SQL.
--- That means we have 8789 distinct observations for Netflix, 1447 for DisneyPlus, and 4803 for IMDb.
SELECT COUNT(DISTINCT show_id) AS Distinct_Registrations_Netflix
    FROM netflix

SELECT COUNT(DISTINCT show_id) AS Distinct_Registrations_DisneyPlus
    FROM disneyPlus

SELECT COUNT(DISTINCT Name) AS Distinct_Registrations_Imdb
    FROM imdb

--- 2. What is the number of movies vs TV shows in the Netflix dataset? What is the number of movies vs TV shows in the DisneyPlus dataset?
--- We've found 6124 movies and 2665 tv shows in the Netflix dataset.
--- We've found 1049 movies and 398 tv shows in the Disney Plus dataset.
SELECT COUNT(show_id) AS No_Shows_Netflix, type
    FROM netflix
    GROUP BY [type]

SELECT COUNT(show_id) AS No_Shows_DisneyPlus, type
    FROM disneyPlus
    GROUP BY [type]

--- 3. Number of Content added through the Years
--- E.G. In 2021 were added 1497 productions.

SELECT YEAR(date_added) AS Year, COUNT(show_id) AS No_Productions_Year
    FROM netflix
    GROUP BY YEAR(date_added) 
    ORDER BY YEAR(date_added)  DESC
--- And if we want to see the data grouped by type, we use this query that says we have 992 movies and 505 tv shows produced in 2021. 
SELECT YEAR(date_added) AS Year, COUNT(show_id) AS No_Productions_Year, [type]
    FROM netflix
    GROUP BY YEAR(date_added), [type]
    ORDER BY YEAR(date_added) DESC

--- 4. What is the oldest Movie on Netflix? (based on release date). What is the oldest Movie on DisneyPlus? (based on release date)
--- The oldest two movies on Netflix are Prelude to War and The Battle of Midway, both of them released in 1942.
--- The oldest movie on Disney Plus is Steamboat Willie, which was released in 1928.
SELECT TOP(2) show_id, type, title, YEAR(release_year) AS Release_Year
    FROM netflix
    WHERE type = 'Movie'
    ORDER BY YEAR(release_year) ASC

SELECT TOP(1) show_id, type, title, release_year
    FROM disneyPlus
    WHERE type = 'Movie'
    ORDER BY release_year ASC

--- 5. What are the TV shows with the largest number of seasons on Netflix? What are the TV shows with the largest number of seasons on DisneyPlus?
--- Grey's Anatomy has the largest no of seasons on Netflix (17).
    SELECT TOP(1) show_id, title, [type], CAST(duration AS int) AS duration, unit_measure
        FROM netflix
        WHERE unit_measure = 'Season'
        ORDER BY CAST(duration AS int) DESC

---- The Simpsons has the largest no of seasons on Disney Plus (32).
SELECT TOP(1) show_id, title, [type], CAST(duration AS int) AS duration, unit_measure
    FROM disneyPlus
    WHERE unit_measure = 'Season'
    ORDER BY CAST(duration AS int) DESC

--- 6. What is the shortest movie on Netflix? What is the shortest movie on DisneyPlus?
--- The Shortest movie on Netflix is Silent which lasts 3 minutes.
SELECT TOP(1) show_id, title, [type], CAST(duration AS int) AS duration, unit_measure
    FROM netflix
    WHERE type = 'Movie'
    ORDER BY CAST(duration AS int) ASC

--- The Shortest movies on Disney Plus last 2 minutes; I found 8 such movies (America the Beautiful, Limitless with Chris Hemsworth, etc.)
--- [SOLVED IN PYTHON] Baymax! has 1 season and it doesn't last 1 minute. The same issue I encountered in Obi-Wan Kenobi and The Proud Family: Louder and Prouder.
--- -> changed the type from "Movie" into "Series" and unit_measure from "Season" to "min"
SELECT TOP(9) show_id, title, [type], CAST(duration AS int) AS duration, unit_measure
    FROM disneyPlus
    WHERE type = 'Movie'
    ORDER BY CAST(duration AS int) ASC

--- 7. Assuming I have 60 mins available and I want to watch a documentary on Netflix, what are my possibilities?
--- There are 181 possibilities if someone would want to watch a documentary and have only 60 minutes in his/ her spare time. 
SELECT title, [type], duration, listed_in
    FROM netflix
    WHERE listed_in LIKE '%Documentaries%' AND duration <= 60
    ORDER BY duration DESC
    
--- IMDb
--- 1. What is the most-voted Movie on IMDb?
--- The most-voted film on IMDb is The Shawshank Redemption, with 2474122 votes.
SELECT TOP(1) *
    FROM imdb
    WHERE [Type] = 'Film'
    ORDER BY CAST(Votes AS int) DESC

--- 2. What is the highest-rated movie on IMDb? What is the highest-rated Series on IMDb?
--- The highest-rated movies on IMDb are The Shawshank Redemption and Toma, both of which have a rate equal to 9.3.
SELECT TOP(2) Name, Rate, Type
    FROM imdb
    WHERE Type ='Film'
    ORDER BY Rate DESC

--- The highest-rated series on IMDb is Aspirants, with a rate of 9.7.
SELECT TOP (1) Name, Rate, Type
    FROM imdb
    WHERE Type = 'Series'
    ORDER BY Rate DESC

--- 3. What is the average rate of all the productions that contain all Nudity, Violence, Profanity, Alcohol, and Frightening scenes rated as ‘Severe;
--- The average rate is 7.326.
SELECT AVG(CAST(Rate AS float)) AS Average_IMDb_Rate
    FROM imdb
    WHERE Nudity LIKE '%Severe%' AND Violence LIKE '%Severe%' AND Profanity LIKE '%Severe%' AND Alcohol LIKE '%Severe%' AND Frightening LIKE '%Severe%'

--- 4. How many Netflix productions have ratings available on IMDb? (join Netflix data with imdb data based on the title - hint)
--- There are 1060 Netflix productions available on IMDb. An inner join will search for the common observations between the two tables. 
SELECT COUNT(n.title) AS Netflix_Productions_Available_IMDb
    FROM netflix n
    INNER JOIN imdb i
    ON n.title = i.Name

--- 5. What are the ratings of the movies you recommended here -> 
---     (Assuming I have 60 mins available and I want to watch a documentary on Netflix, what are my possibilities?) 
---     (join Netflix data with IMDb data based on the title - hint)
--- Only two Netflix documentaries are rated on IMDb: Limitless (7.4) and Long Shot (6.8)
SELECT n.title, n.type, n.duration, n.listed_in, i.Rate
    FROM netflix n
    INNER JOIN imdb i
    --- LEFT JOIN imdb i --- Most documentaries available on Netflix don't have a correspondent rate in the IMDb database. 
    ON n.title = i.Name
    WHERE n.listed_in LIKE '%Documentaries%' AND n.duration <= 60
    ORDER BY n.duration DESC
    
--- Create an unique key for joining Netflix and IMDb data, based on title and release_year
--- After that, save the output as csv
--- INSIGHTS: 
---     1. Joining the two tables only on title will return an outout of 1060 movies and tv shows available both on Netflix and IMDb
---     2. But, joining on an unique key "title+release_year" will create an output with 653 rows, meaning that for 407 registrations were created remakes ~ 38.40%. 
SELECT *
    FROM netflix n 
    INNER JOIN imdb i
    ON n.title + ' ' + n.release_year = i.Name + ' ' + i.[Date]



--- SELECT ALL COMMON DATA FROM IMDB & NETFLIX & DISNEY PLUS AND SAVE AS CSV
SELECT n.show_id, n.[type], n.title, n.director, n.cast, n.country, n.date_added, n.release_year, n.rating, n.duration AS Minutes_Or_NoSeasons, n.unit_measure, i.Duration AS Minutes_Show, 
        i.Episodes, i.Rate, i.Votes, i.Genre, i.Nudity, i.Violence, i.Profanity, i.Alcohol, i.Frightening
    FROM netflix n
    INNER JOIN imdb i 
    ON  n.title = i.Name

SELECT d.show_id, d.[type], d.title, d.director, d.cast, d.country, d.date_added, d.release_year, d.rating, d.duration AS Minutes_Or_NoSeasons, d.unit_measure, i.Duration AS Minutes_Show, 
        i.Episodes, i.Rate, i.Votes, i.Genre, i.Nudity, i.Violence, i.Profanity, i.Alcohol, i.Frightening
    FROM disneyPlus d
    INNER JOIN imdb i 
    ON  d.title = i.Name
