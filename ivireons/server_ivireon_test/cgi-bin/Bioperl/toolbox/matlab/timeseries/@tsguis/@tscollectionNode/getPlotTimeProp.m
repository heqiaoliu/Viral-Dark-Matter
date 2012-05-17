function outprop = getPlotTimeProp(h,propname)

% Copyright 2005 The MathWorks, Inc.

%% Interface method used to return time properties to dialogs
switch propname
    case 'AbsoluteTime'
        if ~isempty(h.Tscollection.TimeInfo.StartDate)
            outprop = 'on';
        else
            outprop = 'off';
        end
    case 'TimeUnits'
        outprop = h.Tscollection.TimeInfo.Units;
end
