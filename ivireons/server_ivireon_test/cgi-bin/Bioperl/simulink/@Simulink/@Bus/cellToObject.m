function cellToObject(busCell)
%  cellToObject converts a cell array containing bus information to bus objects.
%
%  Simulink.Bus.cellToObject(busCell) creates a set of bus objects in the 
%  MATLAB base workspace. The input cell array must contain nx1 cells. 
%  Each cell is a 1x2, where the first element of the cell is the bus object 
%  name, the second element is a [kx1] cell array, where k is the number of 
%  elements in the bus object. 
%
%  Example: The following cell array contains bus object information.
%  The bus object name is BC1. The bus contains two signals a and b.
%
%     busCell = { ...
%       { ...
%         'BC1', ...
%         'Header File', ...
%         'Description', { ...
%            {'a',1,'double', [0.2 0],'Real','Frame based'}; ...
%            {'b',1,'double', [0.2 0],'Real','Sample based'}, ...
%         },...
%       }, ...
%     };
%
%   See also Simulink.Bus.save
%

% Copyright 2005-2009 The MathWorks, Inc.
  
  numBus = length(busCell);
  for idx = 1:numBus
    thisCell = busCell{idx};
    
    if length(thisCell) == 2
        % Backward compatible format - header file and description information
        % is missing
        busName  = thisCell{1};   %#ok
        elemInfo = thisCell{2}; 
        headerFile = '';
        description = '';
    else 
        busName  = thisCell{1};   %#ok
        headerFile = thisCell{2};
        description = thisCell{3};
        elemInfo = thisCell{4}; 
    end
    
    numElm = length(elemInfo);
    
    slbusObj = Simulink.Bus;
    slbusObj.HeaderFile = headerFile;
    slbusObj.Description = description;
    
    clear elems;
    for eIdx = 1:numElm
      thisElm = elemInfo{eIdx};
      
      elems(eIdx) = Simulink.BusElement;  %#ok
      elems(eIdx).Name         = thisElm{1};
      elems(eIdx).Dimensions   = thisElm{2};
      elems(eIdx).DataType     = thisElm{3};
      elems(eIdx).SampleTime   = thisElm{4};
      elems(eIdx).Complexity   = thisElm{5};
      elems(eIdx).SamplingMode = [thisElm{6}, ' based'];
      if length(thisElm) > 6
          elems(eIdx).DimensionsMode = thisElm{7};
      end
      
      if eIdx == numElm
        slbusObj.Elements = elems;
      end
    end
    
    assignin('base', busName, slbusObj);
  end
  
%endfunction
