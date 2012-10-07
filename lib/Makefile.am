include $(top_srcdir)/build/vala.am

lib_LTLIBRARIES = libxfce4-dock.la

libxfce4_dock_la_CFLAGS = \
    $(LIBXFCE4_PANEL_CFLAGS) \
    $(LIBXFCONF_CFLAGS) \
    $(EXO_CFLAGS)

libxfce4_dock_la_VALAFLAGS = \
    --header=xfce4-dock.h \
    --library=xfce4-dock \
    --vapi=xfce4-dock.vapi

libxfce4_dock_la_SOURCES = \
    cairo/cairo-color.vala \
    cairo/cairo-context.vala \
    cairo/cairo-pattern.vala \
    model/dock-model.vala \
    view/dock-view.vala \
    view/dock-item.vala \
    view/dock-cell.vala \
    view/dock-cell-image.vala \
    engine/engine.vala \
    engine/lucido-engine.vala \
    dock-plugin.vala

libxfce4_dock_la_LIBADD = \
    $(LIBXFCE4_PANEL_LIBS) \
    $(LIBXFCONF_LIBS) \
    $(EXO_LIBS)

VALAFILES = \
    $(filter %.vala,$(libxfce4_dock_la_SOURCES))

CLEANFILES = \
    $(VALAFILES:.vala=.c) \
    libxfce4_dock_la_vala.stamp \
    xfce4-dock.vapi \
    xfce4-dock.h

EXTRA_DIST = \
    xfce4-dock.vapi \
    xfce4-dock.h
