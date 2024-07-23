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
The 2 main tasks of this analysis were:
**1. Clean and preprocess the raw dataset to ensure data quality.**
**2. Conduct Exploratory Data Analysis to answer many questions/queries**
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
#### Data Cleaning:
- Since the dataset was raw and would be difficult to draw insights from without cleaning, the data underwent a thorough scrubbing phase. The key steps in this phase included:
  - **Dropping/Imputing Inconsistent Values:**
    - Correcting spelling errors and standardizing text values for consistency.
    - Handling blanks by either imputing missing values where appropriate or dropping rows/columns that were not critical for the analysis.
  - **Handling Duplicates:**
    - Identifying and removing duplicate records to ensure that each observation was unique and representative of actual layoff events.
  - **Managing Missing Values:**
    - Assessing the extent and pattern of missing data.
    - Imputing missing values using appropriate statistical methods or domain knowledge.
    - Dropping records with excessive missing values that could not be reliably imputed.
