#!/bin/sh

#(cd ../dist ; sh s_all -A) || exit $?
# -Wno-unused-parameter
# -Wpadded
# -Winline
warnings="-Wall -Wextra -Waddress -Waggregate-return -Wbad-function-cast -Wdeclaration-after-statement -Wformat-security -Wformat -Winline -Wmissing-declarations -Wmissing-field-initializers -Wmissing-prototypes -Wnested-externs -Wpointer-arith -Wredundant-decls -Wshadow -Wunused -Wwrite-strings"
#warnings="$warnings -Wshorten-64-to-32"
#warnings="$warnings -Wformat-nonliteral"
#warnings="$warnings -Wundef"
#warnings="$warnings -Wpadded"
#warnings="$warnings -Wstrict-prototypes"
#warnings="$warnings -Wunreachable-code"
#warnings="$warnings -O -Wuninitialized"
#warnings="$warnings -O3 -fstrict-aliasing -Wstrict-aliasing=2"
#warnings="$warnings -fstack-check -fstack-protector-all"
warnings="$warnings -Werror"
#warnings="$warnings -O3 -fno-strict-aliasing -funroll-loops"

CONF_EXTRA+=$@
#[ -f ../lang/java/Makefile.am ] && CONF_EXTRA+=" --enable-java"

# env LIBS="-ltcmalloc"
export CPPFLAGS="-I/usr/local/include"
export LDFLAGS="-L/usr/local/lib"
export CC="gcc"
#export CC="clang -fsanitize=address"
export CFLAGS=" $CFLAGS $warnings -fPIC -DWIREDTIGER_DEVEL -g3"
../configure -C --enable-silent-rules --enable-python --with-builtins=snappy,zlib --enable-bzip2 --with-berkeleydb=/home/alexg/downloads/db-5.3.21/build_unix/LOCAL_INSTALL $CONF_EXTRA && make -j 12

#CFLAGS='-Werror -Wall -Wextra -Waddress -Waggregate-return -Wbad-function-cast -Wcast-align -Wdeclaration-after-statement -Wformat-security -Wformat-nonliteral -Wformat=2 -Winline -Wmissing-declarations -Wmissing-field-initializers -Wmissing-prototypes -Wnested-externs -Wold-style-definition -Wpointer-arith -Wredundant-decls -Wshadow -Wstrict-prototypes -Wundef -Wunsafe-loop-optimizations -Wunused -Wwrite-strings -fno-strict-aliasing -g' LDFLAGS='-g' ../configure --enable-debug --enable-diagnostic $@
#make
