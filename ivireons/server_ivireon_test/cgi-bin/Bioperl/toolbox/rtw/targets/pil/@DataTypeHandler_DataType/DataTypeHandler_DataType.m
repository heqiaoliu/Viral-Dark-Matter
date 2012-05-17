%DATATYPEHANDLER_DATATYPE class to hold information about a data type
%   DATATYPEHANDLER_DATATYPE class to hold information about a data type. It 
%   has the following inputs:
%
%   NAME - represents the name of the data type e.g. uint8
%   SIZE - of the data type on a machine in bytes

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:33 $

classdef DataTypeHandler_DataType < handle
  
  properties(SetAccess = 'protected', GetAccess = 'public')
    name;
  end
  
  properties(SetAccess = 'protected', GetAccess = 'protected')    
    size;
  end
  
  methods(Access = 'public')
    
    function this = DataTypeHandler_DataType(name, size)
      this.name = name;
      this.size = size;
    end       
        
    function equal = eq(this, dataType)
      equal = strcmp(this.name, dataType.name);      
    end
    
  end
  
end

