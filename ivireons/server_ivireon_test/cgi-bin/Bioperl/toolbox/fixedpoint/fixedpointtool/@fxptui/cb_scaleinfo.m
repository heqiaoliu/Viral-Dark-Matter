function cb_scaleinfo(varargin)
%CB_SCALEINFO

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/14 19:35:01 $

me = fxptui.getexplorer;
if(isempty(me)); return; end
selection = me.getlistselection;
dlg = me.getautoscaledialog;
showdialog = true;
%if this is a selection change set this flag to false so that we don't
%force the window forward every time the list selection changes
if(nargin > 0)
  showdialog = varargin{1};  
end
%if there is no selection and showdialog is true, warn and return.
if((isempty(selection)) && (showdialog))
  fxptui.showdialog('noselectionscaleinfo');
  return;
end
%if the dialog is already open set the source object on it and bring it
%forward only if the autoscale info action was invoked.
if(isa(dlg, 'DAStudio.Dialog'))
  dlg.setSource(fxptui.resultreport(selection));
  if(showdialog)
    dlg.show;
  end
elseif(showdialog)
  dlg = DAStudio.Dialog(fxptui.resultreport(selection));
  me.setautoscaledialog(dlg);
end

% [EOF]
