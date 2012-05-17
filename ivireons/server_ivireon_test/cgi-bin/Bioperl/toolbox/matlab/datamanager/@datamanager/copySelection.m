function copySelection(es,ed) %#ok<INUSD>

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
     if feature('HGUsingMATLABClasses')
          allBrushable = findobj(gContainer,'-function',...
              @(x) isprop(x,'BrushData') && ~isempty(get(x,'Brushdata')) && ...
                any(x.Brushdata(:)>0),...
              'HandleVisibility','on');
     else
         allBrushable = findobj(gContainer,'-Property','Brushdata',...
             'HandleVisibility','on');
     end
     allBrushable= findobj(allBrushable,'flat','-function',...
          @(x) ~isempty(get(x,'Brushdata')) && any(x.Brushdata(:)>0));
     unlinkedGraphics = setdiff(double(allBrushable),double(linkedGraphics));
     if ~isempty(linkedVarList) && ~isempty(unlinkedGraphics)
         msg = xlate('You are trying to copy data from a combination of graphics which are linked, unlinked, or linked to expressions. Please choose which type you want to use for the copy.');
         ButtonName = questdlg(msg, ...
                         'MATLAB', ...
                         'Linked','Unlinked','Abort','Abort');
         if isempty(ButtonName) ||  strcmp(ButtonName,'Abort')
             return
         elseif strcmp(ButtonName,'Unlinked')
             datamanager.copyUnlinked(unlinkedGraphics);
             return
         end
     elseif ~isempty(unlinkedGraphics)
         datamanager.copyUnlinked(unlinkedGraphics);
         return
     end
                     
     cachedVarValues = cell(length(linkedVarList),1);
     for k=1:length(cachedVarValues)
         cachedVarValues{k} = evalin('caller',[linkedVarList{k} ';']);
     end    
     datamanager.copyLinked(fig,linkedVarList,cachedVarValues,mfile,fcnname);
else
     datamanager.copyUnlinked(gContainer);
end