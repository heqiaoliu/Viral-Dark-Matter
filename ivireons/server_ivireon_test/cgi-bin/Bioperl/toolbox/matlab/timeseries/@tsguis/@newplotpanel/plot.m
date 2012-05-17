function plot(h,manager)

%   Author(s): James Owen
%   Copyright 2004-2005 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $ $Date: 2005/12/15 20:56:28 $

%% Display button callback.

tsList = h.Node.getTimeSeries;
if length(tsList)>10
    ButtonName = questdlg(sprintf('Attempting to plot more than %d time series in a single axes may take time. Continue?',length(tsList)), ...
                       xlate('Time Series Tools'), ...
                       xlate('Continue'),xlate('Abort'),xlate('Abort'));
    if strcmp(ButtonName,xlate('Abort'));
        return
    end
end

%% If the existing view radio button is selected find the view node
%% node
if get(h.Handles.RADIOexist,'Value')>0.5
    ind = get(h.Handles.COMBexistview,'Value');
    availableViews = get(h.Handles.COMBexistview,'String');
    % TO DO: replace tsguis.tsseriesview by its parent class - when
    % implemented
    allViews = setdiff(manager.Root.TsViewer.ViewsNode.find(...
        '-depth',2),manager.Root.TsViewer.ViewsNode.find('-depth',1));
    selectedViewNodePos = ...
        strcmp(availableViews{ind},get(allViews,{'Label'}));
    selectedView = allViews(selectedViewNodePos);
%% If the new view radio button is selected create the @tsseriesview node
else
    % Get new view name
    newplotname = get(h.Handles.EDITnewview,'String');
    if isempty(newplotname)
        errordlg('You must specify a name for the new plot.',...
            'Time Series Tools','modal')
        return
    end
    
    % Get new view type
    viewnames = get(h.Handles.COMBViewType,'String');
    newviewtype = viewnames{get(h.Handles.COMBViewType,'Value')};
    
    % Create new view
    selectedView = ...
        manager.Root.TsViewer.ViewsNode.getChildren('Label',newviewtype).addplot(...
              manager,newplotname);
end
 
%% Add the @timeseries to the selected @tsseriesview node
if isempty(tsList)
    return
end
selectedView.addTs(tsList);

h.update(manager,[]);