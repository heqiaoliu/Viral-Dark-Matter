function objs = getBrushableObjs(f)

% Obtain all the hg series as datamanager series objects together with
% their x,yDataSources for children of f

% Copyright 2008-2009 The MathWorks, Inc.

if feature('HGUsingMATLABClasses')
    objs = getBrushableObjsUsingMATLABClasses(f);
    return
else
    host = double(f);
    ls1 = findobj(host,'-class','graph2d.lineseries','HandleVis','on',...
        'Visible','on');
    sc1 = findobj(host,'-class','specgraph.scattergroup','HandleVis','on',...
        'Visible','on');
    stem1 = findobj(host,'-class','specgraph.stemseries','HandleVis','on',...
        'Visible','on');
    area1 = findobj(host,'-class','specgraph.areaseries','HandleVis','on',...
        'Visible','on');
    surf1 = findobj(host,'-class','graph3d.surfaceplot','HandleVis','on',...
        'Visible','on');
    bar1 = findobj(host,'-class','specgraph.barseries','HandleVis','on',...
        'Visible','on');
    stairs1 = findobj(host,'-class','specgraph.stairseries','HandleVis','on',...
        'Visible','on');
end

custom = findobj(host,'-and','HandleVis','on','-not',{'Behavior',struct},'-function',...
    @localHasBrushBehavior,'HandleVis','on');
if isempty(custom)
    objs = [ls1(:);sc1(:);stem1(:);area1(:);surf1(:);bar1(:);stairs1(:)];
    return
end
Iinclude = false(length(custom),1);
for k=1:length(custom)
    bh = hggetbehavior(custom(k),'Brush');
    Iinclude(k) =  bh.Enable;
end 
objs = setdiff([ls1(:);sc1(:);stem1(:);area1(:);surf1(:);bar1(:);stairs1(:);...
                custom(Iinclude)],custom(~Iinclude));


function state = localHasBrushBehavior(h)

state = ~isempty(hggetbehavior(h,'Brush','-peek'));