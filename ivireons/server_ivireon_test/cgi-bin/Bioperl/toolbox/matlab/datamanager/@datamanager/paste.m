function paste(es,ed) %#ok<INUSD>

% Paste the current selection to the command line

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
     [linkedVarList,linkedGraphics] = getLinkedVarsFromGraphic(...
         h,gContainer,mfile,fcnname);
     if feature('HGUsingMATLAbClasses')
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
     
     % If there are unlinked graphics or expression based graphics, ask
     % which should be pasted.
     if ~isempty(linkedVarList) && ~isempty(unlinkedGraphics)
         msg = xlate('You are trying to paste data from a combination of graphics which are linked, unlinked, or linked to expressions.');
         ButtonName = questdlg(msg, ...
                         'MATLAB', ...
                         'Linked','Unlinked','Abort','Abort');
         if isempty(ButtonName) || strcmp(ButtonName,'Abort')
             return
         elseif strcmp(ButtonName,'Unlinked')
             datamanager.pasteUnlinked(unlinkedGraphics);
             return
         end
     elseif ~isempty(unlinkedGraphics) % Only unlinked
         datamanager.pasteUnlinked(unlinkedGraphics);
         return
     end
     
     cachedVarValues = cell(length(linkedVarList),1);
     for k=1:length(cachedVarValues)
         cachedVarValues{k} = evalin('caller',[linkedVarList{k} ';']);
     end
     datamanager.pasteLinked(fig,linkedVarList,cachedVarValues,mfile,fcnname);
else
     datamanager.pasteUnlinked(gContainer);
end