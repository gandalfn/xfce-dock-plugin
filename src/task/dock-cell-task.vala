/* dock-cell-task.vala
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

public class Xdp.DockCellTask : DockCellImage
{
    // properties
    private unowned DockTaskPlugin m_Plugin;

    // accessors
    [CCode (notify = false)]
    public Wnck.Window window { get; set; default = null; }
    [CCode (notify = false)]
    public Launcher launcher { get; set; default = null; }

    // methods
    public DockCellTask (DockTaskPlugin inPlugin)
    {
        m_Plugin = inPlugin;
    }

    public override void
    render (CairoContext inCtx, Cairo.Rectangle inArea)
    {
        if (window != null)
        {
            inCtx.save ();
            unowned Wnck.Workspace current = window.get_screen ().get_active_workspace ();
            if (window.is_visible_on_workspace (current))
            {
                unowned Engine? engine = Engine.get (m_Plugin);
                if (engine != null)
                {
                    engine.paint_highlight (inCtx, inArea);
                }
            }
            inCtx.restore ();
        }

        base.render (inCtx, inArea);

        if (window != null && launcher != null)
        {
            unowned Engine? engine = Engine.get (m_Plugin);
            if (engine != null)
            {
                inCtx.save ();
                engine.paint_selected (inCtx, inArea);
                inCtx.restore ();
            }
        }
    }

    public override void
    click_notify ()
    {
        base.click_notify ();

        if (window != null)
        {
            if (!window.is_active ())
            {
                uint64 now = GLib.get_monotonic_time () / 1000;
                window.activate ((uint32)now);
            }
            else
            {
                window.minimize ();
            }
        }
        else if (launcher != null)
        {
            launcher.run ();
        }
    }

    public override void
    enter_notify ()
    {
        base.enter_notify ();
    }

    public override void
    leave_notify ()
    {
        base.leave_notify ();
    }
}
