require 'mkmf'

$CFLAGS  = "-I/usr/include/opencv -Wall"
$LDFLAGS = "-lhighgui -lcxcore"

dir_config("libcv", ["/usr/local", "/opt/local", "/usr"])

headers = [ 'stdio.h', 'stdlib.h', 'string.h', 'opencv/cxcore.h', 'opencv/highgui.h' ]
lib_1   = [ 'cxcore', 'cvInitFont', headers ]
lib_2   = [ 'highgui', 'cvEncodeImage', headers ]

if have_header('opencv/cxcore.h') && have_library(*lib_1) && have_library(*lib_2)
  create_makefile 'similie'
else
  puts %q{
    Cannot find opencv headers or libraries.

    On debian based systems you can install it from apt as,
      sudo apt-get install libcv-dev libhighgui-dev

    Refer to http://opencv.willowgarage.com/wiki/InstallGuide for other platforms or operating systems.
  }

  exit 1
end
