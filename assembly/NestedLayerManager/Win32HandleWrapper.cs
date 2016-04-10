using System;
using System.Windows.Forms;

namespace MaxCustomControls
{
    public class Win32HandleWrapper : IWin32Window
    {
        public IntPtr Handle { get; set; }
        public Win32HandleWrapper(IntPtr handle)
        {
            Handle = handle;
        }
    }
}