function varargout = validate(hDlg)
%VALIDATE Returns true if this object is valid

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/03/31 18:43:06 $

[b, exception] = uiscopes.AbstractLineVisual.validate(hDlg);

% Make sure that if a user has selected "<user-defined>" that he gives us a
% real range.

inputProc = hDlg.getWidgetValue([hDlg.getSource.Register.Name 'InputProcessing']);

% Get the Time Range depending on our input processing.
if inputProc == 0
    rangeString = hDlg.getWidgetValue([hDlg.getSource.Register.Name 'TimeRangeFrames']);
else
    rangeString = hDlg.getWidgetValue([hDlg.getSource.Register.Name 'TimeRangeSamples']);
end

cb = @(val) ~isscalar(val) || isnan(val) || isinf(val) || ~isreal(val);

if strcmp(rangeString, uiscopes.message('TimeRangeUserDefined'))
    
    % If we see the <user-defined>' string, throw an error, the user must
    % enter a real value here.
    [msg id] = uiscopes.message('SpecifyTimeRange');
    exception = MException(id, msg);
    b = false;
elseif ~strcmp(rangeString, uiscopes.message('TimeRangeInputSampleTime'))
    
    % Check that the time range is a valid variable or number.
    [val, errid, errmsg] = uiservices.evaluate(rangeString);
    if ~isempty(errid)
        b = false;
        exception = MException(errid, errmsg);
    elseif cb(val) || val <= 0
        [msg id] = uiscopes.message('InvalidTimeRange');
        exception = MException(id, msg);
        b = false;
    end
end

% Check that the inputs are valid variables or numbers.
if b
    cb = @(val) any(isnan(val)) || any(isinf(val)) || any(~isreal(val));
    [b, exception] = uiservices.validateWidgetValue(hDlg, 'TimeDisplayOffset', cb);
end

if nargout
    varargout = {b, exception};
elseif ~b
    rethrow(exception);
end

% [EOF]
