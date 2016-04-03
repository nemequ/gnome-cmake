# FindPango.cmake
# <https://github.com/nemequ/gnome-cmake>
#
# CMake support for Pango.
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

set(PANGO_DEPS
  GLib)

if(PKG_CONFIG_FOUND)
  pkg_search_module(PANGO_PKG pango)
endif()

find_library(PANGO pango-1.0 HINTS ${PANGO_PKG_LIBRARY_DIRS})

if(PANGO AND NOT PANGO_FOUND)
  add_library(pango SHARED IMPORTED)
  set_property(TARGET pango PROPERTY IMPORTED_LOCATION "${PANGO}")

  find_path(PANGO_INCLUDE_DIR "pango/pango.h"
    HINTS ${PANGO_PKG_INCLUDE_DIRS})

  if(NOT PANGO_INCLUDE_DIR)
    unset(PANGO_INCLUDE_DIR)
  else()
    file(STRINGS "${PANGO_INCLUDE_DIR}/pango/pango-features.h" PANGO_MAJOR_VERSION REGEX "^#define PANGO_MAJOR_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define PANGO_MAJOR_VERSION \\(([0-9]+)\\)$" "\\1" PANGO_MAJOR_VERSION "${PANGO_MAJOR_VERSION}")
    file(STRINGS "${PANGO_INCLUDE_DIR}/pango/pango-features.h" PANGO_MINOR_VERSION REGEX "^#define PANGO_MINOR_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define PANGO_MINOR_VERSION \\(([0-9]+)\\)$" "\\1" PANGO_MINOR_VERSION "${PANGO_MINOR_VERSION}")
    file(STRINGS "${PANGO_INCLUDE_DIR}/pango/pango-features.h" PANGO_MICRO_VERSION REGEX "^#define PANGO_MICRO_VERSION +\\(?([0-9]+)\\)?$")
    string(REGEX REPLACE "^#define PANGO_MICRO_VERSION \\(([0-9]+)\\)$" "\\1" PANGO_MICRO_VERSION "${PANGO_MICRO_VERSION}")
    set(PANGO_VERSION "${PANGO_MAJOR_VERSION}.${PANGO_MINOR_VERSION}.${PANGO_MICRO_VERSION}")
    unset(PANGO_MAJOR_VERSION)
    unset(PANGO_MINOR_VERSION)
    unset(PANGO_MICRO_VERSION)

    list(APPEND PANGO_INCLUDE_DIRS ${PANGO_INCLUDE_DIR})
  endif()
endif()

set(PANGO_DEPS_FOUND_VARS)
foreach(pango_dep ${PANGO_DEPS})
  string(TOUPPER "${pango_dep}" pango_dep_uc)
  find_package(${pango_dep})

  list(APPEND PANGO_DEPS_FOUND_VARS "${pango_dep_uc}_FOUND")
  list(APPEND PANGO_INCLUDE_DIRS ${${pango_dep_uc}_INCLUDE_DIRS})

  unset(pango_dep_uc)
endforeach(pango_dep)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(PANGO
    REQUIRED_VARS
      PANGO_INCLUDE_DIRS
      ${PANGO_DEPS_FOUND_VARS}
    VERSION_VAR
      PANGO_VERSION)

unset(PANGO_DEPS_FOUND_VARS)
