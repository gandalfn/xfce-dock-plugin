/* dock-cell-image.vala
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

public class Xdp.DockCellImage : DockCell
{
    // accessors
    [CCode (notify = false)]
    public Gdk.Pixbuf pixbuf { get; set; default = null; }

    // methods
    public override void
    render (CairoContext inCtx, Cairo.Rectangle inArea)
    {
        if (pixbuf != null)
        {
            inCtx.save ();
            {
                base.render (inCtx, inArea);

                inCtx.scale (inArea.width / pixbuf.get_width (), inArea.height / pixbuf.get_height ());
                Gdk.cairo_set_source_pixbuf (inCtx, pixbuf, 0, 0);
                inCtx.paint ();
            }
            inCtx.restore ();
        }
    }
}
