function brushRectangle(ax,objs,obj,region,lastregion,brushStyleIndex,...
    brushColor,mfile,fcnname)

% Brush all points in brushable graphics contained in the selection
% rectangle defined by the geoemetry p1,offset

%   Copyright 2007-2010 The MathWorks, Inc.

% For linked plots the following mechanism is used.
% 1. Obtain the brushing array for each brushed graphic
% 2. Use it to modify the brushing array for each variable, possibly
% creating rows which are not completely brushed in the process.
% 3. Redraw the brushing array for any affected variables. Note that
% all cells in any brushed row to be brushed.

if feature('HGUsingMATLABClasses')
    brushRegionUsingMATLABClasses(ax,objs,region,lastregion,brushStyleIndex,...
       brushColor,mfile,fcnname);
    return
end

% Get the Linked Figure struct for this axes, if any
brushMgr = datamanager.brushmanager;
linkMgr = datamanager.linkplotmanager;
linkFigureStruct = [];
linkedVarNames = {};
linkedPlot = false;
fig = ancestor(ax,'figure');
if ~isempty(linkMgr.Figures) 
    ind = [linkMgr.Figures.('Figure')]==handle(fig);
    linkedPlot = any(ind);
    if linkedPlot
        linkFigureStruct = linkMgr.Figures(ind);
    end
end

% Is the brush gesture in extend mode
extendMode = strcmpi(get(fig,'SelectionType'),'extend');

if ischar(brushColor)
    brushColor = brushing.utConvertColorSpecString(brushColor);
    if isempty(brushColor)
        return
    end
end

for k=1:length(objs)
    objH = handle(objs(k));
    brushObj = getappdata(double(objH),'Brushing__');     
    if isempty(brushObj) || ~ishandle(brushObj) || isempty(objH.findprop('BrushData'))
        brushObj = datamanager.enableBrushing(objH);
    end
    if linkedPlot
        gObjLinkInd = find(objH==linkFigureStruct.LinkedGraphics);
    end   
    % Get the xdata,ydata for the current object
    if isa(handle(objs(k)),'specgraph.areaseries')
        [xdata,ydata] = getExtent(brushObj);
    elseif isa(handle(objs(k)),'specgraph.barseries')
        [xdata,ydata] = getExtent(brushObj);
    elseif isa(handle(objs(k)),'graph3d.surfaceplot')
        ydata = get(objs(k),'YData');
        xdata = get(objs(k),'XData');
        zdata = get(objs(k),'ZData');
        if isvector(xdata)
            xdata = xdata(:)';
            xdata = ones(size(zdata,1),1)*xdata;
        end   
        if isvector(ydata)
            ydata = ydata(:)*ones(1,size(zdata,2));
        end 
    else
        ydata = get(objs(k),'YData');
        xdata = get(objs(k),'XData');
    end
    
    try % xdata,ydata may be out of sync in an HG error state
        if ~brushObj.isCustom
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Find the set difference between points enclosed by region
            % and lastregion.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            if length(region)==4 % ROI brushing
                I = (ydata<=region(2)+region(4) & ydata>=region(2)) & ...
                    (xdata<=region(1)+region(3) & xdata>=region(1));
                if ~isempty(lastregion)
                    Idiff = (ydata<=lastregion(2)+lastregion(4) & ...
                            ydata>=lastregion(2)) & ...
                            (xdata<=lastregion(1)+lastregion(3) & ...
                             xdata>=lastregion(1));                  
                    Iexpand = I & ~Idiff;
                    Icontract = ~I & Idiff;
                    Idiff = (Iexpand | Icontract);
                else
                   Idiff = I;
                   Iexpand = I;
                   Icontract = [];
                end
                % If nothing changed for this graphic, quick return
                if ~any(Iexpand(:)) && ~any(Icontract(:))
                    continue;
                end
            elseif length(region)==2 % Vertex only brushing, find closest
                I = false(size(ydata));
                if objs(k)==obj
                    % Clicking on a barseries bar must select the closest
                    % bar with matching horizontal position since the
                    % vertical position of the click is not meaninful.
                    if isa(objH,'specgraph.barseries')
                        if strcmp(get(objH,'Horizontal'),'off')
                            [~,I1] = min(abs(xdata-region(1)));  
                        else
                            [~,I1] = min(abs(ydata-region(2)));  
                        end
                    else     
                        xscale = diff(get(ax,'xlim'));
                        yscale = diff(get(ax,'ylim'));
                        [~,I1] = min(abs(xdata/xscale+1i*ydata/yscale-...
                            (region(1)/xscale+1i*region(2)/yscale)));
                    end
                    I(I1(1)) = true;
                    Iexpand = I;
                    Idiff = I;
                    Icontract = [];
                end
               
            elseif isempty(region)
                Iexpand = false(size(ydata));
                Icontract = [];
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Set/clear or toggle brushing array or BrushData values 
            % corresponding to graphic points in the expanded/contracted
            % region.
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
            isUnlinkedGraphic  = true;
            if linkedPlot && ~isempty(gObjLinkInd)
                varNames = localSetBrushArray(brushMgr,linkFigureStruct,gObjLinkInd,...
                                 Iexpand,Icontract,extendMode,brushColor,mfile,fcnname);
                if ~isempty(varNames)
                    linkedVarNames = [linkedVarNames(:);varNames(:)];
                    isUnlinkedGraphic = false;
                end
            end
            if isUnlinkedGraphic
                if isa(objH,'graph3d.surfaceplot')
                    Icurrent = (objH.BrushData>0);
                    % BrushData may be empty if points were removed
                    if isempty(Icurrent) 
                        Icurrent = false(size(zdata));
                    end
                else
                    Icurrent = any(objH.BrushData>0,1);
                    % BrushData may be empty if points were removed
                    if isempty(Icurrent)
                        Icurrent = false(size(ydata));
                    end
                end
                if extendMode 
                    Icurrent(Idiff) = ~Icurrent(Idiff);
                else
                    Icurrent(Iexpand) = true;
                    Icurrent(Icontract) = false;
                end
                I = Icurrent;               
                brushData = uint8(I*brushStyleIndex);
                lastBrushData = objH.BrushData;
                
                % Turn off object brush listeners so that the draw method can
                % be used for speed up 
                brushObj.setDataListenersEnabled('off');
            
                % Don't redraw/recolor unmodified graphics 
                if ~isempty(brushData) && ~isequal(lastBrushData>0,brushData>0)            
                    objH.BrushData = brushData;
                    brushObj.draw(fig); % Supply the parent figure for speed       
                end
            end
        else % Deal with custom objects
            if linkedPlot && ~isempty(gObjLinkInd)
                if ~isempty(brushObj.LinkBehaviorObject)                    
                    I = datamanager.getVarBrushArrayUsingLinkedBehavior(linkMgr,...
                        ind,brushObj.LinkBehaviorObject,objH,region,lastregion,...
                        extendMode,mfile,fcnname);

                    brushMgr.setBrushingProp(linkFigureStruct.VarNames{gObjLinkInd,2},...
                            mfile,fcnname,'I',I,'Color',brushColor);
                    varNames = linkFigureStruct.VarNames(gObjLinkInd,2);
                    linkedVarNames = [linkedVarNames(:);varNames(:)];
                end
            else % Unlinked plot custom object brushing
                if ~isempty(brushObj.BrushBehaviorObject)
                    feval(brushObj.BrushBehaviorObject.BrushFcn{1},region,objH,...
                        extendMode,brushObj.BrushBehaviorObject.BrushFcn{2:end});
                end
            end         
        end
    catch %#ok<CTCH>
    end
