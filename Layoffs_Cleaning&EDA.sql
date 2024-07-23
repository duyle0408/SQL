---------------------------------------------------------DATA CLEANING--------------------------------------------------------------------

/*-- Create a backup of the original layoffs table before starting the data cleaning process.
DROP TABLE IF EXISTS LAYOFFS1;

CREATE TABLE LAYOFFS1 AS
SELECT
	*
FROM
	LAYOFFS;*/

-- Display the structure of the columns to identify which ones need to be converted or cleaned.
SELECT
	*
FROM
	LAYOFFS1;

-- Check for duplicates in the 'company' column. Note that a company might have layoffs in different periods (e.g., 2022 and 2023).
-- Therefore, partition by both company and date to ensure they are actual duplicates.
SELECT
	COMPANY,
	DATE,
	ROW_NUM
FROM
	(
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					DATE,
					COMPANY
				ORDER BY
					DATE
			) AS ROW_NUM
		FROM
			LAYOFFS1
	)
WHERE
	ROW_NUM > 1;

-- Count the number of true duplicates.
WITH
	DUPLICATE_RECORDS AS (
		SELECT
			COMPANY,
			DATE,
			ROW_NUM
		FROM
			(
				SELECT
					*,
					ROW_NUMBER() OVER (
						PARTITION BY
							DATE,
							COMPANY
						ORDER BY
							DATE
					) AS ROW_NUM
				FROM
					LAYOFFS1
			)
		WHERE
			ROW_NUM > 1
	)
-- Identify approximately 14 duplicate records.
SELECT
	COUNT(*)
FROM
	DUPLICATE_RECORDS;

-- Create a temporary table to handle duplicate records.
DROP TABLE IF EXISTS T1;

CREATE TEMP TABLE T1 AS
WITH
	CTE1 AS (
		SELECT
			*,
			ROW_NUMBER() OVER (
				PARTITION BY
					DATE
				ORDER BY
					DATE
			) AS RANK
		FROM
			LAYOFFS1
		WHERE
			COMPANY IN (
				SELECT
					COMPANY
				FROM
					(
						SELECT
							COMPANY,
							ROW_NUMBER() OVER (
								PARTITION BY
									COMPANY,
									DATE
								ORDER BY
									COMPANY,
									DATE
							) AS ROW_NUM
						FROM
							LAYOFFS1
					) AS SUBQUERY
				WHERE
					ROW_NUM > 1
			)
	)
SELECT
	*
FROM
	CTE1
WHERE
	RANK >= 1;

SELECT
	*
FROM
	T1
ORDER BY
	COMPANY ASC;

-- Remove duplicates from the main table, excluding specific companies.
DELETE FROM LAYOFFS1
WHERE
	(COMPANY, DATE) IN (
		SELECT
			COMPANY,
			DATE
		FROM
			T1
	)
	AND TOTAL_LAID_OFF IS NOT NULL
	AND PERCENTAGE_LAID_OFF IS NOT NULL
	AND COMPANY NOT IN ('IronNet', 'Sendy', 'StockX');

-- Verify the data for blank values after removing duplicates.
SELECT
	*
FROM
	LAYOFFS1;

-- Standardize columns by trimming white spaces.
UPDATE LAYOFFS1
SET
	COMPANY = TRIM(COMPANY);

UPDATE LAYOFFS1
SET
	LOCATION = TRIM(LOCATION);

UPDATE LAYOFFS1
SET
	INDUSTRY = TRIM(INDUSTRY);

UPDATE LAYOFFS1
SET
	STAGE = TRIM(STAGE);

UPDATE LAYOFFS1
SET
	COUNTRY = TRIM(COUNTRY);

-- Identify inconsistent values for the 'LOCATION' column.
SELECT DISTINCT
	LOCATION
FROM
	LAYOFFS1
ORDER BY
	LOCATION ASC;

-- Correct inconsistent location entries.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	LOCATION LIKE '%sseldorf';

