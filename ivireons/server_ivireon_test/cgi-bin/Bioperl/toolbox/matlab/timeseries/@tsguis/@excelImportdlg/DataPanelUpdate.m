function DataPanelUpdate(h,option)
% update the controls in data panel to the current display

% Copyright 2004 The MathWorks, Inc.

if strcmp(option,'column')
    % the first column contains absolute time format
    set(h.Handles.COMBdataSample,'Value',1);
else
    % the first row contains absolute time format
    set(h.Handles.COMBdataSample,'Value',2);
end
