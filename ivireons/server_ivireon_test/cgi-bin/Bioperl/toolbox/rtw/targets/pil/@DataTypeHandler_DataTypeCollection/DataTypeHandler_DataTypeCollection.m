%DATATYPEHANDLER_DATATYPECOLLECTION class to hold DataTypeHandler_DataType objects
%   DATATYPEHANDLER_DATATYPECOLLECTION class to hold DataTypeHandler_DataType
%   objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/08/23 19:11:34 $

classdef DataTypeHandler_DataTypeCollection < TargetsUtils_Collection

  properties(SetAccess = 'protected', GetAccess = 'protected')
    itemIds = {};
  end  
  
  methods(Access = 'public')

    function addItem(this, item)
      addItem@TargetsUtils_Collection(this, item);
      idx = this.findItem(item);
      % item is expected to be a DataTypeHandler_DataType or subclass
      id = item.name;
      this.itemIds(idx) = { id };
    end

    function matchedItem = getItem(this, itemName)
      idxs = strcmp(itemName, this.itemIds);
      matchedItem = this.collection{idxs};
    end     
    
    function clear(this)
      clear@TargetsUtils_Collection(this);
      this.itemIds = {};      
    end
        
    function setDataTypeMaps(this, mapGenerator)
      for i=1:length(this.collection)
        this.collection{i}.map = mapGenerator;
      end
    end

    function display(this)
      disp(sprintf('%-20s%-15s%-15s', 'Data type', 'Size', 'Word order'));
      for i=1:length(this.collection)
        this.collection{i}.disp();
      end      
    end
      
    function disp(this)
      this.display();
    end
    
  end

end
