function time = tsChkTime(time)
%
% tstool utility function
% Copyright 2004-2006 The MathWorks, Inc.

stime = size(time);
if length(stime)>2 
    error('tsChkTime:manytimedim',...
        'Time vector cannot have more than 2 dimensions.')
end
if max(stime)<1
    error('tsChkTime:shorttime',...
        'Time vector cannot be empty.')
end
if stime(2)>1
    stime = stime(2:-1:1);
    time = reshape(time,stime);
end
if stime(2)~=1
    error('tsChkTime:matrixtime',...
        'Time vector must be a 1xn or nx1 vector.')
end
if any(isinf(time)) || any(isnan(time))
    error('tsChkTime:inftime',...
        'Time vector must contain only finite values.')
end
if ~all(isreal(time))
    error('tsChkTime:inftime',...
        'Time vector must contain only real values.')
end
