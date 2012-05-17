function installGraphicListeners(h,f)

%   Copyright 2008-2010 The MathWorks, Inc.

% Builds listeners to changes in the HG hierarchy which monitor the linked 
% graphics and variables and update the datamanager.linkplotmanager Figures
% array

if isempty(h.Figures)
    return
end
I = find([h.Figures.('Figure')]==f);
if isempty(I)
    return
end

% Create the hierarchy listeners
if nargin<=2
    % Create Listener filters
    allPropNames = getplotbrowserproptable;
    if ~feature('HGUsingMATLABClasses')
        objtypes = {'graph2d.lineseries','graph3d.surfaceplot','specgraph.contourgroup',...
            'specgraph.stemseries','specgraph.stairseries','specgraph.barseries',...
            'specgraph.areaseries','specgraph.errorbarseries','specgraph.contourgroup',...
            'specgraph.quivergroup','specgraph.scattergroup','patch'};
    else
        objtypes = {'matlab.graphics.chart.primitive.Line','graphThreeD.surfaceplot',...
            'matlab.graphics.chart.primitive.Stem','matlab.graphics.chart.primitive.Stair','matlab.graphics.chart.primitive.Bar',...
            'matlab.graphics.chart.primitive.Area','matlab.graphics.chart.primitive.ErrorBar','matlab.graphics.chart.primitive.Contour',...
            'matlab.graphics.chart.primitive.Quiver','matlab.graphics.chart.primitive.Scatter','hg2.Patch'};
    end
    filter = repmat(struct('classname',{{}},'properties',{{}},'listentocreation',{[]},'listentodeletion',{[]},'includeallchildren',{[]}),[length(objtypes) 1]);
    for k=1:length(filter)
        I1 = cellfun(@(x) strcmp(objtypes{k},x{1}),allPropNames);
        filter(k).classname = {objtypes{k}};
        filter(k).properties = [allPropNames{I1}{2},{'xdatasource','ydatasource','zdatasource'}];
        filter(k).listentocreation = true;
        filter(k).listentodeletion = true;
        filter(k).includeallchildren = false;
    end

    % Build listener tree
    h.Figures(I).EventManager = objutil.eventmanager(f,'IncludeFilter',filter);
    h.Figures(I).EventManager.ExclusionTag = 'Brushing'; % Exlcude brushing annotations
    h.Figures(I).FigureListeners = ...
            handle.listener(h.Figures(I).EventManager,'NodeChanged',...
               {@localNodeChangedCallback h f});
end

function localNodeChangedCallback(~,ed,h,f)

% Callback for changes in the HG hierarchy
if isempty(h.Figures)
    return
end
I = find([h.Figures.('Figure')]==f);
if isempty(I)
    return
end
h.Figures(I).Dirty = true;

% If the nodechange is due to a property change which is not a data source
% then there is no need to refresh the linked figure graphics.
if strcmp(ed.EventInfo.Type,'PropertyPostSet') && ~isempty(ed.EventInfo.Source) && ...
     isempty(strfind(lower(ed.EventInfo.Source.Name),'source'))
     return
end

% Refresh the linked figure graphics and brushing and clear that figure
% undo stack from the current workspace.
h.LinkListener.postRefresh({handle(h.Figures(I).Figure),'clearUndo','redrawBrushing'});