©2013 Michael Bach, michael.bach@uni-freiburg.de, http://michaelbach.de


Camera2
=======

A simple module to access a camera, based on QTKit
 

To insert into your program
-------------------------
* add a "Capture View" to your interface
* associate this with an instance of Camera2 in the init call


Some details
------------
* the current version only accesses one single camera, but is easily extended (Thomas already did it)

* there is a call to save the next frame as still image, prior to that you may want to set the path with filename and optionally enable auto-numbering so no images are overwritten


History
-------

2013-11-03 added still image export