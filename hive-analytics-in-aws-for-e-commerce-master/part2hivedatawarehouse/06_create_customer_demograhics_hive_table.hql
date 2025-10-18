-- create customer_demographics table and load parquet data
create table customer_demographics (
`CustomerID` int,
`TotalPurchaseYTD` string,
`DateFirstPurchase` string,
`BirthDate` string,
`MaritalStatus` string,
`YearlyIncome` string,
`Gender` string,
`TotalChildren` string,
`NumberChildrenAtHome` string,
`Education` string,
`Occupation` string,
`HomeOwnerFlag` string,
`NumberCarsOwned` string,
`CommuteDistance` string
)
stored as parquet;

load data local inpath 'part-00000-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet' overwrite into table customer_demographics;
load data local inpath 'part-00001-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet' into table customer_demographics;
load data local inpath 'part-00002-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet' into table customer_demographics;
load data local inpath 'part-00003-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet' into table customer_demographics;

-- check data
select * from customer_demographics limit 20;

-- compare with XML data in customer_test
select Demographics from customer_test limit 10;

-- create customer_demo table with appropriate column data types
create external table customer_demo (
`customerid` int,
`totalpurchaseytd` decimal(15,2),
`datefirstpurchase` timestamp,
`birthdate` timestamp,
`maritalstatus` string,
`yearlyincome` string,
`gender` string,
`totalchildren` tinyint,
`numberchildrenathome` tinyint,
`education` string,
`occupation` string,
`homeownerflag` string,
`numbercarsowned` tinyint,
`commutedistance` string
)
stored as parquet;

-- transform data from customer_demographics and insert into customer_demo
insert overwrite table customer_demo
select 
customerid, 
cast(totalpurchaseytd as decimal(15,2)), 
to_date(substr(datefirstpurchase, 1, 10)), 
to_date(substr(birthdate, 1, 10)), 
maritalstatus, 
yearlyincome, 
gender, 
cast(totalchildren as int), 
cast(numberchildrenathome as int), 
education, 
occupation, 
homeownerflag, 
cast(numbercarsowned as int), 
commutedistance
from customer_demographics;

-- check data in customer_demo
select * from customer_demo limit 10;

drop table customer_demographics;
