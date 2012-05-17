function brushPrism(ax,objs,crossX,lastregion,brushStyleIndex,...
    brushColor,mfile,fcnname)

% Brush all points in brushable graphics contained in the selection prism
% defined by the geoemetry O,basis,w,h

%   Copyright 2007-2008 The MathWorks, Inc.

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

for k=1:length(objs)
    gObjH = handle(objs(k));
    brushObj = getappdata(double(gObjH),'Brushing__');
    if isempty(brushObj) || ~ishandle(brushObj) || isempty(gObjH.findprop('BrushData'))
        brushObj = datamanager.enableBrushing(gObjH);
    end
    if linkedPlot
        gObjLinkInd = find(gObjH==linkFigureStruct.LinkedGraphics);
    end
    
    % Prevent brushing rotated histograms (g461328)
    if brushObj.isCustom
        continue;
    end
    
    
    
    try %#ok<TRYNC> % xdata,ydata may be out of sync in an HG error state
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Which points are in the prism? Project onto the crossection
        % (using the basis) and veify the projection is within the
        % crossection limits 0-h and 0-w.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        I = regionpicker(objs(k),crossX);
        I = I(:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Find the set difference between points enclosed by region
        % and lastregion.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~isempty(lastregion)
            Idiff = regionpicker(objs(k),lastregion);
            Idiff = Idiff(:);
            % For linked plot representations of surface plot in extnd
            % mode it is not usually possible to unselect entire rows.
            % Consequently, in order to make extend mode useful we
            % peform an or operation on entire rows, not just
            % individual points.
            if linkedPlot && ~isempty(gObjLinkInd) && isa(gObjH,'graph3d.surfaceplot')
                zdata = localGetZData(objs(k));
                I1 = false(size(zdata));
                I1(I) = true;
                I2 = false(size(zdata));
                I2(Idiff) = true;
                Irows1 = any(I1,2);
                Irows2 = any(I2,2);
                Iexpanded = logical((Irows1 & ~Irows2)*ones(1,size(I1,2)));
                Icontracted = logical((~Irows1 & Irows2)*ones(1,size(I1,2)));
                Idiff = (Iexpanded | Icontracted);
            else
                Iexpanded = I & ~Idiff;
                Icontracted = ~I & Idiff;
                Idiff = (Iexpanded | Icontracted);
            end
        else
            if linkedPlot && isa(gObjH,'graph3d.surfaceplot')
                zdata = localGetZData(objs(k));
                I1 = false(size(zdata));
                I1(I) = true;
                Irows1 = any(I1,2);
                Iexpanded = Irows1;
                Icontracted = [];
            else
                Iexpanded = I;
                Icontracted = [];
                Idiff = Iexpanded;
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Set/clear or toggle brushing array or BrushData values
        % corresponding to graphic points in the expanded/contracted
        % region.
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        isUnlinkedGraphic  = true;
        if linkedPlot && ~isempty(gObjLinkInd)
            varNames = localSetBrushArray(brushMgr,linkFigureStruct,...
                gObjLinkInd,Iexpanded,Icontracted,extendMode,brushColor,...
                mfile,fcnname);
            if ~isempty(varNames)
                linkedVarNames = [linkedVarNames(:);varNames(:)];
                isUnlinkedGraphic = false;
            end
        end
        if isUnlinkedGraphic
            Icurrent = gObjH.BrushData>0;
            % BrushData may be empty if points were removed
            if isempty(Icurrent)
                zdata = localGetZData(objs(k));
                Icurrent = false(size(zdata));
            end
            if extendMode
                Icurrent(Idiff) = ~Icurrent(Idiff);
            else
                Icurrent(Iexpanded) = true;
                Icurrent(Icontracted) = false;
            end
            I = Icurrent;
            
            brushData = uint8(I*brushStyleIndex);
            lastBrushData = gObjH.BrushData;
            
            % Turn off object brush listeners so that the draw method can
            % be used for speed up
            brushObj.setDataListenersEnabled('off');
            
            % Don't redraw/recolor unmodified graphics
            if ~isempty(brushData) && ~isequal(lastBrushData>0,brushData>0)
                gObjH.BrushData = brushData;
                brushObj.draw(fig); % Supply the parent figure for speed
            end
        end
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
% Inline copy of the same subfunction in brushRectangle
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


function zdata = localGetZData(obj)

zdata = [];
try %
    zdata = get(obj,'ZData');
catch mException
    if strcmp(mException.identifier,'MATLAB:class:InvalidProperty')
        return;
    else
        rethrow(mException);
    end
end