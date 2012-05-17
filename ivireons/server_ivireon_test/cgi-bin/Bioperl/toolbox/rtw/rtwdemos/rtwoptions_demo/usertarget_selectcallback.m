function usertarget_selectcallback(hDlg, hSrc)
%   Copyright 2002-2004 The MathWorks, Inc.
%   $Revision: 1.1.4.2 $  $Date: 2004/08/10 02:03:47 $
  
  disp(['*** Select callback triggered:', sprintf('\n'), ...
        '  Uncheck and disable "Terminate function required".']);
  slConfigUISetVal(hDlg, hSrc, 'IncludeMdlTerminateFcn', 'off');
  slConfigUISetEnabled(hDlg, hSrc, 'IncludeMdlTerminateFcn', false);
