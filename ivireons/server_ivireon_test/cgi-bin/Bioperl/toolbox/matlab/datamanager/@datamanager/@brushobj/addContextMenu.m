function addContextMenu(this)

% Create and add a context menu to the supplied graphic object. Updates
% the corresponding datamanager object

if ~isempty(this.ContextMenu) && ishandle(this.ContextMenu)
    if any(cellfun('isempty',get(this.SelectionHandles,{'uicontextmenu'})))
        set(this.SelectionHandles,'uicontextmenu',this.ContextMenu);
    end
    return
end

fig = ancestor(this.HGHandle,'figure');
ax = ancestor(this.HGHandle,'axes');
cmenu = uicontextmenu('Parent',fig,'Serializable','off','Tag',...
    'BrushSeriesContextMenu');
setappdata(fig,'BrushingContextMenu',cmenu);
mreplace = uimenu(cmenu,'Label','Replace with','Tag','BrushSeriesContextMenuReplaceWith');
uimenu(mreplace,'Label','NaNs','Tag','BrushSeriesContextMenuNaNs','Callback',{@datamanager.dataEdit 'replace' NaN});
uimenu(mreplace,'Label','Define a constant...','Tag','BrushSeriesContextMenuDefineAConstant','Callback',...
  {@datamanager.dataEdit 'replace'});
uimenu(cmenu,'Label','Remove','Tag','BrushSeriesContextMenuRemove','Callback',{@datamanager.dataEdit 'remove' false});
uimenu(cmenu,'Label','Remove Unbrushed','Tag','BrushSeriesContextMenuRemoveUnbrushed','Callback',...
  {@datamanager.dataEdit 'remove' true});
uimenu(cmenu,'Label','Create Variable','Tag','BrushSeriesContextMenuCreateVariable','Callback',...
  {@datamanager.newvar},'Separator','on');
uimenu(cmenu,'Label','Paste Data to Command Line','Tag','BrushSeriesContextMenuPasteDataToCommandLine','Callback',...
  {@datamanager.paste},'Tag','LiveLine','Separator','on');
uimenu(cmenu,'Label','Copy Data to Clipboard','Tag','BrushSeriesContextMenuCopyDataToClipboard','Callback',...
  {@datamanager.copySelection});
uimenu(cmenu,'Label','Clear all brushing','Tag','BrushSeriesContextMenuClearAllBrushing','Callback',...
  {@localClearBrushing ax},'Separator','on');
this.ContextMenu = cmenu;
for k=1:length(this.SelectionHandles)
     set(this.SelectionHandles(k),'uicontextmenu',cmenu);
end

function localClearBrushing(es,ed,ax)

fig = handle(ancestor(ax,'figure'));
brushMgr = datamanager.brushmanager;
if ~isempty(fig.findprop('LinkPlot')) && fig.LinkPlot    
    [mfile,fcnname] = datamanager.getWorkspace(1);
    brushMgr.clearLinked(fig,ax,mfile,fcnname);
end
brushMgr.clearUnlinked(ax);

