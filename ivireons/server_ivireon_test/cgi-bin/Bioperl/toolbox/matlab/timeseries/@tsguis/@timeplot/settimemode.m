function settimemode(view,h,mode)

%   Copyright 2004-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $ $Date: 2005/05/27 14:17:31 $

%% Note that a draw must be performed after calling this method. This will
%% fire a ViewChange event on the axesgrid which will trigger the refresh
%% method through a listener which will update the Start and End text boxes
%% 

%% Toggles the time domain panel between abs time and relative time
%% settings

if strcmp(mode,'relative')
    % Replace formats by units in the units combo
    startcombopos = find(strcmp(view.TimeUnits,get(findtype('TimeUnits'),'String')));
    h.Handles.TimePnl.setabstimemode(false,startcombopos-1);

    % Close any calendars
    if ~isempty(h.Calendar)
        h.Calendar.Visible = 'off';
    end 
%% Relative time radio callback    
elseif strcmp(mode,'absolute')
    formatCombPos = find(strcmp(view.TimeFormat,cell(h.Handles.TimePnl.absformats)));
    if ~isempty(formatCombPos)
        h.Handles.TimePnl.setabstimemode(true,formatCombPos-1);
    else
        h.Handles.TimePnl.setabstimemode(true,0);
    end
end

