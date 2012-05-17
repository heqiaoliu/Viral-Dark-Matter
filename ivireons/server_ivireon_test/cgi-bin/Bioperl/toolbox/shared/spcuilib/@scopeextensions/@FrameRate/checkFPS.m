function [success, exception] = checkFPS(~, local_fps)
%CheckFPS Check if frame rate is valid.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2009/06/11 16:05:47 $

exception = [];

% this fcn is called from validate, which converts a string input to a
% numeric value via str2double.  That fcn limits the input to scalar
% doubles, outputting NaN if the input is not scalar/double.  We
% replicate that here so direct user-inputs can be checked.
if ~isnumeric(local_fps)
    local_fps = NaN;
end

success = ~isnan(local_fps);  % invalid entries produce NaN
if ~success
    [msg, id] = uiscopes.message('FrameRateNotNumeric');
    exception = MException(id, msg);
    return
end
success = isreal(local_fps) && ~issparse(local_fps) && isscalar(local_fps);
if ~success
    [msg, id] = uiscopes.message('FrameRateNotRealScalar');
    exception = MException(id, msg);
    return
end
success = (local_fps > 0);
if ~success
    [msg, id] = uiscopes.message('FrameRateNotPositive');
    exception = MException(id, msg);
    return
end
success = ~isinf(local_fps);
if ~success
    [msg, id] = uiscopes.message('FrameRateNotNumeric');
    exception = MException(id, msg);
    return
end

% [EOF]