UPDATE LAYOFFS1
SET
	LOCATION = 'Dusseldorf'
WHERE
	COMPANY = 'Springlane';

-- Identify and count blank values for each column.
SELECT
	COUNT(*) AS TOTAL_ROWS,
	COUNT(
		CASE
			WHEN COMPANY = '' THEN 1
		END
	) AS BLANK_COMPANY,
	COUNT(
		CASE
			WHEN LOCATION = '' THEN 1
		END
	) AS BLANK_LOCATION,
	COUNT(
		CASE
			WHEN INDUSTRY = '' THEN 1
		END
	) AS BLANK_INDUSTRY,
	COUNT(
		CASE
			WHEN STAGE = '' THEN 1
		END
	) AS BLANK_STAGE,
	COUNT(
		CASE
			WHEN COUNTRY = '' THEN 1
		END
	) AS BLANK_COUNTRY
FROM
	LAYOFFS1;

-- There are only 3 blanks, all in the 'INDUSTRY' column. Address these based on known company information.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	INDUSTRY = '';

-- Impute known industry values for specific companies.
-- Example: Airbnb.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	COMPANY = 'Airbnb';

UPDATE LAYOFFS1
SET
	INDUSTRY = 'Travel'
WHERE
	DATE = '2023-03-03';

-- Example: Juul.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	COMPANY = 'Juul';

UPDATE LAYOFFS1
SET
	INDUSTRY = 'Consumer'
WHERE
	DATE = '2022-11-10';

-- Example: Carvana.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	COMPANY = 'Carvana';

UPDATE LAYOFFS1
SET
	INDUSTRY = 'Transportation'
WHERE
	DATE = '2022-05-10';

-- Confirm successful population of the 'INDUSTRY' column.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	INDUSTRY = '';

-- Standardize 'INDUSTRY' values with common variations.
SELECT DISTINCT
	INDUSTRY
FROM
	LAYOFFS1
ORDER BY
	INDUSTRY ASC;

-- Standardize variations of 'Crypto'.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	INDUSTRY LIKE 'Crypto%';

UPDATE LAYOFFS1
SET
	INDUSTRY = 'Crypto'
WHERE
	INDUSTRY = 'CryptoCurrency'
	OR INDUSTRY = 'Crypto Currency';

-- Correct misspelled 'Transportation'.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	INDUSTRY LIKE '%Transporation%';

UPDATE LAYOFFS1
SET
	INDUSTRY = 'Transportation'
WHERE
	INDUSTRY = 'Transporation'
	AND INDUSTRY LIKE 'Trans%';

-- Standardize 'United States' entries.
SELECT DISTINCT
	COUNTRY
FROM
	LAYOFFS1
ORDER BY
	COUNTRY ASC;

UPDATE LAYOFFS1
SET
	COUNTRY = 'United States'
WHERE
	COUNTRY = 'United States.';

-- Count the null values for each column to identify missing data.
SELECT
	COUNT(*) AS TOTAL_ROWS,
	COUNT(
		CASE
			WHEN COMPANY IS NULL THEN 1
		END
	) AS MISSING_COMPANY,
	COUNT(
		CASE
			WHEN LOCATION IS NULL THEN 1
		END
	) AS MISSING_LOCATION,
	COUNT(
		CASE
			WHEN INDUSTRY IS NULL THEN 1
		END
	) AS MISSING_INDUSTRY,
	COUNT(
		CASE
			WHEN TOTAL_LAID_OFF IS NULL THEN 1
		END
	) AS MISSING_TOTAL_LAID_OFF,
	COUNT(
		CASE
			WHEN PERCENTAGE_LAID_OFF IS NULL THEN 1
		END
	) AS MISSING_PERCENTAGE,
	COUNT(
		CASE
			WHEN DATE IS NULL THEN 1
		END
	) AS MISSING_DATE,
	COUNT(
		CASE
			WHEN STAGE IS NULL THEN 1
		END
	) AS MISSING_STAGE,
	COUNT(
		CASE
			WHEN COUNTRY IS NULL THEN 1
		END
	) AS MISSING_COUNTRY,
	COUNT(
		CASE
			WHEN FUNDS_RAISED_MILLIONS IS NULL THEN 1
		END
	) AS MISSING_FUNDS
