/* dock-task-item.vala
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

internal class Xdp.DockTaskItem : DockItem
{
    // properties
    private Gtk.Image        m_Image;

    // accessors
    public Wnck.Application application {
        set {
            if (value != null)
            {
                m_Image.set_from_icon_name (value.get_icon_name (), Gtk.IconSize.DIALOG);
            }
        }
    }

    // methods
    construct
    {
        m_Image = new Gtk.Image ();
        m_Image.show ();
        add (m_Image);
    }
}
