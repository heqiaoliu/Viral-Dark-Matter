function varargout = validate(hDlg)
%VALIDATE Returns true if this object is valid

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 03:07:58 $

cb = @(val) ~isscalar(val) || isnan(val) || isinf(val) || ~isreal(val) || ~isstrictlypositive(val) || val-floor(val) > eps; %must also be integer
[b, exception] = uiservices.validateWidgetValue(hDlg, 'PointsPerSignal', cb);

if nargout
    varargout = {b, exception};
elseif ~b
    throw(exception);
end

% -------------------------------------------------------------------------
function b = isstrictlypositive(val)
b = true;
if val <= 0
    b = false;
end

% [EOF]
