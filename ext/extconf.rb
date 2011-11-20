require 'mkmf'

def inc_paths lib, defaults
  path = %x{pkg-config #{lib} --cflags 2>/dev/null}.strip
  path.size > 0 ? path : defaults.map {|name| "-I#{name}"}.join(' ')
end

def lib_paths lib, defaults
  path = %x{pkg-config #{lib}  --libs-only-L 2>/dev/null}.strip
  path.size > 0 ? path : defaults.map {|name| "-L#{name}"}.join(' ')
end

def lib_names lib, defaults
  path = %x{pkg-config #{lib}  --libs-only-l 2>/dev/null}.strip
  path.size > 0 ? path : defaults.map {|name| "-l#{name}"}.join(' ')
end

$CFLAGS  = inc_paths('opencv', %w(/usr/include/opencv)) + ' -Wall'
$LDFLAGS = lib_names('opencv', %w(highgui cxcore))
cxcore   = $LDFLAGS.scan(%r{-l(\w*core)}).flatten.first
highgui  = $LDFLAGS.scan(%r{-l(\w*highgui)}).flatten.first

raise "unable to find opencv cxcore"  unless cxcore
raise "unable to find opencv highgui" unless highgui

headers = %w(stdio.h stdlib.h string.h opencv/cxcore.h opencv/highgui.h)
lib_1   = [cxcore,  'cvInitFont',    headers]
lib_2   = [highgui, 'cvEncodeImage', headers]

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
