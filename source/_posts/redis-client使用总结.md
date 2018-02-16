title: redis client使用总结
date: 2018-02-15 20:28:03
categories:
- redis
tags:
- redis
---
本文记录了使用redis client的基本配置和连接超限的问题
<!--more-->

## 客户端配置
java端的redis client使用的是jedis，他的连接池实现是基于Apache Commons Pool 2，配置也参考的GenericObjectPoolConfig，分别是minIdle,maxIdle,maxTotal,其中maxTotal包含了活跃和非活跃的连接总数

> maximum total connections (maxTotal) includes both active and idle connections.maximum idle connections (maxIdle) are connections that are ready to be used (but are currently unused).

另外timeout是在Jedis的构造函数里指定的，他同时指定了connectionTimeout(最大连接时间)和soTimeout(最大响应时机 )


## 服务端配置
客户端配置就上面几个，用起来还是挺简单的，但是用的过程中还是会遇到一些问题，比如ERR max number of clients reached，有可能会是以下几个原因

#### 1.连接数超过限制
redis server最大连接数的配置由maxclients决定，2.6以后的版本默认值是10000，如果设置的值超过了操作系统的最大值限制，则会在启动的时候给出提示

> $ ./redis-server --maxclients 100000
[41422] 23 Jan 11:28:33.179 # Unable to set the max number of files limit to 100032 (Invalid argument), setting the max clients configuration to 10112.

#### 2.timeout没有配置
一般情况下，超过10000的最大连接数，是使用上的问题，首先redis服务端默认的timout配置的是0，即不会关闭连接，即便这个连接已经空闲很久，这时候如果客户端在重启前没有关闭连接或者说中间有防火墙之类的断开了连接，redis 服务端将会永久保留这些连接，这时候只要配置timeout即可

> config get timeout ## 查看timeout配置

#### 3.keepalive的设置
除了timeout也还可以通过keepalive配置来解决，比如sentinel的连接超时时间，timeout的配置是不生效的，这里的keepalive指的是TCP协议层的配置，他有三个参数影响：

> tcp_keepalive_time     default 7200 seconds
tcp_keepalive_probes   default 9
tcp_keepalive_intvl    default 75 seconds

超时公式为：
> tcp_keepalive_time+tcp_keepalive_intvl*tcp_keepalive_probes=7895s=131.58min

这个时间还是挺久的，redis服务端在3.2版本已经以后，默认设置了tcp_keepalive_time为300秒(以前的版本默认为0，也就是不启用)

配置上这个参数之后，对于一些客户端没有正常关闭的场景也能及时的关闭

#### 4.正确关闭客户端连接
另外说到客户端的正确配置，如果是使用Spring的话，只要配置下bean的destroy-method，在这里关闭连接池即可，如果没有用Spring，则要自己注册一个ShutdownHook

---

# 参考
1.[redis报-ERR max number of clients reached错误](http://coolnull.com/2842.html)
2.[Custom Configuration of TCP Socket Keep-Alive Timeouts](http://coryklein.com/tcp/2015/11/25/custom-configuration-of-tcp-socket-keep-alive-timeouts.html)
3.[Redis Clients Handling](https://redis.io/topics/clients)