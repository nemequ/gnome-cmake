# FindGLib.cmake
# <https://github.com/nemequ/gnome-cmake>
#
# CMake support for GLib/GObject/GIO.
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

if(PKG_CONFIG_FOUND)
  pkg_search_module(GLib_PKG    glib-2.0)
  pkg_search_module(GObject_PKG gobject-2.0)
  pkg_search_module(GIO_PKG     gio-2.0)
endif()

find_library(GLib    glib-2.0    HINTS ${GLib_PKG_LIBRARY_DIRS})
find_library(GObject gobject-2.0 HINTS ${GObject_PKG_LIBRARY_DIRS})
find_library(GIO     gio-2.0     HINTS ${GIO_PKG_LIBRARY_DIRS})

if(GLib AND NOT GLib_FOUND)
  add_library(glib-2.0 SHARED IMPORTED)
  set_property(TARGET glib-2.0 PROPERTY IMPORTED_LOCATION "${GLib}")

  find_path(GLib_INCLUDE_DIRS "glib.h"
    HINTS ${GLib_PKG_INCLUDE_DIRS}
    PATH_SUFFIXES "glib-2.0")

  get_filename_component(GLib_LIBDIR "${GLib}" DIRECTORY)
  find_path(GLib_CONFIG_INCLUDE_DIR "glibconfig.h"
    HINTS
      ${GLib_LIBDIR}
      ${GLib_PKG_INCLUDE_DIRS}
    PATHS
      "${CMAKE_LIBRARY_PATH}"
    PATH_SUFFIXES
      "glib-2.0/include"
      "glib-2.0")
  unset(GLib_LIBDIR)

  if(GLib_CONFIG_INCLUDE_DIR)
    file(STRINGS "${GLib_CONFIG_INCLUDE_DIR}/glibconfig.h" GLib_MAJOR_VERSION REGEX "^#define GLIB_MAJOR_VERSION +([0-9]+)")
    string(REGEX REPLACE "^#define GLIB_MAJOR_VERSION ([0-9]+)$" "\\1" GLib_MAJOR_VERSION "${GLib_MAJOR_VERSION}")
    file(STRINGS "${GLib_CONFIG_INCLUDE_DIR}/glibconfig.h" GLib_MINOR_VERSION REGEX "^#define GLIB_MINOR_VERSION +([0-9]+)")
    string(REGEX REPLACE "^#define GLIB_MINOR_VERSION ([0-9]+)$" "\\1" GLib_MINOR_VERSION "${GLib_MINOR_VERSION}")
    file(STRINGS "${GLib_CONFIG_INCLUDE_DIR}/glibconfig.h" GLib_MICRO_VERSION REGEX "^#define GLIB_MICRO_VERSION +([0-9]+)")
    string(REGEX REPLACE "^#define GLIB_MICRO_VERSION ([0-9]+)$" "\\1" GLib_MICRO_VERSION "${GLib_MICRO_VERSION}")
    set(GLib_VERSION "${GLib_MAJOR_VERSION}.${GLib_MINOR_VERSION}.${GLib_MICRO_VERSION}")
    unset(GLib_MAJOR_VERSION)
    unset(GLib_MINOR_VERSION)
    unset(GLib_MICRO_VERSION)

    list(APPEND GLib_INCLUDE_DIRS ${GLib_CONFIG_INCLUDE_DIR})
  endif()
endif()

