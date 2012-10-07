include $(top_srcdir)/build/vala.am

plugin_LTLIBRARIES = libdock-task-plugin.la

libdock_task_plugin_la_VALAFLAGS = \
    --vapidir=$(top_builddir)/lib \
    --pkg=libxfce4ui-1 \
    --pkg=libgtop-2.0 \
    --pkg=xfce4-dock

libdock_task_plugin_la_CFLAGS = \
    -I$(top_builddir)/lib \
    $(LIBXFCE4_PANEL_CFLAGS) \
    $(LIBXFCE4_UI_CFLAGS) \
    $(LIBXFCONF_CFLAGS) \
    $(GARCON_CFLAGS) \
    $(LIBWNCK_CFLAGS) \
    $(LIBGTOP_CFLAGS) \
    -DWNCK_I_KNOW_THIS_IS_UNSTABLE

libdock_task_plugin_la_SOURCES = \
    dock-task-plugin.vala \
    dock-task-model.vala \
    dock-cell-task.vala \
    launcher.vala

libdock_task_plugin_la_LDFLAGS = \
    -module -avoid-version -no-undefined

libdock_task_plugin_la_LIBADD = \
    $(top_builddir)/lib/libxfce4-dock.la \
    $(LIBXFCE4_PANEL_LIBS) \
    $(LIBXFCE4_UI_LIBS) \
    $(LIBXFCONF_LIBS) \
    $(GARCON_LIBS) \
    $(LIBGTOP_LIBS) \
    $(LIBWNCK_LIBS)

desktopdir = $(datadir)/xfce4/panel/plugins
desktop_in_files = dock-task-plugin.desktop.in
desktop_DATA = $(desktop_in_files:.desktop.in=.desktop)
@INTLTOOL_DESKTOP_RULE@

EXTRA_DIST = $(desktop_in_files)

VALAFILES = \
    $(filter %.vala,$(libdock_task_plugin_la_SOURCES))

CLEANFILES = \
    $(VALAFILES:.vala=.c) \
    libdock_task_plugin_la_vala.stamp \
    $(desktop_DATA)
