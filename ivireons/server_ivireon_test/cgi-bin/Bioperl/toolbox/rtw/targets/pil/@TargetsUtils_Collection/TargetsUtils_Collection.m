%TARGETSUTILS_COLLECTION class to hold objects of the same type
%   TARGETSUTILS_COLLECTION class to hold objects of the same type. The class 
%   makes use of the object eq method to compare objects.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/11/13 04:58:30 $

classdef TargetsUtils_Collection < handle
  
  properties(SetAccess = 'protected', GetAccess = 'protected')
    collection = {};
  end

  methods(Access = 'public')

    function addItem(this, item)
      try
        % Try to find the item
        idx = this.findItem(item);
        % Item was found replace it with the new item
        this.collection(idx) = { item };        
      catch e %#ok<NASGU>
        % Item was not found it is a new item add it to the end
        this.collection(end + 1) = { item };
      end     
    end 
    
    function item = getItem(this, item)
      idx = this.findItem(item);
      item = this.collection{idx};
    end 
    
    function clear(this)
      this.collection = [];
    end 
    
    
  end 
  
  methods(Access = 'protected')

    function idx = findItem(this, item)
      for i=1:length(this.collection)
        if this.collection{i} == item
          idx = i;
          return;
        end
      end
      rtw.pil.ProductInfo.error('pil', 'TargetsUtilsItemNotFound');
    end 
        
  end
  
end 