FROM
	LAYOFFS1;

-- Address the only company with a missing 'INDUSTRY' value.
-- Research indicates Bally's Corporation is in the entertainment industry.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	INDUSTRY IS NULL;

-- Impute the 'INDUSTRY' value as 'Entertainment'.
UPDATE LAYOFFS1
SET
	INDUSTRY = 'Entertainment'
WHERE
	INDUSTRY IS NULL;

-- Remove rows with missing 'DATE' information due to insufficient data for imputation.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	DATE IS NULL;

DELETE FROM LAYOFFS1
WHERE
	DATE IS NULL;

-- Impute missing 'STAGE' values with 'Unknown'.
-- Impute missing 'STAGE' values with 'Unknown'.
UPDATE LAYOFFS1
SET
	STAGE = 'Unknown'
WHERE
	STAGE IS NULL;

-- Leave the 'FUNDS_RAISED_MILLIONS' column as is due to insufficient data for imputation.
SELECT
	*
FROM
	LAYOFFS1
WHERE
	FUNDS_RAISED_MILLIONS IS NULL;

-- Delete rows where both 'TOTAL_LAID_OFF' and 'PERCENTAGE_LAID_OFF' are NULL, as at least one of these fields is essential.
DELETE FROM LAYOFFS1
WHERE
	TOTAL_LAID_OFF IS NULL
	AND PERCENTAGE_LAID_OFF IS NULL;

---------------------------------------------------EXPLORATORY DATA ANALYSIS--------------------------------------------------------------

SELECT
	*
FROM
	LAYOFFS1;

-- QUERY 1: Display the unique locations and their aggregated total layoffs for 2022 and 2023.
SELECT DISTINCT
	LOCATION,
	SUM(TOTAL_LAID_OFF) AS SUM_LAYOFFS
FROM
	LAYOFFS1
WHERE
	EXTRACT(YEAR FROM DATE) IN (2022, 2023) AND TOTAL_LAID_OFF IS NOT NULL
GROUP BY
	LOCATION
ORDER BY
	SUM_LAYOFFS DESC;

-- QUERY 2: Display locations with average layoffs greater than the average of all companies
WITH
    AVG_LAYOFFS_OVERALL AS (
        SELECT
            AVG(TOTAL_LAID_OFF) AS AVG_TOTAL_LAYOFFS
        FROM
            LAYOFFS1
    )
SELECT
    LOCATION,
    COUNT(LOCATION) AS LOCATION_COUNT,
    AVG(TOTAL_LAID_OFF) AS AVG_LAYOFFS_LOCATION,
    AVG_TOTAL_LAYOFFS
FROM
    LAYOFFS1,
    AVG_LAYOFFS_OVERALL
GROUP BY
    LOCATION,
    AVG_TOTAL_LAYOFFS
HAVING
    COUNT(LOCATION) > 1
    AND AVG(TOTAL_LAID_OFF) > AVG_TOTAL_LAYOFFS
ORDER BY
    AVG_LAYOFFS_LOCATION DESC;

SELECT * FROM LAYOFFS1 WHERE LOCATION = 'Amsterdam';

-- QUERY 3.1: Retrieve companies with the most and least layoffs in 2023.

-- Create Temp Table to query from
DROP TABLE IF EXISTS LAYOFFS_23_T;

CREATE TEMP TABLE LAYOFFS_23_T AS
WITH
	LAYOFFS_23 AS (
		SELECT
			COMPANY,
			SUM(
				CASE
					WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN TOTAL_LAID_OFF
					ELSE 0
				END
			) AS LAYOFFS_2023
		FROM
			LAYOFFS1
		GROUP BY
			COMPANY
		HAVING
			SUM(
				CASE
					WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN TOTAL_LAID_OFF
					ELSE 0
				END
			) > 0
	)
