/* launcher.vala
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

public class Xdp.Launcher : GLib.Object
{
    // properties
    private Garcon.MenuItem m_Launcher;

    // methods
    public Launcher (string inFilename)
    {
        m_Launcher = new Garcon.MenuItem.for_path (inFilename);
    }

    private string?
    get_command_line (string? inFilename = null)
    {
        string command = m_Launcher.command;

        if (command == null || command == "")
            return null;

        if ("%u" in command)
        {
            command = command.replace ("%u", inFilename == null ? "" : GLib.Shell.quote (inFilename));
        }
        else if ("%U" in command)
        {
            command = command.replace ("%U", inFilename == null ? "" : GLib.Shell.quote (inFilename));
        }
        else if ("%f" in command)
        {
            command = command.replace ("%f", inFilename == null ? "" : GLib.Shell.quote (inFilename));
        }
        else if ("%F" in command)
        {
            command = command.replace ("%F", inFilename == null ? "" : GLib.Shell.quote (inFilename));
        }

        if ("%i" in command)
        {
            command = command.replace ("%i", "--icon " + GLib.Shell.quote (m_Launcher.icon_name));
        }

        if ("%c" in command)
        {
            command = command.replace ("%c", GLib.Shell.quote (m_Launcher.name));
        }

        if ("%k" in command)
        {
            command = command.replace ("%k", GLib.Shell.quote (m_Launcher.get_uri ()));
        }

        return command;
    }

    public Gdk.Pixbuf?
    get_icon (Gtk.IconTheme inTheme)
    {
        Gdk.Pixbuf pixbuf = null;

        try
        {
            pixbuf = inTheme.load_icon (m_Launcher.get_icon_name (), 48, 0);
        }
        catch (GLib.Error err)
        {
            warning ("Error on load %s: %s", m_Launcher.get_icon_name (), err.message);
        }

        return pixbuf;
    }

    public void
    run (string? inFilename = null)
    {
        string? command = get_command_line (inFilename);

        if (command != null)
        {
            try
            {
                Xfce.spawn_command_line_on_screen (Gdk.Screen.get_default (), command,
                                                   m_Launcher.requires_terminal,
                                                   m_Launcher.supports_startup_notification);
            }
            catch (GLib.Error err)
            {
                critical ("Error on launch %s: %s", command, err.message);
            }
        }
    }

    public bool
    match (Wnck.Window inWindow)
    {
        int pid = inWindow.get_pid ();
        GLibTop.proc_args buf;

        string[]? args = GLibTop.get_proc_argv (out buf, pid, 1024);
        string command = get_command_line ();
        if (args != null && command != null)
        {
            string cmd = string.joinv (" ", args);

            if (command.has_prefix (cmd))
            {
                return true;
            }

            string[] command_argv;
            try
            {
                if (GLib.Shell.parse_argv (command, out command_argv))
                {
                    if (command_argv[0] == args[0])
                        return true;
                }
            }
            catch (GLib.Error err)
            {
                warning ("Error on parse %s: %s", command, err.message);
            }

            if (inWindow.get_name () == m_Launcher.name)
                return true;

            if (inWindow.get_class_group ().get_name () == m_Launcher.name)
                return true;

            if (m_Launcher.name == GLib.Path.get_basename (args[0]))
                return true;
        }

        return false;
    }
}
