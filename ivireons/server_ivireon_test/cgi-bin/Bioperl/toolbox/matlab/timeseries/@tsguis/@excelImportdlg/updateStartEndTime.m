function updateStartEndTime(h,startindex,endindex)
% UPDATESTARTENDTIME updates absolute time/relative time edit boxes

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2005 The MathWorks, Inc.

% ind=get(h.Handles.COMBtimeSource,'Value');
% if ind==3
%     % the time vector is selected from matlab workspace
%     ;
% elseif ind==2 || ind==1
%     % the time vector is defined manually
%     set(h.Handles.EDTtimeManualEnd,'String',num2str(endindex-startindex+1))
% elseif ind==1
% check if a valid time vector exists (first and last elements)
if get(h.Handles.COMBdataSample,'Value')==1
    % time vector is stored as a column
    [startTime,startTimeFormat]=h.getTimeColumn(startindex);
    [endTime,endTimeFormat]=h.getTimeColumn(endindex);
else
    % time vector is stored as a row
    [startTime,startTimeFormat]=h.getTimeRow(startindex);
    [endTime,endTimeFormat]=h.getTimeRow(endindex);
end
if ~isempty(startTime) && ~isempty(endTime)
    if iscell(startTime)
        set(h.Handles.EDTtimeSheetStart,'String',startTime{1});
    else
        set(h.Handles.EDTtimeSheetStart,'String',num2str(startTime(1),30));
    end
    if iscell(endTime)    
        set(h.Handles.EDTtimeSheetEnd,'String',endTime{1});
    else
        set(h.Handles.EDTtimeSheetEnd,'String',num2str(endTime(1),30));
    end
else
    set(h.Handles.EDTtimeSheetStart,'String','');
    set(h.Handles.EDTtimeSheetEnd,'String','');
end
% absolute manually defined
if get(h.Handles.COMBuseFormat,'Value')==1
    set(h.Handles.EDTtimeManualStart,'String',datestr(now))
    set(h.Handles.EDTtimeManualEnd,'String',num2str(endindex-startindex+1))
    set(h.Handles.EDTtimeManualInterval,'String','1')
% relative manually defined
else
    set(h.Handles.EDTtimeManualStart,'String','0')
    set(h.Handles.EDTtimeManualEnd,'String',num2str(endindex-startindex+1))
    set(h.Handles.EDTtimeManualInterval,'String','1')
end
% end