function syncPlotInfo(h)
% Sync the read-only textual and plot display with timeseries data

% Copyright 2005-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $ $Date: 2008/12/29 02:11:26 $


if isempty(h.Handles) || isempty(h.Handles.utabPlot) || ...
        ~ishghandle(h.Handles.utabPlot)
    return % No panel
end

ts = h.Timeseries;
str = cell(4,1);
str{1,:} = sprintf('  Name: %s',ts.Name);
blk_path = ts.BlockPath;
str{2,:} = sprintf('  Block path: %s',blk_path);
str{3,:} = sprintf('  Port index: %d',ts.PortIndex);
tinfo = ts.TimeInfo;

if isnan(tinfo.Increment)
    str_tinfo = sprintf('Non-uniformly sampled data with Start-time = %0.3g, End-time = %0.3g and %d samples.',...
        tinfo.Start,tinfo.End,tinfo.Length);
else
    str_tinfo = sprintf('Uniformly sampled data with interval = %0.3g, Start-time = %0.3g, End-time = %0.3g, and %d samples.',...
        tinfo.Increment, tinfo.Start,tinfo.End,tinfo.Length);
end

str{4,:} = sprintf('  Time Information: %s',str_tinfo);


% Render new panels or update their data
if ~isfield(h.Handles,'PlotTextInfo') || isempty(h.Handles.PlotTextInfo) ||...
        ~isfield(h.Handles,'PlotDataHandle') || isempty(h.Handles.PlotDataHandle) ||...
        ~ishghandle(h.Handles.PlotTextInfo) || any(~ishghandle(h.Handles.PlotDataHandle)) ||...
        ~isequal(size(ts.Data,2),length(h.Handles.PlotDataHandle))
    %build a new panel
    h.Handles.PlotTextInfoPanel = uipanel('Parent',h.Handles.utabPlot,'Title',...
        xlate('Logged Signal Information'),'tag','loggedsignalinfo','units','char',...
        'pos',[0 0 1 1]/10);

    h.Handles.PlotTextInfo = uicontrol('parent',h.Handles.PlotTextInfoPanel,'style',...
        'text','units','norm','string',str,'pos',[0 0 1 0.9],...
        'horizontalAlignment','left');

    h.Handles.PlotViewPanel = uipanel('Parent',h.Handles.utabPlot,'Title',...
        xlate('Logged Signal Plot'),'tag','loggedsignalplot','units','char',...
        'pos',[0 0 1 1]/10);
    h.Handles.PlotDataHandle = h.plot(h.Handles.PlotViewPanel);
else %simply update the data
    set(h.Handles.PlotTextInfo,'string',str);
    time = ts.Time;
    data = ts.Data;
    N = 5000;
    if length(time)>N
        %time1 = linspace(time(1),time(end),2000).';
        %data1 = interp1(time,data,time1);
        time1 = time(end-N+1:end);
        data1 = data(end-N+1:end,:);
    else
        time1 = time;
        data1 = data;
    end
    for k = 1:length(h.Handles.PlotDataHandle)
        set(h.Handles.PlotDataHandle(k),'Xdata',time1,'Ydata',data1(:,k));
    end
    if ~isempty(time1)
        set(get(h.Handles.PlotDataHandle(1),'parent'),'ylimmode','auto',...
            'xlim',[time1(1),time1(end)+max(eps(time1(end)),0.02*(time1(end)-time1(1)))]);
    end
    %axis(get(h.Handles.PlotDataHandle(1),'parent'),'tight')
end
