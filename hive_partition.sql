#https://stackoverflow.com/questions/21477855/dynamic-partitioning-create-as-on-hive
#https://stackoverflow.com/questions/20756561/how-to-pick-up-all-data-into-hive-from-subdirectories
#https://cwiki.apache.org/confluence/display/Hive/LanguageManual+DDL

describe tablename;
describe extended tablename;

create table db1.z_part1_like like db1.z_part1; -- Will have the partitions columns as well.

show partitions db1.z_part1;
      viewdate=2018-08-01
      viewdate=2018-08-02


ALTER TABLE db1.z_part1 SET TBLPROPERTIES ("hive.input.dir.recursive" = "TRUE",
    "hive.mapred.supports.subdirectories" = "TRUE",
    "hive.supports.subdirectories" = "TRUE",
    "mapred.input.dir.recursive" = "TRUE");
    
ALTER TABLE db1.z_part1 SET TBLPROPERTIES ("comment" = "mycomment");

# Cluster and Partitioning
ALTER TABLE table_name CLUSTERED BY (col_name, col_name, ...) [SORTED BY (col_name, ...)]
  INTO num_buckets BUCKETS;

ALTER TABLE mktg_bana.z_part1_like CLUSTERED BY (cookie) SORTED BY (cookie) into 1000 buckets;  
                                                                          
# SKEWING of DATA                                                                       
ALTER TABLE table_name NOT SKEWED;                                                                          

#Primary & foregin Keys
ALTER TABLE table_name ADD CONSTRAINT constraint_name PRIMARY KEY (column, ...) DISABLE NOVALIDATE;
ALTER TABLE table_name ADD CONSTRAINT constraint_name FOREIGN KEY (column, ...) REFERENCES table_name(column, ...) DISABLE NOVALIDATE RELY;
ALTER TABLE table_name DROP CONSTRAINT constraint_name; 
                                                                          
create table pk(id1 integer, id2 integer,
  primary key(id1, id2) disable novalidate);
 
create table fk(id1 integer, id2 integer,
  constraint c1 foreign key(id1, id2) references pk(id2, id1) disable novalidate);
                                                                          
#Add Partition                                                                          
 ALTER TABLE page_view ADD PARTITION (dt='2008-08-08', country='us') location '/path/to/us/part080808'
                          PARTITION (dt='2008-08-09', country='us') location '/path/to/us/part080809';                                                                         

#Temperory table                                                                          
CREATE TEMPORARY TABLE list_bucket_multiple (col1 STRING, col2 int, col3 STRING);
CREATE TEMPORARY TABLE db1.z_part1_temp as Select * from db1.z_part1;

CREATE TRANSACTIONAL TABLE transactional_table_test(key string, value string) PARTITIONED BY(ds string) STORED AS ORC;
                                                                          
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
var data1 = spark.sql("""Select cookie,url,viewdate
from db1.partners_web_data_uri_sessionized
where viewdate = '""" + dated + """' limit 10""")

data1.createOrReplaceTempView("data1")
spark.sql("""insert overwrite table  db1.z_part1 partition(viewdate) Select cookie,url,viewdate from data1""")

spark.sql("""insert overwrite table  db1.z_part1 partition(viewdate='""" + dated+ """') Select cookie,url from data1""")

var mdfwdus = wdus.select("url").dropDuplicates()
mdfwdus.createOrReplaceTempView("mdfwdus")
