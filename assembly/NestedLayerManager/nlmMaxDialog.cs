using System;
using System.Windows.Forms;
using System.Drawing;
namespace NestedLayerManager
{
    //Classes for NLM when in max dialog
    namespace MaxDialog
    {
        // Window hook class used to capture special keys when in 3ds max dialog
        public class WindowHook : NativeWindow
        {
            private const int WM_GETDLGCODE = 0x0087;
            private const int DLGC_WANTALLKEYS = 0x0004;
            public WindowHook() { }
            protected override void WndProc(ref Message m)
            {
                switch (m.Msg)
                {
                    case WM_GETDLGCODE:
                        m.Result = (IntPtr)DLGC_WANTALLKEYS;
                        break;
                    default:
                        base.WndProc(ref m);
                        break;
                }
            }
        }
    }
}