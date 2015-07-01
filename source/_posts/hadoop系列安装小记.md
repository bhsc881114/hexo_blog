title: "hadoop系列安装小记"
date: 2015-06-18 23:41:26
categories:
- hadoop
tags:
- hadoop安装
---

<center>![viewport-index](http://7xijc0.com1.z0.glb.clouddn.com/img-myhadoop-bigger4.jpg)</center>
最近需要维护hadoop集群，把以前的安装文档翻出来，理了理，记录在此
<!--more-->

# cdh
当时装的是5.1.0，现在最新的版本是[5.4.2](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_vd_cdh_package_tarball.html)，因为有在线业务使用，所以暂时不升级。独立下载hadoop各个组件再安装比较繁琐(hdfs+yarn+hbsae+zk+hive)，没有选好版本可能会冲突，CDH的版本都是选定好的，安装和升级文档齐全,非常方便

* [5.1.0各版本信息](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_vd_cdh_package_previous.html?scroll=topic_7#concept_rjt_wjx_dp_unique_2)
* [5.1.0安装文档](http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/CDH5-Installation-Guide.html)
* [升级文档](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_upgrade_command_line.html)

# 安装前配置

**[官方流程](http://www.cloudera.com/content/cloudera-content/cloudera-docs/CDH5/latest/CDH5-Installation-Guide/cdh5ig_cdh5_install.html)** 大致分一下3个步骤：
* 1.[配置cdh库，并通过yum安装](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_install.html)
* 2.[配置网络/hdfs/YARN等](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_cluster_deploy.html#topic_11)
* 3.[其他组件安装,比如hbase/hive](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_cdh5_comp_install.html#topic_4_5_unique_4)

## 配置yum源

* 下载rpm:
wget http://archive.cloudera.com/cdh5/one-click-install/redhat/5/x86_64/cloudera-cdh-5-0.x86_64.rpm
* 安装rpm，会加一个clouder的yum源： sudo yum --nogpgcheck localinstall cloudera-cdh-5-0.x86_64.rpm  
* 清下yum缓存: yum clean all 、 yum makecache
* 导入GPG验证的key：sudo rpm --import http://archive.cloudera.com/cdh5/redhat/5/x86_64/cdh/RPM-GPG-KEY-cloudera
* 可能的问题:

```
1.运行yum的可能遇到错误:
It's possible that the above module doesn't match the current version of Python, which is:2.7.3 (default, May 19
2014, 15:04:50) [GCC 4.1.2 20080704 (Red Hat 4.1.2-46)]

需要修改yum的python依赖版本：
修改文件： vim /usr/bin/yum
修改头#!/usr/bin/python  => #!/usr/bin/python2.4

2.找不到host命令，需要装下bind-utils：yum install bind-utils
```

## 安装jdk
```
yum -y install unzip
curl -L -s get.jenv.io | bash
source /home/admin/.jenv/bin/jenv-init.sh
jenv install java 1.7.0_45
```

jdk通过USER账号安装，cdh系列的需要在自己的特定账号下执行，比如hdfs账号，所以会出现找不到JAVA_HOME的问题,解决方法：

* 在/etc/sudoers 配置：Defaults env_keep+=JAVA_HOME
* 设置ROOT下的JAVA_HOME指向USER。。，需要修改USER为可执行权限
* 还有另一个方法，是在/etc/default/bigtop-utils 下配置javahome（chmod 755 /home/USER）
```
export JAVA_HOME=/home/USER/.jenv/candidates/java/current
chmod 755 /home/USER/
```

# HDFS

## 安装和配置
**NameNode、Client**
```
sudo yum install hadoop-hdfs-namenode
sudo yum install hadoop-client
```

**安装DataNode**
```
在DataNode机器上执行：
sudo yum install hadoop-yarn-nodemanager hadoop-hdfs-datanode hadoop-mapreduce
```

**设置hdfs config文件到自己的目录下**

```
sudo cp -r /etc/hadoop/conf.empty /etc/hadoop/conf.my_cluster
sudo /usr/sbin/alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.my_cluster 50
sudo /usr/sbin/alternatives --set hadoop-conf /etc/hadoop/conf.my_cluster
sudo chmod -R 777 /etc/hadoop/conf.my_cluster
（alternatives --config java好像无效）

创建数据目录（用户组hdfs:hdfs 权限700）:
datanode：sudo mkdir -p /data/hadoop/hdfs/dn
sudo chown -R hdfs:hdfs /data/hadoop

```

**hadoop-env.sh**
```
hadoop默认为namenode、datanode都是1G的内存：
export HADOOP_NAMENODE_OPTS="$HADOOP_NAMENODE_OPTS -Xmx3072m -verbose:gc -Xloggc:/var/log/hadoop-hdfs/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
export HADOOP_DATANODE_OPTS="$HADOOP_DATANODE_OPTS -Xmx2048m -verbose:gc -Xloggc:/var/log/hadoop-hdfs/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
```

**core-site.xml**
```
<property>
<!-- namenode地址和端口 -->
 <name>fs.defaultFS</name>
 <value>hdfs://cdhhadoop1:8020</value>
</property>
<!-- 回收站，默认保留一天 -->
<property>
 <name>fs.trash.interval</name>
 <value>1440</value>
</property>
<property>
 <name>fs.trash.checkpoint.interval</name>
 <value>0</value>
</property>
<!-- 配置Snappy压缩 -->
 <property>
  <name>io.compression.codecs</name>
 <value>org.apache.hadoop.io.compress.DefaultCodec,org.apache.hadoop.io.compress.GzipCodec,org.apache.hadoop.io.compress.BZip2Codec,org.apache.hadoop.io.compress.SnappyCodec</value>
</property>
```

**配置hdfs-site.xml**
```
<!-- 超级用户 -->
<property>
   <name>dfs.permissions.superusergroup</name>
   <value>admin</value>
</property>
<!-- hdfs副本 -->
<property>
   <name>dfs.replication</name>
   <value>2</value>
</property>
<!-- dfs.namenode.name.dir 作为namenode存放元信息的目录，如果设置多个则会有一个拷贝，可以在另外一台机器上搭一个NFS共享目录，作为备份 ->
  <property>
    <name>dfs.namenode.name.dir</name>
    <value>/data/hadoop/hdfs/nn</value>
  </property>
  <property>
     <name>dfs.datanode.data.dir</name>
     <value>/data/hadoop/hdfs/dn</value>
  </property>
```

* 其他配置:
> 1.如果datanode的目录有一个写失败，DataNode就会停止，这样这个DataNode上的所有目录的副本都会增加，如果要避免这种情况，可以设置容忍失败的目录个数
> 2.可以配置负载均衡，默认的分配策略是随机的，可以配置一个策略比如磁盘大小
> 3.没有配置web hdfs

## 启动

* 格式化namenode
```
sudo -u hdfs hdfs namenode -format

日志文件目录：/var/log/hadoop-hdfs
```

* 启动namenode
```
sudo service hadoop-hdfs-namenode start
```

* 启动datanode
```
sudo service hadoop-hdfs-datanode start
```

* 初始化

hdfs运行以后，推荐在hdfs上创建tmp目录，并设置权限：
```
$ sudo -u hdfs hadoop fs -mkdir /tmp
$ sudo -u hdfs hadoop fs -chmod -R 1777 /tmp
```

## 测试

http://localhost:50070/dfshealth.html#tab-overview

简单的测试只要执行下hadoop fs命令即可，如果要测试读写性能，要等mapreduce装好
```
【写性能测试】
hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-test.jar  TestDFSIO -write -nrFiles 10 -fileSize 1000
我们集群的一次测试结果：
----- TestDFSIO ----- : write
           Date & time: Sun Jul 13 21:40:41 CST 2014
       Number of files: 10
Total MBytes processed: 10000.0（总共10个文件，每个1G）
     Throughput mb/sec: 6.452312250618132（总大小/Map总时间）
Average IO rate mb/sec: 6.50354528427124
 IO rate std deviation: 0.6099282285067701
Test exec time sec: 197.818（整体执行时间）
```

>Throughput是总大小文/每个Map时间之和，如果算并发吞吐量的话，可以乘以Map数量，详细解读可以参考：[Benchmarking and Stress Testing an Hadoop Cluster With TeraSort, TestDFSIO & Co](http://www.michael-noll.com/blog/2011/04/09/benchmarking-and-stress-testing-an-hadoop-cluster-with-terasort-testdfsio-nnbench-mrbench/)


```
【读性能测试】
hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-test.jar  TestDFSIO -read -nrFiles 10 -fileSize 1000
20:38:21 INFO fs.TestDFSIO: ----- TestDFSIO ----- : read
20:38:21 INFO fs.TestDFSIO:  Date & time: Tue Jul 15 20:38:21 CST 2014
20:38:21 INFO fs.TestDFSIO:        Number of files: 10
20:38:21 INFO fs.TestDFSIO: Total MBytes processed: 10000.0
20:38:21 INFO fs.TestDFSIO:      Throughput mb/sec: 16.79261125104954
20:38:21 INFO fs.TestDFSIO: Average IO rate mb/sec: 16.829221725463867
20:38:21 INFO fs.TestDFSIO:  IO rate std deviation: 0.8154139285912413
20:38:21 INFO fs.TestDFSIO:     Test exec time sec: 84.614


测试结果以后需要清理测试结果
hadoop jar /usr/lib/hadoop-0.20-mapreduce/hadoop-test.jar  TestDFSIO -clean
```
>
在windows看客户端下测试Hdfs，需要到
https://github.com/srccodes/hadoop-common-2.2.0-bin 下载并替换hadoopHome下的bin目录


# YARN

## 安装和配置
```
sudo yum install hadoop-yarn-resourcemanager
sudo yum install hadoop-mapreduce-historyserver hadoop-yarn-proxyserver
sudo mkdir -p /data/yarn/local
sudo mkdir -p /data/yarn/logs
sudo chown -R yarn:yarn /data/yarn
hadoop fs -mkdir -p /user/history
hadoop fs -chmod -R 1777 /user/history
hadoop fs -chown mapred:hadoop /user/history
```

**yarn-site.xml**
```
<configuration>
   <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>cdhhadoop1</value>
  </property>
  <property>
    <name>yarn.resourcemanager.webapp.address</name>
    <value>cdhhadoop1:8088</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>
  <property>
    <name>yarn.nodemanager.aux-services.mapreduce_shuffle.class</name>
    <value>org.apache.hadoop.mapred.ShuffleHandler</value>
  </property>
  <property>
    <name>yarn.log-aggregation-enable</name>
    <value>true</value>
  </property>
  <property>
    <description>List of directories to store localized files in.</description>
    <name>yarn.nodemanager.local-dirs</name>
    <value>file:///data/yarn/local</value>
  </property>
  <property>
    <description>Where to store container logs.</description>
    <name>yarn.nodemanager.log-dirs</name>
    <value>file:///data/yarn/logs</value>
  </property>
  <property>
    <description>Where to aggregate logs to.</description>
    <name>yarn.nodemanager.remote-app-log-dir</name>
    <value>hdfs:///log/yarn/apps</value>
  </property>
  <property>
    <description>Classpath for typical applications.</description>
     <name>yarn.application.classpath</name>
     <value>
        $HADOOP_CONF_DIR,
        $HADOOP_COMMON_HOME/*,$HADOOP_COMMON_HOME/lib/*,
        $HADOOP_HDFS_HOME/*,$HADOOP_HDFS_HOME/lib/*,
        $HADOOP_MAPRED_HOME/*,$HADOOP_MAPRED_HOME/lib/*,
        $HADOOP_YARN_HOME/*,$HADOOP_YARN_HOME/lib/*
     </value>
  </property>
```

## 启动

* 端口
```
resourceManager 8088/cluster
nodeManager  8042/node
JobHistory  19888/jobhistory
Name:http://localhost:8088/cluster/nodes
Node1:http://localhost:8042/node
Node2:http://localhost:8043/node
```

## 测试
```
通过hadoop自带的randowmwriter测试下：
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar randomwriter out
21:14:34 INFO mapreduce.Job: Job job_1405247153654_0004 completed successfully
21:14:34 INFO mapreduce.Job: Counters: 33
        File System Counters
                FILE: Number of bytes read=0
                FILE: Number of bytes written=1772230
                FILE: Number of read operations=0
                FILE: Number of large read operations=0
                FILE: Number of write operations=0
                HDFS: Number of bytes read=2350
                HDFS: Number of bytes written=21545727074（写入20G）
                HDFS: Number of read operations=80
                HDFS: Number of large read operations=0
                HDFS: Number of write operations=40
        Job Counters
                Killed map tasks=10
                Launched map tasks=30
                Other local map tasks=30
                Total time spent by all maps in occupied slots (ms)=7247472
                Total time spent by all reduces in occupied slots (ms)=0
                Total time spent by all map tasks (ms)=7247472
                Total vcore-seconds taken by all map tasks=7247472
                Total megabyte-seconds taken by all map tasks=7421411328
        Map-Reduce Framework
                Map input records=20
                Map output records=2043801
                Input split bytes=2350
                Spilled Records=0
                Failed Shuffles=0
                Merged Map outputs=0
                GC time elapsed (ms)=8157
                CPU time spent (ms)=641440
                Physical memory (bytes) snapshot=2889732096
                Virtual memory (bytes) snapshot=14388494336
                Total committed heap usage (bytes)=2371878912
        org.apache.hadoop.examples.RandomWriter$Counters
                BYTES_WRITTEN=21475013178
                RECORDS_WRITTEN=2043801
        File Input Format Counters
                Bytes Read=0
        File Output Format Counters
                Bytes Written=21545727074
The job took 604 seconds.
```

# ZK
## 安装和配置
*安装*
```
sudo yum install zookeeper
sudo yum install zookeeper-server
```
**拷贝配置**
```
sudo cp -r /etc/zookeeper/conf.dist /etc/zookeeper/conf.my_cluster
sudo alternatives --verbose --install /etc/zookeeper/conf zookeeper-conf /etc/zookeeper/conf.my_cluster 50
sudo alternatives --set zookeeper-conf /etc/zookeeper/conf.my_cluster
```

**修改配置文件并在节点间同步**
```
/etc/zookeeper/conf.my_cluster/zoo.cfg
server.1=A:2888:3888
server.2=B:2888:3888
server.3=C:2888:3888
```

**创建数据目录**
```
mkdir -p /data/zookeeper
chown -R zookeeper:zookeeper /data/zookeeper
```
## 启动
```
启动日志在/var/log/zookeeper
在A运行 :
$ service zookeeper-server init --myid=1
$ service zookeeper-server start
在B运行
$ service zookeeper-server init --myid=2
$ service zookeeper-server start
在C运行
$ service zookeeper-server init --myid=3
$ service zookeeper-server start
```

## 测试
```
zookeeper-client -server A:2181
zookeeper-client -server B:2181

目录列表： ls /
创建目录： create /test "empty"
```

# HBase

## 安装和配置
**安装**
```
所有机器上： sudo yum install hbase
NameNode：sudo yum install hbase-master
DataNode： sudo yum install hbase-regionserver
```

**拷贝自己的配置文件**
```
sudo cp -r /etc/hbase/conf.dist /etc/hbase/conf.my_cluster
sudo alternatives --verbose --install /etc/hbase/conf hbase-conf /etc/hbase/conf.my_cluster 50
sudo alternatives --set hbase-conf /etc/hbase/conf.my_cluster
```
**修改最大文件数限制**
```
避免Too many open files（/etc/security/limits.conf）
hdfs  -       nofile  32768
hbase -       nofile  32768
阿里云机器默认已经是65535，所以不做修改

hdfs DataNode会限制打开的文件数（ /etc/hadoop/conf/hdfs-site.xml）
<property>
  <name>dfs.datanode.max.xcievers</name>
  <value>65535</value>
</property>
```

**创建目录**
```
hadoop fs -mkdir /hbase
hadoop fs -chown hbase /hbase
```
**hbase-site.xml**
```
<property>
  <name>hbase.cluster.distributed</name>
  <value>true</value>
</property>
<property>
  <name>hbase.rootdir</name>
  <value>hdfs://myhost:8020/hbase</value>
</property>
<property>
  <name>hbase.zookeeper.quorum</name>
    <value>A,B,C</value>
</property>
<!--关闭checksum-->
<property>
    <name>hbase.regionserver.checksum.verify</name>
    <value>false</value>
    <description>
        If set to  true, HBase will read data and then verify checksums  for
        hfile blocks. Checksum verification inside HDFS will be switched off.
        If the hbase-checksum verification fails, then it will  switch back to
        using HDFS checksums.
    </description>
  </property>
<property>
    <name>hbase.hstore.checksum.algorithm</name>
    <value>NULL</value>
    <description>
      Name of an algorithm that is used to compute checksums. Possible values
      are NULL, CRC32, CRC32C.
    </description>
  </property>
````

## 启动
```
service hbase-master start
service hbase-regionserver start
```

## 测试
```
60010是master的端口 http://localhost:60010/master-status?filter=all
60030是regionServer的端口

测试hbase集群是否支持snappy：
hbase org.apache.hadoop.hbase.util.CompressionTest hdfs://namenode:8020/benchmarks/hbase snappy
通过hbase shell访问hbase
```

# Hive

## 安装和配置
**安装hive/metastore/hieveserver**
```
sudo yum install -y hive
sudo yum install -y hive-metastore
sudo yum install -y hive-server2
```

**mysql-connector-java.jar**
```
在metastore的机器，把mysql-connector-java.jar放到/usr/lib/hive/lib/目录下
```

**java堆配置**
[我们配置的是3G](http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cdh_ig_hive_install.html#concept_alp_4kl_3q_unique_1)
```
官方文档有误，实际配置文件是:/etc/hive/conf/hive-env.sh
if [ "$SERVICE" = "hiveserver2或者metastore" ]; then
   export HADOOP_OPTS="${HADOOP_OPTS} -Xmx3072m -Xms1024m -Xloggc:/var/log/hive/gc.log -XX:+PrintGCDetails -XX:+PrintGCDateStamps"
fi
export HADOOP_HEAPSIZE=512
```

**metastore配置(配置文件：hive-site.xml)**
[参考](http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hive_metastore_configure.html)

**metastore 配置hdfs**
```
先初始化下hdfs得配置,再从namenode把最新的配置拷过来：scp /etc/hadoop/conf.my_cluster/hdfs-site.xml /etc/hadoop/conf.my_cluster/core-site.xml host:/etc/hadoop/conf.my_cluster/
```

**hiveserver2配置(配置文件：/etc/hive/conf/hive-site.xml)**
[主要是配置metastore地址，zk地址](http://www.cloudera.com/content/cloudera/en/documentation/cdh5/v5-1-x/CDH5-Installation-Guide/cdh5ig_hiveserver2_configure.html)
```
<property>
  <name>hive.support.concurrency</name>
  <description>Enable Hive's Table Lock Manager Service</description>
  <value>true</value>
</property>
<property>
  <name>hive.zookeeper.quorum</name>
  <description>Zookeeper quorum used by Hive's Table Lock Manager</description>
  <value>A,B,C</value>
</property>
<property>
  <name>hive.metastore.local</name>
  <value>false</value>
</property>
<property>
  <name>hive.metastore.uris</name>
  <value>thrift://xxxxx:9083</value>
</property>
```

## 启动
```
sudo /sbin/service hive-metastore start
sudo /sbin/service hive-server2 start
```

## 测试
* 1./usr/lib/hive/bin/beeline
* 2.!connect jdbc:hive2://localhost:10000 username password org.apache.hive.jdbc.HiveDriver
    或者： !connect jdbc:hive2://10.241.52.161:10000 username password org.apache.hive.jdbc.HiveDriver
* 3.show tables;

>hive服务端日志在：/var/log/hive
hive shell日志在/tmp/admin/hive.log，之前有个配置错误引起的异常，一直没找到日志，原来路径是在/etc/hive/conf下的log4j配置的

# 参考
* [Platform base: HDFS + MR](http://hadooper.blogspot.jp/2010/11/platform-base-hdfs-mr.html)
* [hive搭建&测试](http://blog.fens.me/hadoop-hive-intro/)
* [从Hadoop到Spark的架构实践](http://www.csdn.net/article/2015-06-08/2824889?utm_source=tuicool)
