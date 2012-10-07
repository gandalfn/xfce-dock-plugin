/* dock-item.vala
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

internal class Xdp.DockItem : GLib.InitiallyUnowned
{
    // properties
    private unowned DockView m_View      = null;
    private Cairo.Rectangle  m_Geometry  = Cairo.Rectangle ();
    private bool             m_Deleted   = false;
    private bool             m_MouseOver = false;

    // accessor
    public double x {
        get {
            return m_Geometry.x;
        }
        set {
            m_Geometry.x = value;
        }
    }

    public double y {
        get {
            return m_Geometry.y;
        }
        set {
            m_Geometry.y = value;
        }
    }

    public double width {
        get {
            return m_Geometry.width;
        }
        set {
            m_Geometry.width = value;
        }
    }

    public double height {
        get {
            return m_Geometry.height;
        }
        set {
            m_Geometry.height = value;
        }
    }

    public bool deleted {
        get {
            return m_Deleted;
        }
        set {
            m_Deleted = value;
            destroyed (this);
        }
    }

    public bool mouse_is_over {
        get {
            return m_MouseOver;
        }
        set {
            if (m_MouseOver != value)
            {
                m_MouseOver = value;

                if (m_View.cell != null)
                {
                    Gtk.TreeIter iter;

                    if (m_View.model.get_iter (out iter, path))
                    {
                        unowned GLib.HashTable<string, uint> attributes = m_View.attributes;
                        foreach (unowned string name in attributes.get_keys ())
                        {
                            GLib.Value val;
                            m_View.model.get_value (iter, (int)attributes[name], out val);

                            m_View.cell.set_property (name, val);
                        }
                    }

                    m_View.cell.mouse_is_over = m_MouseOver;
                    if (m_MouseOver)
                        m_View.cell.enter_notify ();
                    else
                        m_View.cell.leave_notify ();
                }
            }
        }
    }
    public int  indice        { get; set; default = -1; }

    public Gtk.TreePath? path {
        owned get {
            return indice >= 0 ? new Gtk.TreePath.from_string ("%i".printf (indice)) : null;
        }
    }

    // signals
    public signal void destroyed (DockItem inItem);

    // methods
    public DockItem (DockView inDockView, int inIndice)
    {
        m_View = inDockView;
        indice = inIndice;
    }

    public void
    click_notify ()
    {
        if (m_View.cell != null)
        {
            Gtk.TreeIter iter;

            if (m_View.model.get_iter (out iter, path))
            {
                unowned GLib.HashTable<string, uint> attributes = m_View.attributes;
                foreach (unowned string name in attributes.get_keys ())
                {
                    GLib.Value val;
                    m_View.model.get_value (iter, (int)attributes[name], out val);

                    m_View.cell.set_property (name, val);
                }
            }

            m_View.cell.mouse_is_over = m_MouseOver;
            m_View.cell.click_notify ();
        }
    }

    public void
    paint (CairoContext inCtx)
    {
        if (m_Geometry.width > 0 && m_Geometry.height > 0 && indice >= 0)
        {
            inCtx.save ();
            {
                inCtx.rectangle (m_Geometry.x, m_Geometry.y, m_Geometry.width, m_Geometry.height);
                inCtx.clip ();
                inCtx.translate (m_Geometry.x, m_Geometry.y);

                if (m_View.cell != null)
                {
                    Gtk.TreeIter iter;

                    if (m_View.model.get_iter (out iter, path))
                    {
                        unowned GLib.HashTable<string, uint> attributes = m_View.attributes;
                        foreach (unowned string name in attributes.get_keys ())
                        {
                            GLib.Value val;
                            m_View.model.get_value (iter, (int)attributes[name], out val);

                            m_View.cell.set_property (name, val);
                        }
                    }

                    m_View.cell.mouse_is_over = mouse_is_over;
                    m_View.cell.render (inCtx, { 0.0, 0.0, m_Geometry.width, m_Geometry.height });
                }
            }
            inCtx.restore ();
        }
    }

    public void
    queue_draw ()
    {
        m_View.content.queue_draw_area ((int)m_Geometry.x, (int)m_Geometry.y,
                                        (int)m_Geometry.width, (int)m_Geometry.height);
    }
}
