%TARGETSCOMMS_DATATYPEHANDLER class containing common data type handler functionality
%   TARGETSCOMMS_DATATYPEHANDLER class containing common data type handler 
%   functionality which should be extended by a target providing a conversionInfo 
%   structure and values for memoryUnits, targetEndian.

%   Copyright 1990-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/11 14:34:11 $

classdef TargetsComms_DataTypeHandler < handle

  properties(SetAccess = 'protected', GetAccess = 'public')
    memoryUnits;  
  end % properties(SetAccess = 'protected', GetAccess = 'public')
  
  properties(SetAccess = 'protected', GetAccess = 'protected')
    % Info required for conversions
    conversionInfo = struct('dataTypes', {{}}, 'hash', {{}});    
  end % properties(SetAccess = 'protected', GetAccess = 'protected')
    
  methods(Access = 'public')
    
    % This method returns a host value in the target representation
    function targetValue = getTargetValue(this, hstValue, dataType)
      if ~(ismember(dataType, this.conversionInfo.hash))
        error('TargetsComms_DataTypeHandler:getTargetValue', ['Unsupported data type: ' dataType])
      end
      % make sure the input data is of the correct type to be processed
      data0 = eval([dataType '(' num2str(hstValue) ')']);
      % create an array of memory units
      data1 = typecast(data0, this.memoryUnits);
      % get the map for this data type
      map = this.getMap(dataType);
      % apply the map and return value
      targetValue = data1(map);
    end % function getTargetValue

    % This method returns a target value in the host representation
    function hostValue = getHostValue(this, tgtValue, dataType)
      numMemoryUnits = this.getNumMemoryUnits(dataType);
      % Check the data size
      dataSize = length(tgtValue);
      if mod(dataSize, numMemoryUnits)
        error('TargetsComms_DataTypeHandler:getHostValue', ['Invalid data length for data type ' dataType]);
      end
      % Make sure the data is of the correct type to be processed
      dataCorrectType = cast(tgtValue, this.memoryUnits);
      % Get the map which allows us to swap the bytes
      map = this.getMap(dataType);
      % Check the size of the target value
      if dataSize > numMemoryUnits
        numberOfTiles = dataSize / numMemoryUnits;
        % Tile the map
        map = repmat(map, 1, numberOfTiles);
        % Create an offset array for the tiled map
        offsetIdxs = 0:numMemoryUnits:(numMemoryUnits * (numberOfTiles - 1));
        offset = [];
        for i=1:numMemoryUnits
          offset = [offset offsetIdxs];
        end
        offset = sort(offset);
        % Adjust the map with the offsets
        map = map + offset;
      end
      % Host representation in bytes
      hostValueMemUnits = dataCorrectType(map);
      % Convert to require datatype
      hostValue = typecast(hostValueMemUnits, dataType);
    end % function getHostValue

    % This method returns the size of a host data type in number of target 
    % memory units
    function dataTypeSize = getSize(this, dataType)
      dataTypeSize = this.getNumMemoryUnits(dataType);
    end % function getSize
        
    % This method returns a string listing the supported data types for 
    % the target
    function supportedDataTypes = getSupportedDataTypes(this)
      supportedDataTypes = '';
      for i=1:length(this.conversionInfo.hash)
        if i == 1
          supportedDataTypes = this.conversionInfo.hash{i};
        else
          supportedDataTypes = [supportedDataTypes ', ' this.conversionInfo.hash{i}];
        end
      end
    end % function getSupportedDataTypes
    
  end % methods(Access = 'public')
  
  methods(Access = 'protected')
    
    % This method return an index map for a particular data type
    function map = getMap(this, targetDataType)
      [member location] = ismember(targetDataType, this.conversionInfo.hash);
      if member
        map = this.conversionInfo.dataTypes{location}.map;
      else
        error('TargetsComms_DataTypeHandler:getMap', ['Unsupported data type: ' targetDataType]);
      end
    end % function getMap
    
    % This method returns the number of target memory units used for a 
    % particular data type
    function numMemoryUnits = getNumMemoryUnits(this, targetDataType)
      [member location] = ismember(targetDataType, this.conversionInfo.hash);
      if member
        numMemoryUnits = this.conversionInfo.dataTypes{location}.numMemoryUnits;
      else
        error('TargetsComms_DataTypeHandler:getNumMemoryUnits', ['Unsupported data type: ' targetDataType]);
      end
    end % function getNumMemoryUnits
    
  end % methods(Access = 'protected')
  
end % classdef
