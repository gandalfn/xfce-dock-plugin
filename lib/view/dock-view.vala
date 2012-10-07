/* dock-view.vala
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

public class Xdp.DockView : Gtk.Frame
{
    // types
    private struct Color
    {
        public Gdk.Color color;
        public double    alpha;

        public Color (string inValue, uint inAlpha = 255)
        {
            Gdk.Color.parse (inValue, out color);
            alpha = (double)inAlpha / 255.0;
        }
    }

    // properties
    private DockModel                    m_Model;
    private GLib.List<DockItem>          m_Items = new GLib.List<DockItem> ();
    private DockCell                     m_Cell;
    private GLib.HashTable<string, uint> m_Attributes = new GLib.HashTable<string, uint> (GLib.str_hash, GLib.str_equal);
    private Xfce.HVBox                   m_Box;
    private Gtk.Alignment                m_Align;
    private Gtk.EventBox                 m_Content;
    private Gtk.Label                    m_Border[2];
    private int                          m_Size = -1;
    private Gtk.Orientation              m_Orientation = Gtk.Orientation.HORIZONTAL;
    private uint                         m_ItemSpacing = 0;
    private unowned DockItem?            m_ItemMouseOver = null;
    private uint                         m_CellSizeRequest = 32;

    // accessors
    internal GLib.HashTable<string, uint> attributes {
        get {
            return m_Attributes;
        }
    }

    internal Gtk.Widget content {
        get {
            return m_Content;
        }
    }

    public Gdk.Rectangle content_allocation {
        get {
            Gdk.Rectangle area = Gdk.Rectangle ();
            area.x = m_Content.allocation.x + (int)left_padding;
            area.y = m_Content.allocation.y + (int)top_padding;
            area.width = m_Content.allocation.width;
            area.height = m_Content.allocation.height;
            return area;
        }
    }

    [CCode (notify = false)]
    public DockModel model {
        get {
            return m_Model;
        }
        construct set {
            if (m_Model != null)
            {
                m_Model.row_inserted.disconnect(on_row_inserted);
                m_Model.row_deleted.disconnect(on_row_deleted);
                m_Model.rows_reordered.disconnect(on_rows_reordered);
                m_Model.row_changed.disconnect(on_row_changed);
            }

            m_Model = value;

            if (m_Model != null)
            {
                m_Model.row_inserted.connect(on_row_inserted);
                m_Model.row_deleted.connect(on_row_deleted);
                m_Model.rows_reordered.connect(on_rows_reordered);
                m_Model.row_changed.connect(on_row_changed);
            }
        }
    }

    [CCode (notify = false)]
    public DockCell? cell {
        get {
            return m_Cell;
        }
        set {
            m_Cell = value;
        }
    }

    [CCode (notify = false)]
    public int size {
        get {
            return m_Size;
        }
        set {
            if (m_Size != value)
            {
                m_Size = value;
                queue_resize ();
            }
        }
    }

    [CCode (notify = false)]
    public Gtk.Orientation orientation {
        get {
            return m_Orientation;
        }
        set {
            if (m_Orientation != value)
            {
                m_Orientation = value;
                queue_resize ();
            }
        }
    }

    [CCode (notify = false)]
    public uint left_padding {
        get {
            return m_Align.left_padding;
        }
        set {
            m_Align.left_padding = value;
        }
    }

    [CCode (notify = false)]
    public uint right_padding {
        get {
            return m_Align.right_padding;
        }
        set {
            m_Align.right_padding = value;
        }
    }

    [CCode (notify = false)]
    public uint top_padding {
        get {
            return m_Align.top_padding;
        }
        set {
            m_Align.top_padding = value;
        }
    }

    [CCode (notify = false)]
    public uint bottom_padding {
        get {
            return m_Align.bottom_padding;
        }
        set {
            m_Align.bottom_padding = value;
        }
    }

    [CCode (notify = false)]
    public uint item_spacing {
        get {
            return m_ItemSpacing;
        }
        set {
            if (m_ItemSpacing != value)
            {
                m_ItemSpacing = value;
                queue_resize ();
            }
        }
    }

    [CCode (notify = false)]
    public bool expand_begin {
        get {
            bool expand, fill;
            uint padding;
            Gtk.PackType pack;

            m_Box.query_child_packing (m_Border[0], out expand, out fill, out padding, out pack);
            return expand;
        }
        set {
            bool expand, fill;
            uint padding;
            Gtk.PackType pack;

            m_Box.query_child_packing (m_Border[0], out expand, out fill, out padding, out pack);
            m_Box.set_child_packing (m_Border[0], value, fill, padding, pack);
        }
    }

    [CCode (notify = false)]
    public bool expand_end {
        get {
            bool expand, fill;
            uint padding;
            Gtk.PackType pack;

            m_Box.query_child_packing (m_Border[1], out expand, out fill, out padding, out pack);
            return expand;
        }
        set {
            bool expand, fill;
            uint padding;
            Gtk.PackType pack;

            m_Box.query_child_packing (m_Border[1], out expand, out fill, out padding, out pack);
            m_Box.set_child_packing (m_Border[1], value, fill, padding, pack);
        }
    }

    // methods
    construct
    {
        Gdk.Display display = Gdk.Display.get_default();
        Gdk.Screen screen = display.get_default_screen();

        shadow = Gtk.ShadowType.NONE;

        // set widget properties
        set_flags(Gtk.WidgetFlags.NO_WINDOW);
        set_colormap(screen.get_rgba_colormap());

        // Create main box
        m_Box = new Xfce.HVBox (m_Orientation, false, 0);
        m_Box.show ();
        add (m_Box);

        // Create borders
        m_Border[0] = new Gtk.Label (null);
        m_Border[0].show ();
        m_Border[1] = new Gtk.Label (null);
        m_Border[1].show ();

        // Create alignment for adjustment space
        m_Align = new Gtk.Alignment (0.5f, 0.5f, 1.0f, 1.0f);
        m_Align.show ();
        m_Box.pack_start (m_Border[0], false, true, 0);
        m_Box.pack_start (m_Align, false, true, 0);
        m_Box.pack_start (m_Border[1], false, true, 0);

        // Create event box for content
        m_Content = new Gtk.EventBox ();
        m_Content.above_child = true;
        m_Content.visible_window = true;
        m_Content.set_app_paintable (true);
        m_Content.set_colormap(screen.get_rgba_colormap());

        // Set lambda methods for event box compositing
        m_Content.realize.connect ((w) => {
            w.window.set_composited (true);
        });
        m_Content.expose_event.connect (on_content_expose_event);

        // add events to content
        m_Content.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK |
                              Gdk.EventMask.LEAVE_NOTIFY_MASK |
                              Gdk.EventMask.POINTER_MOTION_MASK);

        // connect onto button press event
        m_Content.button_press_event.connect (on_content_button_press_event);

        // connect onto enter/leave events
        m_Content.enter_notify_event.connect (on_content_enter_notify_event);
        m_Content.leave_notify_event.connect (on_content_leave_notify_event);

        // connect onto motion notify event
        m_Content.motion_notify_event.connect (on_content_motion_notify_event);

        // Add event box to view
        m_Content.show ();
        m_Align.add (m_Content);

        // Conect after expose to draw composited widgets
        Signal.connect_after(this, "expose_event", (GLib.Callback)on_expose_event, this);
    }

    public DockView (DockModel inModel)
    {
        GLib.Object (model: inModel);
    }

    private inline unowned DockItem?
    get_item_at_pos (double inX, double inY)
    {
        unowned DockItem? ret = null;

        foreach (unowned DockItem? item in m_Items)
        {
            if (inX >= item.x && inX <= item.x + item.width &&
                inY >= item.y && inY <= item.y + item.height)
            {
                return item;
            }
        }
        return ret;
    }

    private inline void
    resize_content ()
    {
        unowned GLib.List<DockItem> last = m_Items.last ();

        if (m_Orientation == Gtk.Orientation.HORIZONTAL)
            m_Content.set_size_request ((int)((last.data as DockItem).x + (last.data as DockItem).width + m_ItemSpacing),
                                        (int)(last.data as DockItem).height);
        else
            m_Content.set_size_request ((int)(last.data as DockItem).width,
                                        (int)((last.data as DockItem).y + (last.data as DockItem).height + m_ItemSpacing));
    }

    private void
    add_item (GLib.List<DockItem>? inPos, int inIndice)
    {
        double x = 0;
        double y = 0;
        double width = m_CellSizeRequest;
        double height = m_CellSizeRequest;

        if (inPos != null)
        {
            x = (inPos.data as DockItem).x;
            y = (inPos.data as DockItem).y;
        }
        else if (m_Items.last () != null)
        {
            unowned GLib.List<DockItem> last = m_Items.last ();
            if (m_Orientation == Gtk.Orientation.HORIZONTAL)
            {
                x = (last.data as DockItem).x + (last.data as DockItem).width + m_ItemSpacing;
                y = (last.data as DockItem).y;
            }
            else
            {
                x = (last.data as DockItem).x;
                y = (last.data as DockItem).y + (last.data as DockItem).height + m_ItemSpacing;
            }
        }

        DockItem new_item = new DockItem (this, inIndice);
        new_item.destroyed.connect (on_item_destroyed);

        new_item.x = x;
        new_item.y = y;
        new_item.width = width;
        new_item.height = height;

        for (unowned GLib.List<DockItem>? item = inPos; item != null; item = item.next)
        {
            (item.data as DockItem).indice = (item.data as DockItem).indice + 1;
            if (m_Orientation == Gtk.Orientation.HORIZONTAL)
            {
                (item.data as DockItem).x += new_item.width + m_ItemSpacing;
            }
            else
            {
                (item.data as DockItem).y += new_item.height + m_ItemSpacing;
            }
        }

        m_Items.insert_before (inPos, new_item);

        m_Content.queue_draw_area ((int)new_item.x, (int)new_item.y, (int)width, (int)height);

        resize_content ();
    }

    private void
    on_row_inserted (Gtk.TreePath inPath, Gtk.TreeIter inIter)
    {
        bool append = false;
        int indice = inPath.get_indices ()[0];

        if (m_Items != null)
        {
            for (unowned GLib.List<DockItem>? item = m_Items.last (); item != null; item = item.prev)
            {
                unowned DockItem dock_item = (DockItem)item.data;
                if (dock_item.indice <= indice)
                {
                    add_item (item.next, indice);
                    append = true;
                    break;
                }
            }
        }

        if (!append)
        {
            add_item (null, indice);
        }
    }

    private void
    on_row_changed (Gtk.TreePath inPath, Gtk.TreeIter inIter)
    {
        int indice = inPath.get_indices ()[0];
        foreach (unowned DockItem item in m_Items)
        {
            if (!item.deleted && item.indice == indice)
            {
                item.queue_draw ();
                break;
            }
        }
    }

    private void
    on_row_deleted (Gtk.TreePath inPath)
    {
        int indice = inPath.get_indices ()[0];
        foreach (unowned DockItem item in m_Items)
        {
            if (!item.deleted && item.indice == indice)
            {
                item.queue_draw ();
                item.deleted = true;
                break;
            }
        }
    }

    private void
    on_rows_reordered (Gtk.TreePath inPath, Gtk.TreeIter? inIter, void* inNewOrder)
    {
    }

    private void
    on_item_destroyed (DockItem inItem)
    {
        unowned GLib.List<DockItem> pos = m_Items.find (inItem);
        if (pos != null)
        {
            for (unowned GLib.List<DockItem> item = pos.next; item != null; item = item.next)
            {
                (item.data as DockItem).indice = (item.data as DockItem).indice - 1;
                if (m_Orientation == Gtk.Orientation.HORIZONTAL)
                {
                    (item.data as DockItem).x -= (pos.data as DockItem).width + m_ItemSpacing;
                }
                else
                {
                    (item.data as DockItem).y -= (pos.data as DockItem).height + m_ItemSpacing;
                }
            }

            m_Items.delete_link (pos);

            resize_content ();
        }
    }

    private bool
    on_content_button_press_event (Gdk.EventButton inEvent)
    {
        if (inEvent.button == 1)
        {
            unowned DockItem? item = get_item_at_pos (inEvent.x, inEvent.y);
            if (item != null)
            {
                item.click_notify ();
            }
        }

        return true;
    }

    private bool
    on_content_enter_notify_event (Gdk.EventCrossing inEvent)
    {
        m_ItemMouseOver = get_item_at_pos (inEvent.x, inEvent.y);
        if (m_ItemMouseOver != null)
        {
            m_ItemMouseOver.mouse_is_over = true;
            m_ItemMouseOver.queue_draw ();
        }

        return true;
    }

    private bool
    on_content_leave_notify_event (Gdk.EventCrossing inEvent)
    {
        if (m_ItemMouseOver != null)
        {
            m_ItemMouseOver.mouse_is_over = false;
            m_ItemMouseOver.queue_draw ();
        }
        m_ItemMouseOver = null;

        return true;
    }

    private bool
    on_content_motion_notify_event (Gdk.EventMotion inEvent)
    {
        unowned DockItem? item = get_item_at_pos (inEvent.x, inEvent.y);
        if (item != null)
        {
            if (item != m_ItemMouseOver)
            {
                if (m_ItemMouseOver != null)
                {
                    m_ItemMouseOver.mouse_is_over = false;
                    m_ItemMouseOver.queue_draw ();
                }
                m_ItemMouseOver = item;
                m_ItemMouseOver.mouse_is_over = true;
                m_ItemMouseOver.queue_draw ();
            }
        }
        else if (m_ItemMouseOver != null)
        {
            m_ItemMouseOver.mouse_is_over = false;
            m_ItemMouseOver.queue_draw ();
            m_ItemMouseOver = null;
        }

        return true;
    }

    private bool
    on_content_expose_event (Gdk.EventExpose inEvent)
    {
        CairoContext ctx = new CairoContext.from_widget (m_Content);

        // Clear background
        ctx.set_operator(Cairo.Operator.CLEAR);
        Gdk.cairo_region (ctx, inEvent.region);
        ctx.fill ();

        // Paint items
        Gdk.Rectangle rect = Gdk.Rectangle ();
        ctx.set_operator(Cairo.Operator.OVER);
        foreach (unowned DockItem item in m_Items)
        {
            rect.x = (int)item.x;
            rect.y = (int)item.y;
            rect.width = (int)item.width;
            rect.height = (int)item.height;
            if (inEvent.region.rect_in (rect) != Gdk.OverlapType.OUT)
            {
                item.paint (ctx);
            }
        }

        return true;
    }

    [CCode (instance_pos = -1)]
    private bool
    on_expose_event (Gtk.Widget inWidget, Gdk.EventExpose inEvent)
    {
        // Clear background
        CairoContext ctx = new CairoContext.from_widget (inWidget);
        Gdk.cairo_region (ctx, inEvent.region);
        ctx.clip ();

        ctx.set_operator(Cairo.Operator.OVER);

        // Paint content box
        CairoContext content_ctx = new CairoContext.from_widget (m_Content);
        ctx.set_source_surface(content_ctx.get_target(), m_Content.allocation.x, m_Content.allocation.y);
        ctx.paint();

        return true;
    }

    internal override void
    size_request (out Gtk.Requisition outRequisition)
    {
        base.size_request (out outRequisition);

        if (m_Orientation == Gtk.Orientation.HORIZONTAL)
        {
            double min_width = (m_Cell.min_width * m_Items.length ()) +
                               (m_ItemSpacing * (m_Items.length () - 1)) +
                                m_Align.left_padding + m_Align.right_padding;

            if (m_Size < min_width)
                outRequisition.width = (int)min_width;
            else
                outRequisition.width = m_Size;
        }
        else
        {
            double min_height = (m_Cell.min_height * m_Items.length ()) +
                                (m_ItemSpacing * (m_Items.length () - 1)) +
                                 m_Align.top_padding + m_Align.bottom_padding;

            if (m_Size < min_height)
                outRequisition.height = (int)min_height;
            else
                outRequisition.height = m_Size;
        }
    }

    internal override void
    size_allocate (Gdk.Rectangle inAllocation)
    {
        base.size_allocate (inAllocation);

        if (m_Orientation == Gtk.Orientation.HORIZONTAL)
        {
            double width_request = inAllocation.width -
                                   ((m_ItemSpacing * (m_Items.length () - 1)) +
                                    m_Align.left_padding + m_Align.right_padding);
            width_request /= m_Items.length ();

            m_CellSizeRequest = (uint)double.min (inAllocation.height -
                                                  (m_Align.top_padding + m_Align.bottom_padding),
                                                  width_request);
            m_Content.set_size_request ((int)((m_CellSizeRequest * m_Items.length ()) +
                                              double.max(0, m_ItemSpacing * (m_Items.length () - 1))), -1);

            double x = 0;
            double y = 0;

            foreach (unowned DockItem item in m_Items)
            {
                item.x = x;
                item.y = y;
                item.width = (double)m_CellSizeRequest;
                item.height = (double)m_CellSizeRequest;

                x += item.width + m_ItemSpacing;
            }
        }
        else
        {
            double height_request = inAllocation.height -
                                   ((m_ItemSpacing * (m_Items.length () - 1)) +
                                    m_Align.top_padding + m_Align.bottom_padding);
            height_request /= m_Items.length ();

            m_CellSizeRequest = (uint)double.min (inAllocation.width -
                                                  (m_Align.right_padding + m_Align.left_padding),
                                                  height_request);
            m_Content.set_size_request (-1, (int)((m_CellSizeRequest * m_Items.length ()) +
                                                  double.max(0, m_ItemSpacing * (m_Items.length () - 1))));

            double x = 0;
            double y = 0;

            foreach (unowned DockItem item in m_Items)
            {
                item.x = x;
                item.y = y;
                item.width = (double)m_CellSizeRequest;
                item.height = (double)m_CellSizeRequest;

                y += item.height + m_ItemSpacing;
            }
        }
    }

    public void
    set_attribute (string inName, uint inColumn)
    {
        m_Attributes.insert (inName, inColumn);
    }
}
