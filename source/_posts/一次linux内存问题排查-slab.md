title: "一次linux内存问题排查-slab"
date: 2015-04-19 08:08:47
categories:
- linux内存
tags:
- slab
- 内存
- pagecache
photos:
- http://7xijc0.com1.z0.glb.clouddn.com/xxxx.png
---

一次内存告警的排查过程，linux内存占用分析
<!--more-->

# 问题
有一台机器内存不足的告警，机器内存总共8G，top看了下:
![img](http://7xijc0.com1.z0.glb.clouddn.com/A1.png)

已经使用有7G，进程实际占用的物理内存是RES，目测实际应该只占了3G不到，数据对不上，什么鬼

# 内存占用分析
主要参考了[Linux Used内存到底哪里去了](http://blog.yufeng.info/archives/2456)，收获挺大，分享下

## nmon、slabtop等工具
先装了nmon，他能够比较直观的现实内存占用情况:
![img](http://7xijc0.com1.z0.glb.clouddn.com/A2.png)
通过meminfo也可以看，就是数据有点多，容易忽略
![img](http://7xijc0.com1.z0.glb.clouddn.com/A3.png)
发现slab特别大，应该是这个原因(slabtop)
![img](http://7xijc0.com1.z0.glb.clouddn.com/A4.png)

## 分析slab占用情况
把slab占用比较大的打出来,
{% codeblock %}
 cat /proc/slabinfo |awk '{if($3*$4/1024/1024 > 100){print $1,$3*$4/1024/1024} }'

  ext3_inode_cache 282.575
  proc_inode_cache 2154.03
  dentry_cache 868.075
{% endcodeblock %}

**发现proc_inode这个占了2G多，当然dentry也不小，proc的文件是挺多，但是这么多肯定不正常**

---

# 释放缓存
不知道为啥proc会占这么大，怀疑是阿里云的问题（只是怀疑，最后没查到原因就好了），如果想主动释放inoed可以用下面的方法：

To free pagecache:
* echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes:
* echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes:
* echo 3 > /proc/sys/vm/drop_caches

# 内存使用计算
内存相关的有有进程的内存管理、伙伴分配算法、slab、page table、MNU，page cache等等，每一项都值得展开，这里先只看怎么计算内存使用，霸爷给出的计算方式挺靠谱：slab+page table+res

## slab
slab 个人解就是一个内存池，因为一个page太大了放一些小对象不经济，所以就搞了个对象池，用于分配这些小对象，可以参考
[slab、slub、slob](http://stackoverflow.com/questions/15470560/what-to-choose-between-slab-and-slub-allocator-in-linux-kernel)，另外还有slub更适应现代高性能服务器大量进程的情况，代码也更简单

## RES
RES指进程实际占用的内存（resident resident set size），man top给出的算法是 RES = CODE + DATA.实际中我发现很多进程对不上，whatever

## page table
linux的内存分page来管理（一般是4K），所有有个page table做描述信息也很好理解
![img](http://7xijc0.com1.z0.glb.clouddn.com/page-table.png)

## buffer、cache
buffer和cache是已经使用的内存，可以释放。page cache，他和文件系统关系比较大，后续分享rocketmq时再细讲吧
