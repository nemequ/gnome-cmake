# FindSoup.cmake
# <https://github.com/nemequ/gnome-cmake>
#
# CMake support for libsoup.
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

set(SOUP_DEPS
  GLib)

if(PKG_CONFIG_FOUND)
  pkg_search_module(SOUP_PKG libsoup-2.4)
endif()

find_library(SOUP soup-2.4 HINTS ${SOUP_PKG_LIBRARY_DIRS})

if(SOUP AND NOT SOUP_FOUND)
  add_library(libsoup-2.4 SHARED IMPORTED)
  set_property(TARGET libsoup-2.4 PROPERTY IMPORTED_LOCATION "${SOUP}")

  find_path(SOUP_INCLUDE_DIR "libsoup/soup.h"
    HINTS ${SOUP_PKG_INCLUDE_DIRS})

  if(NOT SOUP_INCLUDE_DIR)
    unset(SOUP_INCLUDE_DIR)
  else()
    file(STRINGS "${SOUP_INCLUDE_DIR}/libsoup/soup-version.h" SOUP_MAJOR_VERSION REGEX "^#define SOUP_MAJOR_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define SOUP_MAJOR_VERSION \\(([0-9]+)\\)$" "\\1" SOUP_MAJOR_VERSION "${SOUP_MAJOR_VERSION}")
    file(STRINGS "${SOUP_INCLUDE_DIR}/libsoup/soup-version.h" SOUP_MINOR_VERSION REGEX "^#define SOUP_MINOR_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define SOUP_MINOR_VERSION \\(([0-9]+)\\)$" "\\1" SOUP_MINOR_VERSION "${SOUP_MINOR_VERSION}")
    file(STRINGS "${SOUP_INCLUDE_DIR}/libsoup/soup-version.h" SOUP_MICRO_VERSION REGEX "^#define SOUP_MICRO_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define SOUP_MICRO_VERSION \\(([0-9]+)\\)$" "\\1" SOUP_MICRO_VERSION "${SOUP_MICRO_VERSION}")
    set(SOUP_VERSION "${SOUP_MAJOR_VERSION}.${SOUP_MINOR_VERSION}.${SOUP_MICRO_VERSION}")
    unset(SOUP_MAJOR_VERSION)
    unset(SOUP_MINOR_VERSION)
    unset(SOUP_MICRO_VERSION)

    list(APPEND SOUP_INCLUDE_DIRS ${SOUP_INCLUDE_DIR})
  endif()
endif()

set(SOUP_DEPS_FOUND_VARS)
foreach(soup_dep ${SOUP_DEPS})
  string(TOUPPER "${soup_dep}" soup_dep_uc)
  find_package(${soup_dep})

  list(APPEND SOUP_DEPS_FOUND_VARS "${soup_dep_uc}_FOUND")
  list(APPEND SOUP_INCLUDE_DIRS ${${soup_dep_uc}_INCLUDE_DIRS})

  unset(soup_dep_uc)
endforeach(soup_dep)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(SOUP
    REQUIRED_VARS
      SOUP_INCLUDE_DIRS
      ${SOUP_DEPS_FOUND_VARS}
    VERSION_VAR
      SOUP_VERSION)

unset(SOUP_DEPS_FOUND_VARS)
