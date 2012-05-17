function varargout = validateSource(this, hSource)
%VALIDATESOURCE Validate the source

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:17 $

if nargin < 2
    hSource = this.Application.DataSource;
end

b = true;
exception = MException.empty;

if any(getSampleTimes(hSource) == 0)
    [msg, id] = uiscopes.message('InvalidSampleTimeForVectorVisual', this.Config.Name);
    b         = false;
    exception = MException(id, msg);
end

if nargout
    varargout = {b, exception};
else
    throw(exception);
end

% [EOF]
