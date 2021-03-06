#https://stackoverflow.com/questions/21477855/dynamic-partitioning-create-as-on-hive
#https://stackoverflow.com/questions/20756561/how-to-pick-up-all-data-into-hive-from-subdirectories
#https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL
#https://cwiki.apache.org/confluence/display/Hive/Hive+Transactions
#https://community.hortonworks.com/articles/49971/hive-streaming-compaction.html
#https://cwiki.apache.org/confluence/display/Hive/ListBucketing

# Cluster and Partitioning
ALTER TABLE table_name CLUSTERED BY (col_name, col_name, ...) [SORTED BY (col_name, ...)]
  INTO num_buckets BUCKETS;

ALTER TABLE db1.z_part1_like CLUSTERED BY (cookie) SORTED BY (cookie) into 1000 buckets;  

                                                                          
#Add Partition                                                                          
 ALTER TABLE page_view ADD PARTITION (dt='2008-08-08', country='us') location '/path/to/us/part080808'
                          PARTITION (dt='2008-08-09', country='us') location '/path/to/us/part080809';                                                                         

#Partition Table                                                                          
insert overwrite table tmp.table1 partition(ptdate,ptchannel)  
select col_a,count(1) col_b,ptdate,ptchannel
from tmp.table2
group by ptdate,ptchannel,col_a ;

CREATE TABLE temps_orc_partition_date
(statecode STRING, countrycode STRING, sitenum STRING, paramcode STRING, poc STRING, latitude STRING, longitude STRING, datum STRING, param STRING, timelocal STRING, dategmt STRING, timegmt STRING, degrees double, uom STRING, mdl STRING, uncert STRING, qual STRING, method STRING, methodname STRING, state STRING, county STRING, dateoflastchange STRING)
PARTITIONED BY (datelocal STRING)
STORED AS ORC;


create table db1.z_part1
(cookie STRING,
url STRING)
PARTITIONED BY (viewdate STRING)
STORED AS ORC;

ALTER TABLE db1.z_part1 DROP IF EXISTS PARTITION(year = 2012, month = 12, day = 18);

ALTER TABLE db1.z_part1 DROP IF EXISTS PARTITION(viewdate = '2018-08-04');

show partitions db1.z_part1

insert overwrite table  db1.z_part1 partition(viewdate)  #Dynamic Partitioning
Select cookie,url,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '2018-08-01' limit 100

insert overwrite table  db1.z_part1 partition(viewdate)  
Select cookie,url,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '2018-08-02' limit 10

--Hive does not support column sequencing
insert overwrite table  db1.z_part1 partition(viewdate)  
Select url,url,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '2018-08-03' limit 10

insert overwrite table  db1.z_part1 partition(viewdate)  
Select url,cookie,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '2018-08-04' limit 10


insert into db1.z_part1 partition(viewdate)  
Select url,cookie,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '2018-08-04' limit 10


Select viewdate,count(*)
from db1.z_part1
group by viewdate


set hive.exec.dynamic.partition=true;  
set hive.exec.dynamic.partition.mode=nonstrict;  

spark.conf.set("hive.exec.dynamic.partition", "true") 
spark.conf.set("hive.exec.dynamic.partition.mode", "nonstrict")


drop table tmp.table1;

create table tmp.table1(  
col_a string,col_b int)  
partitioned by (ptdate string,ptchannel string)  
row format delimited  
fields terminated by '\t' ;  

insert overwrite table tmp.table1 partition(ptdate,ptchannel)  
select col_a,count(1) col_b,ptdate,ptchannel
from tmp.table2
group by ptdate,ptchannel,col_a ;

https://stackoverflow.com/questions/15616290/hive-how-to-show-all-partitions-of-a-table
show partitions db1.z_part1


spark.conf.set("hive.exec.dynamic.partition", "true") 
spark.conf.set("hive.exec.dynamic.partition.mode", "nonstrict")

val dated= "2018-08-05"
var data1 = spark.sql("""Select cookie,url,viewdate from db1.partners_web_data_uri_sessionized where viewdate = '""" + dated + """' limit 10""")

data1.createOrReplaceTempView("data1")
spark.sql("""insert overwrite table  db1.z_part1 partition(viewdate) Select cookie,url,viewdate from data1""")

spark.sql("""insert overwrite table  db1.z_part1 partition(viewdate='""" + dated+ """') Select cookie,url from data1""")

var mdfwdus = wdus.select("url").dropDuplicates()
mdfwdus.createOrReplaceTempView("mdfwdus")
                                                                          
#https://stackoverflow.com/questions/31341498/save-spark-dataframe-as-dynamic-partitioned-table-in-hive
#https://stackoverflow.com/questions/38487667/overwrite-specific-partitions-in-spark-dataframe-write-method
df.write().mode(SaveMode.Append).partitionBy("colname").saveAsTable("Table")
df.write.partitionBy('year', 'month').insertInto(...)
df.write.mode(SaveMode.Overwrite).save("/root/path/to/data/partition_col=value")
                                                                          
###                                                                           
spark.conf.set("hive.exec.dynamic.partition", "true") 
spark.conf.set("hive.exec.dynamic.partition.mode", "nonstrict")
spark.conf.set("spark.sql.sources.partitionOverwriteMode", "dynamic") --Spark 2.3 Onwards

df = spark.sql("Select cookie,url,viewdate from mydb1_web.webData where viewdate = '2018-08-01' limit 50")
df.write.mode("overwrite").partitionBy("viewdate").saveAsTable("mydb1_bana.z_part1_spk")

2018-08-01      50

df = spark.sql("Select cookie,url,viewdate from mydb1_web.webData where viewdate = '2018-08-02' limit 45")
df.write.mode("overwrite").partitionBy("viewdate").saveAsTable("mydb1_bana.z_part1_spk")

2018-08-02      45

df = spark.sql("Select cookie,url,viewdate from mydb1_web.webData where viewdate = '2018-08-03' limit 40")
df.write.mode("append").insertInto("mydb1_bana.z_part1_spk") #no Need to specfy partiton by

2018-08-02      45
2018-08-03      40

df = spark.sql("Select cookie,url,viewdate from mydb1_web.webData where viewdate = '2018-08-03' limit 30")
df.write.mode("overwrite").insertInto("mydb1_bana.z_part1_spk")

2018-08-02      45
2018-08-03      70
                                                                          
spark.sql("ALTER TABLE mydb1_bana.z_part1_spk DROP IF EXISTS PARTITION(viewdate = '2018-08-03')") #Works after droping the partition

