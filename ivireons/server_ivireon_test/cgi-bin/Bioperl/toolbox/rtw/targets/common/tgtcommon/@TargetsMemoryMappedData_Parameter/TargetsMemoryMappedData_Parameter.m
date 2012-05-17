%TARGETSMEMORYMAPPEDDATA_PARAMETER class representing a parameter
%   TARGETSMEMORYMAPPEDDATA_PARAMETER class representing a parameter

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:14:10 $

classdef TargetsMemoryMappedData_Parameter < TargetsMemoryMappedData_TypedSymbol
      
  methods
       
    function this = TargetsMemoryMappedData_Parameter(varargin)
      % Define constructors
      sigs{1} = {'symbolName'};
      sigs{2} = {'symbolName' 'address'};
      sigs{3} = {'symbolName' 'address' 'dataType'};
      
      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      switch n
        % Constructor functions
        case 1
          % param = TargetsMemoryMappedData_Parameter('symbolName', 'mySymbol')
          superArgs = {'symbolName', args.symbolName};
        case 2
          % param = TargetsMemoryMappedData_Parameter('symbolName', 'mySymbol', 'address', '000000')
          superArgs = {'symbolName', args.symbolName, 'address', args.address};
        case 3
          % param = TargetsMemoryMappedData_Parameter('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8')
          superArgs = {'symbolName', args.symbolName, 'address', args.address, 'dataType', args.dataType};
        otherwise
          error('TargetsMemoryMappedData_Parameter:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end
      % call super class constructor
      this = this@TargetsMemoryMappedData_TypedSymbol(superArgs{:});
      
    end % function TargetsMemoryMappedData_Parameter

  end % methods
  
end % classdef
