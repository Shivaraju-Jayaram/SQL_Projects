# Netflix Data Analytics

![Netflix Logo](https://github.com/Shivaraju-Jayaram/Images/blob/main/logo%20(1).png)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives
Analyze the distribution of content types (movies vs TV shows).
Identify the most common ratings for movies and TV shows.
List and analyze content based on release years, countries, and durations.
Explore and categorize content based on specific criteria and keywords.

## Dataset
The data for this project is sourced from the Kaggle dataset:
Dataset: [Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema
```SQL
CREATE TABLE netflix (
	show_id       VARCHAR(7),
	show_type     VARCHAR(10),
	title         VARCHAR(150),
	director      VARCHAR(250),
	casts         VARCHAR(1000),
	country	      VARCHAR(150),
	date_added    VARCHAR(50),
	release_year  INT,
	rating        VARCHAR(10),
	duration      VARCHAR(25),
	listed_in     VARCHAR(100),
	description   VARCHAR(300)
)
```
## Business Problem and Solutions
### 1. Count the number of Movies vs TV Shows
```SQL
SELECT
    show_type,
    COUNT(*) no_of_shows
FROM netflix
GROUP BY show_type
```
### 2. Find the most common rating for movies and TV shows
```SQL
SELECT
    show_type,
    rating
FROM(
    SELECT
        show_type,
        rating,
        COUNT(*),
        RANK() OVER(PARTITION BY show_type ORDER BY COUNT(*) DESC) ranking
    FROM netflix
    GROUP BY 1, 2
    ORDER BY 1, 3 DESC ) t1
WHERE ranking = 1
```

### 3. List all movies released in a specific year (e.g., 2020)
```SQL
SELECT * 
FROM netflix
WHERE
    show_type = 'Movie' AND
    release_year = 2020
```
### 4. Find the top 5 countries with the most content on Netflix
```SQL
SELECT
    TRIM(new_country),
    COUNT(*)
FROM (
      SELECT
          UNNEST(STRING_TO_ARRAY(country, ',')) new_country
      FROM netflix ) country_list
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5
```

### 5. Identify the longest movie
```SQL
SELECT *
FROM netflix
WHERE
    show_type = 'Movie' AND
    SPLIT_PART(duration, ' ', 1)::INTEGER = (
                                              SELECT MAX(SPLIT_PART(duration, ' ', 1)::INTEGER)
                                              FROM netflix )
```
### 6. Find content added in the last 5 years
```SQL
SELECT *
FROM netflix
WHERE
    TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years'
```
### 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
```SQL
SELECT *
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%'
```
### 8. List all TV shows with more than 5 seasons
```SQL
SELECT
    *,
    SPLIT_PART(duration, ' ', 1)::INTEGER season_duration
FROM netflix
WHERE
    show_type = 'TV Show' AND
    SPLIT_PART(duration, ' ', 1)::INTEGER > 5
```
### 9. Count the number of content items in each genre
```SQL
SELECT
    TRIM(Genre) AS Genre,
    COUNT(show_id) AS Total_Content
FROM(
      SELECT
          DISTINCT UNNEST(STRING_TO_ARRAY(listed_in, ',')) Genre,
          show_id
      FROM netflix ) genres
GROUP BY 1
```
### 10.Find each year and the average numbers of content release in India on netflix return top 5 year with highest avg content release!
```SQL
SELECT
    EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
    COUNT(*) yearly_count,
    ROUND(COUNT(*)::NUMERIC/(
                            SELECT COUNT(*)
                            FROM netflix
                            WHERE country LIKE '%India%')::NUMERIC * 100, 2) as avg_content_per_year
FROM netflix
WHERE country LIKE '%India%'
GROUP BY 1
```
### 11. List all movies that are documentaries
```SQL
SELECT *
FROM netflix
WHERE
    show_type = 'Movie' AND
    listed_in ILIKE '%Documentaries%'
```
### 12. Find all content without a director
```SQL
SELECT * 
FROM netflix
WHERE director IS NULL
```
### 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
```SQL
SELECT *
FROM netflix
WHERE
    casts ILIKE '%Salman Khan%' AND
    release_year >= EXTRACT(YEAR FROM CURRENT_DATE) - 10
```
### 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
```SQL
SELECT
    TRIM(actors),
    COUNT(*)
FROM(
      SELECT 
          UNNEST(STRING_TO_ARRAY(casts, ',')) actors, country
      FROM netflix)
WHERE country LIKE '%India%'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10
```
### 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
```SQL
SELECT
    category,
    COUNT(*)
FROM (
      SELECT
          *,
          CASE WHEN description ILIKE '%kill%' OR
                    description ILIKE '%violence%' THEN 'Bad'
          ELSE 'Good' END category
      FROM netflix ) category
GROUP BY 1
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.

## Findings and Conclusion
* **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
* **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
* **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
* **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.


This analysis provides a comprehensive view of Netflix's content and can help inform content strategy and decision-making.
