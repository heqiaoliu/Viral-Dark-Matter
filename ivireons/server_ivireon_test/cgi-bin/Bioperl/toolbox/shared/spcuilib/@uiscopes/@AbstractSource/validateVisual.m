function varargout = validateVisual(this, hVisual)
%VALIDATEVISUAL Validate the visual

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:44:15 $

if ~isempty(hVisual)
    [b, exception] = validateSource(hVisual, this);
else
    b = true;
    exception = MException.empty;
end
this.IsSourceValid = b;

if nargout
    varargout = {b, exception};
elseif ~b
    throw(exception);
end

% [EOF]
