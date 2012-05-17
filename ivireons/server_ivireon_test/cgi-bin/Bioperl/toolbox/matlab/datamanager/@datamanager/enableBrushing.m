function hout = enableBrushing(h)

% Switchyard for creating brushing annotation objects

% Copyright 2010 The MathWorks, Inc.

h = handle(h);
hout = getappdata(double(h),'Brushing__');
isSeriesObject = isa(h,'graph2d.lineseries') || isa(h,'specgraph.areaseries') || ...
    isa(h,'specgraph.barseries') || isa(h,'graph3d.surfaceplot') || ...
    isa(h,'specgraph.scattergroup') || isa(h,'specgraph.stemseries') || ...
    isa(h,'specgraph.stairseries');

% copyobj will not copy the BrushData instance prop but will copy the 
% appdata brushing reference so if there is not BrushData prop, force a
% rebuild of the brushing object.
if isSeriesObject
    if ~isprop(h,'BrushData') && isempty(hggetbehavior(h,'brush','-peek'))     
        p = schema.prop(h,'BrushData','MATLAB array');
        p.AccessFlags.Serialize = 'off';
        hout = [];
    end
    if isempty(get(h,'BrushData'))
        if ~isempty(findprop(handle(h),'ZData')) && ~isempty(get(h,'ZData'))
            set(h,'BrushData',uint8(zeros(size(get(h,'ZData')))));
        else
            set(h,'BrushData',uint8(zeros(size(get(h,'YData')))));
        end
    end
end

if ~isempty(hout) && ishandle(hout) && ...
        (~hout.isCustom && ~isempty(hout.HGHandle))
    return;
end
if isa(h,'graph2d.lineseries')
    hout = datamanager.lineseries(h);
elseif isa(h,'specgraph.areaseries')
    % Add datamanager brushing objects to all peers
    peers = get(h,'AreaPeers');
    for k=1:length(peers)
        hpeer = getappdata(double(peers(k)),'Brushing__');
        if isempty(hpeer) || ~ishandle(hpeer)
           datamanager.areaseries(peers(k));
        end
    end
    hout = getappdata(double(h),'Brushing__');
    if isempty(hout)
       hout = datamanager.areaseries(h);
    end
elseif isa(h,'specgraph.barseries')
    % Add datamanager brushing objects to all peers
    peers = get(h,'BarPeers');
    for k=1:length(peers)
        hpeer = getappdata(double(peers(k)),'Brushing__');
        if isempty(hpeer) || ~ishandle(hpeer)
            datamanager.barseries(peers(k));
        end
    end
    hout = getappdata(double(h),'Brushing__');
    if isempty(hout)
        hout = datamanager.barseries(h);
    end
elseif isa(h,'graph3d.surfaceplot')
    hout = datamanager.surfaceplot(h);
elseif isa(h,'specgraph.scattergroup')
    hout = datamanager.scattergroup(h);
elseif isa(h,'specgraph.stemseries')
    hout = datamanager.stemseries(h);
elseif isa(h,'specgraph.stairseries')
    hout = datamanager.stairseries(h);
else 
    brushBehavior = hggetbehavior(h,'brush','-peek');
    if ~isempty(brushBehavior)
        hout = datamanager.customseries(h,brushBehavior);
        hout.LinkBehaviorObject = hggetbehavior(h,'linked','-peek');
        setappdata(double(h),'Brushing__',hout);
    end
end