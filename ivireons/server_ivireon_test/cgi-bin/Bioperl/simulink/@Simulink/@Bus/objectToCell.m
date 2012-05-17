function ret = objectToCell(busNames)
% Simulink.Bus.objectToCell converts bus objects to cell array format
%
% Usage: cells = Simulink.Bus.objectToCell(busName)
%
% Inputs:
%      busNames: A cell array of bus object names to convert to cell arrays.
%                If the busNames array is empty, all bus objects in the 
%                base workspace will be converted.
%
%                Each bus object will be converted to a cell array with the following
%                data:
%                {BusName, HeaderFile, Description, BusElements}
%                The BusElements field will be a sub cell array with the following data
%                for each element:
%                {ElementName, Dimensions, DataType, SampleTime, Complexity, SamplingMode}
%                
%
%        Output: A cell array of cell arrays, each of which is a bus object that
%                has been converted. An example of the cell array generated is shown below
% 
%        busCell = { ...
%          { ...
%             'BC1', ...
%             'Header File', ...
%             'Description', { ...
%                {'a',1,'double', [0.2 0],'Real','Frame based'}; ...
%                {'b',1,'double', [0.2 0],'Real','Sample based'}; ...
%             },...
%          }, ...
%       };
%
%      
% Examples:
%       c = Simulink.Bus.objectToCell()            Converts all bus objects to cell arrays
%       c = Simulink.Bus.objectToCell({'myBus1'})  Converts 'myBus1' to cell array
%
    
%
%   Copyright 1994-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $
    
% do not disp backtraces when reporting warning
wStates = [warning; warning('query','backtrace')];
warning off backtrace;
warning on; %#ok

try
    % Assume defaults
    if nargin == 0
        busNames = {};
    end
    
    % Check user specified busNames
    isOk = iscell(busNames);
    if isOk
        for idx = 1:length(busNames)
            if ~isvarname(busNames{idx})
                isOk = false;
                break;
            end
        end
    end
    
    if ~isOk
        DAStudio.error('Simulink:tools:slbusObjectToCellInvalidInput');
    end
  
    % Collect the list of bus names if the user did not specify
    if isempty(busNames)
        var = evalin('base','whos');
        for idx = 1:length(var)
            if (strcmp(var(idx).class,'Simulink.Bus'))
                busNames{end+1} = var(idx).name; %#ok Hard to precompute size ahead of time
            end
        end 
    end
    
    % Convert the bus objects into cell arrays
    ret = convert_bus_to_cell_format_l(busNames);
    
catch me
    warning(wStates); %#ok
    rethrow(me);
end
warning(wStates); %#ok

% Function: convert_bus_to_cell_format_l ======================================
% Abstract:
%      Convert the input array of bus objects to cell arrays.
%
function ret = convert_bus_to_cell_format_l(busNames)
    ret = cell(length(busNames), 1);
    for idx = 1:length(busNames)
        ret{idx,1} = convert_one_bus_in_cell_format_l(busNames{idx});
    end
    
%endfunction convert_bus_to_cell_format_l
    
% Function convert_one_bus_in_cell_format_l ====================================
% Abstract:
%    Convert a single bus object to the cell format
%
function  ret = convert_one_bus_in_cell_format_l(busName)

busObj = sl('slbus_get_object_from_name', busName);

els = cell(length(busObj.Elements), 1);
headerFile = busObj.HeaderFile;
% No need to escape quotes here as we handle it in save.
description = busObj.Description;

for idx = 1:length(busObj.Elements)
  els{idx,1} = convert_one_bus_element_cell_format_l(busObj.Elements(idx)); 
end

ret = {busName, headerFile, description, els};

%endfunction convert_one_bus_in_cell_format_l


% Function convert_one_bus_element_cell_format_l ===============================
% Abstract:
%    Convert one bus element in the cell format.
%
function ret = convert_one_bus_element_cell_format_l(busElm)
  name    = busElm.Name;
  dimsStr = sl('busUtils', 'GetDimsStr', busElm.Dimensions);
  dType   = busElm.DataType;
  tsStr   = sl('busUtils', 'GetSampleTimeStr', busElm.SampleTime);
  cplxStr = busElm.Complexity;
  % removed trailing based string
  frameStr= busElm.SamplingMode(1:(end-6));
  
  dimsModeStr = busElm.DimensionsMode;
  ret = {name, str2num(dimsStr), dType, str2num(tsStr), cplxStr, frameStr, dimsModeStr}; %#ok str2num required since dimStr/tsStr are not scalars
  
%endfunction convert_one_bus_element_cell_format_l
