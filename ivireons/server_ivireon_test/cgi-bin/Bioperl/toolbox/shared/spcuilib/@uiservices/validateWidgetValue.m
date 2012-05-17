function [b, exception, val] = validateWidgetValue(hDlg, tag, invalidator)
%VALIDATEWIDGETVALUE Validate the widget value.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/11/16 22:34:45 $

% Get the value from the DDG widget.
fulltag = [hDlg.getSource.Register.Name tag];
variable = hDlg.getWidgetValue(fulltag);

% Try to evaluate it.
[val, errid, errmsg] = uiservices.evaluate(variable);

% If the evaluation fails, throw that error.
if ~isempty(errid)
    b = false;
    exception = MException(errid, errmsg);
elseif invalidator(val)
    
    % Test whether the value is valid with the fcn handle given to us.
    b = false;
    [msg id] = uiscopes.message(['Invalid' tag]);
    exception = MException(id, msg);
else
    b = true;
    exception = MException.empty;
end

% [EOF]