end

% Restore the BrushData listeners
for k=1:length(objs)
    brushObj = getappdata(double(objs(k)),'Brushing__');
    brushObj.setDataListenersEnabled('on');
end

% Refresh the brush manager if any linked graphics were brushed. This
% should be done after brushing arrays have been updated to minimize 
% the update traffic when brushing multiple graphics from the same variable
if ~isempty(linkedVarNames)
    linkedVarNames = unique(linkedVarNames);
    for k=1:length(linkedVarNames)
        brushMgr.draw(linkedVarNames{k},mfile,fcnname);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inline copy of the same subfunction in brushPrism
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function linkedVarNames = localSetBrushArray(brushMgr,linkFigureStruct,...
                           gObjLinkInd,Iextend,Icontract,extendMode,...
                           brushColor,mfile,fcnname)


% Use the gObjH BrushData property to subs-assign into the BrushingArray of
% the corresponding data sources. Returns up to 3 references variable names
% in the 3 data sources.

linkedVarNames = [];
if ~isempty(get(linkFigureStruct.LinkedGraphics(gObjLinkInd),'linkDataError'))
    return
end
linkedVarNames = cell(3,1);
for row=1:3
    varName = linkFigureStruct.VarNames{gObjLinkInd,row};
    
    if ~isempty(varName)
        I = brushMgr.getBrushingProp(varName,mfile,fcnname,'I'); 
        if isempty(I) % Brushed axpression
            continue;
        end
        Igraphic = eval(['I' linkFigureStruct.SubsStr{gObjLinkInd,row} ';']);
        linkedVarNames{row} = varName;
        if extendMode
            Igraphic(Iextend) = ~Igraphic(Iextend);
            Igraphic(Icontract) = ~Igraphic(Icontract);            
        else
            Igraphic(Iextend) = true;
            Igraphic(Icontract) = false;
        end
        changeStatus = localSetBrushingArraySubstr(brushMgr,varName,...
            linkFigureStruct.SubsStr{gObjLinkInd,row},Igraphic,mfile,fcnname);
        if changeStatus
             brushMgr.setBrushingProp(varName,mfile,fcnname,'Color',...
                 brushColor);
        end
    end
end
linkedVarNames = linkedVarNames(~cellfun('isempty',linkedVarNames));

function changeStatus = localSetBrushingArraySubstr(h,varName,subsstr,I,mfilename,fcnname)

% Subassign the brushing array using the subsstr for the specified variable
changeStatus = false;
ind = find(strcmp(varName,h.VariableNames) & strcmp(mfilename,h.DebugMFiles) & ...
       strcmp(fcnname,h.DebugFunctionNames));
if isempty(ind)
    return
end

% I always comes in a row vector (BrushData property). If varName is a 
% column vector we need to transpose. If varName is an array ...
if isempty(subsstr)
    if isequal(size(h.SelectionTable(ind).I),size(I))
        Ilocal = I;
    else
        Ilocal = I';
    end
else
    Ilocal = h.SelectionTable(ind).I;    
    try
        eval(['Ilocal' subsstr ' = I;']);
    catch %#ok<CTCH>
    end
end

Iexist = h.getBrushingProp(ind,mfilename,fcnname,'I');
if ~isequal(Iexist,I)
    h.setBrushingProp(ind,mfilename,fcnname,'I',Ilocal);
    changeStatus = true;
end