Download
--------

RastaConverterBeta3.zip

http://www.atariage.com/forums/topic/156160-quantizator/page__st__125#entry2509434

Rasta-opthack5.zip

http://www.atariage.com/forums/topic/156160-quantizator/page__st__275#entry2518629

FreeImage

http://freeimage.sourceforge.net/download.html
http://downloads.sourceforge.net/freeimage/FreeImage3153Win32.zip

Allegro

http://www.allegro.cc/files/?v=4.2
http://static.allegro.cc/file/library/allegro-4.2.3/allegro-msvc10-4.2.3.zip

Microsoft Visual C++ 2010 Express

http://www.microsoft.com/visualstudio/en-us/products/2010-editions/visual-cpp-express

VirtualDub

http://www.virtualdub.org

Cygwin (Get patch, make, perl, zip, unzip, rxvt, 7z)

http://www.cygwin.com

Altirra

http://www.virtualdub.org/altirra.html

Mads

http://mads.atari8.info

Unzip
-----

  Launch cygwin rxvt

  unzip RastaMovie-0.3.zip

  cd RastaMovie-0.3

  unzip RastaConverterBeta3.zip
  mv RastaConverterBeta3/Palettes .
  mv RastaConverterBeta3/Generator/no_name.* .

  unzip Rasta-opthack5.zip

  7z x mads_1.9.4.7z mads.exe

  chmod +x mads.exe

  cd src

  patch -i ../Rasta-opthack5.patch

  unzip allegro-msvc10-4.2.3.zip

  mv allegro-msvc10-4.2.3/* .

  unzip FreeImage3153Win32.zip

  cp FreeImage/Dist/FreeImage.dll bin
  cp FreeImage/Dist/FreeImage.lib lib
  cp FreeImage/Dist/FreeImage.h include

Build
-----

  Launch Visual C++, Load RastaConverter.sln

  Change from "Debug" to "Release" configuration

  Build by pressing F7.

  cp Release/RastaConverter.exe ..      (Overwrite)

  cp bin/*.dll ..

  cd ..

  chmod +x *.exe *.dll

Extract Movie Frames
--------------------

  Open video in VirtualDub.  Select range of frames.

  File->Export->Image Sequence->PNG  Save into RastaMovie-0.3 directory.

Make Movie
----------

  make movie=<base name>

You can parallelize across 4 cores with:

  make -j4 movie=<base name>

You can set the maximum number of evaluations per frame in RasterConverter
with:

  make par max_evals=500000 movie=<base name>

Only 64 frames are used for the movie.

This can take several hours depending on max_evals.

Set max_evals to 1 for quick dryrun.

Run in Altirra
--------------

  make show

  Select 1088K Memory Size.

Contact
-------

  http://www.atariage.com/forums/user/21021-xuel/
