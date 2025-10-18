/*
Enter Spark shell in EC2 instance:

$ docker exec -i -t hdp_spark-master bash
$ ./spark/bin/spark-shell

*/

import scala.xml.XML
import java.io.Serializable

// load the data from hive table to dataframe
val hive_df = spark.sql("select * from default.customer_test")

// select only required columns: CustomerID, Demographics where Demographics is an XML String column
val projDF = hive_df.select("CustomerID","Demographics")
/*
Sample projDF record:

scala> projDF.show(1, false)
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|CustomerID|Demographics                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
|11061     |<IndividualSurvey xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"><TotalPurchaseYTD>8129.02</TotalPurchaseYTD><DateFirstPurchase>2001-09-13Z</DateFirstPurchase><BirthDate>1954-02-27Z</BirthDate><MaritalStatus>M</MaritalStatus><YearlyIncome>75001-100000</YearlyIncome><Gender>M</Gender><TotalChildren>2</TotalChildren><NumberChildrenAtHome>0</NumberChildrenAtHome><Education>Partial College</Education><Occupation>Skilled Manual</Occupation><HomeOwnerFlag>1</HomeOwnerFlag><NumberCarsOwned>2</NumberCarsOwned><CommuteDistance>5-10 Miles</CommuteDistance></IndividualSurvey>|
+----------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
*/

case class CustomerDemo(
	CustomerID: Int, 
	TotalPurchaseYTD: String, 
	DateFirstPurchase: String, 
	BirthDate: String, 
	MaritalStatus: String, 
	YearlyIncome: String, 
	Gender: String, 
	TotalChildren: String, 
	NumberChildrenAtHome: String, 
	Education: String, 
	Occupation: String, 
	HomeOwnerFlag: String, 
	NumberCarsOwned: String, 
	CommuteDistance: String
) extends Serializable

// function to process XML String column
def createCustDemo(custId: Int, demo:String): CustomerDemo = {
	val node = XML.loadString(demo)
	CustomerDemo(
		custId,
		(node \\ "IndividualSurvey" \\ "TotalPurchaseYTD").text,
		(node \\ "IndividualSurvey" \\ "DateFirstPurchase").text,
		(node \\ "IndividualSurvey" \\ "BirthDate").text,
		(node \\ "IndividualSurvey" \\ "MaritalStatus").text,
		(node \\ "IndividualSurvey" \\ "YearlyIncome").text,
		(node \\ "IndividualSurvey" \\ "Gender").text,
		(node \\ "IndividualSurvey" \\ "TotalChildren").text,
		(node \\ "IndividualSurvey" \\ "NumberChildrenAtHome").text,
		(node \\ "IndividualSurvey" \\ "Education").text,
		(node \\ "IndividualSurvey" \\ "Occupation").text,
		(node \\ "IndividualSurvey" \\ "HomeOwnerFlag").text,
		(node \\ "IndividualSurvey" \\ "NumberCarsOwned").text,
		(node \\ "IndividualSurvey" \\ "CommuteDistance").text
	)
}

// process each record in projDF to parse XML String column into multiple columns using lambda expression
val projRDD = projDF.map(r => createCustDemo(r.get(0).toString.toInt, r.get(1).toString))
/*
scala> projRDD.printSchema()
root
 |-- CustomerID: integer (nullable = false)
 |-- TotalPurchaseYTD: string (nullable = true)
 |-- DateFirstPurchase: string (nullable = true)
 |-- BirthDate: string (nullable = true)
 |-- MaritalStatus: string (nullable = true)
 |-- YearlyIncome: string (nullable = true)
 |-- Gender: string (nullable = true)
 |-- TotalChildren: string (nullable = true)
 |-- NumberChildrenAtHome: string (nullable = true)
 |-- Education: string (nullable = true)
 |-- Occupation: string (nullable = true)
 |-- HomeOwnerFlag: string (nullable = true)
 |-- NumberCarsOwned: string (nullable = true)
 |-- CommuteDistance: string (nullable = true)

scala> projRDD.show(1, false)
+----------+----------------+-----------------+-----------+-------------+------------+------+-------------+--------------------+---------------+--------------+-------------+---------------+---------------+
|CustomerID|TotalPurchaseYTD|DateFirstPurchase|BirthDate  |MaritalStatus|YearlyIncome|Gender|TotalChildren|NumberChildrenAtHome|Education      |Occupation    |HomeOwnerFlag|NumberCarsOwned|CommuteDistance|
+----------+----------------+-----------------+-----------+-------------+------------+------+-------------+--------------------+---------------+--------------+-------------+---------------+---------------+
|11061     |8129.02         |2001-09-13Z      |1954-02-27Z|M            |75001-100000|M     |2            |0                   |Partial College|Skilled Manual|1            |2              |5-10 Miles     |
+----------+----------------+-----------------+-----------+-------------+------------+------+-------------+--------------------+---------------+--------------+-------------+---------------+---------------+ 
*/

// write the projRDD dataset into files - data will be stored in customer_demographics_xml_processed directory
projRDD.toDF.write.format("parquet").mode("append").save("customer_demographics_xml_processed")
