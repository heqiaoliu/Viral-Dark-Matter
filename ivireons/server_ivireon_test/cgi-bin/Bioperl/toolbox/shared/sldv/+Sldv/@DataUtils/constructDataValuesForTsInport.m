% Function: constructDataValuesForTsInport ==================================
% Abstract:
%   This function constructs the dataValues and dataNoEffect objects for
%   the given testData of the inport. They are both Simulink.Timeseries
%   objects.
%
function [inportValuesObj, leafeIdx] = constructDataValuesForTsInport( ...                                                                
                                                                leafeIdx, ...
                                                                inportInfoData, ...  
                                                                timeExpanded, ...
                                                                timeCompressed, ...                                                                   
                                                                inportTestData)

%   Copyright 2008-2009 The MathWorks, Inc.
                                                          
        
        if ~iscell(inportTestData)
            Dimensions = Sldv.DataUtils.getDimAndTime(inportTestData,timeCompressed);            
                                                                                         
            DataMatrix = Sldv.DataUtils.interpBelow(timeCompressed, inportTestData, timeExpanded, ...
                                                    Dimensions);
                                                
            % Create a timeseries object. The isTimeFirst property should 
            % be assigned to true for 2-d data and false otherwise unless
            % there is a single sample, in which case isTimeFirst is true 
            % if and only if signal is scalar.
            if length(timeExpanded)==1
                isTimeFirst = ndims(DataMatrix)<=2 && size(DataMatrix,1)==1 && ...
                    length(Dimensions)<=1;
                tempMLtimeseriesobj = timeseries(DataMatrix,timeExpanded,'IsTimeFirst',...
                    isTimeFirst,'InterpretSingleRowDataAs3D',~isTimeFirst);   
            else
                isTimeFirst = ndims(DataMatrix)<=2; 
                tempMLtimeseriesobj = timeseries(DataMatrix,timeExpanded,'IsTimeFirst',...
                    isTimeFirst); 
            end
           
            inportValuesObj = Simulink.Timeseries(tempMLtimeseriesobj);       

            if isfield(inportInfoData, 'Name')
                inportValuesObj.Name = inportInfoData.Name;
                inportValuesObj.BlockPath = inportInfoData.BlockPath;
                inportValuesObj.PortIndex = inportInfoData.PortIndex;
                inportValuesObj.SignalName = inportInfoData.SignalName;
                inportValuesObj.ParentName = inportInfoData.ParentName;                              
            end        
            
            leafeIdx = leafeIdx+1;
        else                        
            inportValuesObj = Simulink.TsArray;
            
            if isfield(inportInfoData, 'Name')
                inportValuesObj.Name = inportInfoData.Name;
                inportValuesObj.BlockPath = inportInfoData.BlockPath;
                inportValuesObj.PortIndex = inportInfoData.PortIndex;                                                
            end
            
            subInportInfoData = inportInfoData;            
            
            numSignals = length(inportTestData);
            
            subNames = cell(1,numSignals);
            subElems = cell(1,numSignals);
            subClass = cell(1,numSignals);
            
            elements = cell(1,numSignals);      
            
            for i=1:numSignals
                subTestData = inportTestData{i};             
                
                subInportInfoData.Name = sprintf('%s_%d',inportInfoData.Name,i);
                subInportInfoData.SignalName = sprintf('%s.%d',inportInfoData.SignalName,i);
                                
                
                [subinportValuesObj, leafeIdx] = Sldv.DataUtils.constructDataValuesForTsInport( ...                                                                           
                                                                                                leafeIdx, ...
                                                                                                subInportInfoData, ...  
                                                                                                timeExpanded, ...
                                                                                                timeCompressed, ...                                                                         
                                                                                                subTestData);
                                                                            
                                                            
                
                if isa(subinportValuesObj,'Simulink.TsArray')
                    inportValuesObj.IsBus = 1;                   
                    subClass{i} = 'TsArray';
                    subElems{i} = length(subinportValuesObj.members);
                else                    
                    subClass{i} = 'Timeseries';
                    subElems{i} = 1;
                end
                                                            
                subNames{i} = subinportValuesObj.Name;                                                
                elements{i} = subinportValuesObj;
            end
            
            inportValuesObj.Members = struct('name',subNames,'elems',subElems,'class',subClass);       
            
            for i=1:numSignals
                schema.prop(inportValuesObj,subNames{i},'MATLAB array');                
            end
                                 
            for i=1:numSignals
                inportValuesObj.(subNames{i}) = elements{i};
            end                  
        end
end