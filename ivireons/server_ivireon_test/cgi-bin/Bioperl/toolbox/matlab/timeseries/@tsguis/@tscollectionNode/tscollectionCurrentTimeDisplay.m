function tscollectionCurrentTimeDisplay(h,varargin)
%% Method which builds/populates the tscollection current time (text info)
%% on the viewcontainer panel. 

%   Author(s): Rajiv Singh
%   Copyright 2005-2008 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $ $Date: 2008/12/29 02:11:47 $

import javax.swing.*;

if isempty(h.Handles) || isempty(h.Handles.PNLTsOuter) || ...
        ~ishghandle(h.Handles.PNLTsOuter)
    return % No panel
end

tinfo = h.Tscollection.TimeInfo;
if isempty(tinfo)
     h.Handles.currentTimeInfo = uicontrol('parent',h.Handles.pnlTimeInfo,...
        'style','text','String',{},'Units','Characters','pos',[0.01 0.02 0.99 0.98]/10,...
        'HorizontalAlignment','Left','vis','off');
    return
end
if isempty(tinfo.StartDate)
    if isnan(tinfo.Increment)
        str_tinfo = sprintf('Non-uniform %0.3g-%0.3g %s with %d samples.',...
            tinfo.Start,tinfo.End,tinfo.Units,tinfo.Length);
    else
        str_tinfo = sprintf('Uniform %0.3g-%0.3g %s with %d samples.',...
            tinfo.Start,tinfo.End,tinfo.Units,tinfo.Length);
    end
else
    startTime = tinfo.Start*tsunitconv('days',tinfo.Units)+datenum(tinfo.StartDate);
    endTime = tinfo.End*tsunitconv('days',tinfo.Units)+datenum(tinfo.StartDate);
    if ~isempty(tinfo.Format) && tsIsDateFormat(tinfo.Format)
        startTimeStr = datestr(startTime,tinfo.Format);
        endTimeStr = datestr(endTime,tinfo.Format);
    else
        startTimeStr = datestr(startTime);
        endTimeStr = datestr(endTime);
    end
    
    if isnan(tinfo.Increment)
        str_tinfo = sprintf('Non-uniform %s-%s with %d samples.',...
            startTimeStr,endTimeStr,tinfo.Length);
    else
        str_tinfo = sprintf('Uniform %s-%s with %d samples.',...
            startTimeStr,endTimeStr,tinfo.Length);
    end
end
strcell = {[xlate('Current Time Information: '),str_tinfo]};

if ~isfield(h.Handles,'currentTimeInfo') || isempty(h.Handles.currentTimeInfo)
    h.Handles.currentTimeInfo = uicontrol('parent',h.Handles.pnlTimeInfo,...
        'style','text','String',strcell,'Units','Characters','pos',[0.01 0.02 0.99 0.98]/10,...
        'HorizontalAlignment','Left','vis','off');
else
    set(h.Handles.currentTimeInfo,'String',strcell,'vis','on');
end

