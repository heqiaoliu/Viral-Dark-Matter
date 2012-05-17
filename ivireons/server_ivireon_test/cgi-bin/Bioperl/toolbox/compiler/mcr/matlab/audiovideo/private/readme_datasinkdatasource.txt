README for MatlabDataSink & MatlabDataSource DLLs
Author: binky@mathworks.com, copied from toolbox/mmblks/bin/win32/readme_mmblks_mmio.txt
Last updated: 6/25/03

To use the MatlabDataSink and MatlabDataSource DLLs, you'll need to
register the 2 new DirectShow filters.

Follow the steps below to accomplish these two tasks.  If you have any
problems, feel free to send me an email or give me a call.

Steps:

1)  The register_filters.reg file in this directory takes care of registering 
    the new DirectShow filters, so long as your A sandbox root is 
    D:\Work\A\matlab (meaning this directory is 
    D:\Work\A\matlab\toolbox\matlab\audiovideo\private).  Basically we need
    to tell the registry where some DLLs live, and that can differ based on
    the paths to different peoples' sandboxes:

    a) If your sandbox root is D:\Work\A\matlab:    
    Simply double-click on register_filters.reg and click "Yes" and "OK" 
    when prompted.  Or if you're in a command window, simply type in 
    "register_filters.reg" (without the quotes) and hit enter, then click 
    on "Yes" and "OK" when prompted.

    b) If your sandbox root is NOT D:\Work\A\matlab:
    You're going to have to edit the register_filters.reg file.  Open 
    register_filters.reg in your favorite text editor and change all 
    occurences of the string

	D:\\Work\\A\\matlab\\toolbox\\matlab\\audiovideo\\private

    with the corresponding path of toolbox/matlab/audiovideo/private for your
    sandbox.  USE DOUBLE BACKSLASHES ( "\\" ) and make sure the resulting
    file path is valid.

    For instance, if your sandbox root is Q:\MySweetSandbox\A\matlab, 
    replace

	D:\\Work\\A\\matlab\\toolbox\\matlab\\audiovideo\\private

    in the register_filters.reg file with

	Q:\\MySweetSandbox\\A\\matlab\\toolbox\\matlab\\audiovideo\\private

    Now, to get the information into the registry, simply double-click on 
    register_filters.reg and click "Yes" and "OK" when prompted.  Or if 
    you're in a command window, simply type in "register_filters.reg" 
    (without the quotes) and hit enter, then click on "Yes" and "OK" when 
    prompted.
