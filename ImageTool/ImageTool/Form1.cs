using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using System.Drawing.Drawing2D;
using System.Xml;
using System.IO;

namespace ImageTool
{
    public partial class Form1 : Form
    {
        string file;
        List<PixelObject> pixels = new List<PixelObject>();

        public Form1()
        {
            InitializeComponent();
        }

        private void btnOpen_Click(object sender, EventArgs e)
        {
            DialogResult dr = openImage.ShowDialog();
            if (dr == DialogResult.OK)
            {
                pixels.Clear();
                file = openImage.FileName;
                lbPath.Text = file;
                ttPath.SetToolTip(this.lbPath, file);
                getPixel(file);
            }
        }

        private void getPixel(string path)
        {
            Image img = Image.FromFile(path);
            Size s = new Size(183, 133);
            Image fn = resizeImage(img, s);
            Bitmap bm = new Bitmap(fn);

            for (int y = 0; y < bm.Height; y++)
            {
                for (int x = 0; x < bm.Width; x++)
                {
                    Color c = bm.GetPixel(x, y);
                    if (!c.Equals(Color.FromArgb(0)))
                    {
                        PixelObject po = new PixelObject(x, y, c);
                        pixels.Add(po);
                    }
                }
            }
            lbPath.Text = "Done.";
            ttPath.RemoveAll();
            btnExport.Enabled = true;
        }

        private Image resizeImage(Image imgToResize, Size size)
        {
            int sourceWidth = imgToResize.Width;
            int sourceHeight = imgToResize.Height;
            if (sourceHeight <= size.Height && sourceWidth <= size.Width)
            {
                return imgToResize;
            }

            float nPercent = 0;
            float nPercentW = 0;
            float nPercentH = 0;

            nPercentW = ((float)size.Width / (float)sourceWidth);
            nPercentH = ((float)size.Height / (float)sourceHeight);

            if (nPercentH < nPercentW)
                nPercent = nPercentH;
            else
                nPercent = nPercentW;

            int destWidth = (int)(sourceWidth * nPercent);
            int destHeight = (int)(sourceHeight * nPercent);

            Bitmap b = new Bitmap(destWidth, destHeight);
            Graphics g = Graphics.FromImage((Image)b);
            g.InterpolationMode = InterpolationMode.HighQualityBicubic;

            g.DrawImage(imgToResize, 0, 0, destWidth, destHeight);
            g.Dispose();

            return (Image)b;
        }

        private void saveXML(string path)
        {
            using (StreamWriter sw = new StreamWriter(path))
            {
                XmlTextWriter xw = new XmlTextWriter(sw);
                xw.Formatting = Formatting.Indented;
                xw.Indentation = 2;
                xw.WriteStartDocument();
                xw.WriteStartElement("pixeldoc");

                foreach (PixelObject po in pixels)
                {
                    xw.WriteStartElement("pixel");
                    xw.WriteAttributeString("x", po.X.ToString());
                    xw.WriteAttributeString("y", po.Y.ToString());
                    xw.WriteAttributeString("c", string.Format("0x{0:X2}{1:X2}{2:X2}", po.Color.R, po.Color.G, po.Color.B));
                    xw.WriteAttributeString("a", ((float)po.Color.A / 255).ToString());
                    xw.WriteEndElement();
                }

                xw.WriteEndElement();
                xw.Close();
                sw.Close();
            }
        }

        private void btnExport_Click(object sender, EventArgs e)
        {
            DialogResult dr = saveFile.ShowDialog();
            if (dr == DialogResult.OK)
            {
                saveXML(saveFile.FileName);
                lbPath.Text = "XML file saved!";
            }
        }
    }
}
