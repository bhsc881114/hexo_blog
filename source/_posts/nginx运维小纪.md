title: "nginx运维小纪"
date: 2015-07-18 16:50:10
categories:
- 服务端运维
tags:
- nginx

---

最近搭了nginx作为日志服务器来做性能和操作分析，记录一下过程和遇到的一些问题
<!--more-->

# 日志

## 按天滚动

按天滚动一开始配置了logrotate实现，执行时间配置为0点0分，但实际真正执行时间是0点1分，一开始怀疑是其他cron.daily的其他任务影响，毕竟cron.daily会处理很多东西
![cron.daily](http://7xijc0.com1.z0.glb.clouddn.com/nginx1.png)

在cron.daily其他脚本上加了个日志，统计开始时间和结束时间，确实发现logrotate因为freshclam的影响延迟了
```
start freshclam 00:01:04
end freshclam 00:01:16
start logrotate 00:01:17
```
但是还是不能解释为什么不是0分开始，最后老老实实配置了一个独立的任务
```
0 0 * * * ~/tengine/logrotate.sh
```

## 分隔符
默认格式的分隔符比较混乱，因此采用了0x01，就是用vim编辑的时候要注意不是0x01，而是ctrl+v,ctrl+a 


## 响应时间
日志里面和时间相关的变量主要是2个，$request_time和$upstream_response_time

> $request_time就是从接请求的第一个字节到发送完响应数据的时间，即包括接收请求数据时间、程序响应时间、输出响应数据时间。
> $upstream_response_time指从Nginx向后端建立连接开始到接受完数据然后关闭连接为止的时间。

$request_time肯定比$upstream_response_time值大，特别是使用POST方式传递参数时，因为Nginx会把request body缓存住，接受完毕后才会把数据一起发给后端。所以如果用户网络较差，或者传递数据较大时，$request_time会比$upstream_response_time大很多

## 日志分析
我们的模式是将日志定时同步到hadoop集群再进行分析，不过也发现goaccess这个工具，可以比较好的分析日志，唯一的缺点是日志比较大的时间cpu飙高。。所以要分析最好换一台机器
```
goaccess -f tengine/logs/a.log -a --date-format=%F --time-format=%T --log-format="%h %d %t %U %s %b %R %u %^ %^ %L"
```

## referer CFNetwork
发现很多ua是 CFNetwork/672.X.X Darwin/14.X.X的没有referer，怀疑是某些网络环境下客户端不是webview而是用的CFNetwork库l来请求

---

# 性能配置

## 进程数和连接数配置

```
worker_processes  3;
events {
    use epoll;
    multi_accept on;
    worker_connections  4024;
}
```

## 长连接和超时
我们的服务简单，量还比较大，所以就把这个时间配置的尽量小，实际操作中发现基本维持在400来个连接，连接数基本是请求量的1/2
```
keepalive_timeout  12;
```

> curl 'http://127.0.0.1/nginx-status'
Active connections: 418 
server accepts  handled  requests request_time
 	   14168862 14168862 25943492 226096881
Reading: 1 Writing: 1 Waiting: 416 


```
## 下面的两个timeout一开始配置成10s，发现有部分http状态码是408的日志，就是因为10s超时，1分钟还是会有几条这样的错误，最重要的是错误了以后这个日志会打到根的access.log，后面把这个值调大到30
client_header_timeout  30;
client_body_timeout    30;
```

## sendfile、nopush、nodelay
```
    sendfile        on;
    tcp_nopush     on;
    tcp_nodelay    on;
```
TCP 传输的MSS有1460字节，为了提升网络利用率，避免拥塞，Nagle算法在发现要发送的数据太小的时候，会延时超过200ms再发送或者等数据超过MSS再发送，通过tcp_nodelay on可以关闭这个算法。当然这个选项是在长连接的情况下才有效的

tcp_nopush实际上对应的是linux tcp栈的TCP_CORK选项，他会禁止小包的发送，直到超过MSS。在nginx他，他在sendfile on的情况下才有效。sendfile可以让静态数据在内核态直接发送数据，而不用上下文切换进入用户态再发送。

tcp_nodelay和tcp_nopush结合的时候，首先tcp_nopush会堆积数据直到MSS才发送，之后移除tcp_nopush，剩下的最后1个包会因为tcp_nodelay马上发送。

## 其他
gzip压缩、文件缓存等，不过在我们场景下并没有启用


## tcp协议栈
协议栈主要是调整下滑动窗口大小，端口范围，backlog等
```
# accept的队列长度
net.core.somaxconn = 3240000
# 所有进程打开的文件总数
# 设置echo  6553560 > /proc/sys/fs/file-max
# 或修改 /etc/sysctl.conf, 加入
# fs.file-max = 6553560 重启生效
sys.fs.file_max
#向外连接的端口范围
net.ipv4.ip_local_port_range = 2000 65000 
# 支持更大的TCP窗口. 如果TCP窗口最大超过65535(64KB), 必须设置该数值为1
net.ipv4.tcp_window_scaling = 1
# 同时所处理的最大timewait数量
net.ipv4.tcp_max_tw_buckets = 6000
# 接收缓冲区默认值
net.core.rmem_default = 8388608
# 发送缓冲区默认值
net.core.wmem_default = 8388608
# 接收缓冲区最大值
net.core.rmem_max = 16777216
# 发送缓冲区最大值
net.core.wmem_max = 16777216
# TCP接收缓冲区，min default max
net.ipv4.tcp_rmem = 4096 87380 16777216
net.ipv4.tcp_wmem = 4096 65536 16777216

```

## ulimit
ulimit 设置当前shell以及由它启动的进程的资源限制，修改/etc/security/limits.conf
```
* soft nofile 65535 
* hard nofile 65535
```

---

# 参考
1.[被遗忘的Logrotate](http://huoding.com/2013/04/21/246)
2.[使用nginx记日志](http://blog.linezing.com/?p=950)
3.[Tuning NGINX for Performance](https://www.nginx.com/blog/tuning-nginx/)
4.[神秘的40毫秒延迟与 TCP_NODELAY](http://jerrypeng.me/2013/08/mythical-40ms-delay-and-tcp-nodelay/)
5.[Nginx 配置之性能篇](http://imququ.com/post/my-nginx-conf-for-wpo.html)
6.[UNDERSTANDING SENDFILE, TCP_NODELAY AND TCP_NOPUSH](https://t37.net/nginx-optimization-understanding-sendfile-tcp_nodelay-and-tcp_nopush.html)
7.[为最佳性能调优 Nginx](http://blog.jobbole.com/87531/)


