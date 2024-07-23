## Executive Summary

### Data Dictionary:
- **company**: Name of the company
- **location**: The city/branch of the company that laid off employees
- **industry**: Sector which the company operates in
- **total_laid_off**: Number of employees laid off in that round
- **percentage_laid_off**: Percentage of employees laid off in the company
- **date**: The date the layoff round happened. Time periods span from 2020 to 2023.
- **stage**: Growth stage of the company
- **country**: Country where the layoff round happened
- **funds_raised_millions**: Most recent amount of money gained from a funding round (in millions USD)

### Situation:
In recent years, the job market has experienced significant fluctuations, especially in terms of layoffs across various industries. To better understand these trends and their implications, an analysis was conducted using data from [Kaggle Layoffs Dataset](https://www.kaggle.com/datasets/emaoyeyiola/exploring-the-layoffs-dataset) and related SQL queries.

### Task:
The 3 main tasks of this analysis were:

1. **Import CSV into PostgreSQL database**
2. **Clean and preprocess the raw dataset to ensure data quality**
3. **Conduct Exploratory Data Analysis to answer many questions/queries**

Example queries included:
- Display the unique locations and their aggregated total layoffs for 2022 and 2023.
- Show locations with average layoffs greater than the average of all companies.
- Retrieve companies with the most and least layoffs in 2023.
- Identify companies with 100% layoffs over the last 4 years, categorized based on layoff percentage.
- Count the number of companies that went bankrupt each year and percentage overall.
- Identify companies that have had multiple rounds of layoffs.
- Calculate the average number of layoffs by industry for each year from 2020 to 2023.
- Identify any seasonal trends in layoffs by analyzing the number of layoffs by quarter for each year.
- Compare layoffs in 2023 to those in 2022 for companies in the Tech industry.
- Calculate the total number of layoffs for each country represented in the dataset.
- Analyze the 2023 layoffs by the size of the company (e.g., small, medium, large) and determine if there is a significant difference in the layoff percentages.
- Identify industries that seem more resilient to layoffs by comparing the layoff rates across different industries over the years.

### Action

#### Data Import
- A new table named "Layoffs" was created, with column names and data types specified based on the CSV file.
- The data was imported into the PostgreSQL database for querying.

#### Data Cleaning:
- A copy of the original table was created to ensure the integrity of the raw data.
- **Dropping/Imputing Inconsistent Values**: Corrected spelling errors, standardized text values, handled blanks, and addressed critical columns with missing values.
- **Handling Duplicates**: Identified and removed duplicate records.
- **Managing Missing Values**: Assessed and imputed missing values using appropriate methods or dropped records with excessive missing data.

#### Exploratory Data Analysis
- The analysis began with a basic SELECT query to understand the table's structure.
- Various queries were run to answer specific questions about layoffs by location, company, industry, and more.

### Results
**Key Insights:**
- **Locations with the Most Layoffs**: The San Francisco Bay Area, Seattle, and New York City experienced the highest number of layoffs.
- **Average Layoffs by Location**: Amsterdam, Shenzhen, and Phoenix had the highest average layoffs per location, indicating significant layoffs involving major companies.
- **Companies with Most and Least Layoffs in 2023**: Google had the highest single layoff event in 2023, while Kinde had the smallest.
- **100% Layoffs Over Four Years**: The year 2022 had the highest number of companies with 100% layoffs, indicating significant industry disruptions.
- **Companies with Multiple Layoff Rounds**: Major companies like Loft, Uber, and Swiggy had more than four layoff rounds.
- **Average Layoffs by Industry (2020-2023)**: Industries like Hardware, Sales, and Tech showed significant increases in average layoffs from 2022 to 2023.
- **Seasonal Trends in Layoffs**: No consistent seasonal trend, with significant layoffs occurring during the COVID-19 pandemic in early 2020 and increasing again from Q2 2022 onwards.
- **Tech Industry Layoffs (2022 vs. 2023)**: The number of tech layoffs in 2023 was approximately 4.5 times that of 2022, but the average percentage of staff laid off decreased.
- **Total Layoffs by Country**: The United States had an overwhelming number of layoffs, significantly higher than other countries.
- **Layoffs by Company Size**: Smaller companies tended to lay off more staff, with small firms cutting off half of their staff on average.
- **Industry Resilience to Layoffs**: The Sales industry maintained a low layoff percentage, indicating resilience in both 2022 and 2023.
  ------------------------------------------------------------ DETAILS -----------------------------------------------------------------------------------
-- Dataset Comprehension:
![image](https://github.com/user-attachments/assets/70329bf6-3921-4a95-85f2-7c34a7373c55)

#### Data Import
First, we'll create a new table in the Tables section called "Layoffs" fill in the column names from the CSV file into the database and specify their data types and length/precision.

![image](https://github.com/user-attachments/assets/577cd344-4cf8-4ba0-9119-c928c9c12865)

Next, using the import/export tool, we are going to link the CSV file to our database and define the necessary format and encoding we want. 
Then we'll have the data available for querying.
(partial code)![image](https://github.com/user-attachments/assets/349175ea-641c-4c93-8123-6344e372c774)




#### Data Cleaning:
- Before we start any data cleaning process and analysis, it is always good practice to make a copy of the original table and work on the copy itself
  
- ![image](https://github.com/user-attachments/assets/4964c407-ffe2-4442-99e2-2829ab3f95e3)

- Since the dataset was raw and would be difficult to draw insights from without cleaning, the data underwent a thorough scrubbing phase. The key steps in this phase included:
- 
  - **Dropping/Imputing Inconsistent Values:**
    - Correcting spelling errors and standardizing text values for consistency.
    - Handling blanks by either imputing missing values where appropriate or dropping rows/columns that were not critical for the analysis.
    - Below is one example - see full script for more details
      
    - ![image](https://github.com/user-attachments/assets/9e475374-05df-46c1-9cec-f571ad1098ee)
      

  - **Handling Duplicates:**
    - Identifying and removing duplicate records to ensure that each observation was unique and representative of actual layoff events.
    - Below is one example - see full script for more details
    - ![image](https://github.com/user-attachments/assets/b59091e1-aa8d-4a35-a2e5-6d31bdd5354f)
  
    - ![image](https://github.com/user-attachments/assets/b9d8e731-3c0c-41f8-8f10-b98bd332404c)
  
  - **Managing Missing Values:**
    - Assessing the extent and pattern of missing data.
    - Imputing missing values using appropriate statistical methods or domain knowledge.
    - Dropping records with excessive missing values that could not be reliably imputed.
    - Below is one example - see full script for more details.
    - ![image](https://github.com/user-attachments/assets/4ddec0b5-8cef-49a3-b13e-1d7eed74f98b)

#### Exploratory Data Analysis
- Prior to starting our analysis, we should always begin with the phrase "SELECT * FROM TABLE" to get a good view of what the table looks like
  
- ![image](https://github.com/user-attachments/assets/09e6e6bc-fb06-4d24-b841-038309981526)

- Now we can start answering the questions listed above
  **Display the unique locations and their aggregated total layoffs for 2022 and 2023.**
  ![image](https://github.com/user-attachments/assets/f2e5f123-a83c-45d3-9043-10416473d465)
  
  This query identifies and ranks locations by the total number of layoffs in 2022 and 2023. It filters for relevant years and valid layoff counts, groups the data by location, sums up the layoffs for each location, and orders the results to show locations with the highest layoffs first. This helps pinpoint the areas most impacted by layoffs

  Interpretation: To no surprise that we see SF Bay Area (where Silicon Valley is located), Seattle (where many major tech hubs such as Amazon have headquarters), and New York City (Financial Center) are in the top 3 with the most overwhemling number of layoffs belonging to SF Bay Area.

  **Display locations with average layoffs greater than the average of all companies**
  ![image](https://github.com/user-attachments/assets/ac88d841-0cc1-4ca3-b646-ffc707aaee20)

  This query identifies locations with average layoffs exceeding the overall company average. It calculates the overall average layoffs first, then groups the data by location, computing the average layoffs per location. It filters for locations with more than one layoff event and an average layoff count above the overall average, sorting the results by the highest average layoffs per location.

  ![image](https://github.com/user-attachments/assets/0dbf401e-e277-4645-9dd0-4174675028ba)
  
  Interpretation: With their location counts being low but their average layoffs per location being at the top 3 and much higher than the average overall,
  Amsterdam, Shenzen and Phoenix seem like cities in which there were massive layoffs involving big companies that would pull the numbers up massively
  
  **Retrieve companies with the most and least layoffs in 2023.**
  This query identifies the companies with the highest and lowest layoffs in 2023. It first creates a temporary table LAYOFFS_23_T that aggregates total layoffs per company for 2023. Then, it retrieves the company with the maximum and minimum layoffs by joining the table with itself on the condition that their respective layoffs match the highest and lowest values found in the table.
  ![image](https://github.com/user-attachments/assets/b8d846fd-2702-46e7-bdc5-99dce4e47425)
  
  ![image](https://github.com/user-attachments/assets/9a28cf07-fdd3-4ad4-9bba-f57e4428ccff)

  

  ![image](https://github.com/user-attachments/assets/5b544a8f-3b84-4d75-be5a-7dcdf04169ea)

  Interpretation: Google has had the single biggest layoff round in 2023 where 12000 staff was affected and Kinde had the opposite with only 8 employees fired
  
**Identify companies with 100% layoffs over the last 4 years, categorized into quartiles based on layoff percentage.**

![image](https://github.com/user-attachments/assets/9adb6011-30af-4bd9-9508-4a0bc936e678)

![image](https://github.com/user-attachments/assets/0ef3c770-46f5-45bf-99a0-ea6a6173c36f)

The BANKRUPT_COMPANIES view is created to list companies that had 100% layoffs from 2020 to 2023. The companies are ranked into quartiles based on the percentage of layoffs.
The next query counts the number of companies that went bankrupt each year by extracting the year from the layoff dates. 
Finally, the percentages of bankruptcies for each year are calculated by dividing the yearly counts by the total number of bankruptcies over the four years.

![image](https://github.com/user-attachments/assets/79944e34-0478-4338-b0a7-646dbb8dae21)

-- Interpretation: 2022 had the highest number of companies with 100% layoffs, classified as bankrupt, with 58 out of 116, making up 50% of the total. Followed by 2020 with 36 out of 116, roughly 31% of the total.

**Identify companies that have had multiple rounds of layoffs**

![image](https://github.com/user-attachments/assets/d2f13195-45b4-4f86-99e3-f5758ec83b5e)

This query groups Company and aggregates the amount of layoff rounds they have had throughout all the years.

![image](https://github.com/user-attachments/assets/26192ee9-beb5-42c6-8b07-2bc15c4961a5)

-- Interpretation: Some major companies like Loft, Uber and Swiggy have had repeated layoffs, specifically more than 4 times.

**Calculate the average number of layoffs by industry for each year from 2020 to 2023.**

![image](https://github.com/user-attachments/assets/435f7438-a155-4766-b301-165a025c9dd0)

This query calculates the average number of layoffs by industry for each year from 2020 to 2023. It first creates a temporary table, INDUSTRY_AVERAGE, which groups the data by industry and calculates the average number of layoffs for each year separately using conditional aggregation. The final result is a table that displays the industry along with the average number of layoffs for each year from 2020 to 2023, sorted alphabetically by industry. The subsequent SELECT statement retrieves all rows from the INDUSTRY_AVERAGE table.

![image](https://github.com/user-attachments/assets/7dcf6668-8827-4c64-b63e-1cbf9b541b02)

-- Interpretation: Some industries like Hardware, Sales, and Tech (a.k.a Other) significantly increased in layoff average from 2022 to 2023.

**Identify any seasonal trends in layoffs by analyzing the number of layoffs by quarter for each year.**

![image](https://github.com/user-attachments/assets/9fa79a70-3eb6-473f-bad1-0e90e466e63c)

This query analyzes seasonal trends in layoffs by counting the number of layoffs by quarter for each year from 2020 to 2023. It uses the EXTRACT function to identify the month and year of each layoff, then groups the layoffs by quarters (Q1: January-March, Q2: April-June, Q3: July-September, Q4: October-December) for each year. The resulting counts for each quarter are provided as separate columns in the output, showing the distribution of layoffs across different seasons over the years.
  
![image](https://github.com/user-attachments/assets/852beb8f-f978-4d81-b1fb-38ac39ec76e1)

-- Interpretation: Significant layoffs occurred in Q1 and Q2 of 2020 due to COVID-19. Layoffs consistently increased from Q2 of 2022 onwards. There appears to be no seaonal trends in the layoffs. The significant amounts have either been caused by the COVID-19 pandemic in 2020, or the overall massive layoffs policy that started in 2022.

**Compare layoffs in 2023 to those in 2022 for companies in the TECH INDUSTRY.**

![image](https://github.com/user-attachments/assets/62cef410-91b2-47c9-b190-d7c11711305c)

This query calculates the total and average percentage of layoffs in the 'Other' industry for the years 2022 and 2023. 
It then computes the percentage differences between these two years.

![image](https://github.com/user-attachments/assets/f9b2e068-7bed-49f5-a59a-f1a542cb74a7)

-- Interpretation: The number of tech layoffs in 2023 is approximately 4.5 times that of 2022, but the average percentage of staff laid off has decreased in 2023.


**Calculate the total number of layoffs for each country represented in the dataset.**

![image](https://github.com/user-attachments/assets/b881afb5-e493-4061-897c-782fa1d9bce5)

This query calculates the total number of layoffs by country and compares each country's layoffs to the global average. It starts by summing up the total layoffs for each country, filtering out those with minimal layoffs. The results are ordered by the total number of layoffs in descending order. The final selection includes the total layoffs for each country, the global average number of layoffs, and the difference between each country's total layoffs and the global average.

![image](https://github.com/user-attachments/assets/64fc3c5b-9964-4f27-adfc-89658e01356c)

-- Interpretation: The United States has an overwhelming number of layoffs, which is 7 times higher than that of the second place, India. A total of 28 countries have higher layoff figures than the global average.

**Analyze the 2023 layoffs by the size of the company (e.g., small, medium, large) and determine if there is a significant difference in the layoff percentages.**

![image](https://github.com/user-attachments/assets/5dd5cb38-3b58-4717-b54b-fbe2204df930)

This query examines the relationship between company size (based on funds raised) and the average percentage of layoffs in 2023. First, it categorizes companies into 'Small', 'Medium', and 'Large' based on their funds raised. For each company, the average percentage of layoffs is calculated. In the final selection, the query calculates the average layoff percentage for each company size category and orders the results by this average in descending order. This helps to understand how layoff rates differ among companies of various sizes.

![image](https://github.com/user-attachments/assets/032f1f99-1d0d-494e-ade9-82fe373ca280)

-- Interpretation: Small to medium companies tend to lay off more staff, with small firms cutting off half of their staff on average. This might be due to low funding resulting in inadequate budgets for salaries during hardships.

**Are there any industries that seem more resilient to layoffs? Compare the layoff rates across different industries over the years.**

![image](https://github.com/user-attachments/assets/d3556b12-070c-4a75-b67a-593454729ffb)

This query creates a temporary table, LAYOFFS_INDUSTRIES, which calculates the average percentage of layoffs for each industry for the years 2022 and 2023. It also computes the difference in average layoff percentages between these two years. The results are grouped by industry and ordered by the average percentage of layoffs in 2022 and 2023 in ascending order.

![image](https://github.com/user-attachments/assets/34666095-9c54-451f-96a1-77e3aa8d33cd)

-- Interpretation: The Sales industry has been extremely resilient to layoffs in both 2022 and 2023. Sales layoffs percentage has been kept at around 10% in those two years.