if(GObject AND NOT GLib_FOUND)
  add_library(gobject-2.0 SHARED IMPORTED)
  set_property(TARGET gobject-2.0 PROPERTY IMPORTED_LOCATION "${GObject}")
  set_property (TARGET gobject-2.0 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${GLib}")

  find_path(GObject_INCLUDE_DIRS "glib-object.h"
    HINTS ${GObject_PKG_INCLUDE_DIRS}
    PATH_SUFFIXES "glib-2.0")
  if(GObject_INCLUDE_DIRS)
    list(APPEND GObject_INCLUDE_DIRS ${GLib_INCLUDE_DIRS})
    list(REMOVE_DUPLICATES GObject_INCLUDE_DIRS)
  endif()
endif()

if(GIO AND NOT GLib_FOUND)
  add_library(gio-2.0 SHARED IMPORTED)
  set_property(TARGET gio-2.0 PROPERTY IMPORTED_LOCATION "${GIO}")
  set_property (TARGET gobject-2.0 APPEND PROPERTY INTERFACE_LINK_LIBRARIES "${GIO}")

  find_path(GIO_INCLUDE_DIRS "gio/gio.h"
    HINTS ${GIO_PKG_INCLUDE_DIRS}
    PATH_SUFFIXES "glib-2.0")
  if(GIO_INCLUDE_DIRS)
    list(APPEND GIO_INCLUDE_DIRS ${GObject_INCLUDE_DIRS})
    list(REMOVE_DUPLICATES GIO_INCLUDE_DIRS)
  endif()
endif()

find_program(GLib_GENMARSHAL glib-genmarshal)
if(GLib_GENMARSHAL AND NOT GLib_FOUND)
  add_executable(glib-genmarshal IMPORTED)
  set_property(TARGET glib-genmarshal PROPERTY IMPORTED_LOCATION "${GLib_GENMARSHAL}")
endif()

find_program(GLib_MKENUMS glib-mkenums)
if(GLib_MKENUMS AND NOT GLib_FOUND)
  add_executable(glib-mkenums IMPORTED)
  set_property(TARGET glib-mkenums PROPERTY IMPORTED_LOCATION "${GLib_MKENUMS}")
endif()

find_program(GLib_COMPILE_SCHEMAS glib-compile-schemas)
if(GLib_COMPILE_SCHEMAS AND NOT GLib_FOUND)
  add_executable(glib-compile-schemas IMPORTED)
  set_property(TARGET glib-compile-schemas PROPERTY IMPORTED_LOCATION "${GLib_COMPILE_SCHEMAS}")
endif()

# glib_install_schemas(
#   [DESTINATION directory]
#   schemas…)
#
# Validate and install the listed schemas.
function(glib_install_schemas)
  set (options)
  set (oneValueArgs DESTINATION)
  set (multiValueArgs)
  cmake_parse_arguments(GSCHEMA "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  unset (options)
  unset (oneValueArgs)
  unset (multiValueArgs)

  foreach(schema ${GSCHEMA_UNPARSED_ARGUMENTS})
    get_filename_component(schema_name "${schema}" NAME)
    string(REGEX REPLACE "^(.+)\.gschema.xml$" "\\1" schema_name "${schema_name}")
    set(schema_output "${CMAKE_CURRENT_BINARY_DIR}/${schema_name}.gschema.xml.valid")

    add_custom_command(
      OUTPUT "${schema_output}"
      COMMAND glib-compile-schemas
        --strict
        --dry-run
        --schema-file="${schema}"
      COMMAND "${CMAKE_COMMAND}" ARGS -E touch "${schema_output}"
      DEPENDS "${schema}"
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
      COMMENT "Validating ${schema}")

    add_custom_target("gsettings-schema-${schema_name}" ALL
      DEPENDS "${schema_output}")

    if(CMAKE_INSTALL_FULL_DATADIR)
      set(SCHEMADIR "${CMAKE_INSTALL_FULL_DATADIR}/glib-2.0/schemas")
    else()
      set(SCHEMADIR "${CMAKE_INSTALL_PREFIX}/share/glib-2.0/schemas")
    endif()
    install(FILES "${schema}"
      DESTINATION "${SCHEMADIR}")
    install(CODE "execute_process(COMMAND \"${GLib_COMPILE_SCHEMAS}\" \"${SCHEMADIR}\")")
  endforeach()
endfunction()

find_program(GLib_COMPILE_RESOURCES glib-compile-resources)
if(GLib_COMPILE_RESOURCES AND NOT GLib_FOUND)
  add_executable(glib-compile-resources IMPORTED)
  set_property(TARGET glib-compile-resources PROPERTY IMPORTED_LOCATION "${GLib_COMPILE_RESOURCES}")
endif()

function(glib_compile_resources SPEC_FILE)
  set (options INTERNAL)
  set (oneValueArgs TARGET SOURCE_DIR HEADER SOURCE C_NAME)
  set (multiValueArgs)
  cmake_parse_arguments(GLib_COMPILE_RESOURCES "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  unset (options)
  unset (oneValueArgs)
  unset (multiValueArgs)

  if(NOT GLib_COMPILE_RESOURCES_SOURCE_DIR)
    set(GLib_COMPILE_RESOURCES_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()

  set(FLAGS)

  if(GLib_COMPILE_RESOURCES_INTERNAL)
    list(APPEND FLAGS "--internal")
  endif()

  if(GLib_COMPILE_RESOURCES_C_NAME)
    list(APPEND FLAGS "--c-name" "${GLib_COMPILE_RESOURCES_C_NAME}")
  endif()

  get_filename_component(SPEC_FILE "${SPEC_FILE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")

  execute_process(
    COMMAND glib-compile-resources
      --generate-dependencies
      --sourcedir "${GLib_COMPILE_RESOURCES_SOURCE_DIR}"
      "${SPEC_FILE}"
    OUTPUT_VARIABLE deps
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    OUTPUT_STRIP_TRAILING_WHITESPACE)

  if(GLib_COMPILE_RESOURCES_HEADER)
    get_filename_component(GLib_COMPILE_RESOURCES_HEADER "${GLib_COMPILE_RESOURCES_HEADER}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")

    add_custom_command(
      OUTPUT "${GLib_COMPILE_RESOURCES_HEADER}"
      COMMAND glib-compile-resources
        --sourcedir "${GLib_COMPILE_RESOURCES_SOURCE_DIR}"
        --generate-header
        --target "${GLib_COMPILE_RESOURCES_HEADER}"
        ${FLAGS}
        "${SPEC_FILE}"
      DEPENDS "${SPEC_FILE}" ${deps}
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()

  if(GLib_COMPILE_RESOURCES_SOURCE)
    get_filename_component(GLib_COMPILE_RESOURCES_SOURCE "${GLib_COMPILE_RESOURCES_SOURCE}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")

    add_custom_command(
      OUTPUT "${GLib_COMPILE_RESOURCES_SOURCE}"
      COMMAND glib-compile-resources
        --sourcedir "${GLib_COMPILE_RESOURCES_SOURCE_DIR}"
        --generate-source
        --target "${GLib_COMPILE_RESOURCES_SOURCE}"
        ${FLAGS}
        "${SPEC_FILE}"
      DEPENDS "${SPEC_FILE}" ${deps}
      WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}")
  endif()
endfunction()

find_program(GDBUS_CODEGEN gdbus-codegen)
if(GDBUS_CODEGEN AND NOT GLib_FOUND)
  add_executable(gdbus-codegen IMPORTED)
  set_property(TARGET gdbus-codegen PROPERTY IMPORTED_LOCATION "${GDBUS_CODEGEN}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GLib
    REQUIRED_VARS
      GLib_INCLUDE_DIRS
      GObject_INCLUDE_DIRS
      GIO_INCLUDE_DIRS
      GLib_MKENUMS
      GLib_GENMARSHAL
      GLib_COMPILE_SCHEMAS
      GLib_COMPILE_RESOURCES
      GDBUS_CODEGEN
    VERSION_VAR
      GLib_VERSION)
