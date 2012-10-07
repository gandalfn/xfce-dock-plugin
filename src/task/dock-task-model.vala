/* dock-task-model.vala
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

public class Xdp.DockTaskModel : DockModel
{
    // types
    public enum Columns
    {
        WINDOW = DockModel.Columns.LAST,
        LAUNCHER,
        ICON
    }

    // properties
    private unowned Wnck.Screen m_Screen;
    private Gtk.IconTheme       m_Theme;

    // methods
    public DockTaskModel (int inScreen)
    {
        base ({ typeof (Wnck.Window), typeof (Object), typeof (Gdk.Pixbuf) });

        m_Screen = Wnck.Screen.get (inScreen);
        m_Screen.window_opened.connect (on_window_opened);
        m_Screen.window_closed.connect (on_window_closed);
        m_Screen.active_workspace_changed.connect (on_active_workspace_changed);

        Gdk.Screen screen = Gdk.Display.get_default ().get_screen (m_Screen.get_number ());
        m_Theme = Gtk.IconTheme.get_for_screen (screen);
        m_Theme.changed.connect (on_icon_theme_changed);
    }

    private void
    on_icon_theme_changed ()
    {
        Gtk.TreeIter iter;
        if (get_iter_first(out iter))
        {
            do
            {
                Launcher launcher = null;
                get (iter, Columns.LAUNCHER, out launcher);
                if (launcher != null)
                {
                    set (iter, Columns.ICON, launcher.get_icon (m_Theme));
                }
            } while (iter_next(ref iter));
        }
    }

    private void
    on_window_opened (Wnck.Window inWindow)
    {
        if (!inWindow.is_skip_tasklist ())
        {
            bool found = false;
            Gtk.TreeIter iter;
            if (get_iter_first(out iter))
            {
                do
                {
                    Launcher launcher = null;
                    Wnck.Window window = null;
                    get (iter, Columns.LAUNCHER, out launcher, Columns.WINDOW, out window);
                    if (launcher != null)
                    {
                        if (launcher.match (inWindow))
                        {
                            if (window == null)
                            {
                                set (iter, Columns.WINDOW, inWindow, Columns.ICON, inWindow.get_icon ());
                                found = true;
                            }
                            break;
                        }
                    }
                } while (iter_next(ref iter));
            }

            if (!found)
            {
                append (out iter);
                set (iter, Columns.WINDOW, inWindow, Columns.ICON, inWindow.get_icon ());
            }
        }
    }

    private void
    on_window_closed (Wnck.Window inWindow)
    {
        Gtk.TreeIter iter;

        if (get_iter_first(out iter))
        {
            do
            {
                Launcher launcher = null;
                Wnck.Window window;
                get (iter, Columns.WINDOW, out window, Columns.LAUNCHER, out launcher);
                if (window != null && inWindow.get_xid () == window.get_xid ())
                {
                    if (launcher != null)
                    {
                        set (iter, Columns.WINDOW, null, Columns.ICON, launcher.get_icon (m_Theme));
                    }
                    else
                    {
                        remove (iter);
                    }
                    break;
                }
            } while (iter_next(ref iter));
        }
    }

    private void
    on_active_workspace_changed (Wnck.Workspace? inOldWorkspace)
    {
        Gtk.TreeIter iter;

        if (get_iter_first(out iter))
        {
            unowned Wnck.Workspace current = m_Screen.get_active_workspace ();

            do
            {
                Wnck.Window window;
                get (iter, Columns.WINDOW, out window);
                if (window != null)
                {
                    if (window.is_on_workspace (current))
                    {
                        row_changed (get_path (iter), iter);
                    }
                    else if (inOldWorkspace != null && window.is_on_workspace (inOldWorkspace))
                    {
                        row_changed (get_path (iter), iter);
                    }
                }
            } while (iter_next(ref iter));
        }
    }

    public void
    add_launcher (string inFilename)
    {
        Launcher launcher = new Launcher (inFilename);

        Gtk.TreeIter iter;
        append (out iter);
        set (iter, Columns.LAUNCHER, launcher, Columns.ICON, launcher.get_icon (m_Theme));
    }
}
