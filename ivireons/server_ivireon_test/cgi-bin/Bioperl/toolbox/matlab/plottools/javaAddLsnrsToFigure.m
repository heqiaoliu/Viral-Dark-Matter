function javaAddLsnrsToFigure (fig, javaSelectionManager)
% This undocumented function may be removed in a future release.
  
% This is a utility function used by the plot tool.

% Copyright 2002-2010 The MathWorks, Inc.

% Get a handle to the PlotManager
plotmgr = getappdata (fig, 'PlotManager');
if isempty(plotmgr)
    plotmgr = graphics.plotmanager;
    setappdata (fig, 'PlotManager', plotmgr);
end

% Create the PlotManager object-selection listener. TO DO: Remove the
% following conditions once hg objects use MCOS
model = graph2dhelper('findScribeLayer',fig);
selLsnr = handle.listener (plotmgr, ...
	     'PlotSelectionChange', ...
         {@selectionLsnr, javaSelectionManager});
% TO DO: Remove the following conditions once modes are ready     
if ~feature('HGUsingMATLABClasses')
    if ~isactiveuimode(fig,'Standard.EditPlot') && isempty(model.SelectedObjects)
        selectionLsnr([],struct('SelectedObjects',fig),javaSelectionManager);
    else
        selectionLsnr([],struct('SelectedObjects',model.SelectedObjects),...
            javaSelectionManager);
    end
end

% Second, create the PlotDone listener:
plotDoneLsnr = handle.listener (plotmgr, ...
         'PlotFunctionDone', ...
         {@figPlotDoneCallback, javaSelectionManager});

% Third, guarantee that the event handlers will not pass out of scope
% and be garbage-collected:
selPropName = 'SelectionMgrScribeSel';
if ~isprop(handle(fig), selPropName)
    % TO DO: Remove the following conditions once hg objects use MCOS
    if feature('HGUsingMATLABClasses')
        p = addprop(fig,selPropName);
        p.Transient = true;
        p.Hidden = true;
    else
        p = schema.prop (handle(fig), selPropName, 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    end
end
set (handle(fig), selPropName, selLsnr);

plotDonePropName = 'SelectionMgrPlotDone';
if ~isprop (handle(fig), plotDonePropName)
    % TO DO: Remove the following conditions once hg objects use MCOS
    if feature('HGUsingMATLABClasses')
        p = addprop(fig,plotDonePropName);
        p.Transient = true;
        p.Hidden = true;
    else
        p = schema.prop (handle(fig), plotDonePropName, 'MATLAB array');
        p.AccessFlags.Serialize = 'off';
        p.Visible = 'off';
    end
end
set (handle(fig), plotDonePropName, plotDoneLsnr);


%-------------------------------
function selectionLsnr(hProp, eventData, javaSelectionManager) %#ok<INUSL>


tmp = eventData.SelectedObjects;

% Remove invalid handles
ind = ~ishghandle(tmp);
tmp(ind) = [];

% Create an array of custom Property Panel UDD objects
customPanelObjs = cell(length(tmp),1);
customPanelsExist = false;
% No need to look for hg1 object series parents. 
% TO DO: Add behavior objects once they are implemented in hg2
if ~feature('HGUsingMATLABClasses')
    for i = 1:length(tmp)
      if ~isprop(tmp(i),'ShapeType') && ...
            (strcmp ('line', get (tmp(i),'type')) || ...
             strcmp ('patch', get (tmp(i),'type')) || ...
             strcmp ('text', get (tmp(i),'type')))
        theParent = handle (get (tmp(i), 'parent'));
        parentSuperClasses = get (classhandle(theParent), 'superclasses');
        if ~isempty (parentSuperClasses)
          if (strcmp ('series', get (parentSuperClasses(1),'name')))
            tmp(i) = theParent;
          end
        end 
      end

      % Register any custom Property Panels
      behavePlotEdit = hggetbehavior(tmp(i),'PlotTools','-peek');
      if ~isempty(behavePlotEdit) && ~isempty(behavePlotEdit.PropEditPanelObject)
          com.mathworks.page.plottool.PropertyEditor.registerGraphicsToPropPanel(...
              behavePlotEdit.PropEditPanelJavaClass,strrep(class(behavePlotEdit.PropEditPanelObject),'.','_'));
          customPanelObjs{i} = java(behavePlotEdit.PropEditPanelObject);
          customPanelsExist = true;
      end
    end
end
objs = javaGetHandles (tmp);
if customPanelsExist
    javaSelectionManager.onScribeSelectionChanged(objs,customPanelObjs);
else
    javaSelectionManager.onScribeSelectionChanged(objs);
end

%-------------------------------
function figPlotDoneCallback (~, ~, javaSelectionManager)
ac = javaSelectionManager.getFigureCanvas;
awtinvoke(ac, 'requestFocus()');
