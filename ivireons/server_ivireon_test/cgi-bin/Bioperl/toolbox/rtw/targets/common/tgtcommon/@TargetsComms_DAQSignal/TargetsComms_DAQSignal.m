%TARGETSCOMMS_DAQSIGNAL class representing a DAQSignal
%   TARGETSCOMMS_DAQSIGNAL class representing a DAQSignal

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/11/13 00:14:07 $

classdef TargetsComms_DAQSignal < TargetsMemoryMappedData_Signal

  properties(SetAccess = 'public', GetAccess = 'public')
    eventChannel = 1;
  end % properties

  methods

    function this = TargetsComms_DAQSignal(varargin)
      % Define constructors
      sigs{1} = {'symbolName'};
      sigs{2} = {'signal'};
      sigs{3} = {'signal' 'eventChannel'};
      sigs{4} = {'symbolName' 'address'};
      sigs{5} = {'symbolName' 'address' 'dataType'};
      sigs{6} = {'symbolName' 'address' 'dataType' 'sampleTime'};
      sigs{7} = {'symbolName' 'address' 'dataType' 'sampleTime', 'eventChannel'};

      % Parse arguments
      args = targets_parse_argument_pairs({sigs{2}{:} sigs{7}{:}}, varargin);

      n = targets_find_signature(sigs, args);

      % flag indicating whether to init eventChannel property or not
      initEventChannel = false;
      
      switch n
        % Constructor functions
        case 1
          % daqSig = TargetsComms_DAQSignal('symbolName', 'mySymbol')
          superArgs = {'symbolName', args.symbolName};
        case 2
          % daqSig = TargetsComms_DAQSignal('signal', sig)
          if isa(args.signal, 'TargetsMemoryMappedData_Signal')
            superArgs = {'symbolName', args.signal.symbolName, ...
                         'address', args.signal.address, ...
                         'dataType', args.signal.dataType, ...
                         'sampleTime', args.signal.sampleTime};
          else
            error('TargetsComms_DAQSignal:Constructor', 'The signal argument must be a TargetsMemoryMappedData_Signal');
          end
        case 3
          % daqSig = TargetsComms_DAQSignal('signal', sig, 'eventChannel', 1)
          if isa(args.signal, 'TargetsMemoryMappedData_Signal')
            superArgs = {'symbolName', args.signal.symbolName, ...
                         'address', args.signal.address, ...
                         'dataType', args.signal.dataType, ...
                         'sampleTime', args.signal.sampleTime};
            initEventChannel = true;
          else
            error('TargetsComms_DAQSignal:Constructor', 'The signal argument must be a TargetsMemoryMappedData_Signal');
          end
        case 4
          % daqSig = TargetsComms_DAQSignal('symbolName', 'mySymbol', 'address', '000000')
          superArgs = {'symbolName', args.symbolName, 'address', args.address};
        case 5
          % daqSig = TargetsComms_DAQSignal('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8')
          superArgs = {'symbolName', args.symbolName, 'address', args.address, 'dataType', args.dataType};
        case 6
          % daqSig = TargetsComms_DAQSignal('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8', 'sampleTime', 0.1)
          superArgs = {'symbolName', args.symbolName, ...
                       'address', args.address, ...
                       'dataType', args.dataType, ...
                       'sampleTime', args.sampleTime};
        case 7
          % daqSig = TargetsComms_DAQSignal('symbolName', 'mySymbol', 'address', '000000', 'dataType', 'uint8', 'sampleTime', 0.1, 'eventChannel', 1)
          superArgs = {'symbolName', args.symbolName, ...
                       'address', args.address, ...
                       'dataType', args.dataType, ...
                       'sampleTime', args.sampleTime};
          initEventChannel = true;
        otherwise
          error('TargetsComms_DAQSignal:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end
      % call super class constructor
      this = this@TargetsMemoryMappedData_Signal(superArgs{:});
      % continue with initialization
      if initEventChannel
          this.eventChannel = args.eventChannel; 
      end           
    end % function TargetsComms_DAQSignal

    % This method sets the property eventChannel
    function set.eventChannel(this, eventChannel)
      if isnumeric(eventChannel) && (length(eventChannel) == 1) && (eventChannel >= 0)
        this.eventChannel = eventChannel;
      else
        error('TargetsComms_DAQSignal:Property', 'eventChannel property must be a numeric value >= 0');
      end
    end % function set.eventChannel

  end % methods

end % classdef