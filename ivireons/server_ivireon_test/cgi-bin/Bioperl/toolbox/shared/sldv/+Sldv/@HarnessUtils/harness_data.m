function [time, data] = harness_data(testCase, inportUsage)

% Copyright 1990-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

    time = {};
    data = {};

    if isempty(testCase.dataValues)
        return;
    end

    l = length(testCase.timeValues);
    ctime = testCase.timeValues(1);
    if l > 1
        for i=2:l-1
            ctime(end+1) = testCase.timeValues(i); %#ok<AGROW>
            ctime(end+1) = testCase.timeValues(i); %#ok<AGROW>
        end
        ctime(end+1) = testCase.timeValues(l);
    end
    time = { ctime };
    
    signalGroupCount = 1;
    for i = 1:length(testCase.dataValues)        
        if ~any(inportUsage{i})
            continue;
        end
        inportTestData = testCase.dataValues{i};
        flatTestData = getLeafNodes(inportTestData);        
        flatTestData = flatTestData(find(inportUsage{i})); %#ok<FNDSB>        
        numberSignals = getNumberSignalsOnSigBuilderPane(flatTestData,testCase.timeValues);
        testCaseFlatData = cell(numberSignals,1);
        index = 1;
        for k=1:length(flatTestData)
            subData = flatTestData{k};
            [dimensions, numberTimeSteps] = Sldv.DataUtils.getDimAndTime(subData,testCase.timeValues);
            flatSubData = Sldv.DataUtils.flattenData(numberTimeSteps, dimensions, subData);
            numberDataElem = prod(dimensions);
            for j=1:numberDataElem
                tdata = flatSubData(j,1);
                if numberTimeSteps>1
                    for step = 2:numberTimeSteps-1 
                        tdata(end+1) = flatSubData(j,step-1);
                        tdata(end+1) = flatSubData(j,step);
                    end
                    tdata(end+1) = flatSubData(j,numberTimeSteps);
                end
                testCaseFlatData{index}=tdata;
                index = index+1;
            end
        end
        data{signalGroupCount,1} = testCaseFlatData;
        signalGroupCount = signalGroupCount+1;
    end    
end

function list = getLeafNodes(inputNode,list)
    if nargin<2
        list = {};
    end
    if ~iscell(inputNode)
        list{end+1} = inputNode;
    else
        numSignals = length(inputNode);
        for i=1:numSignals
            list = getLeafNodes(inputNode{i},list);
        end
    end    
end

function n = getNumberSignalsOnSigBuilderPane(list,timeValues)
    n = 0;    
    for i=1:length(list)
        Dimensions = Sldv.DataUtils.getDimAndTime(list{i},timeValues);
        n = n + prod(Dimensions);
    end
end