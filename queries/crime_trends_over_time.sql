USE CrimeRecords
SELECT 
*
FROM lapd_crime_records


-- Crime trends over time 

-- How has the number of reported crimes changed year over year?
SELECT 
	YEAR(date_reported) as Years,
	count(*) as crime_reported,
	LAG(COUNT(*)) OVER(ORDER BY YEAR(date_reported)) AS prev_year_count,
	CAST(
        (COUNT(*) - LAG(COUNT(*)) OVER (ORDER BY YEAR(date_reported))) * 100.0 
        / NULLIF(LAG(COUNT(*)) OVER (ORDER BY YEAR(date_reported)), 0) 
        AS DECIMAL(5, 2)
    ) AS pct_change
FROM lapd_crime_records
GROUP BY YEAR(date_reported)
-- Which Month have the highest and lowest crime counts?

SELECT 
	MONTH(date_occurred) AS Months,
	DATENAME(month, date_occurred) AS month_name,
	COUNT(*) AS crime_counts
FROM lapd_crime_records
GROUP BY MONTH(date_occurred), DATENAME(month, date_occurred)
ORDER BY crime_counts DESC ;

-- What days of the week experience the most crime?

SELECT 
	DATENAME(DW, date_occurred) as week_number,
	DATEPART(DW, date_occurred) as day_number_order,
	CASE 
		WHEN DATENAME(DW, date_occurred) in ('Saturday', 'Sunday') THEN 'Weekend'
		ELSE 'Weekday'
	END AS day_type,
	COUNT(*) AS crime_count
FROM lapd_crime_records
GROUP BY DATENAME(DW, date_occurred), DATEPART(dw, date_occurred)
ORDER BY day_number_order

-- At what times of day do different crime categories occur most frequently?

WITH CategorizedCrimes AS (
	SELECT 
		crime_code_desc,
		time_occurred,
		CASE 
			WHEN CAST(LEFT(time_occurred, 2) AS INT) >= 5 AND CAST(LEFT(time_occurred, 2) AS INT) < 12 THEN 'Morning(05:00 - 11:59)'
			WHEN CAST(LEFT(time_occurred, 2) AS INT) >= 12 AND CAST(LEFT(time_occurred, 2) AS INT) < 17 THEN 'Afternoon(12:00 - 16:59)'
			WHEN CAST(LEFT(time_occurred, 2) AS INT) >= 17 AND CAST(LEFT(time_occurred, 2) AS INT) < 21 THEN 'Evening(17:00 - 20
			:59)'
			ELSE 'Night (21:00 - 04:59)'
		END AS time_frame
	FROM lapd_crime_records
)
SELECT 
	crime_code_desc,
	time_frame,
	COUNT(*) AS incident_count,
	RANK() OVER(PARTITION BY crime_code_desc ORDER BY COUNT(*) DESC) AS rank_in_category
FROM CategorizedCrimes
GROUP BY crime_code_desc, time_frame
ORDER BY crime_code_desc, incident_count DESC


-- Has the distribution of crime types changed over the years?

WITH AnnualCrimeTotals AS(
	SELECT 
		YEAR(date_occurred) AS crime_year,
		crime_code_desc AS crime_category,
		COUNT(*) AS category_count,
		SUM(COUNT(*)) OVER (PARTITION BY YEAR(date_occurred)) AS total_annual_crimes
	FROM lapd_crime_records
	GROUP BY YEAR(date_occurred), crime_code_desc
)
SELECT
	crime_year,
	crime_category,
	category_count,
	total_annual_crimes,
	CAST((category_count * 100.0/ total_annual_crimes) AS decimal(5,2)) AS percentage_share
FROM AnnualCrimeTotals
ORDER BY crime_year DESC, percentage_share DESC

-- How much time passes between an incident and its reporting?
	
SELECT 
record_no,
crime_code_desc,
date_occurred,
date_reported,
DATEDIFF(day, date_occurred, date_reported) AS reporting_lag_days
FROM lapd_crime_records
ORDER BY reporting_lag_days DESC



SELECT 
    CASE 
        WHEN DATEDIFF(day, date_occurred, date_reported) = 0 THEN 'Same Day'
        WHEN DATEDIFF(day, date_occurred, date_reported) BETWEEN 1 AND 7 THEN '1 to 7 Days'
        WHEN DATEDIFF(day, date_occurred, date_reported) BETWEEN 8 AND 30 THEN '1 to 4 Weeks'
        ELSE 'Over 30 Days / Delayed'
    END AS reporting_delay_category,
    COUNT(*) AS incident_count,
    CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_share
FROM lapd_crime_records
WHERE date_occurred IS NOT NULL AND date_reported IS NOT NULL
GROUP BY 
    CASE 
        WHEN DATEDIFF(day, date_occurred, date_reported) = 0 THEN 'Same Day'
        WHEN DATEDIFF(day, date_occurred, date_reported) BETWEEN 1 AND 7 THEN '1 to 7 Days'
        WHEN DATEDIFF(day, date_occurred, date_reported) BETWEEN 8 AND 30 THEN '1 to 4 Weeks'
        ELSE 'Over 30 Days / Delayed'
    END
ORDER BY incident_count DESC;