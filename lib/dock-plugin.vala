/* dock-plugin.vala
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

public abstract class Xdp.DockPlugin : Xfce.PanelPlugin
{
    // properties
    private Exo.Binding m_TopMarginBinding;
    private Exo.Binding m_BottomMarginBinding;

    // accessors
    public DockView view { get; construct set; default = null; }

    // methods
    ~DockPlugin ()
    {
        Engine.unset (this);
    }

    private void
    plug_engine ()
    {
        unowned Engine? engine = Engine.get (this);
        if (engine != null)
        {
            if (orientation == Gtk.Orientation.HORIZONTAL)
            {
                m_TopMarginBinding = new Exo.Binding (engine, "top_margin",
                                                      view, "top_padding");
                m_BottomMarginBinding = new Exo.Binding (engine, "bottom_margin",
                                                         view, "bottom_padding");
            }
            else
            {
                m_TopMarginBinding = new Exo.Binding (engine, "top_margin",
                                                      view, "right_padding");
                m_BottomMarginBinding = new Exo.Binding (engine, "bottom_margin",
                                                         view, "left_padding");
            }
        }
    }

    internal override void
    realize ()
    {
        base.realize ();

        Engine.set (this);
    }

    internal override bool
    size_changed (int inSize)
    {
        if (view != null)
            view.size = size;

        return true;
    }

    internal override void
    orientation_changed (Gtk.Orientation orientation)
    {
        plug_engine ();
    }

    internal int
    compare (DockPlugin inOther)
    {
        return orientation == Gtk.Orientation.HORIZONTAL ?
               allocation.x - inOther.allocation.x :
               allocation.y - inOther.allocation.y;
    }
}
