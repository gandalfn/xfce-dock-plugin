/* engine.vala
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

public abstract class Xdp.Engine : GLib.Object
{
    // const properties
    private const string QUARK_NAME = "XfceDockEngine";
    public const string CHANNEL_NAME = "xfce4-dock-plugin";

    // properties
    public CairoColor bg_highlight;
    public CairoColor bg_step_1;
    public CairoColor bg_step_2;
    public CairoColor selected;
    public CairoColor highlight;

    // accessors
    protected abstract Xfconf.Channel channel { get; }

    public Gtk.Container   parent        { get; construct; default = null; }
    public Gtk.Orientation orientation   { get; construct set; default = Gtk.Orientation.HORIZONTAL; }
    public uint            border        { get; construct set; default = 0; }
    public uint            top_margin    { get; construct set; default = 0; }
    public uint            bottom_margin { get; construct set; default = 0; }
    public float           line_width    { get; construct set; default = 1.2f; }

    public string bg_highlight_color {
        owned get {
            return bg_highlight.to_string ();
        }
        set {
            bg_highlight = CairoColor.from_string (value);
            if (parent != null) parent.queue_draw ();
        }
    }

    public string bg_step_1_color {
        owned get {
            return bg_step_1.to_string ();
        }
        set {
            bg_step_1 = CairoColor.from_string (value);
            if (parent != null) parent.queue_draw ();
        }
    }

    public string bg_step_2_color {
        owned get {
            return bg_step_2.to_string ();
        }
        set {
            bg_step_2 = CairoColor.from_string (value);
            if (parent != null) parent.queue_draw ();
        }
    }

    public string selected_color {
        owned get {
            return selected.to_string ();
        }
        set {
            selected = CairoColor.from_string (value);
            if (parent != null) parent.queue_draw ();
        }
    }

    public string highlight_color {
        owned get {
            return highlight.to_string ();
        }
        set {
            highlight = CairoColor.from_string (value);
            if (parent != null) parent.queue_draw ();
        }
    }

    public GLib.List<unowned DockPlugin> dock_plugins {
        owned get {
            GLib.List<unowned DockPlugin> list = new GLib.List<unowned DockPlugin> ();
            if (parent != null)
            {
                parent.forall ((c) => {
                    if (c is DockPlugin)
                    {
                        list.prepend (c as DockPlugin);
                    }
                });
                list.sort (DockPlugin.compare);
            }

            return list.copy ();
        }
    }

    // static methods
    public static new unowned Engine?
    @get (DockPlugin inPlugin)
    {
        unowned Engine? engine = null;
        if (inPlugin.parent != null)
        {
            engine = inPlugin.parent.get_data<Engine?> (QUARK_NAME);
        }

        return engine;
    }

    public static new void
    @set (DockPlugin inPlugin)
    {
        unowned Engine? engine = get (inPlugin);
        if (engine == null && inPlugin.parent != null)
        {
            Xfconf.Channel channel = new Xfconf.Channel.with_property_base (CHANNEL_NAME, "engine");
            string engine_name = channel.get_string ("current", "lucido");

            switch (engine_name)
            {
                case "lucido":
                    Engine new_engine = new LucidoEngine (inPlugin);
                    inPlugin.parent.set_data<Engine?> (QUARK_NAME, new_engine);
                    break;
            }
        }
        else
        {
            engine.ref ();
        }
    }

    public static void
    unset (DockPlugin inPlugin)
    {
        unowned Engine? engine = get (inPlugin);
        if (engine != null)
        {
            if (engine.ref_count == 1)
            {
                inPlugin.parent.set_data<Engine?> (QUARK_NAME, null);
            }
            else
            {
                engine.unref ();
            }
        }
    }

    // methods
    construct
    {
        // connect on panel expose event
        parent.expose_event.connect (on_paint);

        // bind channel properties
        Xfconf.Property.bind (channel, "/border", typeof(uint), this, "border");
        Xfconf.Property.bind (channel, "/top_margin", typeof(uint), this, "top_margin");
        Xfconf.Property.bind (channel, "/bottom_margin", typeof(uint), this, "bottom_margin");
        Xfconf.Property.bind (channel, "/line_width", typeof(float), this, "line_width");
        Xfconf.Property.bind (channel, "/bg_highlight", typeof(string), this, "bg_highlight_color");
        Xfconf.Property.bind (channel, "/bg_step_1", typeof(string), this, "bg_step_1_color");
        Xfconf.Property.bind (channel, "/bg_step_2", typeof(string), this, "bg_step_2_color");
        Xfconf.Property.bind (channel, "/selected", typeof(string), this, "selected_color");
        Xfconf.Property.bind (channel, "/highlight", typeof(string), this, "highlight_color");
    }

    private bool
    on_paint (Gdk.EventExpose inEvent)
    {
        if (parent != null)
        {
            CairoContext ctx = new CairoContext.from_widget (parent);

            // Clear background
            ctx.set_operator (Cairo.Operator.CLEAR);
            Gdk.cairo_region (ctx, inEvent.region);
            ctx.clip ();
            ctx.paint ();

            // Paint background
            ctx.set_operator (Cairo.Operator.OVER);
            ctx.save ();
            paint_background (ctx);
            ctx.restore ();

            // Paint childs
            parent.forall ((c) => {
                parent.propagate_expose (c, inEvent);
            });

            // Paint foreground
            ctx.set_operator (Cairo.Operator.OVER);
            ctx.save ();
            paint_foreground (ctx);
            ctx.restore ();
        }

        return true;
    }

    public abstract void paint_background (CairoContext inCtx);
    public abstract void paint_foreground (CairoContext inCtx);
    public abstract void paint_selected   (CairoContext inCtx, Cairo.Rectangle inArea);
    public abstract void paint_highlight  (CairoContext inCtx, Cairo.Rectangle inArea);
    public abstract void paint_reflection (CairoContext inCtx, Cairo.Rectangle inArea);
}
