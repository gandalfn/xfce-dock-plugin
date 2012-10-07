/* dock-container.vala
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

public class Xdp.DockContainer : Gtk.EventBox
{
    // properties
    private int                 m_Size;
    private uint                m_Spacing;
    private GLib.List<DockItem> m_Items = new GLib.List<DockItem> ();
    private Gtk.Orientation     m_Orientation = Gtk.Orientation.HORIZONTAL;

    // accessors
    public int size {
        get {
            return m_Size;
        }
        set {
            if (m_Size != value)
            {
                m_Size = value;
            }
        }
    }

    public uint spacing {
        get {
            return m_Spacing;
        }
        set {
            if (m_Spacing != value)
            {
                m_Spacing = value;
            }
        }
    }

    // methods
    public DockContainer ()
    {
        Gdk.Display display = Gdk.Display.get_default();
        Gdk.Screen screen = display.get_default_screen();

        above_child = true;
        visible_window = true;
        set_app_paintable (true);
        set_colormap(screen.get_rgba_colormap());
    }

    internal override void
    realize ()
    {
        base.realize ();

        window.set_composited (true);
    }
}
