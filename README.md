Baidu Maps Download
===================

Download Baidu Maps to one PNG image file.

Usage
-----

### Download map pieces

Download map pieces to ``maps`` directory.
Start Point (sp) is the top-left point of the map while End Point (ep) is the bottom-right point.
Level ranges from 1 to 19 and defaults to 12. Higher level means a more detailed map with more image pieces to be downloaded. Type can be ``web`` (default) or ``sate`` (satellite image).
The ``maps`` directory will be emptied each time excuting this script.

    bash point2pieces.sh sp_x sp_y ep_x ep_y [level=12 [type=web]]

Example:

    bash point2pieces.sh 12550000.00, 2650000.00 12650000.00, 2550000.00

### Concatenate map pieces

Concatenate map pieces in ``maps`` directory to one PNG image file named ``done.png``. Map pieces and intermediate files will be deleted.

    bash pieces2one.sh

Requirements
------------

* cURL
* ImageMagick
* bc

See Also
--------

* [Baidu Maps Coordinates Utils](https://github.com/caiguanhao/baidu-maps-coord-utils)


Developer
---------

* caiguanhao
