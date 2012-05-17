function brushup(es,evd)

% This static method is called by the brush mode for windowButtonUpFcn
% events. This code may be modified in future releases.

%  Copyright 2008-2010 The MathWorks, Inc.

fig = es;
brushmode = getuimode(fig,'Exploration.Brushing');
selectionObject = brushmode.ModeStateData.SelectionObject;
if isempty(selectionObject)
    return
end
ax = selectionObject.Axes;

% Restore xlimmode,ylimmode if not using HGUsingMATLABClasses
if ~feature('HGUsingMATLABClasses')
    set(ax,'XLimMode',brushmode.ModeStateData.xLimMode)
    set(ax,'YLimMode',brushmode.ModeStateData.yLimMode)
end
% Brush a single point or clear brushing in response to a single click on a 
% 2d axes. 
if is2D(ax) || feature('HGUsingMATLABClasses')
    r = selectionObject.Graphics;
    if is2D(ax) 
        t = selectionObject.Text;
    end
    figSelectionType = get(fig,'SelectionType');
    
    % If the selectionObject has an empty Graphics property then brushdrag
    % was not called, and no drag gesture occured. In this case, this is a
    % click gesture and datamanager.brushRectangle should be called with
    % clicked object and current figure pixel location as the selected
    % region.
    if isempty(r) && (strcmpi(figSelectionType,'normal') || ...
            strcmpi(figSelectionType,'extend'))
        % Find the clicked graphics object 
        if feature('HGUsingMATLABClasses')
            hitobj = plotedit({'hittestHGUsingMATLABClasses',fig,evd});
        else
            hitobj = hittest(es);
            % If this is a shift click on brushing annotation, the hitobj will
            % be the brushing annotation rather than the underlying graphic
            % object. In this case try the hittest again to get the right
            % obj.
            hitobj_cache = [];
            while ~isempty(hitobj) && strcmp(get(hitobj,'Tag'),'Brushing')
                hitobj_cache = [hitobj_cache;hitobj]; %#ok<AGROW>
                set(hitobj_cache,'HitTest','off')
                hitobj = hittest(ancestor(es,'figure'));           
            end
            set(hitobj_cache,'HitTest','on');
        end
        % Get current workspace for the initator of the brush
        % Note that brushup is called by the mode object using hgeval.
        % This introduces 2 more stack layers
        [mfile,fcnname] = datamanager.getWorkspace(5);
        
        % Brush either the closest vertex on the clicked object or clear
        % the brushing if clicking on the axes background
        if feature('HGUsingMATLABClasses')
            % Vertex picking when HGUsingMATLABClasses is done in the
            % datamanager.brushRectangle method because it is analogous to
            % finding the interior vertices of a brushing polygon which is
            % also performed in the datamanager.brushRectangle by the
            % DataAnnotable::getEnclosedPoints() method
            if isplotchild(hitobj) || ~isempty(hggetbehavior(hitobj,'brush','-peek'))
                currentFigPoint = hgconvertunits(fig,[get(fig,'CurrentPoint') 0 0],...
                    get(fig,'Units'),'pixels',fig);
                datamanager.brushRectangle(ax,hitobj,...
                            hitobj,currentFigPoint(1:2),[],...
                            brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                            mfile,fcnname);
            elseif ishghandle(hitobj,'axes') && strcmp(get(fig,'SelectionType'),'normal')
                datamanager.brushRectangle(ax,brushmode.ModeStateData.brushObjects,...
                        [],[],[],...
                        brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                        mfile,fcnname); 
            end
        else
            brushObj = getappdata(double(hitobj),'Brushing__');
            if isplotchild(hitobj) || (~isempty(brushObj) && brushObj.isCustom)
                % getVertex methods mimic the behavior of the @series graphic
                % updateDataCursor methods
                brushObj = getappdata(double(hitobj),'Brushing__');
                if ~isempty(brushObj) && ishandle(brushObj)
                    if brushObj.isCustom
                        v = vertexpicker(double(hitobj));
                    else
                        v = brushObj.getVertex(ax);
                    end
                    if ~isempty(v)
                        datamanager.brushRectangle(ax,hitobj,...
                            hitobj,v(1:2),[],...
                            brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                            mfile,fcnname);

                    end
                end
            elseif strcmp(get(hitobj,'type'),'axes') && strcmp(get(fig,'SelectionType'),'normal') % Clear brushing
                datamanager.brushRectangle(ax,brushmode.ModeStateData.brushObjects,...
                            [],[],[],...
                            brushmode.ModeStateData.brushIndex,brushmode.ModeStateData.color,...
                            mfile,fcnname); 
            end  
        end
    end
    
else
     set(ax,'ZLimMode',brushmode.ModeStateData.zLimMode)   
end

% Fire the mode accessor ActionPreCallback
brushmode.fireActionPostCallback(struct('Axes',ax));
    
% Clear selection ROI
selectionObject.reset;
brushmode.ModeStateData.lastRegion = [];
brushmode.ModeStateData.SelectionObject = [];

% Linked plots should resume updating linkedgraphics after a brush
linkMgr = datamanager.linkplotmanager;
if length(linkMgr.Figures)>=1
    if brushmode.ModeStateData.LastLinkState
        linkMgr.setEnabled('on');
    else
        linkMgr.setEnabled('off');
    end
end

% Restore LegendColorbarListeners
if ~isempty(findprop(handle(ax),'LegendColorbarListeners'))
    res = get(ax,'LegendColorbarListeners');
    for k=1:min(length(brushmode.ModeStateData.LegendColorbarListenersState),length(res))
        res(k).Enabled = brushmode.ModeStateData.LegendColorbarListenersState{k}; 
    end
end