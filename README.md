# JPCycleImageView
JPCycleImageView是一款简单好用的“轮播图”组件，它最大的特点就是内存优化、缓存处理、代码简单；

内存优化：为了节省内存空间，无论要展示多少图片，实际上只开辟了三张视图的内存，实现内存的反复利用；
缓存处理：图片的下载不依赖第三方下载类，JPCycleImageView内部引用的是独立封装的图片下载类“JPImageDownloader”，可以很方便地管理内存；
代码简单：使用代码简单明了，对一些刚入行的同道来说绝对是个好用的东西！


![image](https://github.com/JaryPan/JPCycleImageView/blob/master/JPCycleImageView.gif)
