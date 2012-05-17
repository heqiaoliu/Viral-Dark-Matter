function selected_sibs = getAllBrushedObjects(gobj)

% Copyright 2008-2010 The MathWorks, Inc.

% Get all the objects in the graphic container which have been brushed.
% Be sure to include the peer axes for any plotyy axes.
if feature('HGUsingMATLABClasses')
    selected_sibs = getAllBrushedObjectsUsingMATLABClasses(gobj);
    return;
end

sibs = findobj(gobj,'-Property','Brushdata','HandleVisibility','on');
if isappdata(gobj,'graphicsPlotyyPeer')
    sibs = [sibs(:)',findobj(getappdata(gobj,'graphicsPlotyyPeer'),...
        '-Property','Brushdata','HandleVisibility','on')];
end
selected_sibs = findobj(sibs,'flat','-function',...
    @(x) ~isempty(get(x,'Brushdata')) && any(x.Brushdata(:)>0));
if length(selected_sibs)==length(sibs)
    return;
end    
 
% Check for objects brushed using behavior objects
custom = findobj(sibs,'-and','HandleVis','on','-not',{'Behavior',struct},'-function',...
    @localHasBrushBehavior,'HandleVis','on');
if isempty(custom)
    return
end

% Add objects brushed by enabled behavior objects
Iinclude = false(length(custom),1);
for k=1:length(custom)
    bh = hggetbehavior(custom(k),'Brush');
    Iinclude(k) =  bh.Enable;
end 
selected_sibs = [selected_sibs(:); custom(Iinclude)];


function state = localHasBrushBehavior(h)

state = ~isempty(hggetbehavior(h,'Brush','-peek'));