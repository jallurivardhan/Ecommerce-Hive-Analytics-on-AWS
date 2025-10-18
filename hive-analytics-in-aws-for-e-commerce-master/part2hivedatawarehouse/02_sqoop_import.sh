# ABOUT SQOOP
# Sqoop is a commad line interface application for data transfer between Hadoop and relational databases
# Sqoop can only deal with structured data
# NO data aggregation can be done using Sqoop - hence sqoop jobs are only map-only i.e., no reducer tasks are created
# split-by: used to slice the data based on a column to increase data load parallelism
# target-dir: sqoop imports data by creating a new directory of this name, pre-existence of this directory will result in failure

sqoop import --connect jdbc:mysql://ra_mysql:3306/testdb \
--username root \
--password example \
--query 'SELECT SalesOrderID,OrderDate,DueDate,ShipDate,Status,SalesOrderNumber,PurchaseOrderNumber,AccountNumber,CustomerID,ContactID,BillToAddressID,ShipToAddressID,ShipMethodID,CreditCardID,CreditCardApprovalCode,CurrencyRateID,SubTotal,TaxAmt,Freight,TotalDue,Comment,SalesPersonID,TerritoryID,territory,CountryRegionCode,ModifiedDate from v_salesorderheader_demo WHERE $CONDITIONS' \
--split-by SalesOrderID \
--target-dir /input/v_salesorderheader/

sqoop import --connect jdbc:mysql://ra_mysql:3306/testdb \
--username root \
--password example \
--query 'SELECT SalesOrderDetailID,SalesOrderID,CarrierTrackingNumber,OrderQty,ProductID,UnitPrice,UnitPriceDiscount,LineTotal,SpecialOfferID,Description,DiscountPct,Type,Category,ModifiedDate from v_salesorderdetails_demo WHERE $CONDITIONS' \
--split-by SalesOrderID \
--target-dir /input/v_salesorderdetails/

sqoop import --connect jdbc:mysql://ra_mysql:3306/testdb \
--username root \
--password example \
--query 'SELECT CustomerID,Name,SalesPersonID,Demographics,TerritoryID,SalesQuota,CommissionPct,SalesYTD,SalesLastYear,ModifiedDate from v_stores WHERE $CONDITIONS' \
--split-by CustomerID \
--target-dir /input/v_stores/

sqoop import --connect jdbc:mysql://ra_mysql:3306/testdb \
--username root \
--password example \
--query 'SELECT CustomerID, AccountNumber, CustomerType, Demographics, TerritoryID, ModifiedDate FROM v_customer WHERE $CONDITIONS' \
--split-by CustomerID \
--target-dir /input/v_customer/

sqoop import --connect jdbc:mysql://ra_mysql:3306/testdb \
--username root \
--password example \
--query 'SELECT CreditCardID, CardType, CardNumber, ExpMonth, ExpYear, ModifiedDate FROM ccard WHERE $CONDITIONS' \
--split-by CreditCardID \
--target-dir /input/creditcard/ 

# Commands to check the files created
hadoop fs -ls /input/v_customer/
hadoop fs -cat /input/v_customer/part-m-00000
hadoop fs -ls /input/v_salesorderheader_demo/ 