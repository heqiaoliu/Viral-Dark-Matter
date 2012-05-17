function outprop = getPlotTimeProp(h,propname)

% Copyright 2005 The MathWorks, Inc.

%% Interface method used to return time properties to dialogs
if ~isempty(h.Plot) && ishandle(h.Plot)
    outprop = get(h.Plot,propname);
else
    outprop = [];
end