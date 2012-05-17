function [isUniformed, interval] = tsIsUniformedTime(time,varargin) 
%
% tstool utility function

%   Copyright 2005-2008 The MathWorks, Inc.

% TSISUNIFORMEDTIME  returns the flag as well as the interval if uniformed
% Note: 1. the input parameter time has to be a numeric array; 2. varargin
% is an optional used-defined relative tolerance threshold whose default
% value is 1e-12

% Check time vector type
if ~isnumeric(time)
    error('tsIsUniformedTime:invTimeArray','Input time vector has to be a numeric array.');
end
% Get absolute difference between successive time points
dt = diff(time);
% Check if the threshold is provided by user
if nargin == 2 
    threshold = varargin{1};
else
    threshold = 1e-12;
end
% single time point
if isempty(dt)
    isUniformed = false;
    interval = NaN;    
% otherwise
else
    % uniformed
    if max(abs(diff(dt)))/mean(abs(time))<threshold
        isUniformed = true;
        interval = dt(1);
    % non-uniformed
    else
        isUniformed = false;
        interval = NaN;    
    end
end