function [sldvDataRandomized, warnmsg] = randomize(sldvData, randSeed) 
    % Randomly assign data values that don't affect objectives
    % to arbitrary values within the range of permissible values of
    % their data type.          

%   Copyright 2008-2010 The MathWorks, Inc.
    
    warnmsg = '';

    if ~isfield(sldvData,'Version') || ...
                Sldv.DataUtils.dataVersionLessThan(sldvData,'1.3')
        errstr = ['sldvData is in old format. Please use '...
                  'Sldv.DataUtils.convertToCurrentFormat(model, sldvData) to convert '...
                  'the sldvData to its current format before using '...
                  'Sldv.DataUtils.convertToCurrentFormat(sldvData, randSeed)'];
        error('SLDV:SldvDataUtils:Randomize:SldvDataOldFormat',errstr);        
    end
    
    sldvDataRandomized = sldvData;
    
    if Sldv.DataUtils.modelHasFixedPntInput(sldvData) && ...
            exist('fi','file')~=2
        warnmsg = [ char(10) ...
            'The randomization of data is not done because the ' ...
            'model has input signals of Fixed Point type and the Fixed-Point Toolbox is  ' ...
            'not installed. Fixed-Point Toolbox is required to correctly randomize test data.' ... 
            char(10)]; 
        return;
    end        
    
    SimData = Sldv.DataUtils.getSimData(sldvData);
    if isempty(SimData)    
        return;
    end
    
    % Cache the default random number stream and then create a new one with
    % initial state based on the number of model objects and objectives 
    savedDflt = RandStream.setDefaultStream(RandStream('mt19937ar','seed',randSeed));
    
    inportInfo = sldvDataRandomized.AnalysisInformation.InputPortInfo;
    
	for tstIdx = 1:length(SimData)
		dataValues = SimData(tstIdx).dataValues;
		dataNoEffect = SimData(tstIdx).dataNoEffect;
        numTimeSteps = length(SimData(tstIdx).timeValues);
        
        if isempty(dataValues)            
            continue;
        end        

        simData = SimData(tstIdx);
        for portIdx = 1:length(dataValues)

            computeInput = genRandomizedData(dataValues{portIdx}, ...
                                             dataNoEffect{portIdx}, ...
                                             inportInfo{portIdx}, ...
                                             numTimeSteps);

            simData.dataValues{portIdx} = computeInput;                                    
        end
        sldvDataRandomized = Sldv.DataUtils.setSimData(sldvDataRandomized,tstIdx,simData);
	end

    % Restore the default random number stream
    RandStream.setDefaultStream(savedDflt);
end

function computeInput = genRandomizedData(inportTestData, inportNoEffectData, ...
                                          inportInfo, numTimeSteps)
                                      
    if ~iscell(inportTestData)
        dimensions = inportInfo.Dimensions;
        
        computeInput = Sldv.DataUtils.flattenData(numTimeSteps,dimensions,inportTestData);
        noEffect = Sldv.DataUtils.flattenData(numTimeSteps,dimensions,inportNoEffectData);
                
        if any(any(noEffect))           
            flatdimensions = prod(dimensions);
            randomInput = Sldv.DataUtils.util_randvalue(flatdimensions,numTimeSteps,computeInput);            
            computeInput(noEffect) = randomInput(noEffect);                 
        end
        
        computeInput = Sldv.DataUtils.reshapeData(numTimeSteps,dimensions,computeInput);
    else
        computeInput = inportTestData;
        for i=1:length(computeInput)
            computeInput{i} = genRandomizedData(inportTestData{i}, inportNoEffectData{i}, ...
                                                inportInfo{i+1}, numTimeSteps);
        end
    end
end    