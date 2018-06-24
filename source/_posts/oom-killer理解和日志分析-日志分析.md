title: 'oom killer理解和日志分析:日志分析'
date: 2018-06-24 22:19:07
categories:
- linux内存
tags:
- oom killer
- 内存

---
oom killer日志分析,有疑问的可以先看上一篇：【oom killer理解和日志分析:知识储备】
<!--more-->

下面是一台8G内存上的一次oom killer的日志，上面跑的是RocketMQ 3.2.6，java堆配置：-server -Xms4g -Xmx4g -Xmn2g -XX:PermSize=128m -XX:MaxPermSize=320m
```
Jun  4 17:19:10 iZ23tpcto8eZ kernel: AliYunDun invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
Jun  4 17:19:10 iZ23tpcto8eZ kernel: AliYunDun cpuset=/ mems_allowed=0

Jun  4 17:19:10 iZ23tpcto8eZ kernel: active_anon:1813257 inactive_anon:37301 isolated_anon:0 active_file:84 inactive_file:0 isolated_file:0 unevictable:0 dirty:0 writeback:0 unstable:0 free:23900 slab_reclaimable:34218 slab_unreclaimable:5636 mapped:1252 shmem:100531 pagetables:68092 bounce:0 free_cma:0

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA free:15900kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 2801 7792 7792

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA32 free:43500kB min:24252kB low:30312kB high:36376kB
active_anon:2643608kB(2.5G)  inactive_anon:61560kB active_file:40kB inactive_file:40kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2869240kB mlocked:0kB dirty:0kB writeback:0kB mapped:748kB shmem:160024kB slab_reclaimable:54996kB slab_unreclaimable:6816kB kernel_stack:704kB pagetables:67440kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:275 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 0 4990 4990

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 Normal free:36200kB min:43192kB low:53988kB high:64788kB
active_anon:4609420kB(4.3G) inactive_anon:87644kB active_file:296kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:5242880kB managed:5110124kB mlocked:0kB dirty:0kB writeback:0kB mapped:4260kB shmem:242100kB slab_reclaimable:81876kB slab_unreclaimable:15720kB kernel_stack:1808kB pagetables:204928kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:511 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 0 0 0

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA: 1*4kB (U) 1*8kB (U) 1*16kB (U) 0*32kB 2*64kB (U) 1*128kB (U) 1*256kB (U) 0*512kB 1*1024kB (U) 1*2048kB (R) 3*4096kB (M) = 15900kB
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA32: 1281*4kB (UEM) 825*8kB (UEM) 1404*16kB (UEM) 290*32kB (EM) 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 43468kB
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 Normal: 1441*4kB (UEM) 3177*8kB (UEM) 315*16kB (UEM) 0*32kB 0*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 36220kB
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 hugepages_total=0 hugepages_free=0 hugepages_surp=0 hugepages_size=2048kB

Jun  4 17:19:10 iZ23tpcto8eZ kernel: 100592 total pagecache pages
Jun  4 17:19:10 iZ23tpcto8eZ kernel: 0 pages in swap cache
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Swap cache stats: add 0, delete 0, find 0/0
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Free swap  = 0kB
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Total swap = 0kB
Jun  4 17:19:10 iZ23tpcto8eZ kernel: 2097151 pages RAM
Jun  4 17:19:10 iZ23tpcto8eZ kernel: 94167 pages reserved
Jun  4 17:19:10 iZ23tpcto8eZ kernel: 284736 pages shared
Jun  4 17:19:10 iZ23tpcto8eZ kernel: 1976069 pages non-shared

Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ pid ]   uid  tgid total_vm      rss nr_ptes swapents oom_score_adj name
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  338]     0   338    10748      844      25        0             0 systemd-journal
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  351]     0   351    26113       61      20        0             0 lvmetad
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  368]     0   368    10509      149      23        0         -1000 systemd-udevd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  521]     0   521   170342      908     178        0             0 rsyslogd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  525]     0   525     8671       82      21        0             0 systemd-logind
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  526]    81   526     7157       96      19        0          -900 dbus-daemon
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  530]     0   530    31575      162      17        0             0 crond
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  540]    28   540   160978      131      37        0             0 nscd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  548]     0   548    27501       30      10        0             0 agetty
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  588]     0   588     1621       26       9        0             0 iprinit
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  590]     0   590     1621       25       9        0             0 iprupdate
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  601]     0   601     9781       23       8        0             0 iprdump
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  838]    38   838     7399      169      18        0             0 ntpd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [  881]     0   881      386       44       4        0             0 aliyun-service
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 5973]  1000  5973    41595      165      32        0             0 gmond
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 3829]     0  3829    33413      292      67        0             0 sshd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 3831]  1000  3831    33582      476      68        0             0 sshd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 3832]  1000  3832    29407      622      16        0             0 bash
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [14638]     0 14638    20697      210      42        0         -1000 sshd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [11531]     0 11531    33413      293      66        0             0 sshd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [11533]  1000 11533    33413      292      64        0             0 sshd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [11534]  1000 11534    29361      584      15        0             0 bash
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 3172]     0  3172     6338      161      17        0             0 AliYunDunUpdate
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 3224]     0  3224    32867     2270      61        0             0 AliYunDun
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 5417]  1000  5417    28279       51      14        0             0 sh
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 5421]  1000  5421    28279       53      13        0             0 sh
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [ 5424]  1000  5424 36913689  1537770   66407        0             0 java
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17132]     0 17132    21804      215      44        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17133]     0 17133    21804      285      43        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17134]     0 17134    21866      290      44        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17135]     0 17135    21866      290      44        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17136]     0 17136    21841      290      44        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [17137]     0 17137    21804      245      43        0             0 zabbix_agentd
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [13669]  1000 13669    28279       51      14        0             0 sh
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [13673]  1000 13673    28279       50      13        0             0 sh
Jun  4 17:19:10 iZ23tpcto8eZ kernel: [13675]  1000 13675   879675   204324     494        0             0 java

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Out of memory: Kill process 5424 (java) score 800 or sacrifice child
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Killed process 5424 (java) total-vm:147654756kB, anon-rss:6151080kB, file-rss:0kB
```
还是跟上篇一样，带着问题看

