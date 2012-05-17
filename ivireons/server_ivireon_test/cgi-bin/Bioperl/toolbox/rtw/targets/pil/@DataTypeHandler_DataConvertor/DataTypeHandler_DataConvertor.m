%DATATYPEHANDLER_DATACONVERTOR class for converting between host and target data representations
%   DATATYPEHANDLER_DATACONVERTOR class for converting between host and target data
%   representations. Input is a DATATYPECOLLECTION which is a object of type
%   DATATYPEHANDLER_DATATYPECOLLECTION containing specifications of data types
%   to be converted using this class

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:32 $

classdef DataTypeHandler_DataConvertor < handle
  
  properties(SetAccess = 'public', GetAccess = 'public')
    mode; % Map, ValueSame, ValueMixed
  end
  
  properties(SetAccess = 'protected', GetAccess = 'protected')
    dataTypeCollection;    
  end
  
  methods(Access = 'public')
    
    function this = DataTypeHandler_DataConvertor(dataTypeCollection)
      this.dataTypeCollection = dataTypeCollection;
    end
  end
  
  methods
    
    function set.mode(this, mode)
      this.mode = mode;
    end
  end
  
  methods(Access = 'public')
      
    function convertedData = convert(this, dataToConvert, dataTypeName)
      % get the data type spec
      dataTypeSpec = this.dataTypeCollection.getItem(dataTypeName);      
      % calculate the map
      numElements = length(dataToConvert) / length(dataTypeSpec.map);
      map = this.getArrayMap(numElements, dataTypeSpec);
      % convert the data using the map      
      convertedData = dataToConvert(map);
    end
    
  end
  
  methods

    function this = set.dataTypeCollection(this, dataTypeCollection)
      if isa(dataTypeCollection, 'DataTypeHandler_DataTypeCollection')
        this.dataTypeCollection = dataTypeCollection;
      else
        error('DataTypeHandler_DataConvertor:Property:dataTypeCollection', 'dataTypeCollection must be an object of or an object of a subclass of DataTypeHandler_DataTypeCollection');
      end
    end
  end
    
    
      methods(Access = 'protected')
    function map = getArrayMap(this, numElements, dataTypeSpec)
      % map array for a single data type
      mapTile = dataTypeSpec.map;      
      mapLength = length(mapTile);
          
      % Preallocate map for speed
      mapSize = numElements * mapLength;
      map = zeros(1, mapSize);

      % Tile the map array so that it is the right size to re arrange the data
      for i = 0:(mapSize) - 1
        % Calculate which tile of the map array i is in
        mapTileN = floor(i / mapLength);
        % Calculate an offset based on the current tile
        mapOffset = mapTileN * mapLength;
        % Get the index of the map element for i
        mapTileIndex = i - mapOffset;
        % Add the map tile element to the map
        map(mapOffset + (mapTileIndex + 1)) = mapTile(mapTileIndex + 1) + mapOffset;
      end
    end
        
  end
  
end
