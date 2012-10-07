/* lucido-engine.vala
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

public class Xdp.LucidoEngine : Engine
{
    // properties
    private Xfconf.Channel m_Channel = null;

    // accessors
    protected override Xfconf.Channel channel {
        get {
            if (m_Channel == null)
            {
                m_Channel = new Xfconf.Channel.with_property_base (Engine.CHANNEL_NAME,
                                                                   "/lucido");
            }

            return m_Channel;
        }
    }

    public uint indicator_size { get; construct set; default = 4; }

    // methods
    construct
    {
        // bind channel properties
        Xfconf.Property.bind (channel, "/indicator_size", typeof(uint), this, "indicator_size");
    }

    public LucidoEngine (Xdp.DockPlugin inPlugin)
    {
        GLib.Object (parent: inPlugin.parent, orientation: inPlugin.orientation);
    }

    private Cairo.Path
    create_wave_path (CairoContext inCtx)
    {
        inCtx.new_path ();
        inCtx.move_to (0, 0);
        foreach (DockPlugin plugin in dock_plugins)
        {
            if (plugin.view != null)
            {
                inCtx.line_to (plugin.view.content_allocation.x - parent.allocation.height, 0);
                inCtx.rel_curve_to (parent.allocation.height / 2, 0,
                                    parent.allocation.height / 2, plugin.allocation.height,
                                    parent.allocation.height, plugin.allocation.height);
                inCtx.rel_line_to (plugin.view.content_allocation.width, 0);
                inCtx.rel_curve_to (parent.allocation.height / 2, 0,
                                    parent.allocation.height / 2, -plugin.allocation.height,
                                    parent.allocation.height, -plugin.allocation.height);
            }
        }
        inCtx.line_to (parent.allocation.width, 0);
        return inCtx.copy_path ();
    }

    public override void
    paint_background (CairoContext inCtx)
    {
        //double x, y;
        //inCtx.get_target ().get_device_offset (out x, out y);

        //inCtx.translate (-x, -y);
        inCtx.move_to (0, 0);

        // Create wave path
        Cairo.Path wave = create_wave_path (inCtx);
        inCtx.new_path ();

        // Draw background
        inCtx.save ();
        {
            CairoPattern pattern = new CairoPattern.linear (0, 0, 0, parent.allocation.height);
            pattern.add_color_stop (0, bg_step_1);
            pattern.add_color_stop (1, bg_step_2);
            inCtx.set_source (pattern);

            inCtx.move_to (0, 0);
            inCtx.append_path (wave);
            inCtx.line_to (parent.allocation.width, 0);
            inCtx.line_to (parent.allocation.width, parent.allocation.height);
            inCtx.line_to (0, parent.allocation.height);
            inCtx.line_to (0, 0);
            inCtx.fill ();
        }
        inCtx.restore ();

        // Draw highlight background
        inCtx.save ();
        {
            CairoPattern pattern = new CairoPattern.linear (0, 0, 0, parent.allocation.height);
            pattern.add_color_stop_alpha (0, bg_highlight, 0);
            pattern.add_color_stop_alpha (1, bg_highlight, 1);
            inCtx.set_source (pattern);

            inCtx.move_to (0, 0);
            inCtx.append_path (wave);
            inCtx.line_to (parent.allocation.width, 0);
            inCtx.line_to (0, 0);
            inCtx.clip ();

            inCtx.rectangle (0, parent.allocation.height / 3, parent.allocation.width, parent.allocation.height);
            inCtx.fill ();
        }
        inCtx.restore ();
    }

    public override void
    paint_foreground (CairoContext inCtx)
    {
        //double x, y;
        //inCtx.get_target ().get_device_offset (out x, out y);

        //inCtx.translate (-x, -y);
        inCtx.move_to (0, 0);

        // Create wave path
        Cairo.Path wave = create_wave_path (inCtx);
        inCtx.new_path ();

        // Draw highlight border
        inCtx.save ();
        {
            inCtx.move_to (0, 0);
            inCtx.set_source_color (bg_highlight);
            inCtx.set_line_width (line_width);
            inCtx.translate (0, line_width);
            inCtx.scale (1.0, ((double)parent.allocation.height - (line_width * 2.0)) / (double)parent.allocation.height);
            inCtx.append_path (wave);
            inCtx.stroke ();
        }
        inCtx.restore ();
    }

    public override void
    paint_selected (CairoContext inCtx, Cairo.Rectangle inArea)
    {
        inCtx.save ();
        inCtx.translate (inArea.x, inArea.y);

        double x = inArea.width / 2.0;
        double y = inArea.height;

        inCtx.move_to (x, y);
        inCtx.arc (x, y, indicator_size / 2.0, 0, GLib.Math.PI * 2);

        CairoPattern rg = new CairoPattern.radial (x, y, 0, x, y, indicator_size / 2);
        rg.add_color_stop_alpha (0, selected, 1);
        rg.add_color_stop_alpha (0.1, selected, 1);
        rg.add_color_stop_alpha (0.2, selected, 0.6);
        rg.add_color_stop_alpha (0.25, selected, 0.25);
        rg.add_color_stop_alpha (0.5, selected, 0.15);
        rg.add_color_stop_alpha (1.0, selected, 0.0);

        inCtx.set_source (rg);
        inCtx.fill ();
        inCtx.restore ();
    }

    public override void
    paint_highlight (CairoContext inCtx, Cairo.Rectangle inArea)
    {
        inCtx.save ();
        inCtx.set_source_color (highlight);
        inCtx.rounded_rectangle (inArea.x, inArea.y, inArea.width, inArea.height, 5, CairoCorner.ALL);
        inCtx.fill ();
        inCtx.restore ();
    }

    public override void
    paint_reflection (CairoContext inCtx, Cairo.Rectangle inArea)
    {
    }
}
