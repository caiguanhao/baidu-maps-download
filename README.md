Baidu Maps Download
===================

Download Baidu Maps to one PNG image file.

Usage
-----

### Download map pieces

Download map pieces to ``maps`` directory. The ``maps`` directory will be emptied each time excuting this script.

Level ranges from 1 to 19 and defaults to 12. Higher level means a more detailed map with more image pieces to be downloaded.
Type can be ``web`` (default), ``web-alt`` (bigger font size, good for printing and mobile browsing, available for ``level`` from 10 to 18) or ``sate`` (satellite image).

#### Start Point and End Point

Start Point (``sp``) is the top-left point of the map while End Point (``ep``) is the bottom-right point.

    bash points2pieces.sh sp_x sp_y ep_x ep_y [level=12 [type=web]]

#### Center Point

Get the map of area surrounds the Center Point (``cp``).
You can specify the ``width`` and ``height`` of the map.
This script will output a ``crop`` option which can be used as argument of ``pieces2one.sh`` script.

    bash center2pieces.sh [OPTION] cp_x cp_y [level=12 [type=web [width=2000 [height=2000]]]]
    
    Options:
        --dry-run        Show list of commands instead of executing them.

### Concatenate map pieces

Concatenate map pieces in ``maps`` directory to one PNG image file named ``done.png``.
You can specify [``crop``](http://www.imagemagick.org/Usage/crop/) option for the ``convert`` process.
Map pieces and intermediate files will be deleted.

    bash pieces2one.sh [crop]

Example
-------

**Download (part of) map of Guangzhou in one command:**

    bash points2pieces.sh 12550000.00, 2650000.00 12650000.00, 2550000.00 && bash pieces2one.sh

**Download a 1000x1000px map around a certain point:**

    bash center2pieces.sh 12616085.15, 2628677.18 15 web-alt 1000 1000 | xargs bash pieces2one.sh

Requirements
------------

* cURL
* ImageMagick
* bc

See Also
--------

* [Baidu Maps Coordinates Utils](https://github.com/caiguanhao/baidu-maps-coord-utils) (includes coordinates to point conversion)
* [BaiduMapsDownloader in Java](https://github.com/java-MagicWang/BaiduMapDownloader/blob/master/MapDownloader.java)

Developer
---------

* caiguanhao
