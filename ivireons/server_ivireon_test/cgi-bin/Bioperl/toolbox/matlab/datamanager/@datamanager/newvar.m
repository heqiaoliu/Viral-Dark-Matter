function newvar(es,ed) %#ok<INUSD>

% Creates a new variable from brushed graphics

% Get the host axes/figure

% Copyright 2008-2010 The MathWorks, Inc.

fig = ancestor(es,'figure');
gContainer = fig;
if ~isempty(es) && ~isempty(ancestor(es,'uicontextmenu'))
    gContainer = get(fig,'CurrentAxes');
    if isempty(gContainer)
        gContainer = fig;
    end
end

if datamanager.isFigureLinked(fig)
     h = datamanager.linkplotmanager;
     [mfile,fcnname] = datamanager.getWorkspace(1);
     [linkedVarList,linkedGraphics] = h.getLinkedVarsFromGraphic(...
         gContainer,mfile,fcnname);
     allBrushable = datamanager.getAllBrushedObjects(gContainer);
     unlinkedGraphics = setdiff(double(allBrushable),double(linkedGraphics));
     if ~isempty(linkedVarList) && ~isempty(unlinkedGraphics)
         msg = xlate('You are trying to create a variable from a combination of graphics which are linked, unlinked, or linked to expressions.');
         ButtonName = questdlg(msg, ...
                         'MATLAB', ...
                         'Linked','Unlinked','Abort','Abort');
         if isempty(ButtonName) ||  strcmp(ButtonName,'Abort')
             return
         elseif strcmp(ButtonName,'Unlinked')
             localNewVarUnlinked(unlinkedGraphics);
             return
         end
     elseif ~isempty(unlinkedGraphics)
         localNewVarUnlinked(unlinkedGraphics);
         return
     end    
     
    cachedVarValues = cell(length(linkedVarList),1);
    for k=1:length(cachedVarValues)
         cachedVarValues{k} = evalin('caller',[linkedVarList{k} ';']);
    end
    datamanager.newvardisambiguateVariables(fig,linkedVarList,cachedVarValues,mfile,fcnname,...
        @localMultiVarCallback);
else   
    localNewVarUnlinked(gContainer);
end

function localNewVarUnlinked(gContainer)

sibs = datamanager.getAllBrushedObjects(gContainer);
if isempty(sibs)
    errordlg('At least one graphic object must be brushed','MATLAB','modal')
else
    datamanager.newvardisambiguate(handle(sibs),@localMultiObjCallback);
end
    
function outData = localMultiObjCallback(gobj)

if feature('HGUsingMATLABClasses')
    outData = brushing.select.getArraySelection(gobj);
else   
   this = getappdata(double(gobj),'Brushing__');
   outData = this.getArraySelection;
end


function outData = localMultiVarCallback(varName,varValue,mfile,fcnname)

brushMgr = datamanager.brushmanager;
I = brushMgr.getBrushingProp(varName,mfile,fcnname,'I');
if isvector(varValue)
    outData = varValue(I);
else
    outData = varValue(any(I,2),:);
end
       


