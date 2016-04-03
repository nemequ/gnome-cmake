# FindGDKPixbuf.cmake
# <https://github.com/nemequ/gnome-cmake>
#
# CMake support for GDK Pixbuf.
#
# License:
#
#   Copyright (c) 2016 Evan Nemerson <evan@nemerson.com>
#
#   Permission is hereby granted, free of charge, to any person
#   obtaining a copy of this software and associated documentation
#   files (the "Software"), to deal in the Software without
#   restriction, including without limitation the rights to use, copy,
#   modify, merge, publish, distribute, sublicense, and/or sell copies
#   of the Software, and to permit persons to whom the Software is
#   furnished to do so, subject to the following conditions:
#
#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#   NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#   HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#   WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
#   DEALINGS IN THE SOFTWARE.

find_package(PkgConfig)

set(GDKPIXBUF_DEPS
  GLib)

if(PKG_CONFIG_FOUND)
  pkg_search_module(GDKPIXBUF_PKG gdk-pixbuf-2.0)
endif()

find_library(GDKPIXBUF gdk_pixbuf-2.0 HINTS ${GDKPIXBUF_PKG_LIBRARY_DIRS})

if(GDKPIXBUF)
  add_library(gdk_pixbuf-2.0 SHARED IMPORTED)
  set_property(TARGET gdk_pixbuf-2.0 PROPERTY IMPORTED_LOCATION "${GDKPIXBUF}")

  set(GDKPIXBUF_INCLUDE_DIRS)

  find_path(GDKPIXBUF_INCLUDE_DIR "gdk-pixbuf/gdk-pixbuf.h"
    HINTS ${GDKPIXBUF_PKG_INCLUDE_DIRS})

  if(NOT GDKPIXBUF_INCLUDE_DIR)
    unset(GDKPIXBUF_INCLUDE_DIR)
  else()
    file(STRINGS "${GDKPIXBUF_INCLUDE_DIR}/gdk-pixbuf/gdk-pixbuf-features.h" GDKPIXBUF_VERSION REGEX "^#define GDKPIXBUF_VERSION \\\"[^\\\"]+\\\"")
    string(REGEX REPLACE "^#define GDKPIXBUF_VERSION \\\"([0-9]+)\\.([0-9]+)\\.([0-9]+)\\\"$" "\\1.\\2.\\3" GDKPIXBUF_VERSION "${GDKPIXBUF_VERSION}")

    list(APPEND GDKPIXBUF_INCLUDE_DIRS ${GDKPIXBUF_INCLUDE_DIR})
  endif()
endif()

set(GDKPIXBUF_DEPS_FOUND_VARS)
foreach(gdkpixbuf_dep ${GDKPIXBUF_DEPS})
  string(TOUPPER "${gdkpixbuf_dep}" gdkpixbuf_dep_uc)
  find_package(${gdkpixbuf_dep})

  list(APPEND GDKPIXBUF_DEPS_FOUND_VARS "${gdkpixbuf_dep_uc}_FOUND")
  list(APPEND GDKPIXBUF_INCLUDE_DIRS ${${gdkpixbuf_dep_uc}_INCLUDE_DIRS})

  set_property (TARGET "gdk_pixbuf-2.0" APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${${gdkpixbuf_dep_uc}}")

  unset(gdkpixbuf_dep_uc)
endforeach(gdkpixbuf_dep)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GDKPIXBUF
    REQUIRED_VARS
      GDKPIXBUF_INCLUDE_DIRS
      ${GDKPIXBUF_DEPS_FOUND_VARS}
    VERSION_VAR
      GDKPIXBUF_VERSION)

unset(GDKPIXBUF_DEPS_FOUND_VARS)
