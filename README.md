# CMake modules for GNOME support

This is a collection of CMake modules to support using GNOME libraries
from CMake-based projects.  These modules were initially intended for
use from Vala projects, but many can be used for other languages as
well.

Components include:

 * FindVala — Vala support
   * Functions/Macros:
     * `vala_precompile_target`: Compile Vala to C and generate
       supporting files (such as headers, VAPIs, and GObject
       Introspection repositories).
   * Imported targets:
     * valac (executable)
 * FindGObjectIntrospection — GObject Introspection support
   * Functions/Macros:
     * `gobject_introspection_compile` — Compile a GObject
       Introspection Repository (GIR) to a typelib.
   * Imported targets:
     * g-ir-compiler (executable)
     * g-ir-scanner (executable)
 * FindGLib — GLib/GObject/GIO support
   * Functions/Macros:
     * `glib_compile_resources` — Compile GResources
   * Imported targets:
     * glib-2.0 (library)
     * gobject-2.0 (library)
	 * gio-2.0 (library)
     * glib-genmarshal (executable)
     * glib-mkenums (executable)
	 * glib-compile-schemas (executable)
	 * glib-compile-resources (executable)
 * FindValadoc — [Valadoc](https://wiki.gnome.org/Projects/Valadoc) support
   * Functions/Macros:
     * `valadoc_generate` — Generate documentation
   * Imported targets:
     * valadoc (executable)
