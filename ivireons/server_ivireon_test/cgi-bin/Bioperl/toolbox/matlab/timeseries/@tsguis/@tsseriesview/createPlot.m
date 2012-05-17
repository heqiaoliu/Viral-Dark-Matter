function createPlot(h,viewpanel,ts)

% Copyright 2006 The MathWorks, Inc.

h.Plot = tsguis.timeplot(viewpanel,1,'StyleManager',...
        h.getRoot.TsViewer.StyleManager,'TimeUnits',ts{1}.TimeInfo.Units,...
        'TimeFormat',ts{1}.TimeInfo.Format);

viewpanel.Plot = h.Plot; % On-the-fly build of property editor needs a plot handle
h.Plot.Parent = h; %  Install parent

%% Add node listeners which require a plot to be present
h.addPlotListeners
    
% Lock out selection mode toolbar when normalized.
% The reason is that the current mechanism for drawing normalized
% plots introduces a flicker during mouse actions in special modes. The
% reason is that when in normalization mode the view draw method sets the
% XData and YData of all the lines to empty, leaving it to the view
% adjustview method to reset them to non-empty values. The result is a
% flicker during data selection actions.
h.Plot.addlisteners(handle.listener(h.Plot.AxesGrid,h.Plot.AxesGrid.findprop('YNormalization'),...
        'PropertyPostSet',{@localToolbarEnableToggle h})); 
    
    
function localToolbarEnableToggle(eventSrc,eventData,h)

%% Callback to the timeplot axesgrid YNormalization listener which disables
%% the tsseriesview toolbar buttons when the timeplot is in normalized mode
dataselectmenu = h.Plot.AxesGrid.findMenu('dataselect');
timeselectmenu = h.Plot.AxesGrid.findMenu('timeselect');
if strcmp(h.Plot.Axesgrid.YNormalization,'on')
    set(h.Handles.ToolbarBtns,'Enable','off')
    if ~isempty(dataselectmenu)
        set(dataselectmenu,'Enable','off');
    end
    if ~isempty(timeselectmenu)
        set(timeselectmenu,'Enable','off');
    end    
else
    set(h.Handles.ToolbarBtns,'Enable','on')
    if ~isempty(dataselectmenu)
        set(dataselectmenu,'Enable','on');
    end
    if ~isempty(timeselectmenu)
        set(timeselectmenu,'Enable','on');
    end   
end