SELECT
	*
FROM
	LAYOFFS_23;

-- Retrieve the companies with the highest and lowest layoffs in 2023.
SELECT
	MAX_T.COMPANY AS COMPANY_MAX,
	MAX_T.LAYOFFS_2023 AS MAX_LAYOFFS23,
	MIN_T.COMPANY AS COMPANY_MIN,
	MIN_T.LAYOFFS_2023 AS MIN_LAYOFFS23
FROM
	LAYOFFS_23_T AS MAX_T
	JOIN LAYOFFS_23_T AS MIN_T ON MAX_T.LAYOFFS_2023 = (
		SELECT
			MAX(LAYOFFS_2023)
		FROM
			LAYOFFS_23_T
	)
	AND MIN_T.LAYOFFS_2023 = (
		SELECT
			MIN(LAYOFFS_2023)
		FROM
			LAYOFFS_23_T
	);

-- Query 3.2: Identify companies with 100% layoffs over the last 4 years, categorized into layoff percentage and calculate percentages for each year
DROP VIEW IF EXISTS BANKRUPT_COMPANIES;

CREATE VIEW BANKRUPT_COMPANIES AS
WITH
    BANKRUPT AS (
        SELECT
            COMPANY AS BANKRUPT_COMPANY,
            DATE AS BANKRUPT_DATE,
            PCT_QUARTILE
        FROM
            (
                SELECT
                    COMPANY,
                    DATE,
                    PERCENTAGE_LAID_OFF,
                    NTILE(4) OVER (
                        ORDER BY
                            PERCENTAGE_LAID_OFF DESC
                    ) AS PCT_QUARTILE
                FROM
                    LAYOFFS1
                WHERE
                    PERCENTAGE_LAID_OFF IS NOT NULL
                ORDER BY
                    PERCENTAGE_LAID_OFF DESC,
                    COMPANY ASC
            ) AS LAID_OFF_QTILE
        WHERE
            PERCENTAGE_LAID_OFF = 100.0
            AND EXTRACT(YEAR FROM DATE) IN (2020, 2021, 2022, 2023)
        ORDER BY
            COMPANY ASC
    )
SELECT
    *
FROM
    BANKRUPT;

-- Count the number of companies that went bankrupt each year.
SELECT
    EXTRACT(YEAR FROM BANKRUPT_DATE) AS YEAR,
    COUNT(*) AS BANKRUPT_COUNT
FROM
    BANKRUPT_COMPANIES
GROUP BY
    EXTRACT(YEAR FROM BANKRUPT_DATE)
ORDER BY
    YEAR;

-- Query 3.3: Calculate percentages for each year
WITH YEARLY_COUNTS AS (
    SELECT
        EXTRACT(YEAR FROM BANKRUPT_DATE) AS YEAR,
        COUNT(*) AS BANKRUPT_COUNT
    FROM
        BANKRUPT_COMPANIES
    GROUP BY
        EXTRACT(YEAR FROM BANKRUPT_DATE)
),
TOTAL_COUNT AS (
    SELECT SUM(BANKRUPT_COUNT) AS TOTAL
    FROM YEARLY_COUNTS
)
SELECT
    YEAR,
    BANKRUPT_COUNT,
    ROUND(BANKRUPT_COUNT * 100.0 / TOTAL, 2) AS PERCENTAGE
FROM
    YEARLY_COUNTS, TOTAL_COUNT
ORDER BY
    YEAR;

-- Comment: 2022 had the highest number of companies with 100% layoffs, classified as bankrupt, with 58 out of 116, making up 50% of the total.
-- Followed by 2020 with 36 out of 116, roughly 31% of the total.


-- QUERY 3.4: Identify companies that have had multiple rounds of layoffs
SELECT
	DISTINCT COMPANY,
	COUNT(TOTAL_LAID_OFF) COUNT_LAYOFFS
