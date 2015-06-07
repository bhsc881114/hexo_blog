title: "响应式站点2-viewport和media-query"
date: 2015-05-22 08:58:34
categories: 
- 前端
tags:
- 响应式
- viewport 
- media-query
---

* [响应式站点1-技术基础](http://bhsc881114.github.io/2015/05/12/%E5%93%8D%E5%BA%94%E5%BC%8F%E7%AB%99%E7%82%B9-%E6%8A%80%E6%9C%AF%E5%9F%BA%E7%A1%80/)
* 响应式站点2-viewport和media-query
* 响应式站点3-skills(预告)

以前做一个在手机上的网站，一开始显示的内容都偏小，需要双击缩放才能显示。后来发现加上viewport就可以了，瞬间觉得高大上....扒一扒他的原理
{% codeblock %}
<meta name="viewport" content="width=device-width, initial-scale=1.0">
{% endcodeblock %} 

![viewport-index](http://7xijc0.com1.z0.glb.clouddn.com/viewport-2.png)
<!--more-->

---

# 3种viewport
以前PC端的网站一般宽度在1000px以上,这种大尺寸的页面如何在手机上展示?答案就是：缩放，所以早期看到的网站都很小，需要双击放大某一部分区域才能浏览。

## visual viewport 
visuall viewport,显示的屏幕窗口,可以把他理解为放大镜,距离可以拉近一点拉远一点,显示的内容可以缩小可以放大,大致就是下面这个样子：
  <center>![viewport](http://7xijc0.com1.z0.glb.clouddn.com/viewport33.png)  </center>

比如一个1024px宽的页面，要在320px的手机上显示，可以拉远距离(缩放)全局浏览，也可以拉近只看一部分,并且移动visual viewport来查看网页的不同部分

## layout viewport
PC的网页怎么在320px的手机上渲染？这里有个隐藏的概念,就是layout viewport。当我们设置一个width=20%时,他必须知道父级的width是多少,最终必须找到一个设置绝对值的顶层的元素(body)

早期没有专门为移动端做的页面,所以手机浏览器默认的layout viewport都是接近pc的宽度，这样可以确保PC的网页展示都没问题。[这里](http://www.quirksmode.org/mobile/metaviewport/)里有每个手机浏览器的默认layot viewport，附个图：

![layout](http://7xijc0.com1.z0.glb.clouddn.com/viewport-4.png)

## 修改layout viewport
layout viewport+visual viewport，PC端网页已经可以在手机上展示了，不过显然还不够完美：**能不能不要缩放，不要双击放大以后再拖动来看网页?** 假设手机宽度是320px，那就做个宽度只有320px的页面：
{% codeblock %}
<html>
  <body style="width:320px">
    <div class="contianer">
      hello everyone
    </div>
  </body>
</html>
{% endcodeblock %} 
 <center>![pc viewport](http://7xijc0.com1.z0.glb.clouddn.com/viewport-6.png) </center>
可以看到因为默认的layout viewport是按PC设置的，就算设置一个320px，也会按照PC的效果来展示

ios最早提供了[修改layout viewport](https://developer.apple.com/library/ios/documentation/AppleApplications/Reference/SafariWebContent/UsingtheViewport/UsingtheViewport.html)的能力，我们给上面的页面设置下layout viewport，并且visual viewport不缩放，这样就完美了：
{% codeblock %}
<meta name="viewport" content="width=320px, initial-scale=1.0">
{% endcodeblock %} 
  <center>![pc viewport](http://7xijc0.com1.z0.glb.clouddn.com/viewport-7.png) </center>

## ideal viewport
因为移动端的设备太多,宽度不一,所以上面写死的width=320px是非常不好的。还好设备都有一个ideal viewport，也就是最佳的尺寸，把layout viewport设置成idela viewport，并且visual viewport不要缩放就能达到最好的效果（可能有点绕）：
{% codeblock %}
<meta name="viewport" content="width=device-width, initial-scale=1.0">
{% endcodeblock %} width和initial-scale 设置其他值的效果，可以在这里查看：[understanding-viewport](http://andreasbovens.github.io/understanding-viewpor)

## 小结

设置恰当的viewport，并且设置body的宽度为100%，这样在不同的设备上就能100%的展示，没有缩放，这为我们的响应式设计提供了基础

---

# media query 
为不同的设备设置了网页的布局总宽度之后，需要进行区分，以便为不同的宽度设置不同的布局，media query提供了这种能力，它有非常多的属性，不过我们最常用的就是width
{% codeblock %}
	@media (max-width: 480px) { 
	    // 隐藏某些元素
	}
	@media (max-width: 768px) {  }
	@media (min-width: 1200px) {
	  // 显示某些元素 
	}
{% endcodeblock %} 恰当的断点很重要，根据[2014 css报告](http://reports.quickleft.com/css),设置最多的是480，768，990，1200，当然可能和bootstrap用的最多有关


## device width和width
另外可以再看看device width和width这两个值，大部分时候他们实现的效果是一样的，但是还是有一些细小的差别:

* device-wdith 指的是设备的宽度，在pc上你改变拖动浏览器窗口的大小并不会改变这个值
* width:指的是浏览器的宽度

所以使用width会更好，并且在某些android设备上，使用device-width可能会变成device pixel

# 总结
设置不同的布局宽度、不同宽度设置不同的样式是实现响应式站点的基础。实际使用中，还是有很多细节，比如文字、表格布局、retina 下的图片处理等，下篇继续

