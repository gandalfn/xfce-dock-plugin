/* libxfconf-0.vapi generated by vapigen-0.10, do not modify. */

[CCode (cprefix = "Xfconf", lower_case_cprefix = "xfconf_")]
namespace Xfconf {
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public class Channel : GLib.Object {
        [CCode (has_construct_function = false)]
        public Channel (string channel_name);
        public static unowned Xfconf.Channel @get (string channel_name);
        public bool get_bool (string property, bool default_value);
        public double get_double (string property, double default_value);
        public int32 get_int (string property, int32 default_value);
        public bool get_named_struct (string property, string struct_name, void* value_struct);
        public unowned GLib.HashTable get_properties (string property_base);
        public bool get_property (string property, GLib.Value value);
        public string get_string (string property, string default_value);
        [CCode (array_null_terminated = true)]
        public string[] get_string_list (string property);
        public GLib.PtrArray get_arrayv (string property);
        [CCode (sentinel = "G_TYPE_INVALID")]
        public bool get_struct (string property, void* value_struct, ...);
        public bool get_structv (string property, void* value_struct, [CCode (array_length_pos = 2)] GLib.Type[] member_types);
        public uint32 get_uint (string property, uint32 default_value);
        public uint64 get_uint64 (string property, uint64 default_value);
        public bool has_property (string property);
        public bool is_property_locked (string property);
        public void reset_property (string property_base, bool recursive);
        public bool set_bool (string property, bool value);
        public bool set_double (string property, double value);
        public bool set_int (string property, int32 value);
        public bool set_named_struct (string property, string struct_name, void* value_struct);
        public bool set_property (string property, GLib.Value value);
        public bool set_string (string property, string value);
        public bool set_string_list (string property, [CCode (type = "const gchar* const*", array_length = false)] string[] values);
        [CCode (sentinel = "G_TYPE_INVALID")]
        public bool set_struct (string property, void* value_struct, ...);
        public bool set_structv (string property, void* value_struct, [CCode (array_length_pos = 2)] GLib.Type[] member_types);
        public bool set_uint (string property, uint32 value);
        public bool set_uint64 (string property, uint64 value);
        [CCode (has_construct_function = false)]
        public Channel.with_property_base (string channel_name, string property_base);
        [NoAccessorMethod]
        public bool is_singleton { get; construct; }
        public virtual signal void property_changed (string p0, GLib.Value p1);
    }
    [Compact]
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public class Property {
        [CCode (cname = "xfconf_g_property_bind")]
        public static ulong bind (Xfconf.Channel channel, string xfconf_property, GLib.Type xfconf_property_type, void* object, string object_property);
        [CCode (cname = "xfconf_g_property_bind_gdkcolor")]
        public static ulong bind_gdkcolor (Xfconf.Channel channel, string xfconf_property, void* object, string object_property);
        [CCode (cname = "xfconf_g_property_unbind")]
        public static void unbind (ulong id);
        [CCode (cname = "xfconf_g_property_unbind_all")]
        public static void unbind_all (void* channel_or_object);
        [CCode (cname = "xfconf_g_property_unbind_by_property")]
        public static void unbind_by_property (Xfconf.Channel channel, string xfconf_property, void* object, string object_property);
    }
    [CCode (cprefix = "XFCONF_ERROR_", cheader_filename = "xfconf/xfconf.h")]
    public errordomain Error {
        UNKNOWN,
        CHANNEL_NOT_FOUND,
        PROPERTY_NOT_FOUND,
        READ_FAILURE,
        WRITE_FAILURE,
        PERMISSION_DENIED,
        INTERNAL_ERROR,
        NO_BACKEND,
        INVALID_PROPERTY,
        INVALID_CHANNEL,
    }
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public static void array_free (GLib.GenericArray arr);
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public static bool init () throws Xfconf.Error;
    [CCode (cheader_filename = "xfconf/xfconf.h", array_length = false)]
    public static string[] list_channels ();
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public static void named_struct_register (string struct_name, [CCode (array_length_pos = 1)] GLib.Type[] member_types);
    [CCode (cheader_filename = "xfconf/xfconf.h")]
    public static void shutdown ();
}
