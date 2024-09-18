select * from layoffs;
 -- creating duplicate table for adding row number --
 
create table layoffs_staging
like layoffs;

insert into layoffs_staging
select * from layoffs ;

select * from layoffs_staging;

with duplicate_cte as
 (
select * , row_number() OVER
(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte where row_num>1;

select * from layoffs_staging;

-- creating another duplicate table for data cleaning --

CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

insert into layoffs_staging2
select * , row_number() OVER
(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging;

select* from layoffs_staging2;

-- deleting duplicates --

select * from layoffs_staging2 where row_num>1;

delete from layoffs_staging2 where row_num>1;

-- STANDARDIZATION OF THE TABLE --

SELECT * FROM layoffs_staging2;

select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

SELECT * FROM layoffs_staging2;

select distinct(industry)
from layoffs_staging2
order by 1;

select industry from layoffs_staging2 
where industry like 'crypto%';

update layoffs_staging2
set industry = 'crypto'
where industry like 'crypto%';

select distinct(country)
from layoffs_staging2
where country like 'united states%';

update layoffs_staging2
set country = 'United States'
where country like 'united states%';

select distinct(country)
from layoffs_staging2
order by 1;

SELECT * FROM layoffs_staging2;
 select  `date` from layoffs_staging2;
 
 select `date`, str_to_date(`date`, '%m/%d/%Y')
 from layoffs_staging2;
 
 update layoffs_staging2
 set `date`= str_to_date(`date`, '%m/%d/%Y');
 
 alter table layoffs_staging2
 modify column `date` date;
 
 -- removing null values--
 
 select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
 
 
 select * from layoffs_staging2 where industry is null or industry = '';
 
 select * from layoffs_staging2 where company ='juul';
 
 update layoffs_staging2 
 set industry = null 
 where industry = ''; 
 
 select * from layoffs_staging2 t1
 join layoffs_staging2 t2 
	on t1.company =t2. company and t1. location =t2.location
where t1.industry is null and t2.industry is not null;

update layoffs_staging2 t1 
join layoffs_staging2 t2 
	on t1.company =t2. company and t1. location =t2.location
set t1.industry = t2.industry where  t1.industry is null and t2.industry is not null;

-- finding count of null values in total laid  off and % laid off --

select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

select * , row_number() over(order by company asc) 
from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;

with cte_count as ( 
select company from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null)
select count(company) from cte_count ;
 
 -- deleting rows where  total laid  off and % laid off is null ---
 
 select * from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
 
 delete 
 from layoffs_staging2 where total_laid_off is null and percentage_laid_off is null;
 
 -- REMOVING COLUMNS --
 
  select * from layoffs_staging2;
  
  alter table layoffs_staging2
  DROP COLUMN row_num;
 