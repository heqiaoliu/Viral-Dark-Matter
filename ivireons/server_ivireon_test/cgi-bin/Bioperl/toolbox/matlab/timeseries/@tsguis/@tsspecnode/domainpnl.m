function domainpnl(h,f)

% Copyright 2004-2005 The MathWorks, Inc.

%% Build time panel
if ~isempty(h.Plot) && ishandle(h.Plot) 
    xlim = h.Plot.AxesGrid.getxlim(1);
else % Default time limits - no timeplot yet
    xlim = [0 1];
end
h.Handles.PNLDomain = uipanel('Parent',f,'Units','Pixels','Title',xlate('Define Domain & Range'));

%% Build freq panel components
LBLStart = uicontrol('Style','Text','String','Start freq','HorizontalAlignment',...
    'Left','Parent',h.Handles.PNLDomain,'Units','Pixels','Position',[13 49 48 15]);
h.Handles.TXTStartFreq = uicontrol('Style','Edit','Parent',h.Handles.PNLDomain,'Units','Pixels', ...
    'Position',[67 45 73 21],'String',sprintf('%0.2g',xlim(1)),'Callback', ...
    {@localFreqUpdate h},'HorizontalAlignment','Left','BackgroundColor',[1 1 1]);
LBLEnd = uicontrol('Style','Text','String','End freq','HorizontalAlignment',...
    'Left','Parent',h.Handles.PNLDomain,'Units','Pixels','Position',[156 49 48 15]);
h.Handles.TXTEndFreq = uicontrol('Style','Edit','Parent',h.Handles.PNLDomain,'Units','Pixels', ...
    'Position',[206 45 73 21],'String',sprintf('%0.2g',xlim(2)),'Callback', ...
    {@localFreqUpdate h},'HorizontalAlignment','Left','BackgroundColor',[1 1 1]);
LBLUnits = uicontrol('Style','Text','String','Units','HorizontalAlignment',...
    'Left','Parent',h.Handles.PNLDomain,'Units','Pixels','Position',[296 49 33 15]);
h.Handles.TXTFreqUnits = uicontrol('Style','Popupmenu','Parent',h.Handles.PNLDomain,'Units','Pixels', ...
    'Position',[286+33+10 45 63+30 21],'String',{'cyc/second'}, ...
    'HorizontalAlignment','Left');
if ~ismac
   set(h.Handles.TXTFreqUnits,'BackgroundColor',[1 1 1]);
end
h.Handles.CHKcummulative = uicontrol('Style','Checkbox','Parent',h.Handles.PNLDomain, ...
    'Units','Pixels','Position',[13 45-30 173 21],'String', ...
    'Show cumulative periodogram','HorizontalAlignment','Left','Value',...
    false,'Callback',{@localCumulativeCallback h});

function localFreqUpdate(eventSrc, eventData, h)

%% Callback for start and end time edit boxes which updates the AxesGrid

%% Prevent recursion
% if strcmp(h.EditLock,'on')
%     return
% end

%% No action if there is no TimePlot
if isempty(h.Plot) || ~ishandle(h.Plot) 
    return
end

%% Get the start and end times from the edit boxes and apply them to the
%% axesgrid
startfreq = str2num(get(h.Handles.TXTStartFreq,'String'));
if isempty(startfreq)
    startfreq = -inf;
end
endfreq = str2num(get(h.Handles.TXTEndFreq,'String'));
if isempty(endfreq)
    endfreq = inf;
end
h.Plot.AxesGrid.setxlim([startfreq endfreq]);

function localCumulativeCallback(eventSrc,eventData,h)

%% Callback for the cumulative periodogram checkbox
if ~isempty(h.Plot) && ishandle(h.Plot) 
    onoff = {'off','on'};
    h.Plot.Cumulative = onoff{get(eventSrc,'Value')+1};
    for k=1:length(h.Plot.Waves)
        h.Plot.Waves(k).DataSrc.send('sourcechanged')
    end
end