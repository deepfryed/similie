require 'mkmf'

if have_header 'png.h'
  $LDFLAGS << ' -lpng'
end

if have_header 'jpeglib.h'
  $LDFLAGS << ' -ljpeg'
end

create_header
create_makefile 'fingerprint'