#### 1.谁申请内存以及谁被kill了？
这两个问题，可以从头尾的日志分析出来：
```
Jun  4 17:19:10 iZ23tpcto8eZ kernel: AliYunDun invoked oom-killer: gfp_mask=0x201da, order=0, oom_score_adj=0
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Killed process 5424 (java) total-vm:147654756kB, anon-rss:6151080kB, file-rss:0kB
```
AliYunDun申请内存，kill掉了java进程5424，他占用的内存是6151080K(5.8G)
> 还有一个小问题可能会有疑问，那就是进程5424的RSS（1537770）明明小于6151080，实际是因为这里的RSS是4K位单位的，所以要乘以4，算出来就对了

物理内存申请我们在上一篇分析了，会到不同的Node不同的zone，那么这次申请的是哪一部分？这个可以从**gfp_mask=0x201da, order=0**分析出来，gfp_mask(get free page)是申请内存的时候，会传的一个标记位，里面包含三个信息：区域修饰符、行为修饰符、类型修饰符：

```
0X201da = 0x20000 | 0x100| 0x80 | 0x40 | 0x10 | 0x08 | 0x02
也就是下面几个值：
___GFP_HARDWAL | ___GFP_COLD | ___GFP_FS | ___GFP_IO | ___GFP_MOVABLE| ___GFP_HIGHMEM
```
同时设置了___GFP_MOVABLE和___GFP_HIGHMEM会扫描ZONE_MOVABLE，其实也就是会在ZONE_NORMAL，再贴一次神图

