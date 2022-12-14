ccreate database countires2;
use countires2;

-- data are imported through data importing wizard

ALTER TABLE cc
ADD PRIMARY KEY (PK);

ALTER TABLE fer
ADD FOREIGN KEY (FK)
REFERENCES cc (PK);

ALTER TABLE hdi
ADD FOREIGN KEY (CN)
REFERENCES cc (PK);

ALTER TABLE pop
ADD FOREIGN KEY (FK)
REFERENCES cc (PK);

-- the last table I need to normialise myslef 
CREATE TABLE covid_pp_1
SELECT pp.iso_code, pp.continent, pp.location, pp.median_age, pp.excess_mortality_cumulative_per_million, pp.desc_mort, cc.PK
FROM covid_pp pp
INNER JOIN cc
ON pp.iso_code = cc.alpha_3;

drop table covid_pp;
-- data are copied to new table so the orginal can be dropped I hope :)

ALTER TABLE covid_pp_1
ADD FOREIGN KEY (PK)
REFERENCES cc (PK);

-- joins

SELECT cc.country, cc.PK, cc.region, pop.Pop_21, covid_pp_1.median_age, covid_pp_1.excess_mortality_cumulative_per_million
FROM cc
INNER JOIN pop 
ON cc.PK = pop.FK
INNER JOIN covid_pp_1
ON cc.PK = covid_pp_1.PK;


create Table HDI_Q
Select 
Entity, CN, Human_Development_Index,
NTILE(4) OVER (
    ORDER BY Human_Development_Index ASC ) q
from hdi
WHERE hdi.year = (select
max(year)
from hdi);
-- using quartiles for HDI status --> from 1 lowest to 4 highest, creatting new table with only status and filtered to latest year more useful for futhrt analysis
-- In orginal table HDI I have data from older years - so there's subqery to use only the latest data
-- the old table is not dropped - histroic data may be useful when if I want to track changes


Use countires;
ALTER TABLE HDI_Q
ADD foreign key (CN)
REFERENCES cc (PK);

-- join queries 

SELECT ROUND(AVG(fer.fertlity_rate),2) as AVG_FER, hdi_q.q, round(AVG(covid_pp_1.median_age),2) as AVG_Median_age
FROM fer
INNER JOIN hdi_q
ON fer.FK = hdi_q.CN
INNER JOIN covid_pp_1
ON fer.FK = covid_pp_1.PK
WHERE fer.year = (select
max(year)
from fer)
group by hdi_q.q;

-- on the result we can see big differences in fertility and median age in population depending on Developement Status - we can seee how huge conflict potencial we have.
-- Addtionally we can see that hen on comes to Fertility level the bigest dirrefenceexists between staus "low -1 " and "medium-2". 
-- and when it comes to median age the biggest gap is between level 2 and 3. Improving level of healthcare, education and welath on the very bacic level make pepole have fewer chillgren, living loner demands better quality of these factors.



SELECT fer.CountryN, fer.fertlity_rate, hdi_q.q
from fer
INNER JOIN hdi_q
ON fer.FK = hdi_q.CN
WHERE fer.fertlity_rate > 2.2 and fer.year = (select
max(year)
from fer) AND hdi_q.q = 4;

-- This query find the results with conditions - higest developement countries and fertility rate higher then 2.2 (minium necessary from generation replacement)

Use countires2;
SELECT cc.sub_region, ROUND(AVG (hdi_q.q),2) as HDI_AVG, ROUND(AVG(fer.fertlity_rate),2) as AVG_FER 
from cc
INNER JOIN fer
ON cc.PK = fer.FK
INNER JOIN hdi_q
ON cc.PK = hdi_q.CN
GROUP BY cc.sub_region
HAVING HDI_AVG >= 3.0;

-- This quer finds sub regions with higest HDI status and shows Fertlity Rates for them. 



SELECT cc.country, cc.PK, cc.region, pop.Pop_21, covid_pp_1.median_age, covid_pp_1.desc_mort as covid_excees_deaths
FROM cc
INNER JOIN pop 
ON cc.PK = pop.FK
INNER JOIN covid_pp_1
ON cc.PK = covid_pp_1.PK;


SELECT cc.sub_region, ROUND(AVG (hdi_q.q),2) as HDI_AVG, ROUND(AVG(fer.fertlity_rate),2) as AVG_FER 
from cc
INNER JOIN fer
ON cc.PK = fer.FK
INNER JOIN hdi_q
ON cc.PK = hdi_q.CN
GROUP BY cc.sub_region
HAVING HDI_AVG >= 3.0;

-- This quer finds sub regions with higest HDI status and shows Fertlity Rates for them. 

CREATE TABLE Main
SELECT cc.country, cc.PK, cc.region, fer.fertlity_rate, pop.Pop_21, covid_pp_1.median_age, covid_pp_1.desc_mort as covid_excess_deaths, hdi_q.Human_Development_Index, hdi_q.q
FROM cc
INNER JOIN fer ON cc.PK=fer.FK
INNER JOIN pop ON cc.PK=pop.FK
INNER JOIN covid_pp_1 ON cc.PK = covid_pp_1.PK
INNER JOIN hdi_q ON cc.PK = hdi_q.CN
WHERE fer.year = (select
max(year)
from fer);
-- Table Main - is storing join data from few tables. Can be exported to PowerBI for visualistion or finding correlations

Alter Table Main
ADD FOREIGN KEY (PK)
REFERENCES cc (PK);

-- stored procedure - for comparing data I have in main dataset for two most-populated countires

DELIMITER //
CREATE PROCEDURE China_India()
BEGIN 
    select * from main m
    WHERE PK = 156 or PK = 356;
END //
DELIMITER ;
