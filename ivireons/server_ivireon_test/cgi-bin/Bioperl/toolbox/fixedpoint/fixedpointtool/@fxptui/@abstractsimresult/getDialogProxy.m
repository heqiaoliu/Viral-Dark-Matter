function obj = getDialogProxy(h) %#ok<INUSD> this pointer
%GETDIALOGPROXY

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/04/14 19:35:10 $

me = fxptui.getexplorer;
obj = me.imme.getCurrentTreeNode;
%showdialog=0. treat as selection change and don't bring the dialog forward
fxptui.cb_scaleinfo(0); 

% [EOF]