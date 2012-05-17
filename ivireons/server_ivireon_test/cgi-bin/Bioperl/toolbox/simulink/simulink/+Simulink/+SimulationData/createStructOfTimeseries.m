function ret = createStructOfTimeseries(arg1, leafData)
% Construct a structure with leaves that are timeseriers object.
% CONSTRUCT FROM TSARRAY:
%   >> s = Simulink.SimulationData.createStructOfTimeseries(tsarray);
% CONSTRUCT FROM BUS OBJECT:
%   >> s = Simulink.SimulationData.createStructOfTimeseries('MyBus', tsarray)
%   >> s = Simulink.SimulationData.createStructOfTimeseries('MyBus', {ts1, ts2 ...})
%
% Copyright 2010 The MathWorks, Inc.

    % CHECK ARGUMENTS
    if isa(arg1,'Simulink.TsArray')
    % If first argument is TsArray, no second argument is allowed
        if nargin > 1
            DAStudio.error('Simulink:SimInput:InvalidCreateStructTsArrayArg');
        end
        
    elseif ischar(arg1)
    % If second argument is the name of a Bus object, second argument is 
    % required for leaf initialization.
        if nargin < 2 || ~iscell(leafData)
            DAStudio.error('Simulink:SimInput:InvalidCreateStructBusObjArg');
        end
        
    else
        DAStudio.error('Simulink:SimInput:InvalidCreateStructArg');
    end
    
    % CREATE FROM TSARRAY without validating against bus object
    if isa(arg1,'Simulink.TsArray')
        ret = locCreateFromTsArray(arg1);
        
    % CREATE struct from BUS OBJECT
    else
        % Create the structure
        try
            hierStruct = Simulink.Bus.createMATLABStruct(arg1);
            flatElTypes = evalin('base', [arg1 '.getLeafBusElements']);
        catch me
             DAStudio.error('Simulink:SimInput:InvalidCreateStructBusObj');
        end
        
        % Check the number of leaves
        if length(flatElTypes) ~= length(leafData)
            DAStudio.error('Simulink:SimInput:InvalidCreateStructDataNumData');
        end

        % Now set the leaf data from cell array. The "startIdx"
        % parameter is 1 because we are starting at the first leaf
        % element.
        [ret ~] = locFillInLeaves(hierStruct, flatElTypes, leafData, 1);   
    end

end

%% LOCAL FUNCTIONS ========================================================

%% Function locCreateFromTsArray ------------------------------------------
function ret = locCreateFromTsArray(tsArray)
% Construct a struct of timeseries from a Simulink.TsArray object.
% Hierarchy structure of the TsArray is maintained and no validation is
% performed (no Bus object is used). Note that TsArray permits signal names
% that are NOT MATLAB-valid identifiers.
    
    % Fill in leaf data
    if isa(tsArray, 'Simulink.Timeseries')
        ret = convertToMATLABTimeseries(tsArray);
        return;
    end
    
    % Find the data elements of this TsArray
    fields = tsArray.who;
    ret = struct();
    for idx = 1 : length(fields)
        % Check if field name is valid
        if ~isvarname(fields{idx})
            DAStudio.error('Simulink:SimInput:InvalidCreateBusSignalName',...
                           fields{idx});
        end
        
        % Set the field
        subEl = eval(['tsArray.', fields{idx}]);
        ret = setfield(ret, fields{idx}, locCreateFromTsArray(subEl)); %#ok
    end
    
end

%% Function locFillInLeaves -----------------------------------------------
function [ret curIdx] = locFillInLeaves(input, flatElTypes, data, startIdx)
% Recursive function to fill in the leaves of a structre w/ timeseries.
% INPUT PARAMETERS:
%   input - structure or leaf value to construct hierarchy from. If this is
%   a struct, the returned value must also be a struct. If this is not a
%   struct, the returned value is a MATLAB timeseries with the same data
%   type, complexity and dimensions as 'input'.
%
%   data - cell-array of objects of type Simulink.Timeseries or MATLAB
%   timeseries. This data is used for the leaves of the timeseries.
%
%   startIdx - Index within data cell-array to be used for first leaf of
%   returned structure.
%
% OUTPUT VALUES:
%   ret - struct or timeseries object with same structure as 'input' 
%   parameter. 
%
%   curIdx - Index within 'data' cell-array of first timeseries that is not
%   yet added to structure.
    
    curIdx = startIdx;
    
    % Fill in leaf data
    if ~isstruct(input)        
        % Validate data type, complexity and dimensions
        locValidateData(input, flatElTypes(curIdx), data{curIdx}, curIdx);
        
        % Create the timeseries from input
        if isa(data{curIdx}, 'timeseries')
            ret = data{curIdx};
        else
            ret = convertToMATLABTimeseries(data{curIdx});
        end
        
        % Increment index
        curIdx = curIdx + 1;
        return;
    end
    
    % For structures, recurse over each field
    ret = struct();
    fields = fieldnames(input);
    for idx = 1 : length(fields)
        % Get field and recursively fill in structure
        curField = getfield(input, fields{idx}); %#ok
        [retStruct curIdx] = locFillInLeaves(curField, flatElTypes, data, curIdx);
        
        % Set sub-structure
        ret = setfield(ret, fields{idx}, retStruct); %#ok        
    end
    
end

%% Function locValidateTimeseries -----------------------------------------
function locValidateData(dataSample, elType, dataTs, idx)
% Determine the validity of the 'dataTs' object. This object must be a
% timeseries or Simulink.Timeseries with the same type, complexity and
% dimensions as 'dataSample'.  The 'dataSample' parameter represents a
% single data point of the desired data type as obtained from 
% Simulink.Bus.createMATLABStruct (i.e. the ground value for this signal).

    % Input must be of correct type
    if ~isa(dataTs, 'timeseries') && ~isa(dataTs, 'Simulink.Timeseries')
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataElement');
    end
    
    % Validate data type
    if ~strcmp(class(dataSample), class(dataTs.Data))
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataType', ...
                       idx, ...
                       class(dataTs.Data), ...
                       class(dataSample));
    end
    
    % fi requires some extra checking
    if isfi(dataSample)
        if ~isequivalent(dataSample.numerictype, dataTs.Data.numerictype)
            DAStudio.error('Simulink:SimInput:InvalidCreateStructFiMismatch', ...
                           idx);
        end
    end

    % Validate complexity
    if ~isreal(dataTs.Data) && isreal(dataSample)
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataComplexity', ...
                       idx);
    end

    % Get the sample dimensions from the Timseries
    actualDims = size(dataTs.Data);
    if dataTs.IsTimeFirst
        actualDims = actualDims(2:end);
    else
        actualDims = actualDims(1:end-1);
    end
    
    % If object is a timeseries, we need to check for single-sample row
    % vector
    if isa(dataTs, 'timeseries') && ...
       length(dataTs.Time) == 1 && ...
       length(actualDims) == 1 && ...
       dataTs.DataInfo.InterpretSingleRowDataAs3D
        actualDims = [1 actualDims];
    end
    
    % Get the expected dimensions from the bus object
    expectedDims = elType.Dimensions;
    
    % Validate dimensions
    if ~isequal(actualDims, expectedDims)        
        
        % Get strings for dimensions
        actDimsStr = ['[' num2str(actualDims) ']'];
        expDimsStr = ['[' num2str(expectedDims) ']'];             
        
        DAStudio.error('Simulink:SimInput:InvalidCreateStructDataDims', ...
                       idx, actDimsStr, expDimsStr);
    end
end
