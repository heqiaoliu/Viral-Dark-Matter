function varargout = validateSource(this, hSource)
%VALIDATESOURCE Validate the source

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:43:07 $

if nargin < 2
    hSource = this.Application.DataSource;
end

b = true;
exception = MException.empty;

if strcmpi(getPropValue(this, 'InputProcessing'), 'FrameProcessing')
    
    % If we are in Frame processing mode, then we need to check that the
    % sample times give us the information that we need to draw the frame.
    % If the sample time is continuous (0) or infinite, we cannot draw.
    sampleTimes = getSampleTimes(hSource);
    if any(sampleTimes == 0) || any(isinf(sampleTimes))
        b = false;
        
        [msg, id] = uiscopes.message('InvalidSampleTimeForFrameProcessing');
        
        exception = MException(id, msg);
    end
end

if nargout
    varargout = {b, exception};
elseif ~b
    throw(exception);
end

% [EOF]
