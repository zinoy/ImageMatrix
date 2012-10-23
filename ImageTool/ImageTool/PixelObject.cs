using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace ImageTool
{
    public class PixelObject
    {
        private int _x;

        public int X
        {
            get { return _x; }
            set { _x = value; }
        }
        private int _y;

        public int Y
        {
            get { return _y; }
            set { _y = value; }
        }
        private Color _color;

        public Color Color
        {
            get { return _color; }
            set { _color = value; }
        }

        public PixelObject(int x, int y, Color color)
        {
            _x = x;
            _y = y;
            _color = color;
        }
    }
}
