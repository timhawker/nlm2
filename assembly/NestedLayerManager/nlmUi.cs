using System;
using System.Windows.Forms;
using System.Drawing;
namespace NestedLayerManager
{
    //Classes for User Interface controls
    namespace UI
    {
        public class TopPanel : Panel
        {

            //----------------------------------------------------------------------------
            // Build Controls
            //----------------------------------------------------------------------------

            Button btn_createLayer = new Button();
            Button btn_createFolder = new Button();
            Button btn_deleteSelected = new Button();
            Button btn_addSelObjToLyr = new Button();
            Button btn_selObjWiSelLyrFdr = new Button();
            Button btn_selLyrFdrOfSelObj = new Button();
            Button btn_hideUnhideAll = new Button();
            Button btn_freezeUnfreezeAll = new Button();
            Button btn_collapseExpandAll = new Button();
            Button btn_info = new Button();
            Button btn_settings = new Button();
            TextBox tbx_searchBar = new TextBox();

            //When TopPanel is created, customise all controls
            public TopPanel()
            {

                //----------------------------------------------------------------------------
                // Customise Panel
                //----------------------------------------------------------------------------

                this.Dock = DockStyle.Top;
                this.Height = 55;


                //----------------------------------------------------------------------------
                // Customise Buttons
                //----------------------------------------------------------------------------

                Size btnSize = new Size(27, 27);
                int ChromeWidth = SystemInformation.FrameBorderSize.Width;
                int btnGap = 28;
                int btnHposL = -23;
                int btnHPosR = this.Width - 4 - 2 * ChromeWidth;
                int margin = 5;

                //Create Layer
                btn_createLayer.Location = new Point(btnHposL += btnGap, margin);
                btn_createLayer.Size = btnSize;
                btn_createLayer.FlatStyle = FlatStyle.Flat;
                btn_createLayer.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_createLayer.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_createLayer.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_createLayer.ImageAlign = ContentAlignment.MiddleCenter;
                btn_createLayer.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.createLayer.png"));
                btn_createLayer.Name = "CreateLayer";
                btn_createLayer.MouseEnter += new EventHandler(btnMouseEnter);
                btn_createLayer.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_createLayer);

                //Create Folder
                btn_createFolder.Location = new Point(btnHposL += btnGap, margin);
                btn_createFolder.Size = btnSize;
                btn_createFolder.FlatStyle = FlatStyle.Flat;
                btn_createFolder.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_createFolder.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_createFolder.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_createFolder.ImageAlign = ContentAlignment.MiddleCenter;
                btn_createFolder.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.createFolder.png"));
                btn_createFolder.Name = "CreateFolder";
                btn_createFolder.MouseEnter += new EventHandler(btnMouseEnter);
                btn_createFolder.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_createFolder);

                //Delete Selected
                btn_deleteSelected.Location = new Point(btnHposL += btnGap, margin);
                btn_deleteSelected.Size = btnSize;
                btn_deleteSelected.FlatStyle = FlatStyle.Flat;
                btn_deleteSelected.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_deleteSelected.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_deleteSelected.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_deleteSelected.ImageAlign = ContentAlignment.MiddleCenter;
                btn_deleteSelected.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.delete.png"));
                btn_deleteSelected.Name = "DeleteSelected";
                btn_deleteSelected.MouseEnter += new EventHandler(btnMouseEnter);
                btn_deleteSelected.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_deleteSelected);


