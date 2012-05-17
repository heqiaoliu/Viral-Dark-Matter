%DATATYPEHANDLER_PILDATACONVERTOR convertor class for PIL convertor
%   DATATYPEHANDLER_PILDATACONVERTOR convertor class for PIL convertor

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:39 $

classdef DataTypeHandler_PILDataConvertor < DataTypeHandler_DataConvertor
  
  methods

    function this = DataTypeHandler_PILDataConvertor(varargin)
      this@DataTypeHandler_DataConvertor(varargin{:});
    end
    
    function map = getMap(this, dataTypeName, dataSize)
      % get the data type spec
      dataTypeSpec = this.dataTypeCollection.getItem(dataTypeName);      
      % calculate the map
      map = this.getArrayMap(dataSize, dataTypeSpec);
    end

  end
  
end
