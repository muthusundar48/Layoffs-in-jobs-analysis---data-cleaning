SELECT *
FROM layoffs;

CREATE TABLE layoffs_v1
LIKE layoffs;

SELECT *
FROM layoffs_v1;

-- creating and inserting from raw source
INSERT layoffs_v1
SELECT *
FROM layoffs;

-- findind duplicates
WITH duplicate_cte AS(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,industry, total_laid_off,percentage_laid_off,
`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_v1)
SELECT * FROM duplicate_cte
WHERE row_num>1;

-- creating a table structure like layoffs_v1
CREATE TABLE `layoffs_v2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_v2;

-- insering values into new table from raw source with row_number
INSERT INTO layoffs_v2
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location,industry, total_laid_off,percentage_laid_off,
`date`,stage,country,funds_raised_millions) as row_num
FROM layoffs_v1;

SELECT *
FROM layoffs_v2
WHERE row_num>1;

-- deleting duplicate values where row_num>1
DELETE
FROM layoffs_v2
WHERE row_num>1;

-- verifying there is no row_num equal to 2
SELECT *
FROM layoffs_v2
WHERE row_num>1;

SELECT company,TRIM(company)
FROM layoffs_v2;

-- removing extra spaces before and after
UPDATE layoffs_v2
SET company=TRIM(company);

SELECT *
FROM layoffs_v2;

SELECT DISTINCT industry 
FROM layoffs_v2
WHERE industry LIKE 'crypto%';

-- replacing with distinct values
UPDATE layoffs_v2
SET industry='Crypto'
WHERE industry LIKE 'crypto';

SELECT DISTINCT industry
FROM layoffs_v2
ORDER BY 1;

SELECT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_v2
WHERE country LIKE 'United States.'
ORDER BY 1;

-- removing . from end of a text
UPDATE layoffs_v2
SET country=TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

-- converting date to correct format
SELECT `date`, STR_TO_DATE(`date`,'%m/%d/%Y')
FROM layoffs_v2;

UPDATE layoffs_v2
SET `date`= STR_TO_DATE(`date`,'%m/%d/%Y');

SELECT `date`
FROM layoffs_v2;

DESCRIBE layoffs_v2;

-- updating in industry column
SELECT *
FROM layoffs_v2
WHERE industry IS NULL
OR industry = '';

SELECT *
FROM layoffs_v2
WHERE company='airbnb';

UPDATE layoffs_v2
SET industry=NULL
WHERE industry='';

SELECT t1.company, t1.industry, t2.company, t2.industry
FROM layoffs_v2 t1
JOIN layoffs_v2 t2
	ON t1.company=t2.company
    AND t1.location=t2.location
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

UPDATE layoffs_v2 t1
JOIN layoffs_v2 t2
	ON t1.company=t2.company
SET t1.industry=t2.industry
WHERE t1.industry IS NULL
AND t2.industry IS NOT NULL;

SELECT *
FROM layoffs_v2
WHERE company='airbnb';

-- Delete unwanted rows
SELECT *
FROM layoffs_v2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_v2
WHERE total_laid_off is NULL
AND percentage_laid_off IS NULL;

-- Deleting row_num column
ALTER TABLE layoffs_v2
DROP COLUMN row_num;

SELECT *
FROM layoffs_v2;
