/* dock-cell.vala
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

public abstract class Xdp.DockCell : GLib.InitiallyUnowned
{
    // accessors
    public bool mouse_is_over { get; set; default = false; }

    public virtual uint min_width {
        get {
            return 12;
        }
    }

    public virtual uint min_height {
        get {
            return 12;
        }
    }

    // signals
    public signal void clicked ();
    public signal void enter ();
    public signal void leave ();

    // methods
    public virtual void
    render (CairoContext inCtx, Cairo.Rectangle inArea)
    {
        double scale = mouse_is_over ? 1.0 : 0.9;
        inCtx.translate (inArea.x + inArea.width / 2, inArea.y + inArea.height);
        inCtx.scale (scale, scale);
        inCtx.translate (-inArea.width / 2, -inArea.height);
    }

    public virtual void
    click_notify ()
    {
        clicked ();
    }

    public virtual void
    enter_notify ()
    {
        enter ();
    }

    public virtual void
    leave_notify ()
    {
        leave ();
    }
}
