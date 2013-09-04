require 'mkmf'

def inc_paths lib, defaults
  path = %x{pkg-config #{lib} --cflags 2>/dev/null}.strip
  path.size > 0 ? path : defaults.map {|name| "-I#{name}"}.join(' ')
end

def lib_paths lib, defaults
  path = %x{pkg-config #{lib}  --libs-only-L 2>/dev/null}.strip
  path.size > 0 ? path : defaults.map {|name| "-L#{name}"}.join(' ')
end

def lib_flags lib, defaults
  path = %x{pkg-config #{lib}  --libs-only-l 2>/dev/null}.strip
  path.size > 0 ? path.split(/\s+/).select {|name| %r{core|highgui}.match(name)}.join(' ')
                : defaults.map {|name| "-l#{name}"}.join(' ')
end

def lib_name re
  $LDFLAGS.scan(re).flatten.first
end

$CFLAGS  = inc_paths 'opencv', %w(/usr/include/opencv)
$LDFLAGS = lib_flags 'opencv', %w(opencv_highgui opencv_core)

cxcore   = lib_name(%r{-l(\w*core)})    or raise 'unable to find opencv cxcore'
highgui  = lib_name(%r{-l(\w*highgui)}) or raise 'unable to find opencv highgui'

headers  = %w(stdio.h stdlib.h string.h opencv/cxcore.h opencv/highgui.h)
lib_1    = [cxcore,  'cvInitFont',    headers]
lib_2    = [highgui, 'cvEncodeImage', headers]

if have_header('opencv/cxcore.h') && have_library(*lib_1) && have_library(*lib_2)
  create_makefile 'similie'
else
  puts %q{
    Cannot find opencv headers or libraries.

    On debian based systems you can install it from apt as,
      sudo apt-get install libcv-dev libhighgui-dev

    On macos try,
      brew install opencv

    Refer to http://opencv.willowgarage.com/wiki/InstallGuide for other platforms or operating systems.
  }

  exit 1
end
