%TARGETSMEMORYMAPPEDDATA_TUNABLEMODELDATA class representing TunableModelData
%  TARGETSMEMORYMAPPEDDATA_TUNABLEMODELDATA class representing TunableModelData

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/15 15:04:39 $

classdef TargetsMemoryMappedData_TunableModelData < handle

  properties(SetAccess = 'protected', GetAccess = 'protected')
    symbolList = {};
  end % properties
  
  methods

    % td = TargetsMemoryMappedData_TunableModelData()
    
    % This method adds a symbol to the collection
    function addSymbol(this, symbol)
      if isa(symbol, 'TargetsMemoryMappedData_Symbol')
        this.symbolList(end + 1) = { symbol };        
      else
        error('TargetsMemoryMappedData_TunableModelData:addSymbol', 'symbol must be a TargetsMemoryMappedData_Symbol object or a subclass of TargetsMemoryMappedData_Symbol')
      end
    end
    
    % This method returns matching symbols from the collection
    function matchedSymbol = getSymbolsWithName(this, symbol)
      if ~isa(symbol, 'TargetsMemoryMappedData_Symbol')
        error('TargetsMemoryMappedData_TunableModelData:getSymbol', 'symbol must be a TargetsMemoryMappedData_Symbol object or a subclass of TargetsMemoryMappedData_Symbol')
      end
      matchedSymbol = {};
      % Search
      for i = 1:length(this.symbolList)
        if this.symbolList{i} == symbol
          matchedSymbol(end + 1) = this.symbolList(i);
        end
      end
    end % function getSymbol

    % This method emptys the parameterList and signalList
    function clear(this)
      this.symbolList = {};
    end % function clear

    % This method removes matching symbols from the collection
    function removeSymbol(this, symbol)
      if ~isa(symbol, 'TargetsMemoryMappedData_Symbol')
        error('TargetsMemoryMappedData_TunableModelData:removeSymbol', 'symbol must be a TargetsMemoryMappedData_Symbol object or a subclass of TargetsMemoryMappedData_Symbol')
      end      
      % Search
      idx = 1;
      max_idx = length(this.symbolList);
      while idx <= max_idx
        if this.symbolList{idx} == symbol
          % Remove parameter
          this.symbolList(idx) = '';
          % Decrement end index as now there is 1 less element
          max_idx = max_idx - 1;
        end
        idx = idx + 1;
      end
    end % function removeSymbol
        
  end % methods
  
end % classdef