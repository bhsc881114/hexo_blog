title: "响应式站点2-viewport"
date: 2015-05-22 08:58:34
categories: 
- 前端
- 响应式
tags:
- viewport 
- media-query
---

![viewport-index](http://7xijc0.com1.z0.glb.clouddn.com/viewport-2.png)

viewport原理,设置,media-query
<!--more-->

---

以前主内做一个在手机上的网站，一开始显示的内容都偏小，需要双击缩放才能显示。后来发现加一句
{% codeblock %}
<meta name="viewport" content="width=device-width, initial-scale=1.0">
{% endcodeblock %}
就可以了,瞬间觉得高大上....断断续续研究了一段时间，现总结一下

# PC->Mobile
PC和手机毕竟是尺寸不同的两种设备，怎么让PC上的网站能够展示在手机上?答案就是：缩放，
所以早期看到的网站都很小，需要双击放大某一部分区域才能浏览。

## viewport
viewport 直译为视口,就是我们可见的部分(有点像窗口)，大致就是下面这个样子：
  <center>![viewport](http://7xijc0.com1.z0.glb.clouddn.com/viewport-3.png)  </center>

一个1024px宽的站点，要在320px的手机上显示，就需要先适当缩放，然后再通过移动网页来展示不同的部分

## layout viewport
上面有一个小细节就是一个1024px的站点是怎么在320px的手机上渲染的？这里有个隐藏的概念,
就是layout viewport。当我们设置一个width=20%时,他必须知道父级的width是多少,最终必须找到一个设置绝对值的顶层的元素(body)

早期的站点都是PC的，所以手机浏览器默认的宽度都是接近pc的宽度，这样PC的站点展示都没有问题.这篇文章[Meta viewport](http://www.quirksmode.org/mobile/metaviewport/)里有每个手机浏览器的默认layot viewport，截个图：

![layout](http://7xijc0.com1.z0.glb.clouddn.com/viewport-4.png)




## 缩放

# 设置viewport

## 3种view

## device width和width
