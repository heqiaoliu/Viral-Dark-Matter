function testCaseCompressed = compressTestCaseData(testCase)

%   Copyright 2008-2009 The MathWorks, Inc.

    testCaseCompressed = testCase;
    
    if isempty(testCaseCompressed.dataValues)            
        return;
    end 

    ultimateDataIndex = [];
    
    for i=1:length(testCaseCompressed.dataValues)   
        inportDataIndex = generateDataIndexForInport(testCaseCompressed.dataValues{i},...
                                                     testCaseCompressed.timeValues);                                                     
        if isempty(ultimateDataIndex)
            ultimateDataIndex = inportDataIndex;
        else
            ultimateDataIndex = union(inportDataIndex, ultimateDataIndex);
        end
    end
    
    finalTimeValues = testCaseCompressed.timeValues(ultimateDataIndex);
    
    if ~(length(testCaseCompressed.timeValues)==length(finalTimeValues) && ...
            all(testCaseCompressed.timeValues==finalTimeValues))
        % We need to resample dataValues
        for i=1:length(testCaseCompressed.dataValues)            
            dataValues = constructCompressDataValues( ...    
                                                    ultimateDataIndex, ...
                                                    testCaseCompressed.timeValues, ...
                                                    testCaseCompressed.dataValues{i});
            testCaseCompressed.dataValues{i} = dataValues;                                                                                                      
        end
        for i=1:length(testCaseCompressed.dataNoEffect)                        
            dataNoEffect = constructCompressDataValues( ...    
                                                ultimateDataIndex, ...
                                                testCaseCompressed.timeValues, ...
                                                testCaseCompressed.dataNoEffect{i});
            testCaseCompressed.dataNoEffect{i} = dataNoEffect;            
        end
        testCaseCompressed.timeValues = finalTimeValues;
        testCaseCompressed.stepValues = ultimateDataIndex;
    end
    
end

function inportDataIndex = generateDataIndexForInport(inportTestData, timeValues)
              
    if ~iscell(inportTestData)
        [Dimensions, timeSteps] = Sldv.DataUtils.getDimAndTime(inportTestData,timeValues);

        skipData = generateDataDiff(inportTestData, timeSteps, Dimensions);

        inportDataIndex(1) = 1;
        counter = 2;
        for i=1:timeSteps-1
            if ~skipData(i)
                inportDataIndex(end+1) = counter; %#ok<AGROW>
            end
            counter = counter+1;
        end
        if inportDataIndex(end)~=timeSteps
            inportDataIndex(end+1) = timeSteps; 
        end
    else
        inportDataIndex = [];
        for i=1:length(inportTestData)
           subInportDataIndex = generateDataIndexForInport(inportTestData{i},...
                                                           timeValues); 
           if isempty(inportDataIndex) 
               inportDataIndex = subInportDataIndex;
           else
               inportDataIndex = union(inportDataIndex,subInportDataIndex);
           end
        end        
    end
end                                                  

function skipData = generateDataDiff(inportTestData, timeSteps, Dimensions)
    flatData = reshape(inportTestData, [prod(Dimensions) timeSteps]);    
    skipData = logical(zeros(1,timeSteps-1)); %#ok<LOGL>
    for i=1:timeSteps-1;
        % if skipData(i)==true, then time step i+1 will be skipped
        skipData(i) = isequal(flatData(:,i+1),flatData(:,i));
    end
end

function dataValues = constructCompressDataValues( ...    
                                                ultimateDataIndex, ...
                                                timeValues, ...
                                                inportTestData)
                                                        
    if ~iscell(inportTestData)
        [Dimensions, numberTimeSteps] = Sldv.DataUtils.getDimAndTime(inportTestData,timeValues);

        dt = Sldv.DataUtils.flattenData(numberTimeSteps,Dimensions,inportTestData);                                                                            
        dt = dt(:,ultimateDataIndex);

        numberCompressedTimeSteps = length(ultimateDataIndex);

        dataValues = Sldv.DataUtils.reshapeData(numberCompressedTimeSteps,Dimensions,dt);                
    else
        numSignals = length(inportTestData);
        dataValues = cell(1,numSignals);        
        for i=1:numSignals
            dataValues{i} = constructCompressDataValues( ...                                                                                                                                
                                                        ultimateDataIndex, ...
                                                        timeValues, ...
                                                        inportTestData{i});
        end
    end
end