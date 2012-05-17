function [success, exception] = validate(this)
%VALIDATE Validate settings of dialog object.
%   stat: boolean status, 0=fail, 1=accept
%   err: error message, string

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2009/12/07 20:45:11 $

% Check desired frame rate:
local_fps_str = this.dialog.getWidgetValue('Desiredfps');
local_fps = str2double(local_fps_str);
[success, exception] = checkFPS(this, local_fps);
if ~success, return; end

success = isnumeric(local_fps) && isscalar(local_fps) && ~isnan(local_fps);
if ~success
    [msg, id] = uiscopes.message('FrameRateNotScalar');
    exception = MException(id, msg);
    return;
end

success = ~(local_fps < 1e-6);
if ~success
    [msg, id] = uiscopes.message('FrameRateTooLow');
    exception = MException(id, msg);
    return;
end

allowsDecim = this.dialog.getWidgetValue('allowDecim');
if allowsDecim

    % Check min/max sched frame rate:
    local_fps_str = this.dialog.getWidgetValue('SchedRateMin');
    local_fps_min = str2double(local_fps_str);
    [success, exception] = checkFPS(this, local_fps_min);
    if ~success, return; end
    
    local_fps_str = this.dialog.getWidgetValue('SchedRateMax');
    local_fps_max = str2double(local_fps_str);
    [success, exception] = checkFPS(this, local_fps_max);
    if ~success, return; end
    
    success = (local_fps_min < local_fps_max);
    if ~success
        [msg, id] = uiscopes.message('FrameRateMaximumLessThanMinimum');
        exception = MException(id, msg);
    end

    % Try to make a playback schedule using the numbers we have.
    [warn_str, warn_id] = lastwarn;
    w = warning('off', ...
        'spcuilib:scopeextensions:FrameRate:calculatePlaybackSchedule:PlaybackScheduleFailure');

    schedFPS = calculatePlaybackSchedule(this, local_fps, allowsDecim, ...
        local_fps_min, local_fps_max);
    warning(w);
    lastwarn(warn_str, warn_id);
    if schedFPS > 1000
        %g410343 (the timer Period property should be no less than 0.001 seconds)
        success = false;
        [msg, id] = uiscopes.message('SchedFrameRateTooHigh',...
                    sprintf('%g',schedFPS));
        exception = MException(id, msg);
    end
else
    
    %g449870 Align with command line limits.
    success = ~(local_fps > 100);
    if ~success
        [msg, id] = uiscopes.message('FrameRateTooHigh');
        exception = MException(id, msg);
    end
end

% [EOF]
