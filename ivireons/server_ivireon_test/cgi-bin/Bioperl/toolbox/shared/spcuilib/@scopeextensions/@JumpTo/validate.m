function [success, exception] = validate(this)
%VALIDATE Validate settings of Dialog object
%
% stat: boolean status, 0=fail, 1=accept
% err: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2009/06/11 16:05:52 $

success = true;
exception = [];

% Two levels of checking to do here:
%
%  1 - try to evaluate frame number
%      (could fail general evaluation)
%  2 - check that it's a valid frame
%      (could fail this as well)
%
% Could throw an error, so protect against this
local_frame_str = this.dialog.getWidgetValue('frame');
try
    set(this, 'FrameStr', local_frame_str);
catch exception
    success  = false;
    
    % If the ID is from evalin failing with nothing to eval, the user must
    % have entered a blank value.
    if strcmp(exception.identifier, 'MATLAB:unassignedOutputs')
        [msg, id] = uiscopes.message('JumpToFrameEmpty');
        exception = MException(id, msg);
    end
end

% [EOF]
