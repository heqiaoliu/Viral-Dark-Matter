%DATATYPEHANDLER_BUILTINDATATYPE class to hold information about a primitive type
%   DATATYPEHANDLER_BUILTINDATATYPE class for collecting information about a
%   primitive type. It has the following inputs:
%
%   NAME - represents the name of the data type e.g. uint8
%   SIZE - of the data type on a machine in bytes
%   WORDORDER - ordering of words within the data type on the machine. Possible
%   orderings are BigEndian or LittleEndian

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:30 $

classdef DataTypeHandler_BuiltinDataType < DataTypeHandler_DataType
  
  properties(SetAccess = 'public', GetAccess = 'public')
    map;
  end
  
  properties(SetAccess = 'protected', GetAccess = 'protected')
    wordOrder;
  end
  
  methods(Access = 'public')    
    
    function this = DataTypeHandler_BuiltinDataType(name, size, wordOrder)
      this = this@DataTypeHandler_DataType(name, size);
      this.wordOrder = wordOrder;
    end
  end
  
  methods

    function this = set.map(this, mapGenerator)
      this.map = mapGenerator.getMap(this.size, this.wordOrder);       
    end
  end
  
   methods(Access = 'public')    
 
    function display(this)
      disp(sprintf('%-20s%-15d%-15s', this.name, this.size, this.wordOrder));
    end
    
    function disp(this)
      this.display()
    end
    
  end
  
  methods
    
    function this = set.wordOrder(this, wordOrder)
      valid = strcmp(wordOrder, {'BigEndian', 'LittleEndian'});
      if any(valid)
        this.wordOrder = wordOrder;
      else
        error('DataTypeHandler_BuiltinDataType:Property:wordOrder', 'Word order must be one of ''BigEndian'' or ''LittleEndian''');
      end      
    end
    
  end
  
end
