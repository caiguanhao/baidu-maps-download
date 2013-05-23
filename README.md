Baidu Maps Download
===================

Download Baidu Maps to one PNG image file. Points used here are not coordinates. You may use another BASH tool called [Baidu Maps Coordinates Utils](https://github.com/caiguanhao/baidu-maps-coord-utils) to convert coordinates to points.

Usage
-----

### Download map pieces

Download map pieces to ``maps`` directory. The ``maps`` directory will be emptied each time excuting this script.

Level ranges from 1 to 19 and defaults to 12. Higher level means a more detailed map with more image pieces to be downloaded.
Type can be ``web`` (default), ``web-alt`` (bigger font size, good for printing and mobile browsing, available for ``level`` from 10 to 18) or ``sate`` (satellite image).

#### Start Point and End Point

Start Point (``sp``) is the top-left point of the map while End Point (``ep``) is the bottom-right point.

    bash points2pieces.sh [OPTION] sp_x sp_y ep_x ep_y [level=12 [type=web]]
    
    Options:
        --dry-run              Show list of commands instead of executing them.
        --with-traffic         Also download the traffic layer.
        --with-transport       Also download the transport layer. Valid if type is sate.
        --with-transport-alt   Also download the transport layer with bigger font. Valid if type is sate.

#### Center Point

Get the map of area surrounds the Center Point (``cp``).
You can specify the ``width`` and ``height`` of the map.
This script will output a ``crop`` option which can be used as argument of ``pieces2one.sh`` script.

    bash center2pieces.sh [OPTION] cp_x cp_y [level=12 [type=web [width=2000 [height=2000]]]]
    
    Options:
        --dry-run              Show list of commands instead of executing them.
        --with-traffic         Also download the traffic layer.
        --with-transport       Also download the transport layer. Valid if type is sate.
        --with-transport-alt   Also download the transport layer with bigger font. Valid if type is sate.

### Concatenate map pieces

Concatenate map pieces in ``maps`` directory to one PNG image file named ``done.png``.
You can specify [``crop``](http://www.imagemagick.org/Usage/crop/) option for the ``convert`` process.
All layers will merge automatically. Map pieces, layers and intermediate files will be deleted.

    bash pieces2one.sh [OPTION] [crop]
    
    Options:
        --dry-run        Show list of commands instead of executing them.

Examples
--------

**Download (part of) map of Guangzhou in one command:**

    bash points2pieces.sh 12550000.00, 2650000.00 12650000.00, 2550000.00 && bash pieces2one.sh

**Download a 1000x1000px map around a certain point:**

    bash center2pieces.sh 12616085.15, 2628677.18 15 web-alt 1000 1000 | xargs bash pieces2one.sh

Requirements
------------

* [cURL](http://curl.haxx.se/)
* [ImageMagick](http://www.imagemagick.org/)
* [bc](http://www.gnu.org/software/bc/)

Bugs
----

* Maps in level 1 to level 3 are not continuous.

Optimizations
-------------

You can reduce the file size (up to 50%) of the output PNG image files by using [pngcrush](http://pmt.sourceforge.net/pngcrush/) and/or [optipng](http://optipng.sourceforge.net/):

    (cd maps && pngcrush -rem cHRM -rem gAMA -rem iCCP -rem sRGB -q done.png done_o.png && mv done_o.png done.png)
    
    (cd maps && optipng -quiet -fix -o4 done.png)

See Also
--------

* [Baidu Maps Coordinates Utils](https://github.com/caiguanhao/baidu-maps-coord-utils) (includes coordinates to point conversion)
* [BaiduMapsDownloader in Java](https://github.com/java-MagicWang/BaiduMapDownloader/blob/master/MapDownloader.java)

Developer
---------

* caiguanhao

使用方法
--------

用 Baidu Maps Coordinates Utils 来将坐标转换为点，你可以指定要下载的地图的起始和终止点（即左上角和右下角的点），也可以指定一个中心点和地图大小来下载地图碎片，下载完毕后可执行 pieces2one.sh 将碎片合并成一张大地图。请参考上面的示例命令。