![](http://7xijc0.com1.z0.glb.clouddn.com/memory_node_zone.png)

另外order表示了本次申请内存的大小0，也就是4KB
也就是说AliYunDun尝试从ZONE_NORMAL申请4KB的内存，但是失败了，导致了OOM KILLER

#### 2.各个zone的情况如何？

接下来，自然就会问，连4KB都没有，那到底还有多少？看这部分日志：
```
Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA free:15900kB min:132kB low:164kB high:196kB active_anon:0kB inactive_anon:0kB active_file:0kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:15992kB managed:15908kB mlocked:0kB dirty:0kB writeback:0kB mapped:0kB shmem:0kB slab_reclaimable:0kB slab_unreclaimable:8kB kernel_stack:0kB pagetables:0kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 2801 7792 7792

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 DMA32 free:43500kB min:24252kB low:30312kB high:36376kB
active_anon:2643608kB(2.5G)  inactive_anon:61560kB active_file:40kB inactive_file:40kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:3129216kB managed:2869240kB mlocked:0kB dirty:0kB writeback:0kB mapped:748kB shmem:160024kB slab_reclaimable:54996kB slab_unreclaimable:6816kB kernel_stack:704kB pagetables:67440kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:275 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 0 4990 4990

Jun  4 17:19:10 iZ23tpcto8eZ kernel: Node 0 Normal free:36200kB min:43192kB low:53988kB high:64788kB
active_anon:4609420kB(4.3G) inactive_anon:87644kB active_file:296kB inactive_file:0kB unevictable:0kB isolated(anon):0kB isolated(file):0kB present:5242880kB managed:5110124kB mlocked:0kB dirty:0kB writeback:0kB mapped:4260kB shmem:242100kB slab_reclaimable:81876kB slab_unreclaimable:15720kB kernel_stack:1808kB pagetables:204928kB unstable:0kB bounce:0kB free_cma:0kB writeback_tmp:0kB pages_scanned:511 all_unreclaimable? yes
Jun  4 17:19:10 iZ23tpcto8eZ kernel: lowmem_reserve[]: 0 0 0 0
```

可以看到Normal还有36200KB，DMA32还有43500KB，DMA还有15900KB，其中Normal的free确实小于min，但是DMA32和DMA的free没问题啊？从上篇文章分析来看，分配是有链条的，Normal不够了，会从DMA32以及DMA去请求分配，所以为什么分配失败了呢？

###### 2.1 lowmem_reserve
虽然说分配内存会按照Normal、DMA32、DMA的顺序去分配，但是低端内存相对来说更宝贵些，为了防止低端内存被高端内存用完，linux设计了保护机制，也就是lowmen_reserve，从上面的日志看，他们的值是这样的：
* DMA（index=0）:     lowmem_reserve[]:0 2801 7792 7792
* DMA32（index=1）: lowmem_reserve[]: 0 0 4990 4990
* Normal（index=2）: lowmem_reserve[]: 0 0 0 0

lowmen_reserve的值是一个数组，当Normal(index=2)像DMA32申请内存的时候，需要满足条件：DMA32 high+lowmem_reserve[2] < free，才能申请，来算下：
* Normal：从自己这里申请，free(36200) < min(43192)，所以申请失败了(watermark[min]以下的内存属于系统的自留内存，用以满足特殊使用，所以不会给用户态的普通申请来用)
* Normal转到DMA32申请:high(36376KB) + lowmem_reserve\[2\](4990)\*4=56336KB &gt; DMA32 Free(43500KB),不允许申请
* Normal转到DMA申请:high(196KB) + lowmem_reserve\[2\](7792)\*4  = 31364KB &gt; DMA Free(15900KB),不允许申请,所以....最终失败了

###### 2.2 min_free_kbytes
这里属于扩展知识了，和分析oom问题不大
我们知道了每个区都有min、low、high，那他们是怎么计算出来的，就是根据min_free_kbytes计算出来的，他本身在系统初始化的时候计算，最小128K，最大64M
* watermark[min] = min_free_kbytes换算为page单位即可，假设为min_free_pages。（因为是每个zone各有一套watermark参数，实际计算效果是根据各个zone大小所占内存总大小的比例，而算出来的per zone min_free_pages）
* watermark[low] = watermark[min] * 5 / 4
* watermark[high] = watermark[min] * 3 / 2

**min 和 low的区别：**
* min下的内存是保留给内核使用的；当到达min，会触发内存的direct reclaim
* low水位比min高一些，当内存可用量小于low的时候，会触发 kswapd回收内存，当kswapd慢慢的将内存 回收到high水位，就开始继续睡眠

###### 3.最后的问题：java为什么占用了这么多内存？
内存不足申请失败的细节都分析清楚了，剩下的问题就是为什么java会申请这么多内存(5.8G)，明明-Xmx配置的是4G，加上PermSize，也就最多4.3G。

因为这上面跑的是RocketMQ，他会有文件映射mmap，所以在仔细分析oom日志之前，怀疑是pagecache占用，导致RSS为5.8G，这带来了另一个问题，为什么pagecache没有回收？分析了日志以后，发现和pagecache基本没关系，看这个日志(换行是我后来加上的)：
```
Jun  4 17:19:10 iZ23tpcto8eZ kernel: active_anon:1813257 inactive_anon:37301 isolated_anon:0 active_file:84     
inactive_file:0 isolated_file:0
unevictable:0 dirty:0 writeback:0
unstable:0 free:23900     
slab_reclaimable:34218     
slab_unreclaimable:5636 mapped:1252
shmem:100531 pagetables:68092 bounce:0     
free_cma:0
```
当时的内存大部分都是活跃的匿名页(active_anon 1813257*4KB=6.9G)，非活跃匿名页（inactive_anon 145M），活跃文件页（active_file 84*4=336KB）,非活跃文件页（inactive_file 0），也就是说当时基本没有pagecache

另外，进程重启以后gc文件被覆盖了(运维上没操作好)，另外被oom killer也没有java dump，所以…..真的不知道到底为什么java占了5.8G!!! 悬案还是没有解开 T_T

参考：
* [内存分配掩码（gfp_mask） - 内存域修饰符 & 内存分配标志](https://blog.csdn.net/farmwang/article/details/66975128)
* [Linux page allocation failure 的问题处理 - lowmem_reserve_ratio](https://github.com/digoal/blog/blob/master/201612/20161221_01.md)
* [Linux内核参数min_free_kbytes与lowmem_reserve_ratio](https://blog.csdn.net/petib_wangwei/article/details/75135686)
* [/PROC/MEMINFO之谜](http://linuxperf.com/?hmsr=toutiao.io&p=142&utm_medium=toutiao.io&utm_source=toutiao.io)
* [谨慎调整内核参数:vm.min_free_kbytes](https://www.cnblogs.com/muahao/p/8082997.html)