FROM LAYOFFS1
GROUP BY COMPANY
ORDER BY COUNT_LAYOFFS DESC;

-- Note: Some major companies like Loft, Uber and Swiggy have had repeated layoffs.


-- QUERY 4.1: Calculate the average number of layoffs by industry for each year from 2020 to 2023.
DROP TABLE IF EXISTS INDUSTRY_AVERAGE;
CREATE TEMP TABLE INDUSTRY_AVERAGE AS
SELECT
	INDUSTRY,
	AVG(
		CASE
			WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN TOTAL_LAID_OFF
			ELSE NULL
		END
	) AS AVG_LAYOFFS_23,
	AVG(
		CASE
			WHEN EXTRACT(YEAR FROM DATE) = 2022 THEN TOTAL_LAID_OFF
			ELSE NULL
		END
	) AS AVG_LAYOFFS_22,
	AVG(
		CASE
			WHEN EXTRACT(YEAR FROM DATE) = 2021 THEN TOTAL_LAID_OFF
			ELSE NULL
		END
	) AS AVG_LAYOFFS_21,
	AVG(
		CASE
			WHEN EXTRACT(YEAR FROM DATE) = 2020 THEN TOTAL_LAID_OFF
			ELSE NULL
		END
	) AS AVG_LAYOFFS_20
FROM
	LAYOFFS1
GROUP BY
	INDUSTRY;

SELECT
	*
FROM
	INDUSTRY_AVERAGE
ORDER BY
	AVG_LAYOFFS_23 DESC;

-- QUERY 5.1: Count the number of companies with layoffs each month in 2022.
-- Note: The data for 2023 is only available up to March.
SELECT
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 1 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS JAN_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 2 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS FEB_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 3 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS MAR_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 4 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS APR_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 5 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS MAY_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 6 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS JUN_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 7 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS JUL_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 8 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS AUG_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 9 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS SEP_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 10 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS OCT_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 11 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS NOV_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 12 AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS DEC_22
FROM
	LAYOFFS1;

-- Comment: A surge in layoffs started in June 2022 and remained high throughout the rest of the year.

-- QUERY 5.2: Calculate the average percentage laid off for each month in 2022.
SELECT
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 1 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS JAN_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 2 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS FEB_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 3 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS MAR_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 4 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS APR_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 5 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS MAY_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 6 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS JUN_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 7 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS JUL_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 8 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS AUG_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 9 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS SEP_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 10 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS OCT_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 11 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS NOV_22,
	AVG(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) = 12 AND EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF
		END
	) AS DEC_22
FROM
	LAYOFFS1;

-- QUERY 5.3: Identify any seasonal trends in layoffs by analyzing the number of layoffs by quarter for each year.
SELECT
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (1, 2, 3) AND EXTRACT(YEAR FROM DATE) = 2020 THEN COMPANY
		END
	) AS Q1_20,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (4, 5, 6) AND EXTRACT(YEAR FROM DATE) = 2020 THEN COMPANY
		END
	) AS Q2_20,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (7, 8, 9) AND EXTRACT(YEAR FROM DATE) = 2020 THEN COMPANY
		END
	) AS Q3_20,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (10, 11, 12) AND EXTRACT(YEAR FROM DATE) = 2020 THEN COMPANY
		END
	) AS Q4_20,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (1, 2, 3) AND EXTRACT(YEAR FROM DATE) = 2021 THEN COMPANY
		END
	) AS Q1_21,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (4, 5, 6) AND EXTRACT(YEAR FROM DATE) = 2021 THEN COMPANY
		END
	) AS Q2_21,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (7, 8, 9) AND EXTRACT(YEAR FROM DATE) = 2021 THEN COMPANY
		END
	) AS Q3_21,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (10, 11, 12) AND EXTRACT(YEAR FROM DATE) = 2021 THEN COMPANY
		END
	) AS Q4_21,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (1, 2, 3) AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS Q1_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (4, 5, 6) AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS Q2_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (7, 8, 9) AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS Q3_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (10, 11, 12) AND EXTRACT(YEAR FROM DATE) = 2022 THEN COMPANY
		END
	) AS Q4_22,
	COUNT(
		CASE
			WHEN EXTRACT(MONTH FROM DATE) IN (1, 2, 3) AND EXTRACT(YEAR FROM DATE) = 2023 THEN COMPANY
		END
	) AS Q1_23
