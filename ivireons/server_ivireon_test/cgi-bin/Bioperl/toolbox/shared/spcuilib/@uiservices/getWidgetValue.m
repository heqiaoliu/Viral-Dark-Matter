function widgetValue = getWidgetValue(widgetStruct, hDlg)
%GETWIDGETVALUE Get the widget value.
%   extmgr.getWidgetValue(WIDGET, HDLG) get the widget value for the widget
%   defined in the structure WIDGET given the DAStudio.Dialog object HDLG.
%   If HDLG is empty, use the structure.  WIDGET must have the fields Tag,
%   Source and ObjectProperty defined.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:30:09 $

% If we have the DAStudio.Dialog object use it to get the value of the
% widget via the Tag from the widget structure passed.  If not, use the
% value of the ObjectProperty.  We only want to get the value from the
% dialog if there are unapplied changes, otherwise the change has come from
% somewhere else.
if nargin < 2 || isempty(hDlg) || ~hDlg.hasUnappliedChanges
    widgetValue = widgetStruct.Source.(widgetStruct.ObjectProperty);
else
    widgetValue = hDlg.getWidgetValue(widgetStruct.Tag);
end

% [EOF]
