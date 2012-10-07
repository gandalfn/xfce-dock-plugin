/* dock-task-plugin.vala
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

public class Xdp.DockTaskPlugin : DockPlugin
{
    // methods
    public override void
    @construct ()
    {
        Xfce.textdomain (Config.GETTEXT_PACKAGE, Config.LOCALE_DIR);

        expand = true;
        shrink = false;

        Xdp.DockTaskModel model = new Xdp.DockTaskModel (0);
        view = new Xdp.DockView (model);
        view.cell = new Xdp.DockCellTask (this);
        view.set_attribute ("window", Xdp.DockTaskModel.Columns.WINDOW);
        view.set_attribute ("launcher", Xdp.DockTaskModel.Columns.LAUNCHER);
        view.set_attribute ("pixbuf", Xdp.DockTaskModel.Columns.ICON);
        view.show ();
        add (view);

        add_action_widget (view);

        load_config ();

        menu_show_about ();
        about.connect (() => {
                Gtk.show_about_dialog (null,
                    "program-name", "Dock Task Plugin",
                    "comments", "Dock task plugin for the Xfce 4.10 Panel",
                    null);
            });
    }

    private void
    load_config ()
    {
        unowned string? file = "/home/gandalfn/.config/xfce4/panel/dock-plugin.rc";
        if (file != null)
        {
            Xfce.Rc rc = new Xfce.Rc (file, false);

            view.expand_begin = rc.read_bool_entry ("expand_begin", false);
            view.expand_end = rc.read_bool_entry ("expand_end", true);
            view.bottom_padding = rc.read_int_entry ("bottom_padding", 3);
            view.item_spacing = rc.read_int_entry ("item_spacing", 2);
            string[]? launchers = rc.read_list_entry ("launchers", ",");
            if (launchers != null)
            {
                foreach (unowned string filename in launchers)
                {
                    (view.model as Xdp.DockTaskModel).add_launcher (filename);
                }
            }
        }
    }
}

[ModuleInit]
public Type
xfce_panel_module_init (TypeModule module)
{
    return typeof (Xdp.DockTaskPlugin);
}
