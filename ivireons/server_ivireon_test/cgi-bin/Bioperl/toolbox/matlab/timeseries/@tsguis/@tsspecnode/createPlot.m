function createPlot(h,viewpanel,ts)

% Copyright 2006 The MathWorks, Inc.

h.Plot = tsguis.specplot(viewpanel,1,'StyleManager',...
        h.getRoot.TsViewer.StyleManager);  
viewpanel.Plot = h.Plot; % On-the-fly build of property editor needs a plot handle
h.Plot.Parent = h; %  Install parent

% Add node listeners which require a plot to be present
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

%% Callback to the specplot axesgrid YNormalization listener which disables
%% the tsspecnode toolbar buttons when the specplot is in normalized mode
if strcmp(h.Plot.Axesgrid.YNormalization,'on')
    set(h.Handles.ToolbarBtns,'Enable','off')
else
    set(h.Handles.ToolbarBtns,'Enable','on')
end
