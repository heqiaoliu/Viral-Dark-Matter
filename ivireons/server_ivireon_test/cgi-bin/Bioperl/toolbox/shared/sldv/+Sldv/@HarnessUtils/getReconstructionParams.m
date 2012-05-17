function [reconsParams, posShift, warnmsg] = getReconstructionParams(model, sldvData, maxConstHandle)

%   Copyright 2009 The MathWorks, Inc.

    warnmsg = ''; 
        
    warnmsgForCreation =  [ char(10) ...
                'Harness model can not be generated because the total flat dimension of the input '...
                'signals to the model ''%s'' is too big to be reconstructed at the harness model. '...                
                char(10)]; 
    warnmsgForCreation = sprintf(warnmsgForCreation,get_param(model,'Name'));  
            
    [MaxSimulinkRectLength, MaxZoomScale] = maxConstHandle();
          
    reconsParams.inportWidth   = 24;
    reconsParams.inportHeight  = 12;
    reconsParams.reshapeWidth  = 48;
    reconsParams.reshapeHeight = 18; 
    reconsParams.castWidth     = 75;
    reconsParams.castHeight    = 18;
    reconsParams.rateTranWidth = 48;
    reconsParams.rateTranHeight = 30;
    reconsParams.inportVertSep = 24;
    reconsParams.muxWidth      = 6; 
    reconsParams.mux2muxSep    = 96;    
    reconsParams.busCreateWidth = 20;
    reconsParams.minBlockHSep  = 36;    
    reconsParams.winBufferH    = 90;    
    reconsParams.winBufferV    = 150; 
    reconsParams.busTopV = 200;
    reconsParams.busBottomV = 400;
    
    reconsParams.muxLeft = reconsParams.winBufferH + reconsParams.inportWidth +reconsParams. mux2muxSep;
    reconsParams.reshapeLeft = reconsParams.muxLeft + reconsParams.muxWidth + reconsParams.minBlockHSep;
    reconsParams.castLeft = reconsParams.reshapeLeft + reconsParams.reshapeWidth + reconsParams.minBlockHSep;
    reconsParams.rateTranLeft = reconsParams.castLeft + reconsParams.castWidth + reconsParams.minBlockHSep;
    reconsParams.busCreateLeft =reconsParams.rateTranLeft + reconsParams.rateTranWidth + reconsParams.mux2muxSep;
    reconsParams.outportLeft = reconsParams.busCreateLeft + reconsParams.busCreateWidth + reconsParams.minBlockHSep; 
    
    baseWidth = ceil(1.5*(reconsParams.outportLeft+reconsParams.inportWidth-reconsParams.winBufferH));        
    
    InportInfo = sldvData.AnalysisInformation.InputPortInfo;
    nInports = length(InportInfo);
    
    portRectLength = zeros(1,nInports);
    cumSignalSize = zeros(1,nInports);
        
    posShift = struct('column',[],'prevCount',[]);       
            
    maxRectLength = 0;    
    currentcumSignalSize = 0;
    for i=1:nInports
        inportInfo = InportInfo{i};        
        [portRectLength(i),cumSignalSize(i)] = getMaxRectLength(inportInfo,reconsParams.winBufferV,reconsParams,currentcumSignalSize);
        currentcumSignalSize = cumSignalSize(i);
        maxRectLength = portRectLength(i)+maxRectLength;          
        shiftInfo.column = 0;
        shiftInfo.prevCount = 0;
        posShift(i) = shiftInfo;        
    end
    if maxRectLength>MaxSimulinkRectLength
        zoom_scale = ceil(maxRectLength/MaxSimulinkRectLength);
    else
        zoom_scale = 1;
    end

    if zoom_scale>MaxZoomScale
        if any(portRectLength>=MaxSimulinkRectLength)
            warnmsg = warnmsgForCreation;
            posShift = [];
            reconsParams = [];
            return;
        else
            currRectLength = 0;
            currColShift = 0;      
            maxColShift = ceil(MaxSimulinkRectLength/(baseWidth*zoom_scale));                        
            groupSize = 0;
            for i=1:nInports
                currRectLength = currRectLength+portRectLength(i);                
                if currRectLength>MaxSimulinkRectLength
                    currColShift = currColShift+1;                    
                    if currColShift > maxColShift                        
                        posShift = [];                        
                        break;
                    end
                    groupSize = cumSignalSize(i-1);                    
                    currRectLength = 0;                
                end
                shiftInfo.column = floor((currColShift*baseWidth)/zoom_scale);
                shiftInfo.prevCount = groupSize;
                posShift(i) = shiftInfo;                
            end
            if isempty(posShift)
                warnmsg = warnmsgForCreation;                
                reconsParams = [];
                return;            
            end
        end
    end            
       
    if  zoom_scale>1
        allparams = fieldnames(reconsParams);
        for i=1:length(allparams)
            fieldValue = reconsParams.(allparams{i});
            newfieldValue = floor(fieldValue/zoom_scale);
            reconsParams.(allparams{i}) = newfieldValue;
        end
    end
    
end

function  [maxRectLength,cumSignalSize] = getMaxRectLength(inportInfo,maxRectLength,reconsParams,cumSignalSize)                        
    if iscell(inportInfo)
        for i=2:length(inportInfo)
            [maxRectLength,cumSignalSize] = getMaxRectLength(inportInfo{i},maxRectLength,reconsParams,cumSignalSize); 
        end
    else
        dimension = prod(inportInfo.Dimensions);
        if dimension==1
            maxRectLength = maxRectLength+reconsParams.inportHeight+reconsParams.inportVertSep+reconsParams.inportHeight;                
        else
            maxRectLength = maxRectLength+reconsParams.inportHeight+reconsParams.inportVertSep+...               
                dimension*(reconsParams.inportHeight+reconsParams.inportVertSep)-reconsParams.inportVertSep;            
        end
        cumSignalSize = cumSignalSize + dimension;
    end
end