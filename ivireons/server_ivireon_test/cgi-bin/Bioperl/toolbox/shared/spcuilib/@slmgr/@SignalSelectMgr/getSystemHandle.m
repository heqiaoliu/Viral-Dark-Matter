function systemHandle = getSystemHandle(this)
%GETSYSTEMHANDLE Get the systemHandle.
%   OUT = GETSYSTEMHANDLE(ARGS) <long description>

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/19 21:43:19 $

systemHandle = get(this.Signals, 'System');

if iscell(systemHandle)
    if length(unique([systemHandle{:}])) == 1
        systemHandle = systemHandle{1};
    else
        systemHandle = [systemHandle{:}];
    end
end

% [EOF]
