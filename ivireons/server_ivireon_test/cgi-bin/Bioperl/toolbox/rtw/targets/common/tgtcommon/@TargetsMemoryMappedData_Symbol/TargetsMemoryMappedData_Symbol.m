%TARGETSMEMORYMAPPEDDATA_SYMBOL class representing a Symbol
%   TARGETSMEMORYMAPPEDDATA_SYMBOL class representing a Symbol

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 14:58:27 $

classdef TargetsMemoryMappedData_Symbol < handle

  properties(SetAccess = 'protected', GetAccess = 'public')
    symbolName = '';
    address = '000000';
  end % properties

  properties(Dependent = true)
    addressNumeric;
  end % properties
    
  methods(Access = 'public')

    function this = TargetsMemoryMappedData_Symbol(varargin)
      % Define constructors
      sigs{1} = {'symbolName'};
      sigs{2} = {'symbolName' 'address'};

      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      switch n
        % Constructor functions
        case 1
          % s = TargetsMemoryMappedData_Symbol('symbolName', 'mySymbol')
          this.symbolName = args.symbolName;
        case 2
          % s = TargetsMemoryMappedData_Symbol('symbolName', 'mySymbol', 'address', '000000')
          this.symbolName = args.symbolName;
          this.address = args.address;
        otherwise
          error('TargetsMemoryMappedData_Symbol:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end

    end % function TargetsMemoryMappedData_Symbol
  end
  
  methods
      
    % This method sets the symbolName property
    function this = set.symbolName(this, symbolName)
      if ischar(symbolName)
        this.symbolName = symbolName;
      else
        error('TargetsMemoryMappedData_Symbol:Property', 'symbolName property must be a character array');
      end
    end % function set.symbolName
        
    % This method sets the address property
    function this = set.address(this, address)
      if ischar(address)
        result = regexp(address, '^[0-9a-fA-F]+$', 'end');
        % should only be 1 region matched and the size of the region should be 
        % the same as the input
        if ~isempty(result)
          this.address = address;
        else
          error('TargetsMemoryMappedData_Symbol:Property', 'Address property incorrectly formatted');
        end
      else
        error('TargetsMemoryMappedData_Symbol:Property', 'Address property must be a character array');
      end
    end % function set.address
        
    % This method returns the address of a symbol as a numeric value
    function address = get.addressNumeric(this)
      address = hex2dec(this.address);
    end % function get.addressNumeric
  end
  
  methods(Access = 'public')

    % This method implements == for Symbol objects
    function equal = eq(this, symbol)
      equal = strcmp(this.symbolName, symbol.symbolName);
    end % function eq
    
  end % methods

end % classdef


