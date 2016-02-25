# CMake modules for GNOME libraries and tools

This is a collection of CMake modules to support using GNOME libraries
and tools from CMake-based projects.  These modules were initially
intended for use from Vala projects, but many can be used for other
languages as well.

Components currently include:

 * FindVala — [Vala](https://wiki.gnome.org/Projects/Vala) support.
   * Functions/Macros:
     * `vala_precompile_target`: Compile Vala to C and generate
       supporting files (such as headers, VAPIs, and GObject
       Introspection repositories).
   * Imported executables:
     * valac executable
 * FindGObjectIntrospection —
   [GObject Introspection](https://wiki.gnome.org/Projects/GObjectIntrospection)
   support.
   * Functions/Macros:
     * `gobject_introspection_compile` — Compile a GObject
       Introspection Repository (GIR) to a typelib.
   * Imported executables:
     * g-ir-compiler
     * g-ir-scanner
 * FindGLib — GLib/GObject/GIO support
   * Functions/Macros:
     * `glib_compile_resources` — Compile
       [GResource](https://developer.gnome.org/gio/stable/GResource.html#GResource.description)s
     * `glib_install_schemas` — Validate and install
       [GSettings](https://developer.gnome.org/gio/stable/GSettings.html)s
       schema.
   * Imported libraries:
     * glib-2.0
     * gobject-2.0
     * gio-2.0
   * Imported executables:
     * glib-genmarshal
     * glib-mkenums
     * glib-compile-schemas
     * glib-compile-resources
 * FindValadoc — [Valadoc](https://wiki.gnome.org/Projects/Valadoc) support
   * Functions/Macros:
     * `valadoc_generate` — Generate documentation
   * Imported executables:
     * valadoc

There are still a lot of functions and modules which need writing.
For a list of planned features, see the
[issue tracker](https://github.com/nemequ/gnome-cmake/issues).  If you
end up writing a module, function, macro, etc. which you feel would be
useful, please consider submitting it for inclusion in this
repository.