FROM
	LAYOFFS1;

-- Comment: Significant layoffs occurred in Q1 and Q2 of 2020 due to COVID-19. Layoffs consistently increased from Q2 of 2022 onwards.

-- QUERY 6.1: Compare layoffs in 2023 to those in 2022 for companies in the tech industry.
-- Note: 'Other' is categorized in place of Tech in the dataset.
WITH TECH_LAYOFFS AS (
    SELECT
        SUM(CASE WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN TOTAL_LAID_OFF ELSE 0 END) AS TOTAL_TECH_LAYOFFS_23,
        SUM(CASE WHEN EXTRACT(YEAR FROM DATE) = 2022 THEN TOTAL_LAID_OFF ELSE 0 END) AS TOTAL_TECH_LAYOFFS_22,
        AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN PERCENTAGE_LAID_OFF END) AS AVG_PCT_23,
        AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF END) AS AVG_PCT_22
    FROM LAYOFFS1
    WHERE INDUSTRY = 'Other'
)
SELECT
    TOTAL_TECH_LAYOFFS_23,
    TOTAL_TECH_LAYOFFS_22,
    AVG_PCT_23,
    AVG_PCT_22,
    CASE 
        WHEN TOTAL_TECH_LAYOFFS_22 = 0 THEN NULL
        ELSE ROUND(100.0 * (TOTAL_TECH_LAYOFFS_23 - TOTAL_TECH_LAYOFFS_22) / TOTAL_TECH_LAYOFFS_22, 2)
    END AS SUM_DIFF_PERCENT,
    CASE 
        WHEN AVG_PCT_22 = 0 THEN NULL
        ELSE ROUND(100.0 * (AVG_PCT_23 - AVG_PCT_22) / AVG_PCT_22, 2)
    END AS AVG_DIFF_PERCENT
FROM TECH_LAYOFFS;

-- Comment: The number of tech layoffs in 2023 is approximately 4.5 times that of 2022, but the average percentage of staff laid off has decreased in 2023.

-- QUERY 7.1: Calculate the total number of layoffs for each country represented in the dataset.
WITH
	LAYOFFS_COUNTRY AS (
		SELECT
			COUNTRY,
			SUM(TOTAL_LAID_OFF) AS TOTAL_LAYOFFS
		FROM
			LAYOFFS1
		GROUP BY
			COUNTRY
		HAVING
			SUM(TOTAL_LAID_OFF) > 1 -- Filter out null values
		ORDER BY
			TOTAL_LAYOFFS DESC
	)
SELECT
	COUNTRY,
	TOTAL_LAYOFFS,
	(
		SELECT
			AVG(TOTAL_LAID_OFF)
		FROM
			LAYOFFS1
		WHERE
			TOTAL_LAID_OFF IS NOT NULL
	) AS GLOBAL_AVG_LAYOFFS,
	TOTAL_LAYOFFS - (
		SELECT
			AVG(TOTAL_LAID_OFF)
		FROM
			LAYOFFS1
		WHERE
			TOTAL_LAID_OFF IS NOT NULL
	) AS DIFF_FROM_GLOBAL_AVG
FROM
	LAYOFFS_COUNTRY
ORDER BY
	TOTAL_LAYOFFS DESC;

-- Comment: The United States has an overwhelming number of layoffs, which is 7 times higher than that of the second place, India. A total of 28 countries have higher layoff figures than the global average.