                //Add Selected Objects to Selected Layer
                btn_addSelObjToLyr.Location = new Point(btnHposL += btnGap, margin);
                btn_addSelObjToLyr.Size = btnSize;
                btn_addSelObjToLyr.FlatStyle = FlatStyle.Flat;
                btn_addSelObjToLyr.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_addSelObjToLyr.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_addSelObjToLyr.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_addSelObjToLyr.ImageAlign = ContentAlignment.MiddleCenter;
                btn_addSelObjToLyr.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.addToLayer.png"));
                btn_addSelObjToLyr.Name = "AddSelObjToLyr";
                btn_addSelObjToLyr.MouseEnter += new EventHandler(btnMouseEnter);
                btn_addSelObjToLyr.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_addSelObjToLyr);

                //Select Objects within Selected Layers/Folders
                btn_selObjWiSelLyrFdr.Location = new Point(btnHposL += btnGap, margin);
                btn_selObjWiSelLyrFdr.Size = btnSize;
                btn_selObjWiSelLyrFdr.FlatStyle = FlatStyle.Flat;
                btn_selObjWiSelLyrFdr.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_selObjWiSelLyrFdr.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_selObjWiSelLyrFdr.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_selObjWiSelLyrFdr.ImageAlign = ContentAlignment.MiddleCenter;
                btn_selObjWiSelLyrFdr.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.whichObjects.png"));
                btn_selObjWiSelLyrFdr.Name = "SelObjWiSelLyrFdr";
                btn_selObjWiSelLyrFdr.MouseEnter += new EventHandler(btnMouseEnter);
                btn_selObjWiSelLyrFdr.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_selObjWiSelLyrFdr);

                //Select Layers of Selected Objects
                btn_selLyrFdrOfSelObj.Location = new Point(btnHposL += btnGap, margin);
                btn_selLyrFdrOfSelObj.Size = btnSize;
                btn_selLyrFdrOfSelObj.FlatStyle = FlatStyle.Flat;
                btn_selLyrFdrOfSelObj.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_selLyrFdrOfSelObj.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_selLyrFdrOfSelObj.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_selLyrFdrOfSelObj.ImageAlign = ContentAlignment.MiddleCenter;
                btn_selLyrFdrOfSelObj.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.whichLayers.png"));
                btn_selLyrFdrOfSelObj.Name = "SelLyrFdrOfSelObj";
                btn_selLyrFdrOfSelObj.MouseEnter += new EventHandler(btnMouseEnter);
                btn_selLyrFdrOfSelObj.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_selLyrFdrOfSelObj);

                //Hide/Unhide All
                btn_hideUnhideAll.Location = new Point(btnHposL += btnGap, margin);
                btn_hideUnhideAll.Size = btnSize;
                btn_hideUnhideAll.FlatStyle = FlatStyle.Flat;
                btn_hideUnhideAll.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_hideUnhideAll.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_hideUnhideAll.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_hideUnhideAll.ImageAlign = ContentAlignment.MiddleCenter;
                btn_hideUnhideAll.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.hideUnhide.png"));
                btn_hideUnhideAll.Name = "HideUnhideAll";
                btn_hideUnhideAll.MouseEnter += new EventHandler(btnMouseEnter);
                btn_hideUnhideAll.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_hideUnhideAll);

                //Freeze/Unfreeze All
                btn_freezeUnfreezeAll.Location = new Point(btnHposL += btnGap, margin);
                btn_freezeUnfreezeAll.Size = btnSize;
                btn_freezeUnfreezeAll.FlatStyle = FlatStyle.Flat;
                btn_freezeUnfreezeAll.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_freezeUnfreezeAll.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_freezeUnfreezeAll.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_freezeUnfreezeAll.ImageAlign = ContentAlignment.MiddleCenter;
                btn_freezeUnfreezeAll.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.freezeUnfreeze.png"));
                btn_freezeUnfreezeAll.Name = "FreezeUnfreezeAll";
                btn_freezeUnfreezeAll.MouseEnter += new EventHandler(btnMouseEnter);
                btn_freezeUnfreezeAll.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_freezeUnfreezeAll);

                //Collapse/Expand All
                btn_collapseExpandAll.Location = new Point(btnHposL += btnGap, margin);
                btn_collapseExpandAll.Size = btnSize;
                btn_collapseExpandAll.FlatStyle = FlatStyle.Flat;
                btn_collapseExpandAll.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_collapseExpandAll.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_collapseExpandAll.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_collapseExpandAll.ImageAlign = ContentAlignment.MiddleCenter;
                btn_collapseExpandAll.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.collapseExpand.png"));
                btn_collapseExpandAll.Name = "CollapseExpandAll";
                btn_collapseExpandAll.MouseEnter += new EventHandler(btnMouseEnter);
                btn_collapseExpandAll.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_collapseExpandAll);

                //Top buttons on right
                btn_info.Location = new Point(btnHPosR -= btnGap, margin);
                btn_info.Size = btnSize;
                btn_info.FlatStyle = FlatStyle.Flat;
                btn_info.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_info.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_info.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_info.ImageAlign = ContentAlignment.MiddleCenter;
                btn_info.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.info.png"));
                btn_info.Name = "Information";
                btn_info.Anchor = (AnchorStyles.Top | AnchorStyles.Right);
                btn_info.MouseEnter += new EventHandler(btnMouseEnter);
                btn_info.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_info);

                btn_settings.Location = new Point(btnHPosR -= btnGap, margin);
                btn_settings.Size = btnSize;
                btn_settings.FlatStyle = FlatStyle.Flat;
                btn_settings.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                btn_settings.FlatAppearance.MouseDownBackColor = Color.FromArgb(154, 184, 225);
                btn_settings.FlatAppearance.MouseOverBackColor = Color.FromArgb(174, 204, 235);
                btn_settings.ImageAlign = ContentAlignment.MiddleCenter;
                btn_settings.Image = new Bitmap(GetType().Module.Assembly.GetManifestResourceStream("NestedLayerManager.Icons.settings.png"));
                btn_settings.Name = "Settings";
                btn_settings.Anchor = (AnchorStyles.Top | AnchorStyles.Right);
                btn_settings.MouseEnter += new EventHandler(btnMouseEnter);
                btn_settings.MouseLeave += new EventHandler(btnMouseLeave);
                this.Controls.Add(btn_settings);


                //----------------------------------------------------------------------------
                // Customise Textbox
                //----------------------------------------------------------------------------

                tbx_searchBar.Location = new Point(margin, btnSize.Height + margin + 2);
                tbx_searchBar.Size = new Size(this.Size.Width - (2 * margin) - (2 * ChromeWidth), 16);
                tbx_searchBar.Anchor = (AnchorStyles.Left | AnchorStyles.Top | AnchorStyles.Right);
                tbx_searchBar.BorderStyle = BorderStyle.FixedSingle;
                tbx_searchBar.GotFocus += new EventHandler(searchBarGotFocusPrivate);
                tbx_searchBar.MouseUp += new MouseEventHandler(searchBarMouseUp);
                tbx_searchBar.KeyPress += new KeyPressEventHandler(SearchBarKeyPressed);
                tbx_searchBar.KeyDown += new KeyEventHandler(SearchBarKeyDown);
                this.Controls.Add(tbx_searchBar);
            }


            //----------------------------------------------------------------------------
            // Public Properties
            //----------------------------------------------------------------------------

            //Searchbar text property
            public object SearchBarText
            {
                get { return tbx_searchBar.Text; }
                set { tbx_searchBar.Text = value as string; }
            }

            public Color WindowColor
            {
                //searchbar back color
                //button back color
                get
                {
                    return btn_createLayer.BackColor;
                }
                set
                {
                    btn_createLayer.BackColor = value;
                    btn_createFolder.BackColor = value;
                    btn_deleteSelected.BackColor = value;
                    btn_addSelObjToLyr.BackColor = value;
                    btn_selObjWiSelLyrFdr.BackColor = value;
                    btn_selLyrFdrOfSelObj.BackColor = value;
                    btn_hideUnhideAll.BackColor = value;
                    btn_freezeUnfreezeAll.BackColor = value;
                    btn_collapseExpandAll.BackColor = value;
                    btn_info.BackColor = value;
                    btn_settings.BackColor = value;
                    tbx_searchBar.BackColor = value;
                }
            }

            public Color TextColor
            {
                //searchbar fore color
                get { return tbx_searchBar.ForeColor; }
                set { tbx_searchBar.ForeColor = value; }
            }

            //----------------------------------------------------------------------------
            // Public Events
            //----------------------------------------------------------------------------

            //Button click event
            public event EventHandler buttonClick
            {
                add
                {
                    btn_createLayer.Click += value;
                    btn_createFolder.Click += value;
                    btn_deleteSelected.Click += value;
                    btn_addSelObjToLyr.Click += value;
                    btn_selObjWiSelLyrFdr.Click += value;
                    btn_selLyrFdrOfSelObj.Click += value;
                    btn_hideUnhideAll.Click += value;
                    btn_freezeUnfreezeAll.Click += value;
                    btn_collapseExpandAll.Click += value;
                    btn_info.Click += value;
                    btn_settings.Click += value;
                }
                remove
                {
                    btn_createLayer.Click -= value;
                    btn_createFolder.Click -= value;
                    btn_deleteSelected.Click -= value;
                    btn_addSelObjToLyr.Click -= value;
                    btn_selObjWiSelLyrFdr.Click -= value;
                    btn_selLyrFdrOfSelObj.Click -= value;
                    btn_hideUnhideAll.Click -= value;
                    btn_freezeUnfreezeAll.Click -= value;
                    btn_collapseExpandAll.Click -= value;
                    btn_info.Click -= value;
                    btn_settings.Click -= value;
                }
            }

            //Search bar key down
            public event KeyEventHandler searchBarKeyDown
            {
                add { tbx_searchBar.KeyDown += value; }
                remove { tbx_searchBar.KeyDown -= value; }
            }

            //Search bar got focus
            public event EventHandler searchBarGotFocus
            {
                add { tbx_searchBar.GotFocus += value; }
                remove { tbx_searchBar.GotFocus -= value; }

            }

            //Search bar lost focus
            public event EventHandler searchBarLostFocus
            {
                add { tbx_searchBar.LostFocus += value; }
                remove { tbx_searchBar.LostFocus -= value; }
            }


            //----------------------------------------------------------------------------
            // Private Events
            //----------------------------------------------------------------------------

            //Mouse enter event for theming
            private void btnMouseEnter(object sender, EventArgs e)
            {
                Button btn = sender as Button;
                btn.FlatAppearance.BorderColor = Color.FromArgb(43, 120, 197);
                //Tooltips are created on mouse enter and removed on mouse leave. 
                //This is due to a bug in 3ds Max where child windows are sent behind main window after showing a tooltip.
                ToolTip tt = new ToolTip();
                switch (btn.Name)
                {
                    case "CreateLayer":
                        tt.SetToolTip(btn_createLayer, "Create Layer (Add Selection)");
                        break;
                    case "CreateFolder":
                        tt.SetToolTip(btn_createFolder, "Create Folder");
                        break;
                    case "DeleteSelected":
                        tt.SetToolTip(btn_deleteSelected, "Delete Selected");
                        break;
                    case "AddSelObjToLyr":
                        tt.SetToolTip(btn_addSelObjToLyr, "Add Selected Objects to Selected Layer");
                        break;
                    case "SelObjWiSelLyrFdr":
                        tt.SetToolTip(btn_selObjWiSelLyrFdr, "Select Objects Within Highlighted Selection");
                        break;
                    case "SelLyrFdrOfSelObj":
                        tt.SetToolTip(btn_selLyrFdrOfSelObj, "Select Layers of Selected Objects");
                        break;
                    case "HideUnhideAll":
                        tt.SetToolTip(btn_hideUnhideAll, "Hide/Unhide All");
                        break;
                    case "FreezeUnfreezeAll":
                        tt.SetToolTip(btn_freezeUnfreezeAll, "Freeze/Unfreeze All");
                        break;
                    case "CollapseExpandAll":
                        tt.SetToolTip(btn_collapseExpandAll, "Collapse/Expand All");
                        break;
                    case "Information":
                        tt.SetToolTip(btn_info, "Information");
                        break;
                    case "Settings":
                        tt.SetToolTip(btn_settings, "Settings");
                        break;
                }
                btn.Tag = tt;
            }

            //Mouse leave event for theming
            private void btnMouseLeave(object sender, EventArgs e)
            {
                Button btn = sender as Button;
                btn.FlatAppearance.BorderColor = Color.FromArgb(100, 100, 100);
                ToolTip tt = btn.Tag as ToolTip;
                tt.RemoveAll();
                tt.Dispose();
            }

            //Searchbar select all events
            private Boolean SelectAll = false;
            private void searchBarGotFocusPrivate(object sender, EventArgs e)
            {
                SelectAll = true;
            }
            private void searchBarMouseUp(object sender, EventArgs e)
            {
                if (SelectAll)
                {
                    tbx_searchBar.SelectAll();
                    SelectAll = false;
                }
            }

            //Searchbar stop ding sound from occuring on enter or escape
            private void SearchBarKeyPressed(Object sender, KeyPressEventArgs e)
            {
                if (e.KeyChar == (char)Keys.Return || e.KeyChar == (char)Keys.Escape)
                {
                    e.Handled = true;
                }
            }

            //Searchbar keyboard shortcuts
            private void SearchBarKeyDown(Object sender, KeyEventArgs e)
            {
                //Select all on Ctrl + A
                if (e.Control && e.KeyCode == Keys.A)
                {
                    TextBox SearchBar = sender as TextBox;
                    SearchBar.SelectAll();
                }
            }

        }
    }
}