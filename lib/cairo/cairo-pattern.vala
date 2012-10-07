/* cairo-pattern.vala
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

public class Xdp.CairoPattern : Cairo.Pattern
{
    public CairoPattern (Cairo.Surface inSurface)
    {
        base.for_surface (inSurface);
    }

    public CairoPattern.for_surface (Cairo.Surface inSurface)
    {
        base.for_surface (inSurface);
    }

    public CairoPattern.rgb (double inRed, double inGreen, double inBlue)
    {
        base.rgb(inRed, inGreen, inBlue);
    }

    public CairoPattern.rgba (double inRed, double inGreen, double inBlue,
                              double inAlpha)
    {
        base.rgba(inRed, inGreen, inBlue, inAlpha);
    }

    public CairoPattern.linear (double inX0, double inY0,
                                double inX1, double inY1)
    {
        base.linear(inX0, inY0, inX1, inY1);
    }

    public CairoPattern.radial (double inCx0, double inCy0, double inRadius0,
                                double inCx1, double inCy1, double inRadius1)
    {
        base.radial (inCx0, inCy0, inRadius0, inCx1, inCy1, inRadius1);
    }

    public void
    add_color_stop (double inPos, CairoColor inColor)
    {
        add_color_stop_rgba(inPos, inColor.red, inColor.green, inColor.blue,
                            inColor.alpha);
    }

    public void
    add_color_stop_alpha (double inPos, CairoColor inColor, double inAlpha)
    {
        add_color_stop_rgba(inPos, inColor.red, inColor.green, inColor.blue,
                            inColor.alpha * inAlpha);
    }
}
