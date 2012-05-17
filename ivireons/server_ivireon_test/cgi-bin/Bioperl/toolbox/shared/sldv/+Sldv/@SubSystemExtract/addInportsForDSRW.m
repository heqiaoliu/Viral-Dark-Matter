function addInportsForDSRW(obj)

%   Copyright 2008-2010 The MathWorks, Inc.
   
    posConsts = genPositionConstants(obj.ModelH, obj.PortInfo);
        
    if isfield(obj.PortInfo,'DSMemPrm')
        for dsIdx = 1:length(obj.PortInfo.DSMemPrm)
            dsName = get_param(obj.PortInfo.dataStoreBlks(dsIdx),'DataStoreName');
            portH = Sldv.SubSystemExtract.addDSM(obj.ModelH, ...
                dsName, dsIdx, posConsts);
            addDesignMinMaxFromDSM(portH, obj.PortInfo.dataStoreBlks(dsIdx))
        end        
    end       
    
    posConsts.Bottom = findBottomLocation(obj.ModelH);        
    for idx=1:length(obj.ReferencedSimulinkSignalVars)
        signalVar = obj.ReferencedSimulinkSignalVars(idx);
        portH = Sldv.SubSystemExtract.addDSM(obj.ModelH, signalVar.Name, idx, posConsts);        
        addDesignMinMaxFromSimulinkSignal(portH, signalVar.Value) ;
    end      
        
end

function addDesignMinMaxFromDSM(portH, dsmBlockH)    
    set_param(portH, 'OutMin', get_param(dsmBlockH,'OutMin'))
    set_param(portH, 'OutMax', get_param(dsmBlockH,'OutMax'))
end

function addDesignMinMaxFromSimulinkSignal(portH, dsmObj)    
    set_param(portH, 'OutMin', num2str(dsmObj.Min))
    set_param(portH, 'OutMax', num2str(dsmObj.Max))
end

function posConsts = genPositionConstants(modelH, portInfo)    
    if portInfo.numOfInports>0
        rootMdlInports = find_system(modelH,'searchdepth',1,'BlockType','Inport');    
        position = get_param(rootMdlInports(1),'Position');        
    elseif portInfo.numOfOutports>0
        rootMdlOutports = find_system(modelH,'searchdepth',1,'BlockType','Outport');
        position = get_param(rootMdlOutports(1),'Position');        
    else
        position = [];
    end
    if ~isempty(position)
        posConsts.PrtWidth  = position(3)-position(1);
        posConsts.PrtHeight = position(4)-position(2);        
    else
        posConsts.PrtWidth = 30;
        posConsts.PrtHeight = 16;
    end
    
    posConsts.DsWidth = 4*posConsts.PrtWidth;
    posConsts.DsHeight = ceil(1.25*posConsts.PrtHeight);
    
    posConsts.PrtDsDelta = 50;        

    posConsts.Bottom = findBottomLocation(modelH);
end

function bottom = findBottomLocation(modelH)
    allBlocks = find_system(modelH,'SearchDepth',1);
    allBlocks(1) = [];    
    max_y = 0;
    for idx=1:length(allBlocks)
        position = get_param(allBlocks(idx),'Position');
        max_y = max(max_y, position(4));
    end
    bottom = max_y;
end

% LocalWords:  DS DSW Sldv TCA autorouting constrainstr ds dsm fxp
% LocalWords:  modelworkspace searchdepth sldtype sldvblockreplacementlib
