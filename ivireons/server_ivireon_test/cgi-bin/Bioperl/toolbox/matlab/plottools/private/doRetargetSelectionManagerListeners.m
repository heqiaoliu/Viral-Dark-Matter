function doRetargetSelectionManagerListeners(f)


% Enable the SelectionManager listener for the supplied figure and disable
% them for all other figures. This method is used by the Plot Tools to
% prevent these listeners firing for undocked or unselected figures.

allFig = findobj(handle(0),'type','figure','-function',...
    @(h) isprop(h,'PlotSelectionListener') && ~isempty(get(h,'PlotSelectionListener')));
for k=1:length(allFig)
    fig = handle(allFig(k));
    % Handle udd vs MCOS listeners
    if isobject(fig.PlotSelectionListener)
        fig.PlotSelectionListener.Enabled = (nargin>=1 && fig==f);
    else
        if (nargin>=1 && fig==f)
            set(fig.PlotSelectionListener,'Enabled','on');
        else
            set(fig.PlotSelectionListener,'Enabled','off');
        end
    end
    % Fire the SelectionManager listener callback when the 
    % listener is renabled so that it is up to date.
    if isprop(fig,'SelectionManager')
        fig.SelectionManager.updateSelectedObjectArray(getFigureChildrenList(fig));
    end

end

    
