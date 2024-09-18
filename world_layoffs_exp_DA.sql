-- Total no of rows in the table layoffs_stagings after data cleaning--

select count(*) as count from layoffs_staging2;

-- total no of companies which had laid off --

select count(distinct company) as distint_company from layoffs_staging2 ;
 
-- yearly total_laid_off and its percentage--


select* from layoffs_staging2;

select year(`date`) as years , sum(total_laid_off) as yearly_total_laid_off ,  
ROUND((sum(total_laid_off) / (SELECT SUM(total_laid_off) FROM layoffs_staging2)) * 100, 1) AS perc_laid_off
from layoffs_staging2
group by years
order by 1 desc;

select * 
from layoffs_staging2 where `date` is null;

--  monthly total laid off and its percentage--

select substring(`date`,1,7) as `month` , sum(total_laid_off) as monthly_total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_monthly_laid_off
from layoffs_staging2
group by `month`
order by 1 asc;

-- country where max laid off happened--

select country , sum(total_laid_off) as total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_laid_off
from layoffs_staging2
group by country 
order by 2 desc;

-- company with large laid off --

select company , sum(total_laid_off) as total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_laid_off
from layoffs_staging2
group by company 
order by 2 desc;

-- industry with large laid off --

select industry , sum(total_laid_off) as total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_laid_off
from layoffs_staging2
group by industry 
order by 2 desc;

-- time period of the data provided --

select min(`date`) as start_date, max(`date`) as end_date
from layoffs_staging2;

-- stage that has a larger laid off --

select stage , sum(total_laid_off) as total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_laid_off
from layoffs_staging2
group by stage 
order by 2 desc;

 -- location which has highest lay off --
 
 select location , country ,sum(total_laid_off) as total_laid_off,
round(sum(total_laid_off)/(select sum(total_laid_off) from layoffs_staging2)*100,1) as perc_laid_off
from layoffs_staging2
where total_laid_off is not null
group by location, country
order by 3 desc;


-- rolling total of total lay offs as per month --

with Rolling_total as 
(
select substring(`date`,1,7) as `month` , sum(total_laid_off) as monthly_total_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month` , monthly_total_laid_off , sum(monthly_total_laid_off) over(order by `month`) as rolling_total
from Rolling_total;

-- rolling total of total lay offs as per year --

with Rolling_total as 
(
select year(`date`) as `year`, sum(total_laid_off) as yearly_total_laid_off
from layoffs_staging2
where  year(`date`) is not null
group by `year`
order by 1 asc
)
select`year` ,  yearly_total_laid_off , sum( yearly_total_laid_off) over(order by `year`) as rolling_total
from Rolling_total;

-- company's yearly laid off --

select company , year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2 
group by company , `year`
order by 1 asc;

-- ranking the company laid offs yearly --

with company_yearly_laid_off as 
(
select company , year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2 
where year(`date`) is not null 
group by company , `year`
)
select *, dense_rank() over(partition by `year` order by total_laid_off desc) as yearly_rank 
from company_yearly_laid_off
order by 4 ;

-- first 5 yearly lay offs --

with company_yearly_laid_off as 
(
select company , year(`date`) as `year`, sum(total_laid_off) as total_laid_off
from layoffs_staging2 
where year(`date`) is not null 
group by company , `year`
), Ranking as (
select *, dense_rank() over(partition by `year` order by total_laid_off desc) as yearly_rank 
from company_yearly_laid_off
)
select * from Ranking where yearly_rank <=5;

-- max funds raised -- 

select max(funds_raised_millions)
from layoffs_staging2;

-- highest fund raised comapny --

select* from layoffs_staging2;

select company  , sum(funds_raised_millions) as funds_raised_millions
from layoffs_staging2 
group by company 
order by funds_raised_millions desc; 

-- highest funds raised industry -- 

select industry  , sum(funds_raised_millions) as funds_raised_millions
from layoffs_staging2 
group by industry 
order by funds_raised_millions desc; 

-- highest funds raised country  -- 

select country  , sum(funds_raised_millions) as funds_raised_millions
from layoffs_staging2 
group by country 
order by funds_raised_millions desc; 

-- year where highest fund raised -- 

select year(`date`) as `year` , sum(funds_raised_millions) as funds_raised_millions
from layoffs_staging2 
group by `year` 
order by funds_raised_millions desc; 

-- rolling total of funds raised per month --

with Rolling_total as 
(
select substring(`date`,1,7) as `month` , sum(funds_raised_millions) as monthly_funds_raised
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month` , monthly_funds_raised , sum(monthly_funds_raised) over(order by `month`) as rolling_total
from Rolling_total;
  
  
  -- rolling total of funds raised as per year --

with Rolling_total as 
(
select year(`date`) as `year`, sum(funds_raised_millions) as yearly_funds_raised
from layoffs_staging2
where  year(`date`) is not null
group by `year`
order by 1 asc
)
select`year` ,  yearly_funds_raised , sum( yearly_funds_raised) over(order by `year`) as rolling_total
from Rolling_total;
  
select* from layoffs_staging2;


 