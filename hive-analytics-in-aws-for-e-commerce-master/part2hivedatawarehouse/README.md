# Hive Data Warehouse

After completion of [project setup in AWS](../part1projectsetupinaws), you must be familiar with connecting to AWS EC2 instance and entering different containers hosted on the instance. Now, we need to create a Hive data warehouse in Hadoop containing the data required for performing analytics. Below steps explains how to do so. Out of the 71 tables present in AdventureWorks dataset, we will concentrating on 9 tables in this project to perform our analysis. 

### 1. Load data to MySQL database in AWS
File [```01_partial_dataset_creation.sql```](/part2hivedatawarehouse/01_partial_dataset_creation.sql) contains the queries needed to create the required tables and load data into them in MySQL database. File [```01_views_creation.sql```](/part2hivedatawarehouse/01_views_creation.sql.sql) contains the queries to create the required the views needed to perform data analysis. We need to run these SQL scripts in mysql prompt on AWS to have the data loaded. Steps below:
- Run the below command in your local terminal to copy SQL scripts from your machine to EC2 instance:
```
$ scp -r -i "hive_docker_setup.pem" 01_partial_dataset_creation.sql ec2-user@my-aws-ip-dns-hostname:/home/ec2-user/

$ scp -r -i "hive_docker_setup.pem" 01_views_creation.sql ec2-user@my-aws-ip-dns-hostname:/home/ec2-user/
```
- Copy SQL scripts from EC2 home directory to MySQL container
```
$ docker cp 01_partial_dataset_creation.sql ra_mysql:/var/lib/mysql/01_partial_dataset_creation.sql

$ docker cp 01_views_creation.sql ra_mysql:/var/lib/mysql/01_partial_dataset_creation.sql
```
- Enter MySQl prompt by following the steps [here](../part1projectsetupinaws/README.md#61-accessing-mysql-and-hive-prompt) and run the below commands to create MySQL tables and views and load data into them:
```
mysql> source 01_partial_dataset_creation.sql;

mysql> source 01_views_creation.sql;
```

<br />

### 2. Transfer data from MySQL to Hadoop
This step is a data transfer from MySQL (relational database) to Hadoop (non-relational database). We will use [Apache Sqoop](https://sqoop.apache.org/) to achieve this. File [```02_sqoop_import.sh```](/part2hivedatawarehouse/02_sqoop_import.sh) contains the required commands. Enter the sqoop container on AWS and run the commands in the file one after the other.

Entering sqoop container:
```
$ docker exec -it ra_sqoop bash
```
After running the commands, we will have the data in Hadoop in target directories mentioned in the sqoop commands.

<br />

### 3. Create Hive tables on sqooped data in Hadoop
The sqooped data in [Step 2](#2-transfer-data-from-mysql-to-hadoop) is present in the form of files. We can load this to Hive tables by creating required external tables and running load data queries present in [```03_hive_tables_creation.sql```](/part2hivedatawarehouse/03_hive_tables_creation.hql) in [hive prompt](/part1projectsetupinaws/README.md#61-accessing-mysql-and-hive-prompt).

<br />

### 4. XML data processing in customer_test table using spark-shell
If you look at the customer_test table view that we created in Hive in [Step 3](/part2hivedatawarehouse/README.md#3-create-hive-tables-on-sqooped-data-in-hadoop), it has _Demographics_ column which is an XML string. If you look at the sample data:
```
hive> select CustomerID, Demographics from customer_test limit 1;
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|CustomerID|Demographics                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|11061     |<IndividualSurvey xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"><TotalPurchaseYTD>8129.02</TotalPurchaseYTD><DateFirstPurchase>2001-09-13Z</DateFirstPurchase><BirthDate>1954-02-27Z</BirthDate><MaritalStatus>M</MaritalStatus><YearlyIncome>75001-100000</YearlyIncome><Gender>M</Gender><TotalChildren>2</TotalChildren><NumberChildrenAtHome>0</NumberChildrenAtHome><Education>Partial College</Education><Occupation>Skilled Manual</Occupation><HomeOwnerFlag>1</HomeOwnerFlag><NumberCarsOwned>2</NumberCarsOwned><CommuteDistance>5-10 Miles</CommuteDistance></IndividualSurvey>|
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```
Now we need to parse this XML string column into multiple columns representing individual columns: _TotalPurchaseYTD, DateFirstPurchase, BirthDate, MaritalStatus, YearlyIncome, Gender, TotalChildren, NumberChildrenAtHome, Education, Occupation, HomeOwnerFlag, NumberCarsOwned, and CommuteDistance_. We do this inside Spark shell:
```
# Entering spark-shell: run below commands after connecting to EC2 instance

$ docker exec -i -t hdp_spark-master bash

$ ./spark/bin/spark-shell

# This will open up spark shell where you can run your Spark based Scala code
```
Inside spark-shell, run the code present in [```04_process_customer_demographics_xml_data.scala```](/part2hivedatawarehouse/04_process_customer_demographics_xml_data.scala) file. After this step, we will have the XML processed data as parquet files inside *customer_demographics_xml_processed* folder created in default spark container directory. Sample structure of the created files below:
```
$ ls -ltr /customer_demographics_xml_processed/
-rw-r--r--    1 root     root          5506 Jun  6 16:30 part-00003-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
-rw-r--r--    1 root     root          5457 Jun  6 16:30 part-00002-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
-rw-r--r--    1 root     root          5490 Jun  6 16:30 part-00001-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
-rw-r--r--    1 root     root          5491 Jun  6 16:30 part-00000-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
```

<br />

### 5. Copy XML Processed data from Spark to Hive Container
In this step, we copy the customer_demographics XML processed data parquet files created in [Step 4](/part2hivedatawarehouse/README.md#4-xml-data-processing-in-customertest-table-using-spark-shell) into Hive container. To do this, run the commands specified in [```05_xml_processed_data_to_hive_container.sh```](/part2hivedatawarehouse/05_xml_processed_data_to_hive_container.sh) file from EC2 instance home directory. Keep in mind to change the parquet file names as per your project files created.

<br />

### 6. Create Hive table on XML processed customer_demographics data
Now that we have the XML processed customer_demographics data files in Hive container, we can load this data into Hive table by running the queries present in [```06_create_customer_demographics_hive_table.hql```](/part2hivedatawarehouse/06_create_customer_demograhics_hive_table.hql) file inside the [hive prompt](/part1projectsetupinaws/README.md#61-accessing-mysql-and-hive-prompt). Note that in this hql file, we also convert XML processed columns of String types to appropriate types using casting. You may also note that Steps 4 to 6 in this data warehouse creation part require us to have Hive-Spark dependencies setup as mentioned [here](/part1projectsetupinaws/README.md#7-add-hive-spark-dependencies).

<br />

Hurray!! Now, we have created a data warehouse in Hive to perform data analysis and solve our problem statement.