-- QUERY 8: Analyze the 2023 layoffs by the size of the company (e.g., small, medium, large) and determine if there is a significant difference in the layoff percentages.
WITH
	COMPANY_FUNDS AS (
		SELECT DISTINCT
			COMPANY,
			FUNDS_RAISED_MILLIONS,
			ROUND(AVG(PERCENTAGE_LAID_OFF), 2) AS AVG_PCT_LAID_OFF,
			CASE
				WHEN FUNDS_RAISED_MILLIONS < 10 THEN 'Small'
				WHEN FUNDS_RAISED_MILLIONS >= 10 AND FUNDS_RAISED_MILLIONS < 100 THEN 'Medium'
				ELSE 'Large'
			END AS COMPANY_SIZE
		FROM
			LAYOFFS1
		WHERE
			EXTRACT(YEAR FROM DATE) = 2023
			AND FUNDS_RAISED_MILLIONS IS NOT NULL
		GROUP BY DISTINCT
			COMPANY,
			FUNDS_RAISED_MILLIONS,
			COMPANY_SIZE
		ORDER BY
			FUNDS_RAISED_MILLIONS DESC
	)
SELECT
	COMPANY_SIZE,
	AVG(AVG_PCT_LAID_OFF) AS COMPANY_PCT_LAID_OFF
FROM
	COMPANY_FUNDS
GROUP BY
	COMPANY_SIZE
ORDER BY
	COMPANY_PCT_LAID_OFF DESC;

-- Comment: Small to medium companies tend to lay off more staff, with small firms cutting off half of their staff on average. 
-- This might be due to low funding resulting in inadequate budgets for salaries during hardships.

-- QUERY 9: Are there any industries that seem more resilient to layoffs? Compare the layoff rates across different industries over the years.
-- Drop the temporary table if it exists
DROP TABLE IF EXISTS LAYOFFS_INDUSTRIES;

-- Create the temporary table with average percentage layoffs for 2022 and 2023, and the difference
CREATE TEMP TABLE LAYOFFS_INDUSTRIES AS
SELECT
    INDUSTRY,
    AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF END) AS AVG_PCT_22,
    AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN PERCENTAGE_LAID_OFF END) AS AVG_PCT_23,
    (AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2022 THEN PERCENTAGE_LAID_OFF END)
     - AVG(CASE WHEN EXTRACT(YEAR FROM DATE) = 2023 THEN PERCENTAGE_LAID_OFF END)) AS DIFFERENCE
FROM 
    LAYOFFS1
GROUP BY
    INDUSTRY
ORDER BY
    AVG_PCT_22 ASC, AVG_PCT_23 ASC;

-- Note: The Sales industry has been extremely resilient to layoffs in both 2022 and 2023. 
-- Sales layoffs percentage has been kept at around 10% in those two years

-- Query 9.1: Identify industries that have had a decreasing layoffs percentage in 2023 compared to 2022
SELECT
    INDUSTRY,
    AVG_PCT_22,
    AVG_PCT_23,
    DIFFERENCE
FROM
    LAYOFFS_INDUSTRIES
WHERE
    DIFFERENCE > 0
ORDER BY 
    DIFFERENCE DESC;

-- Note: The top 3 industries that have slowed down their layoffs within a year includes Legal, Travel and Food
-- With the most notable difference in Legal going down 33% from 2022 to 2023.

-- Query 9.2: Identify industries that have had an INCREASING layoffs percentage in 2023 compared to 2022
SELECT
    INDUSTRY,
    AVG_PCT_22,
    AVG_PCT_23,
    DIFFERENCE
FROM
    LAYOFFS_INDUSTRIES
WHERE
    DIFFERENCE < 0
ORDER BY 
    DIFFERENCE ASC;
-- Note: On the other hand, the top 3 industries that have increased their layoffs most dramatically within a year includes Transportation, Real Estate and Education
-- With the most notable difference in Transportation going up 21% from 2022 to 2023.


----------------------------------------------------THE END---------------------------------------------------------------------




