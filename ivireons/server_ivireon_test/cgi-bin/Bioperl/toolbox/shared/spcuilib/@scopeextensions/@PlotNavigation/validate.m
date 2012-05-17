function varargout = validate(hdlg)
%VALIDATE Returns true if this object is valid

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/09/09 21:29:30 $

success   = true;
exception = MException.empty;

ydisplay = hdlg.getWidgetValue('Plot NavigationYDataDisplay');

try
    ydisplay = uiservices.evaluate(ydisplay);
    if isNotValid(ydisplay)
        success = false;
        [msg, id] = uiscopes.message('InvalidYDisplay');
        exception = MException(id, msg);
    end
catch exception
    success = false;
end

if hdlg.getWidgetValue('AutoscaleXAxis')
    xdisplay = hdlg.getWidgetValue('Plot NavigationXDataDisplay');
    try
        xdisplay = uiservices.evaluate(xdisplay);
        if isNotValid(xdisplay)
            success = false;
            [msg, id] = uiscopes.message('InvalidXDisplay');
            exception = MException(id, msg);
        end
    catch exception
        success = false;
    end
end

if nargout
    varargout = {success, exception};
elseif ~success
    throw(exception);
end

% -------------------------------------------------------------------------
function b = isNotValid(displayRange)

b = ~isscalar(displayRange)      || ...
    ~isa(displayRange, 'double') || ...
    isnan(displayRange)          || ...
    ~isreal(displayRange)        || ...
    displayRange > 100           || ...
    displayRange < 1;

% [EOF]
