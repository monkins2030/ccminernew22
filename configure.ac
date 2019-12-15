AC_INIT([ccminer],[3.6.2],[],[ccminer],[http://github.com/monkins1010/ccminer])

AC_PREREQ([2.69])
AC_CANONICAL_TARGET
AC_CONFIG_SRCDIR([ccminer.cpp])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AC_CONFIG_HEADERS([ccminer-config.h])

dnl Make sure anyone changing configure.ac/Makefile.am has a clue
AM_MAINTAINER_MODE

dnl Checks for programs
AC_PROG_CC_C99
AC_PROG_GCC_TRADITIONAL
AM_PROG_CC_C_O
AM_PROG_AS
AC_PROG_RANLIB
AC_PROG_CXX
AC_OPENMP

dnl Checks for header files
AC_HEADER_STDC
AC_CHECK_HEADERS([sys/endian.h sys/param.h syslog.h])
# sys/sysctl.h requires sys/types.h on FreeBSD
# sys/sysctl.h requires sys/param.h on OpenBSD
AC_CHECK_HEADERS([sys/sysctl.h], [], [],
[#include <sys/types.h>
#ifdef HAVE_SYS_PARAM_H
#include <sys/param.h>
#endif
])

AC_CHECK_DECLS([be32dec, le32dec, be32enc, le32enc], [], [],
[AC_INCLUDES_DEFAULT
#ifdef HAVE_SYS_ENDIAN_H
#include <sys/endian.h>
#endif
])

AC_FUNC_ALLOCA
AC_CHECK_FUNCS([getopt_long])
AC_ARG_ENABLE([ccache],
  [AS_HELP_STRING([--enable-ccache],
  [use ccache for building (default is yes if ccache is found)])],
  [use_ccache=$enableval],
  [use_ccache=auto])
# Enable debug
AC_ARG_ENABLE([debug],
    [AS_HELP_STRING([--enable-debug],
                    [use debug compiler flags and macros (default is no)])],
    [enable_debug=$enableval],
    [enable_debug=no])

case $target in
  i*86-*-*)
    have_x86=true
    ;;
  x86_64-*-*)
    have_x86=true
    have_x86_64=true
    ;;
  amd64-*-*)
    have_x86=true
    have_x86_64=true
    ;;
  arm*-*-*)
    have_arm=true
    ;;
  aarch64*-*-*)
    have_arm=true
    ;;
esac

PTHREAD_FLAGS="-pthread"
WS2_LIBS=""

case $target in
  *-*-mingw*)
    have_win32=true
    PTHREAD_FLAGS=""
    WS2_LIBS="-lws2_32"
    ;;
  *86*-apple-darwin*)
    have_osx=true
    PTHREAD_FLAGS=""
    ;;
esac
use_pkgconfig=yes
if test x$use_pkgconfig = xyes; then
  m4_ifndef([PKG_PROG_PKG_CONFIG], [AC_MSG_ERROR(PKG_PROG_PKG_CONFIG macro not found. Please install pkg-config and re-run autogen.sh.)])
  m4_ifdef([PKG_PROG_PKG_CONFIG], [
  PKG_PROG_PKG_CONFIG
  if test x"$PKG_CONFIG" = "x"; then
    AC_MSG_ERROR(pkg-config not found.)
  fi
  ])
fi
AC_CHECK_LIB(jansson, json_loads, request_jansson=false, request_jansson=true)
AC_CHECK_LIB([pthread], [pthread_create], PTHREAD_LIBS="-lpthread",
  AC_CHECK_LIB([pthreadGC2], [pthread_create], PTHREAD_LIBS="-lpthreadGC2",
    AC_CHECK_LIB([pthreadGC1], [pthread_create], PTHREAD_LIBS="-lpthreadGC1",
      AC_CHECK_LIB([pthreadGC], [pthread_create], PTHREAD_LIBS="-lpthreadGC"
))))

AC_CHECK_LIB([z],[gzopen], [], [])
AM_CONDITIONAL([WANT_JANSSON], [test x$request_jansson = xtrue])
AM_CONDITIONAL([HAVE_WINDOWS], [test x$have_win32 = xtrue])
AM_CONDITIONAL([HAVE_OSX], [test x$have_osx = xtrue])
AM_CONDITIONAL([ARCH_x86], [test x$have_x86 = xtrue])
AM_CONDITIONAL([ARCH_x86_64], [test x$have_x86_64 = xtrue])

if test x$request_jansson = xtrue
then
	JANSSON_LIBS="compat/jansson/libjansson.a"
else
	JANSSON_LIBS=-ljansson
fi



if test -z "$LIBCURL"; then
	LIBCURL="-lcurl"
fi
# libcurl install path (for mingw : --with-curl=/usr/local)
AC_ARG_WITH([curl],
  [  --with-curl=PATH         prefix where curl is installed [default=/usr]])

if test -n "$with_curl"; then
	LIBCURL_CFLAGS="$LIBCURL_CFLAGS -I$with_curl/include"
	LIBCURL_CPPFLAGS="$LIBCURL_CPPFLAGS -I$with_curl"
	LIBCURL_LDFLAGS="$LIBCURL_LDFLAGS -L$with_curl/lib"
fi
CFLAGS="$CFLAGS $LIBCURL_CFLAGS"
CPPFLAGS="$CPPFLAGS $LIBCURL_CPPFLAGS"
LDFLAGS="$LDFLAGS $LIBCURL_LDFLAGS"

AC_SUBST(LIBCURL)
AC_SUBST(JANSSON_LIBS)
AC_SUBST(PTHREAD_FLAGS)
AC_SUBST(PTHREAD_LIBS)
AC_SUBST(WS2_LIBS)

AC_CONFIG_FILES([
	Makefile
	compat/Makefile
	compat/jansson/Makefile
	])

dnl find out what version we are running
ARCH=`uname -m`
if [[ $ARCH == "x86_64" ]];
then
  SUFFIX="64"
else
  SUFFIX=""
fi

if test x$have_osx = xtrue
then
  SUFFIX=""
fi

dnl Setup CUDA paths
AC_ARG_WITH([cuda],
   [  --with-cuda=PATH    prefix where cuda is installed [default=/usr/local/cuda]])

AC_ARG_WITH([nvml],
   [  --with-nvml=PATH    prefix where libnvml is installed [default=/usr/lib]])

AM_CONDITIONAL([HAVE_NVML], [test -n "$with_nvml"])

NVCC="nvcc"

if test -n "$with_cuda" ; then
  CUDA_INCLUDES="-I$with_cuda/include"
  CUDA_LIBS="-lcudart"
  CUDA_LDFLAGS="-L$with_cuda/lib$SUFFIX"
  if test -x "$with_cuda/bin/nvcc" ; then
    NVCC="$with_cuda/bin/nvcc"
  fi
else
  CUDA_INCLUDES="-I/usr/local/cuda/include"
  CUDA_LIBS="-lcudart -static-libstdc++"
  CUDA_LDFLAGS="-L/usr/local/cuda/lib$SUFFIX"
fi

if test -n "$with_nvml" ; then
  NVML_LIBPATH=$with_nvml
  CUDA_LDFLAGS="$CUDA_LDFLAGS -ldl"
fi
AC_SUBST(NVML_LIBPATH)

AC_SUBST(CUDA_CFLAGS)
AC_SUBST(CUDA_INCLUDES)
AC_SUBST(CUDA_LIBS)
AC_SUBST(CUDA_LDFLAGS)
AC_SUBST(NVCC)

AC_SUBST(OPENMP_CFLAGS) 

AC_OUTPUT
