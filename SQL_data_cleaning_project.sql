SELECT *
FROM layoffs;

CREATE TABLE layoffs_stagging
LIKE layoffs;

INSERT layoffs_stagging
SELECT *
FROM layoffs;

WITH duplicate_cte AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, `date`, country,funds_raised_millions) AS row_num
FROM layoffs_stagging)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

SELECT *
FROM layoffs_stagging
WHERE company = "casper";

SHOW CREATE TABLE layoffs;

CREATE TABLE layoffs_stage4 (
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
 
INSERT INTO layoffs_stage4
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off,percentage_laid_off, `date`,
 stage,country,funds_raised_millions) AS row_num
FROM layoffs_stagging;

select company, TRIM(company)
FROM layoffs_stage4;

UPDATE layoffs_stage4
SET company = TRIM(company);

UPDATE layoffs_stage4
SET industry = "cypto"
WHERE industry LIKE "crypto%" ;

SELECT DISTINCT industry
FROM layoffs_stage4
ORDER BY 1;


SELECT *
FROM layoffs_stage4
#WHERE industry= " "
;

SELECT `date`, STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_stage4;

UPDATE layoffs_stage4
SET `date`= STR_TO_DATE(`date`, '%m/%d/%Y');


SELECT DISTINCT country
FROM layoffs_stage4
ORDER BY 1;

UPDATE layoffs_stage4
SET country = 'united states'
WHERE country LIKE 'united states%';

ALTER TABLE layoffs_stage4
MODIFY COLUMN `date` DATE;

UPDATE layoffs_stage4
SET industry = NULL
WHERE industry = '';

SELECT t1.industry,t2.industry
FROM layoffs_stage4 AS t1
JOIN layoffs_stage4 AS t2
   ON t1.company = t2.company
   WHERE (t1.industry IS NULL OR t1.industry = '') 
      AND t2.industry IS NOT NULL;
   
UPDATE layoffs_stage4 AS t1
  JOIN layoffs_stage4 AS t2
    ON t1.company = t2.company
     SET t1.industry = t2.industry
       WHERE (t1.industry IS NULL OR t1.industry = '') 
      AND t2.industry IS NOT NULL;

SELECT DISTINCT industry
FROM layoffs_stage4
ORDER BY 1;

ALTER TABLE layoffs_stage4
DROP COLUMN row_num;