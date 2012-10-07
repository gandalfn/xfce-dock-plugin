/* dock-application-view.vala
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

public class Xdp.DockApplicationView : DockView
{
    // methods
    public DockApplicationView ()
    {
        DockApplicationModel model = new DockApplicationModel (0);
        base.with_model (model);
    }

    internal override Gtk.Widget?
    on_widget_added (Gtk.TreePath inPath)
    {
        message ("Add");

        DockApplicationItem item = new DockApplicationItem ();
        item.application = (model as DockApplicationModel)[inPath];

        return item;
    }

    internal override void
    on_widget_changed (Gtk.TreePath inPath)
    {
        message ("Changed");
        Gtk.Widget? widget = get_widget (inPath);
        Wnck.Application? app = (model as DockApplicationModel)[inPath];

        if (widget != null && app != null)
        {
            (widget as DockApplicationItem).application = app;
        }
    }
}
