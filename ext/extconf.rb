require 'mkmf'

Config::CONFIG['CC']  = 'g++'
Config::CONFIG['CPP'] = 'g++'

$CFLAGS  = ""
$LDFLAGS = "-lpHash"

dir_config("libpHash", ["/usr/local", "/opt/local", "/usr"])

if have_library('pHash')
  create_makefile 'similie'
else
  puts %q{
    Cannot find phash headers or libraries.

    On debian based systems you can install it from apt as,
      sudo apt-get install libphash0-dev

  }

  exit 1
end
