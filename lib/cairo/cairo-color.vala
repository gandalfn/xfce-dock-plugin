/* cairo-color.vala
 *
 * Copyright (C) 2009-2012  Nicolas Bruguier
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

/**
 * Miscellaneous functions for color manipulation
 */
public struct Xdp.CairoColor
{
    // properties
    public double red;
    public double green;
    public double blue;
    public double alpha;

    // static methods
    /**
     * Compute HLS color from RGB color
     *
     * @param inoutRed red component in input hue component on output
     * @param inoutGreen green component in input light component on output
     * @param inoutBlue blue component in input sat component on output
     */
    public static void
    rgb_to_hls (ref double inoutRed, ref double inoutGreen, ref double inoutBlue)
    {
        double min;
        double max;
        double red;
        double green;
        double blue;
        double h, l, s;
        double delta;

        red = inoutRed;
        green = inoutGreen;
        blue = inoutBlue;

        if (red > green)
        {
            if (red > blue)
                max = red;
            else
                max = blue;

            if (green < blue)
                min = green;
            else
                min = blue;
        }
        else
        {
            if (green > blue)
                max = green;
            else
                max = blue;

            if (red < blue)
                min = red;
            else
                min = blue;
        }

        l = (max + min) / 2;
        s = 0;
        h = 0;

        if (max != min)
        {
            if (l <= 0.5)
                s = (max - min) / (max + min);
            else
                s = (max - min) / (2 - max - min);

            delta = max -min;
            if (red == max)
                h = (green - blue) / delta;
            else if (green == max)
                h = 2 + (blue - red) / delta;
            else if (blue == max)
                h = 4 + (red - green) / delta;

            h *= 60;
            if (h < 0.0) h += 360;
        }

        inoutRed = h;
        inoutGreen = l;
        inoutBlue = s;
    }

    /**
     * Compute RGB color from HLS color
     *
     * @param inoutHue hue component in input red component on output
     * @param inoutLightness light component in input green component on output
     * @param inoutSaturation sat component in input blue component on output
     */
    public static void
    hls_to_rgb (ref double inoutHue, ref double inoutLightness, ref double inoutSaturation)
    {
        double hue;
        double lightness;
        double saturation;
        double m1, m2;
        double r, g, b;

        lightness = inoutLightness;
        saturation = inoutSaturation;

        if (lightness <= 0.5)
            m2 = lightness * (1 + saturation);
        else
            m2 = lightness + saturation - lightness * saturation;

        m1 = 2 * lightness - m2;

        if (saturation == 0)
        {
            inoutHue = lightness;
            inoutLightness = lightness;
            inoutSaturation = lightness;
        }
        else
        {
            hue = inoutHue + 120;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                r = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                r = m2;
            else if (hue < 240)
                r = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                r = m1;

            hue = inoutHue;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                g = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                g = m2;
            else if (hue < 240)
                g = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                g = m1;

            hue = inoutHue - 120;
            while (hue > 360)
                hue -= 360;
            while (hue < 0)
                hue += 360;

            if (hue < 60)
                b = m1 + (m2 - m1) * hue / 60;
            else if (hue < 180)
                b = m2;
            else if (hue < 240)
                b = m1 + (m2 - m1) * (240 - hue) / 60;
            else
                b = m1;

            inoutHue = r;
            inoutLightness = g;
            inoutSaturation = b;
        }
    }

    //methods
    public CairoColor (double inRed, double inGreen, double inBlue, double inAlpha = 1.0)
    {
        red = inRed;
        green = inGreen;
        blue = inBlue;
        alpha = inAlpha;
    }

    public CairoColor.from_gdk_color (Gdk.Color inColor)
    {
        red = (double)inColor.red / (double)0xffff;
        green = (double)inColor.green / (double)0xffff;
        blue = (double)inColor.blue / (double)0xffff;
        alpha = 1.0;
    }

    public CairoColor.from_string (string inColor)
    {
        int r, g, b, a;
        int nb = inColor.scanf ("#%02x%02x%02x%02x", out r, out g, out b, out a);

        if (nb >= 3)
        {
            red = (double)r / (double)0xff;
            green = (double)g / (double)0xff;
            blue = (double)b / (double)0xff;
            if (nb == 3)
                alpha = 1.0;
            else
                alpha = (double)a / (double)0xff;
        }
    }

    /**
     * Computes a lighter or darker variant of color
     *
     * @param inColor the color to compute from
     * @param inPercent Shading factor, a factor of 1.0 leaves the color unchanged,
     *                  smaller factors yield darker colors, larger factors
     *                  yield lighter colors.
     *
     * @return the computed color
     */
    public void
    shade (double inPercent)
    {
        rgb_to_hls (ref red, ref green, ref blue);

        green *= inPercent;
        if (green > 1.0)
            green = 1.0;
        else if (green < 0.0)
            green = 0.0;

        blue *= inPercent;
        if (blue > 1.0)
            blue = 1.0;
        else if (blue < 0.0)
            blue = 0.0;

        hls_to_rgb(ref red, ref green, ref blue);
    }

    public string
    to_string ()
    {
        return "#%02x%02x%02x%02x".printf ((int)(red * 0xff),
                                           (int)(green * 0xff),
                                           (int)(blue * 0xff),
                                           (int)(alpha * 0xff));
    }
}
