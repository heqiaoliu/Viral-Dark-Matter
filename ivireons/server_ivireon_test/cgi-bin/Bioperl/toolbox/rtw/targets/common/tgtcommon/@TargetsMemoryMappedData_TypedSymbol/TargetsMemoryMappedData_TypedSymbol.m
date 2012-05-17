%TARGETSMEMORYMAPPEDDATA_TYPEDSYMBOL class representing a TypedSymbol
%   TARGETSMEMORYMAPPEDDATA_TYPEDSYMBOL class representing a TypedSymbol

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:14:12 $

classdef TargetsMemoryMappedData_TypedSymbol < TargetsMemoryMappedData_Symbol
  
  properties(SetAccess = 'public', GetAccess = 'public')
    dataType = '';
  end
  
  methods

    function this = TargetsMemoryMappedData_TypedSymbol(varargin)
      % Define constructors
      sigs{1} = {'symbolName'};
      sigs{2} = {'symbolName' 'address'};
      sigs{3} = {'symbolName' 'address' 'dataType'};
      
      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      % flag indicating whether to init dataType property or not
      initDataType = false;
      
      switch n
        % Constructor functions
        case 1
          % ts = TargetsMemoryMappedData_TypedSymbol('symbolName', 'mySymbol')
          superArgs = {'symbolName', args.symbolName};
        case 2
          % ts = TargetsMemoryMappedData_TypedSymbol('symbolName', 'mySymbol', 'address', '000000')
          superArgs = {'symbolName', args.symbolName, 'address', args.address};
        case 3
          % ts = TargetsMemoryMappedData_TypedSymbol('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8')
          superArgs = {'symbolName', args.symbolName, 'address', args.address};
          initDataType = true;
        otherwise
          error('TargetsMemoryMappedData_TypedSymbol:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end      
      % call super class constructor
      this = this@TargetsMemoryMappedData_Symbol(superArgs{:});
      % continue with initialization
      if initDataType
          this.dataType = args.dataType; 
      end
      
    end % function TargetsMemoryMappedData_TypedSymbol
    
    % This method sets the property dataType
    function this = set.dataType(this, dataType)
      if ischar(dataType)
        this.dataType = dataType;
      else
        error('TargetsMemoryMappedData_TypedSymbol:Property', 'dataType property must be a character array');
      end
    end % function set.dataType
    
  end % methods
  
end % classdef