namespace ImageTool
{
    partial class Form1
    {
        /// <summary>
        /// 必需的设计器变量。
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// 清理所有正在使用的资源。
        /// </summary>
        /// <param name="disposing">如果应释放托管资源，为 true；否则为 false。</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }

        #region Windows 窗体设计器生成的代码

        /// <summary>
        /// 设计器支持所需的方法 - 不要
        /// 使用代码编辑器修改此方法的内容。
        /// </summary>
        private void InitializeComponent()
        {
            this.components = new System.ComponentModel.Container();
            this.openImage = new System.Windows.Forms.OpenFileDialog();
            this.saveFile = new System.Windows.Forms.SaveFileDialog();
            this.btnOpen = new System.Windows.Forms.Button();
            this.lbPath = new System.Windows.Forms.Label();
            this.btnExport = new System.Windows.Forms.Button();
            this.ttPath = new System.Windows.Forms.ToolTip(this.components);
            this.SuspendLayout();
            // 
            // openImage
            // 
            this.openImage.FileName = "openFileDialog1";
            this.openImage.Filter = "Images|*.bmp;*.gif;*.jpg;*.png|All files|*.*";
            this.openImage.Title = "Open Image";
            // 
            // saveFile
            // 
            this.saveFile.Filter = "XML File|*.xml";
            this.saveFile.Title = "Export XML";
            // 
            // btnOpen
            // 
            this.btnOpen.Location = new System.Drawing.Point(13, 13);
            this.btnOpen.Name = "btnOpen";
            this.btnOpen.Size = new System.Drawing.Size(75, 23);
            this.btnOpen.TabIndex = 0;
            this.btnOpen.Text = "Open";
            this.btnOpen.UseVisualStyleBackColor = true;
            this.btnOpen.Click += new System.EventHandler(this.btnOpen_Click);
            // 
            // lbPath
            // 
            this.lbPath.AutoEllipsis = true;
            this.lbPath.Location = new System.Drawing.Point(12, 55);
            this.lbPath.Name = "lbPath";
            this.lbPath.Size = new System.Drawing.Size(268, 13);
            this.lbPath.TabIndex = 1;
            this.lbPath.Text = "No such file.";
            // 
            // btnExport
            // 
            this.btnExport.Enabled = false;
            this.btnExport.Location = new System.Drawing.Point(94, 13);
            this.btnExport.Name = "btnExport";
            this.btnExport.Size = new System.Drawing.Size(75, 23);
            this.btnExport.TabIndex = 0;
            this.btnExport.Text = "Export";
            this.btnExport.UseVisualStyleBackColor = true;
            this.btnExport.Click += new System.EventHandler(this.btnExport_Click);
            // 
            // Form1
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(292, 79);
            this.Controls.Add(this.lbPath);
            this.Controls.Add(this.btnExport);
            this.Controls.Add(this.btnOpen);
            this.FormBorderStyle = System.Windows.Forms.FormBorderStyle.FixedDialog;
            this.MaximizeBox = false;
            this.Name = "Form1";
            this.Text = "ImageTool";
            this.ResumeLayout(false);

        }

        #endregion

        private System.Windows.Forms.OpenFileDialog openImage;
        private System.Windows.Forms.SaveFileDialog saveFile;
        private System.Windows.Forms.Button btnOpen;
        private System.Windows.Forms.Label lbPath;
        private System.Windows.Forms.Button btnExport;
        private System.Windows.Forms.ToolTip ttPath;
    }
}

