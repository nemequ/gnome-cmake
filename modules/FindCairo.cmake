# FindCairo.cmake
# <https://github.com/nemequ/gnome-cmake>
#
# CMake support for Cairo.
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

set(CAIRO_DEPS)

if(PKG_CONFIG_FOUND)
  pkg_search_module(CAIRO_PKG cairo)
endif()

find_library(CAIRO cairo HINTS ${CAIRO_PKG_LIBRARY_DIRS})

if(CAIRO)
  add_library(cairo SHARED IMPORTED)
  set_property(TARGET cairo PROPERTY IMPORTED_LOCATION "${CAIRO}")

  set(CAIRO_INCLUDE_DIRS)

  find_path(CAIRO_INCLUDE_DIR "cairo.h"
    HINTS ${CAIRO_PKG_INCLUDE_DIRS})

  if(NOT CAIRO_INCLUDE_DIR)
    unset(CAIRO_INCLUDE_DIR)
  else()
    file(STRINGS "${CAIRO_INCLUDE_DIR}/cairo-version.h" CAIRO_VERSION_MAJOR REGEX "^#define GDK_VERSION_MAJOR +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define GDK_VERSION_MAJOR \\(?([0-9]+)\\)?$" "\\1" CAIRO_VERSION_MAJOR "${CAIRO_VERSION_MAJOR}")
    file(STRINGS "${CAIRO_INCLUDE_DIR}/cairo-version.h" CAIRO_VERSION_MINOR REGEX "^#define GDK_VERSION_MINOR +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define GDK_VERSION_MINOR \\(?([0-9]+)\\)?$" "\\1" CAIRO_VERSION_MINOR "${CAIRO_VERSION_MINOR}")
    file(STRINGS "${CAIRO_INCLUDE_DIR}/cairo-version.h" CAIRO_VERSION_MICRO REGEX "^#define GDK_VERSION_MICRO +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define GDK_VERSION_MICRO \\(?([0-9]+)\\)?$" "\\1" CAIRO_VERSION_MICRO "${CAIRO_VERSION_MICRO}")
    set(CAIRO_VERSION "${CAIRO_VERSION_MAJOR}.${CAIRO_VERSION_MINOR}.${CAIRO_VERSION_MICRO}")
    unset(CAIRO_VERSION_MAJOR)
    unset(CAIRO_VERSION_MINOR)
    unset(CAIRO_VERSION_MICRO)

    list(APPEND CAIRO_INCLUDE_DIRS ${CAIRO_INCLUDE_DIR})
  endif()
endif()

set(CAIRO_DEPS_FOUND_VARS)
foreach(cairo_dep ${CAIRO_DEPS})
  string(TOUPPER "${cairo_dep}" cairo_dep_uc)
  find_package(${cairo_dep})

  list(APPEND CAIRO_DEPS_FOUND_VARS "${cairo_dep_uc}_FOUND")
  list(APPEND CAIRO_INCLUDE_DIRS ${${cairo_dep_uc}_INCLUDE_DIRS})

  set_property (TARGET cairo APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${${cairo_dep_uc}}")

  unset(cairo_dep_uc)
endforeach(cairo_dep)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(CAIRO
    REQUIRED_VARS
      CAIRO_INCLUDE_DIRS
      ${CAIRO_DEPS_FOUND_VARS}
    VERSION_VAR
      CAIRO_VERSION)

unset(CAIRO_DEPS_FOUND_VARS)
