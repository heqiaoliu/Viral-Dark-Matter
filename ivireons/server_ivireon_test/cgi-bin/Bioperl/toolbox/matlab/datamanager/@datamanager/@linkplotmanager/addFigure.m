function addFigure(h,f,mfile,fcnname)

% Clean up any deleted figures that were incorrectly handled
if ~ishghandle(f)
    return
end
if ~isempty(h.Figures)
   h.Figures(~ishghandle([h.Figures.Figure])) = [];
end

if isempty(h.Figures) || ~any([h.Figures.('Figure')]==f)
    % Add LinkPlot property
    if isempty(f.findprop('LinkPlot'))
        if feature('HGUsingMATLABClasses')
           p = addprop(f,'LinkPlot');
           p.Transient = true; 
        else
           p = schema.prop(f,'LinkPlot','bool');
           p.AccessFlags.Serialize = 'off';
        end        
    end
    set(f,'LinkPlot',true);

    figStruct = struct('Figure',f,'Panel',{[]},'VarNames',{{}},'SubsStr',{{}},'LinkedGraphics',{[]},...
             'FigureListeners',{[]},'EventManager',{[]},'DisplayNameListeners',{[]},...
             'CloseListeners',{[]},'SourceDialog',[],'IsEmpty',[],'Dirty',false);
    h.Figures = [h.Figures(:); figStruct];
    ind = length(h.Figures);
else
    ind = find([h.Figures.('Figure')]==f);
end
figStruct = h.updateLinkedGraphics(ind(1));
h.linkListener.postRefresh;
% updateLinkedGraphics may force the figure out of linked mode if
% non-linkable data has been plotted. In this case we need to abort
% the creation of the linked plot panel. G530012
if isempty(figStruct) 
   return
end

% Add a LinkedPlotPanel. Make sure scene viewer is created when using MCOS
% graphics so that its peer has been created by the time the LinkedPlotPanel
% is added to the figure. If this is not done until after the LinkedPlotPanel
% is added then the addSceneServerPeer() on the FigurePeer/FigureHG2Mediator
% will call reconstructFigurePanel() on the FigurePanel which rebuilds 
% the figPeer.getFigurePanelContainer() wiping out the LinkedPlotPanel.
if feature('HGUsingMATLABClasses')
    hg2gcv(f);
end
h.createlinkpanel(f);
h.Figures(ind(1)).Panel.open;

% Install a listener to refresh the Action Panel selection of a live plot
% is closed
localAddFigCloseListener(f,h,ind(1));

% Wait until animation is complete before building listeners
pause(0.2);

% Draw brushing for any newly linked variables.
h.drawBrushing(ind(1),mfile,fcnname);

% Build listener tree last since it might take a while
h.installGraphicListeners(f);

% Make sure the linked plot listener is on
h.setEnabled('on');

function localAddFigCloseListener(f,h,ind)

h.Figures(ind).CloseListeners = ...
    addlistener(f,'ObjectBeingDestroyed',@(es,ed) rmFigure(h,handle(es)));
