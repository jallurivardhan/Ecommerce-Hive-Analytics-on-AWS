
## DOCKER COMMANDS TO COPY FILES FROM SPARK CONTAINER INTO EC2 HOME DIRECTORY
docker cp hdp_spark-master:/customer_demographics_xml_processed/part-00000-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet /home/ec2-user/
docker cp hdp_spark-master:/customer_demographics_xml_processed/part-00001-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet /home/ec2-user/
docker cp hdp_spark-master:/customer_demographics_xml_processed/part-00002-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet /home/ec2-user/
docker cp hdp_spark-master:/customer_demographics_xml_processed/part-00003-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet /home/ec2-user/

## DOCKER COMMANDS TO COPY FILES FROM EC2 HOME DIRECTORY TO HIVE
docker cp /home/ec2-user/part-00000-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet ra_hive-server:/opt
docker cp /home/ec2-user/part-00001-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet ra_hive-server:/opt
docker cp /home/ec2-user/part-00002-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet ra_hive-server:/opt
docker cp /home/ec2-user/part-00003-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet ra_hive-server:/opt

## GRANTING FILE PERMISSIONS TO LOAD FILE DATA INTO A TABLE
chmod 755 part-00000-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
chmod 755 part-00001-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
chmod 755 part-00002-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet
chmod 755 part-00003-a7e0548d-8088-498c-95f9-701f3f34480a-c000.snappy.parquet