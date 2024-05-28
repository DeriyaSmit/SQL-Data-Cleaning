-- Created same table like layoffs
create table layoffs_staging
like layoffs;

-- Imported layoffs data to layoffs_staging
insert into layoffs_staging
select * from layoffs;

-- Created extra column to find duplicate in the layoffs_staging table 
select *, 
       row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

-- Created another table (layoffs_staging2) same as layoffs_staging 
CREATE TABLE `layoffs_staging` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` double DEFAULT NULL,
  `percentage_laid_off` double DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` double DEFAULT NULL,
  `row_num` int
);

-- insert all the date from the layoffs_staging table to layoffs_staging2 table
insert into layoffs_staging2
select *, 
       row_number() over(partition by company,location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

-- Deleted Duplicate data from layoffs_staging2 table
delete from layoffs_staging2 where row_num>=2;

-- Droped the extra column that was created to remove the data the layoffs_staging2 table
alter table layoffs_staging2
drop column	row_num;

-- Removing the extra space's from the company column 
update layoffs_staging2 set company = trim(company) where company is not null;

-- Updating the country name with similar name
update layoffs_staging2 set country="United States" where country like 'United States%';

-- Converting the text date to date
update layoffs_staging2 set `date`= str_to_date(`date`,"%m/%d/%Y");

-- Changing the date data type to date
alter table  layoffs_staging2
modify `date` date;

-- Handling the industry column null value
update layoffs_staging2 st1
join layoffs_staging2 st2
on st1.company=st2.company
set st1.industry=st2.industry
where (st1.industry is null or st1.industry ="") and  st2.industry is not null;

-- Deleting the null values from the total_laid_off and percentage_laid_off
delete from layoffs_staging2 
where total_laid_off is null
and percentage_laid_off is null;
 





