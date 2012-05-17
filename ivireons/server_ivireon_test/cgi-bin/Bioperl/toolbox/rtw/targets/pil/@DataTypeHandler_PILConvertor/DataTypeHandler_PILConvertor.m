%DATATYPEHANDLER_PILCONVERTOR PIL datatype convertor optimised for use with PIL S-function
%   DATATYPEHANDLER_PILCONVERTOR PIL datattype convertor optimised for use with 
%   PIL S-function

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/09/09 21:21:15 $

classdef DataTypeHandler_PILConvertor < DataTypeHandler_GeneralConvertor 
  methods

    function this = DataTypeHandler_PILConvertor(varargin)
      this@DataTypeHandler_GeneralConvertor(varargin{:});
    end   
   
    function map = getMap(this, datatype, dataSize)
        map = this.convertor.getMap(datatype, dataSize);        
    end
       
    function clearDatatypes(this)
      clearDatatypes@DataTypeHandler_GeneralConvertor(this);      
    end
  end

  methods(Access = 'protected')
    function convertor = setConvertor(~, dataTypeCollection)
      convertor = DataTypeHandler_PILDataConvertor(dataTypeCollection);
    end
  end
end
