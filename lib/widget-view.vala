/* widget-view.vala
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

public abstract class Xdp.WidgetView : Gtk.Frame
{
    // types
    private struct Item
    {
        public unowned Gtk.Widget m_Widget;
    }

    // static properties
    private static GLib.Quark     s_IndiceQuark;
    private static GLib.Quark     s_PathQuark;
    private static GLib.Quark     s_EmptyQuark;

    // properties
    private Gtk.TreeModel         m_Model;
    private Gtk.EventBox          m_EventBox;
    private Gtk.Alignment         m_Align;
    private Gtk.Table             m_Content;
    private Item[]                m_Items;

    private Gtk.Orientation       m_Orientation = Gtk.Orientation.HORIZONTAL;
    private uint                  m_RowSpacing = 0;
    private uint                  m_ColumnSpacing = 0;
    private uint                  m_Lines = 1;

    // accessors
    protected Gtk.Widget content {
        get {
            return m_Content;
        }
    }

    [Description (nick = "Model", blurb = "Tree Model associated to widget view")]
    public Gtk.TreeModel model {
        get {
            return m_Model;
        }
        set {
            if (m_Model != null) clear_content();

            m_Model = value;

            if (m_Model != null && m_Model is Gtk.TreeModel)
            {
                m_Model.row_inserted.connect(on_row_inserted);
                m_Model.row_deleted.connect(on_row_deleted);
                m_Model.rows_reordered.connect(on_rows_reordered);
                m_Model.row_changed.connect(on_row_changed);
                refresh ();
            }
        }
    }

    [Description (nick = "Orientation", blurb = "Orientation of widget view")]
    public Gtk.Orientation orientation {
        get {
            return m_Orientation;
        }
        set {
            m_Orientation = value;
            refresh ();
        }
    }

    [Description (nick = "Left padding", blurb = "The padding to insert at the left of the widget.")]
    public uint left_padding {
        get {
            return m_Align.left_padding;
        }
        set {
            m_Align.left_padding = value;
            refresh ();
        }
    }

    [Description (nick = "Right padding", blurb = "The padding to insert at the right of the widget.")]
    public uint right_padding {
        get {
            return m_Align.right_padding;
        }
        set {
            m_Align.right_padding = value;
            refresh ();
        }
    }

    [Description (nick = "Top padding", blurb = "The padding to insert at the top of the widget.")]
    public uint top_padding {
        get {
            return m_Align.top_padding;
        }
        set {
            m_Align.top_padding = value;
            refresh ();
        }
    }

    [Description (nick = "Bottom padding", blurb = "The padding to insert at the bottom of the widget.")]
    public uint bottom_padding {
        get {
            return m_Align.bottom_padding;
        }
        set {
            m_Align.bottom_padding = value;
            refresh ();
        }
    }

    [Description (nick = "Column spacing", blurb = "Space in pixel between column")]
    public uint column_spacing {
        get {
            return m_ColumnSpacing;
        }
        set {
            m_ColumnSpacing = value;
            m_Content.set_col_spacings(m_ColumnSpacing);
            refresh ();
        }
    }

    [Description (nick = "Row spacing", blurb = "Space in pixel between row")]
    public uint row_spacing {
        get {
            return m_RowSpacing;
        }
        set {
            m_RowSpacing = value;
            m_Content.set_row_spacings(m_RowSpacing);
            refresh ();
        }
    }

    [Description (nick = "Lines/Columns", blurb = "Max number of line/column in view ")]
    public uint lines {
        get {
            return m_Lines;
        }
        set {
            m_Lines = value;
            if (m_Lines < 1) m_Lines = 1;
            refresh ();
        }
    }

    // methods
    static construct
    {
        s_IndiceQuark = GLib.Quark.from_string("DockViewIndice");
        s_PathQuark = GLib.Quark.from_string("DockViewPath");
        s_EmptyQuark = GLib.Quark.from_string("DockViewEmpty");
    }

    construct
    {
        var display = Gdk.Display.get_default();
        var screen = display.get_default_screen();

        shadow = Gtk.ShadowType.NONE;

        // set widget properties
        set_flags(Gtk.WidgetFlags.NO_WINDOW);
        set_colormap(screen.get_rgba_colormap());

        // Create event box for content
        m_EventBox = new Gtk.EventBox ();
        m_EventBox.above_child = false;
        m_EventBox.visible_window = true;
        m_EventBox.set_app_paintable (true);
        m_EventBox.set_colormap(screen.get_rgba_colormap());

        // Set lambda methods for event box compositing
        m_EventBox.realize.connect ((w) => {
            w.window.set_composited (true);
        });
        m_EventBox.expose_event.connect ((w, e) => {
            Cairo.Context ctx = Gdk.cairo_create (w.window);

            Gdk.cairo_region (ctx, e.region);
            ctx.clip ();
            ctx.set_operator(Cairo.Operator.CLEAR);
            ctx.paint();

            return false;
        });

        // Add event box to view
        m_EventBox.show ();
        add (m_EventBox);

        // Create alignment for adjustment space
        m_Align = new Gtk.Alignment (0.5f, 0.5f, 1.0f, 1.0f);
        m_Align.show ();
        m_EventBox.add (m_Align);

        // Create content widget
        m_Content = new Gtk.Table(1, 1, true);
        m_Content.set_app_paintable (true);
        m_Content.show ();
        m_Align.add (m_Content);

        m_Content.expose_event.connect ((w, e) => {
            Cairo.Context ctx = Gdk.cairo_create (w.window);

            Gdk.cairo_region (ctx, e.region);
            ctx.clip ();
            ctx.set_operator (Cairo.Operator.CLEAR);
            ctx.paint ();

            return false;
        });

        // Conect after expose to draw composited widgets
        Signal.connect_after(this, "expose_event", (GLib.Callback)on_expose_event, this);
    }

    public WidgetView ()
    {
    }

    public WidgetView.with_model(Gtk.TreeModel inModel)
    {
        model = inModel;
    }

    private bool
    on_each_model_iter_add(Gtk.TreeModel inModel, Gtk.TreePath inPath, Gtk.TreeIter inIter)
    {
        on_row_inserted(inPath, inIter);

        return false;
    }

    private void
    clear_content()
    {
        foreach (unowned Gtk.Widget widget in m_Content.get_children())
        {
            m_Content.remove(widget);
        }

        m_Items = null;
    }

    private void
    shift (int pos)
    {
        GLib.List<unowned Gtk.Widget> list = m_Content.get_children().copy ();
        int n = m_Model.iter_n_children(null);

        for (int cpt = pos; cpt < n; ++cpt)
        {
            uint oldpos = cpt, newpos = cpt + 1;
            uint oldcol, oldline, newcol, newline;

            if (m_Orientation == Gtk.Orientation.VERTICAL)
            {
                oldcol = oldpos % m_Lines;
                oldline = oldpos / m_Lines;
                newcol = newpos % m_Lines;
                newline = newpos / m_Lines;
            }
            else
            {
                oldline = oldpos % m_Lines;
                oldcol = oldpos / m_Lines;
                newline = newpos % m_Lines;
                newcol = newpos / m_Lines;
            }

            // Change widget pos
            foreach (unowned Gtk.Widget widget in list)
            {
                int indice = widget.get_qdata<int> (s_IndiceQuark);
                if (oldpos == indice)
                {
                    m_Content.child_set(widget,
                                        "left-attach", newcol,
                                        "right-attach", newcol + 1,
                                        "top-attach", newline,
                                        "bottom-attach", newline + 1);
                    widget.set_qdata(s_IndiceQuark, newpos.to_pointer());
                    Gtk.TreePath path = new Gtk.TreePath.from_indices(newpos);
                    widget.set_qdata(s_PathQuark, path.to_string());
                    list.remove(widget);
                    m_Items[newpos].m_Widget = widget;
                    break;
                }
            }
        }
    }

    private void
    unshift (int pos)
    {
        GLib.List<unowned Gtk.Widget> list = m_Content.get_children().copy ();
        int n = m_Model.iter_n_children(null);

        for (int cpt = pos + 1; cpt <= n; ++cpt)
        {
            uint oldpos = cpt, newpos = cpt - 1;
            uint oldcol, oldline, newcol, newline;

            if (m_Orientation == Gtk.Orientation.VERTICAL)
            {
                oldcol = oldpos % m_Lines;
                oldline = oldpos / m_Lines;
                newcol = newpos % m_Lines;
                newline = newpos / m_Lines;
            }
            else
            {
                oldline = oldpos % m_Lines;
                oldcol = oldpos / m_Lines;
                newline = newpos % m_Lines;
                newcol = newpos / m_Lines;
            }

            // Change widget pos
            foreach (unowned Gtk.Widget widget in list)
            {
                int indice = widget.get_qdata<int> (s_IndiceQuark);
                if (oldpos == indice)
                {
                    m_Content.child_set(widget,
                                        "left-attach", newcol,
                                        "right-attach", newcol + 1,
                                        "top-attach", newline,
                                        "bottom-attach", newline + 1);
                    widget.set_qdata(s_IndiceQuark, newpos.to_pointer());
                    Gtk.TreePath path = new Gtk.TreePath.from_indices(newpos);
                    widget.set_qdata(s_PathQuark, path.to_string());
                    list.remove(widget);
                    m_Items[newpos].m_Widget = widget;
                    break;
                }
            }
        }
    }

    private void
    resize_content ()
    {
        uint line, col;
        int n = m_Model.iter_n_children(null);

        // Resize content
        if (m_Orientation == Gtk.Orientation.VERTICAL)
        {
            line = n / m_Lines;
            col = m_Lines;
        }
        else
        {
            line = m_Lines;
            col = n / m_Lines;
        }
        m_Content.resize(uint.max (line, 1), uint.max (col, 1));
    }

    private void
    add_widget (Gtk.TreePath inPath, Gtk.Widget? inWidget)
    {
        int pos = inPath.get_indices()[0];
        uint line, col;
        Gtk.Widget? widget = inWidget;

        // No widget from child create label
        if (widget == null)
        {
            widget = new Gtk.Label (null);
            widget.set_qdata (s_EmptyQuark, ((int)true).to_pointer ());
        }
        widget.show ();

        // Add widget in view
        if (m_Orientation == Gtk.Orientation.VERTICAL)
        {
            col = pos % m_Lines;
            line = pos / m_Lines;

            m_Content.attach(widget, col, col + 1, line, line + 1,
                             Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                             Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL, 0, 0);
        }
        else
        {
            col = pos / m_Lines;
            line = pos % m_Lines;

            m_Content.attach(widget, col, col + 1, line, line + 1,
                             Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL,
                             Gtk.AttachOptions.EXPAND | Gtk.AttachOptions.FILL, 0, 0);
        }

        // Set widget floating properties
        widget.set_qdata(s_IndiceQuark, pos.to_pointer());
        widget.set_qdata(s_PathQuark, inPath.to_string());

        // Set widget in array
        m_Items[pos].m_Widget = widget;
    }

    private void
    on_row_inserted (Gtk.TreePath inPath, Gtk.TreeIter inIter)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            int pos = inPath.get_indices()[0];
            int n = m_Model.iter_n_children(null);

            // Resize widgets array
            m_Items.resize (n + 1);

            // Resize content
            resize_content ();

            // If current conflict with another row shift all row +1
            foreach (unowned Gtk.Widget widget in m_Content.get_children())
            {
                int indice = widget.get_qdata<int> (s_IndiceQuark);

                if (pos == indice)
                {
                    shift(pos);
                    // Unset widget at pos
                    m_Items[pos].m_Widget = null;
                    break;
                }
            }

            // Create widget
            Gtk.Widget? widget = on_widget_added (inPath);

            // Add widget in view
            add_widget (inPath, widget);
        }
    }

    private void
    on_row_deleted (Gtk.TreePath inPath)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            bool deleted = false;
            int pos = inPath.get_indices()[0];
            int n = m_Model.iter_n_children(null);

            // remove widget
            foreach (unowned Gtk.Widget widget in m_Content.get_children())
            {
                int indice = widget.get_qdata<int> (s_IndiceQuark);
                if (pos == indice)
                {
                    m_Content.remove(widget);
                    deleted = true;
                    break;
                }
            }

            // unshift all next widgets
            unshift(pos);

            // Resize widgets array
            m_Items.resize (n);

            // Resize content
            resize_content ();

            if (deleted)
            {
                // notify child
                on_widget_removed (inPath);
            }
        }
    }

    private void
    on_rows_reordered (Gtk.TreePath inPath, Gtk.TreeIter? inIter, void* inNewOrder)
    {
        unowned int[]? new_order = (int[]?)inNewOrder;
        GLib.List<unowned Gtk.Widget> list = m_Content.get_children().copy ();
        int n = m_Model.iter_n_children(null);

        for (int cpt = 0; cpt < n; ++cpt)
        {
            uint oldpos = new_order[cpt], newpos = cpt;
            uint oldcol, oldline, newcol, newline;

            if (m_Orientation == Gtk.Orientation.VERTICAL)
            {
                oldcol = oldpos % m_Lines;
                oldline = oldpos / m_Lines;
                newcol = newpos % m_Lines;
                newline = newpos / m_Lines;
            }
            else
            {
                oldline = oldpos % m_Lines;
                oldcol = oldpos / m_Lines;
                newline = newpos % m_Lines;
                newcol = newpos / m_Lines;
            }

            // Change widget pos
            foreach (unowned Gtk.Widget widget in list)
            {
                int indice = widget.get_qdata<int> (s_IndiceQuark);
                if (oldpos == indice)
                {
                    m_Content.child_set(widget,
                                        "left-attach", newcol,
                                        "right-attach", newcol + 1,
                                        "top-attach", newline,
                                        "bottom-attach", newline + 1);
                    widget.set_qdata(s_IndiceQuark, newpos.to_pointer());
                    Gtk.TreePath path = new Gtk.TreePath.from_indices(newpos);
                    widget.set_qdata(s_PathQuark, path.to_string());
                    list.remove(widget);
                    m_Items[newpos].m_Widget = widget;
                    break;
                }
            }
        }
    }

    private void
    on_row_changed (Gtk.TreePath inPath, Gtk.TreeIter inIter)
    {
        if (inPath.get_depth () == 1 && inPath.get_indices () != null)
        {
            int pos = inPath.get_indices()[0];

            if (pos < m_Items.length)
            {
                // notify child
                on_widget_changed (inPath);
            }
        }
    }

    [CCode (instance_pos = -1)]
    private bool
    on_expose_event (Gtk.Widget inWidget, Gdk.EventExpose inEvent)
        requires (inWidget.window is Gdk.Drawable)
    {
        Cairo.Context ctx = Gdk.cairo_create (window);
        Gdk.cairo_region (ctx, inEvent.region);
        ctx.clip();

        // Paint content box
        ctx.set_operator(Cairo.Operator.OVER);
        Cairo.Context evt_box_ctx = Gdk.cairo_create (m_EventBox.window);
        ctx.set_source_surface(evt_box_ctx.get_target(), m_EventBox.allocation.x, m_EventBox.allocation.y);
        ctx.paint();

        return false;
    }

    protected void
    refresh ()
    {
        if (m_Model != null && m_Model is Gtk.TreeModel)
        {
            clear_content();
            m_Model.foreach(on_each_model_iter_add);
        }
    }

    protected virtual Gtk.Widget?
    on_widget_added (Gtk.TreePath inPath)
    {
        return null;
    }

    protected virtual void
    on_widget_changed (Gtk.TreePath inPath)
    {
    }

    protected virtual void
    on_widget_removed (Gtk.TreePath inPath)
    {
    }

    public unowned Gtk.Widget?
    get_widget (Gtk.TreePath inPath)
    {
        int pos = inPath.get_indices()[0];
        GLib.return_val_if_fail (pos >= 0 && pos < m_Items.length, null);

        unowned Gtk.Widget? widget = m_Items[pos].m_Widget;

        if (widget != null)
        {
            bool empty = widget.get_qdata<bool> (s_EmptyQuark);
            return empty ? null : widget;
        }

        return widget;
    }

    public Gtk.TreePath?
    get_path (Gtk.Widget inWidget)
    {
        string path_str = inWidget.get_qdata<string> (s_PathQuark);

        if (path_str != null)
        {
           return new Gtk.TreePath.from_string(path_str);
        }

        return null;
    }

    public void
    set_widget (Gtk.TreePath inPath, Gtk.Widget inWidget)
    {
        int pos = inPath.get_indices()[0];
        GLib.return_if_fail (pos >= 0 && pos < m_Items.length);

        unowned Gtk.Widget? widget = m_Items[pos].m_Widget;

        if (widget != null)
        {
            // Remove old widget
            m_Content.remove (widget);

            // Add the new one
            add_widget (inPath, inWidget);
        }
    }

    public void
    unset_widget (Gtk.TreePath inPath)
    {
        int pos = inPath.get_indices()[0];
        GLib.return_if_fail (pos >= 0 && pos < m_Items.length);

        unowned Gtk.Widget? widget = m_Items[pos].m_Widget;

        if (widget != null)
        {
            // Remove old widget
            m_Content.remove (widget);

            // Add the new one
            add_widget (inPath, null);
        }
    }
}
