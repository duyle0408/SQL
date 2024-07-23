## Executive Summary


#### Data Dictionary:
**company**: Name of the company

**location**: the city/branch of the company that laid off employees

**industry**: sector which the company operates in

**total_laid_off**: number of employees laid off in that round

**date**: the date the layoff round happened. Time periods span from 2020 to 2023.

**stage**: growth stage of the company

**country**: country where the layoff round happened

**funds_raised_millions**: most recent amount of money gained from a funding round (in millions USD)


### Situation:
In recent years, the job market has experienced significant fluctuations, especially in terms of layoffs across various industries. To better understand these trends and their implications, an analysis was conducted using data from [Kaggle Layoffs Dataset](https://www.kaggle.com/datasets/emaoyeyiola/exploring-the-layoffs-dataset) and related SQL queries.

-- Dataset Comprehension:
![image](https://github.com/user-attachments/assets/70329bf6-3921-4a95-85f2-7c34a7373c55)

The raw, uncleaned dataset contains about 2000 rows. The grain of the data is each row represents a record of a single company layoff round (a company can have multiple layoff rounds spanning from 2022 and 2023), quantified by the layoffs number. And unfortunately, we do not have information on the total number of employees that company has, which would have made for even greater insights. But we'll work with what we have for now.

### Task:
The 3 main tasks of this analysis were:

**1. Import CSV into PostgreSQL database**

**2. Clean and preprocess the raw dataset to ensure data quality.**

**3. Conduct Exploratory Data Analysis to answer many questions/queries**

For example:
- Display the unique locations and their aggregated total layoffs for 2022 and 2023.
- Show locations with average layoffs greater than the average of all companies.
- Retrieve companies with the most and least layoffs in 2023.
- Identify companies with 100% layoffs over the last 4 years, categorized into quartiles based on layoff percentage. Count the number of companies that went bankrupt each year.
- Identify companies that have had multiple rounds of layoffs
- Calculate the average number of layoffs by industry for each year from 2020 to 2023.
- Count the number of companies with layoffs each month in 2022.
- Compare layoffs in 2023 to those in 2022 for companies in the Tech industry.
- Calculate the total number of layoffs for each country represented in the dataset.
- Analyze the 2023 layoffs by the size of the company (e.g., small, medium, large) and determine if there is a significant difference in the layoff percentages.
- Are there any industries that seem more resilient to layoffs? Compare the layoff rates across different industries over the years.
And more..

### Action

#### Data Import
First, we'll create a new table in the Tables section called "Layoffs" fill in the column names from the CSV file into the database and specify their data types and length/precision.

![image](https://github.com/user-attachments/assets/577cd344-4cf8-4ba0-9119-c928c9c12865)

Next, using the import/export tool, we are going to link the CSV file to our database and define the necessary format and encoding we want. 
Then we'll have the data available for querying.
![image](https://github.com/user-attachments/assets/349175ea-641c-4c93-8123-6344e372c774)


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

  With their location counts being low but their average layoffs per location being at the top 3 and much higher than the average overall,
  Amsterdam, Shenzen and Phoenix seem like cities in which there were massive layoffs involving big companies that would pull the numbers up massively
  ![image](https://github.com/user-attachments/assets/0dbf401e-e277-4645-9dd0-4174675028ba)

  


  

  


  


































































