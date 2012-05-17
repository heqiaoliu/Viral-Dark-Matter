function outprop = getPlotTimeProp(h,propname)

% Copyright 2005 The MathWorks, Inc.

%% Interface method used to return time properties to dialogs
if ~isempty(h.Plot) && ishandle(h.Plot)
    switch propname
        case 'AbsoluteTime'
            outprop = ''; % Onlt time plots can have absolute time
        otherwise
            outprop = get(h.Plot,propname);
    end
else
    outprop = [];
end