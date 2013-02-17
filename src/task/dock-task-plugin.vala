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
        Xfconf.Channel channel = new Xfconf.Channel.with_property_base (Xfce.panel_get_channel_name (), get_property_base ());
        view.expand_begin = channel.get_bool ("/expand_begin", false);
        view.expand_end = channel.get_bool ("/expand_end", true);
        view.bottom_padding = channel.get_int ("/bottom_padding", 3);
        view.item_spacing = channel.get_int ("/item_spacing", 2);
        string[] launchers = channel.get_string_list ("/launchers");
        foreach (string filename in launchers)
        {
            (view.model as Xdp.DockTaskModel).add_launcher (filename);
        }
    }
}

[ModuleInit]
public Type
xfce_panel_module_init (TypeModule module)
{
    return typeof (Xdp.DockTaskPlugin);
}
