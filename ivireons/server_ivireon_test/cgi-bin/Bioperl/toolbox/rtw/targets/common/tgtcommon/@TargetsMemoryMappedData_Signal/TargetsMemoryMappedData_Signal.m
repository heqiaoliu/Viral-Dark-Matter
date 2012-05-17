%TARGETSMEMORYMAPPEDDATA_SIGNAL class representing a signal
%   TARGETSMEMORYMAPPEDDATA_SIGNAL class representing a signal

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:14:11 $

classdef TargetsMemoryMappedData_Signal < TargetsMemoryMappedData_TypedSymbol
  
  properties(SetAccess = 'public', GetAccess = 'public')
    sampleTime = 0.0;
  end % properties
  
  methods
    
    function this = TargetsMemoryMappedData_Signal(varargin)
      % Define constructors
      sigs{1} = {'symbolName'};
      sigs{2} = {'symbolName' 'address'};
      sigs{3} = {'symbolName' 'address' 'dataType'};
      sigs{4} = {'symbolName' 'address' 'dataType' 'sampleTime'};
      
      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);
      
      % flag indicating whether to init sample time property or not
      initSampleTime = false;
      
      switch n
        % Constructor functions
        case 1
          % sig = TargetsMemoryMappedData_Signal('symbolName', 'mySymbol')
          superArgs = {'symbolName', args.symbolName};
        case 2
          % sig = TargetsMemoryMappedData_Signal('symbolName', 'mySymbol', 'address', '000000')
          superArgs = {'symbolName', args.symbolName, 'address', args.address};
        case 3
          % sig = TargetsMemoryMappedData_Signal('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8')
          superArgs = {'symbolName', args.symbolName, 'address', args.address, 'dataType', args.dataType};
        case 4          
          % sig = TargetsMemoryMappedData_Signal('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8', 'sampleTime', 0.1)
          superArgs = {'symbolName', args.symbolName, 'address', args.address, 'dataType', args.dataType};
          initSampleTime = true;          
        otherwise
          error('TargetsMemoryMappedData_Signal:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end
      % call super class constructor
      this = this@TargetsMemoryMappedData_TypedSymbol(superArgs{:});
      % continue with initialization
      if initSampleTime
         this.sampleTime = args.sampleTime;
      end
      
    end % function TargetsMemoryMappedData_Signal

    % This method sets the property sampleTime
    function set.sampleTime(this, sampleTime)
      if isnumeric(sampleTime) && (length(sampleTime) == 1)
        this.sampleTime = sampleTime;
      else
        error('TargetsMemoryMappedData_Signal:Property', 'sampleTime property must be a numeric value');
      end
    end % function set.sampleTime

    % This method gets the property sampleTime
    function sampleTime = get.sampleTime(this)
      sampleTime = this.sampleTime;
    end % function set.sampleTime
        
  end % methods
  
end % classdef