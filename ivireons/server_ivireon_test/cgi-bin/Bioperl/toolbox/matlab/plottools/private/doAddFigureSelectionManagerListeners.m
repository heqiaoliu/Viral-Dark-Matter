function doAddFigureSelectionManagerListeners(fig,selectionManager)

% Add listeners to the objects being removed from the figure so that the
% SelectionManager array of selected objects can be pruned
if feature('HGUsingMATLABClasses')
    if ~isprop(fig,'PlotSelectionListener')
       p = addprop(fig,'PlotSelectionListener');
       p.Transient = true;
       p.Hidden = true;
    end

    sv = hg2gcv(fig);
    if isempty(fig.PlotSelectionListener)
       fig.PlotSelectionListener = event.listener(sv,'PostUpdate',...
           @(es,ed) selectionManager.updateSelectedObjectArray(getFigureChildrenList(fig)));
    end
    % TO DO: We need do something about uipanels
else
    fig = handle(fig);
    if ~isprop(fig,'PlotSelectionListener')
        p = schema.prop(fig, 'PlotSelectionListener', 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        set (p, 'Visible', 'off');
    end
    
    if isempty(fig.PlotSelectionListener)
        fig.PlotSelectionListener = [handle.listener(fig,'ObjectChildAdded',...
                               {@localFigChildAdded selectionManager}); ...
                                     handle.listener(fig,'ObjectChildRemoved',...
                               {@localFigChildRemoved selectionManager})];
        ax = findobj(fig,'Type','axes');
        for k=1:length(ax)
            localFigChildAdded(fig,struct('Child',ax(k)),selectionManager);
        end
    end
end

function localFigChildAdded(~,ed,selectionManager)

% Add listeners to all axes that are added which purge the SelectionManager
% internal array of selected objects when they are removed
axesList = handle(findobj(ed.Child,'type','axes'));
for k=1:length(axesList)
    ax = handle(axesList(k));
    if isa(ax,'axes')
        if ~isprop(ax,'PlotSelectionListener')
            p = schema.prop(ax, 'PlotSelectionListener', 'MATLAB array');
            p.AccessFlags.Serialize = 'off';
            set (p, 'Visible', 'off');
        end   

        if isempty(ax.PlotSelectionListener)
            ax.PlotSelectionListener = handle.listener(ax,'ObjectChildRemoved',...
                {@localAxesChildRemoved selectionManager});
        end
    end
end

function localAxesChildRemoved(~,ed,selectionManager)

% Purge the removed child from the SelectionManager list of 
childbean = java(ed.Child);
if ~isempty(childbean)
   selectionManager.purgeSelectedObjectArray(childbean);
end

function localFigChildRemoved(~,ed,selectionManager)

if isa(ed.Child,'axes')
    childbeans = java(handle(findobj(ed.Child)));
    if ~isempty(childbeans)
        selectionManager.purgeSelectedObjectArray(childbeans);
    end
end