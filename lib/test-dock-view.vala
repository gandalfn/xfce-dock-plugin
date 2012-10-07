/* test-dock-view.vala
 *
 * Copyright (C) 2012  Nicolas Bruguier
 *
 * This library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this library.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author:
 *  Nicolas Bruguier <gandalfn@club-internet.fr>
 */

static int
main (string[] inArgs)
{
    Gtk.init (ref inArgs);

    Gtk.Window window = new Gtk.Window ();
    /*window.set_colormap (Gdk.Screen.get_default ().get_rgba_colormap ());
    window.set_decorated (false);
    window.expose_event.connect ((e) => {
        Xdp.CairoContext ctx = new Xdp.CairoContext.from_widget (window);
        ctx.set_operator (Cairo.Operator.CLEAR);
        Gdk.cairo_region (ctx, e.region);
        ctx.fill ();

        window.propagate_expose (window.get_child (), e);

        return true;
    });*/
    Xdp.DockTaskModel model = new Xdp.DockTaskModel (0);
    model.add_launcher ("/usr/share/applications/evolution.desktop");
    Xdp.DockView view = new Xdp.DockView (model);
    view.cell = new Xdp.DockCellTask ();
    view.set_attribute ("window", Xdp.DockTaskModel.Columns.WINDOW);
    view.set_attribute ("pixbuf", Xdp.DockTaskModel.Columns.ICON);
    view.bottom_padding = 5;
    view.item_spacing = 5;
    view.show ();
    window.add (view);
    window.show ();

    Gtk.main ();

    return 0;
}
