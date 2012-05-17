%CCPExternalMode_ExternalModeOpen class representing external mode user functions
%   CCPExternalMode_ExternalModeOpen class representing external mode user
%   functions

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2008/05/01 20:23:03 $


classdef CCPExternalMode_ExternalModeOpen < TargetsExternalMode_ExternalModeOpen

  properties(SetAccess = 'protected', GetAccess = 'protected')
    asap2;
    ccpComms;
    dataTypeHandler;
  end

  methods(Access = 'public')
    function this = CCPExternalMode_ExternalModeOpen(varargin)
        % call the super class constructor
        this = this@TargetsExternalMode_ExternalModeOpen(varargin{:});               
    end
            
    function setParameter(this, param, value)
      setParameter@TargetsExternalMode_ExternalModeOpen(this, param, value);
      matchedParameter = this.tuneableModelData.getSymbolsWithName(param);
      dataType = matchedParameter{1}.dataType;
      try
        targetValue = this.dataTypeHandler.getTargetValue(value, dataType);
      catch e
        switch (e.identifier)
          case {'TargetsComms_DataTypeHandler:getMap', 'TargetsComms_DataTypeHandler:getTargetValue'}
            error('CCPExternalMode_ExternalModeOpen:setParameter', ...
              [sprintf('\n') 'It is not possible to tune parameter ' ...
              matchedParameter{1}.symbolName ' because the transfer of data between' ...
              ' the host and target with data type ''' dataType ''' is not' ...
              ' supported. Supported data types for this target are: ' ...
              this.dataTypeHandler.getSupportedDataTypes()]);
          otherwise
            rethrow(e);
        end
      end
      address = matchedParameter{1}.addressNumeric;
      this.ccpComms.transmitParameterUpdate(address, targetValue);
    end % function setParameter

    function getParameter(this)
    end % function getParameter

    function signalSelect(this, sig)
      signalSelect@TargetsExternalMode_ExternalModeOpen(this, sig);
      matchedSig = this.tuneableModelData.getSymbolsWithName(sig);
      if isa(matchedSig{1}, 'TargetsComms_DAQSignal')
        address = matchedSig{1}.addressNumeric;
        eventChannel = matchedSig{1}.eventChannel;
        dataType = matchedSig{1}.dataType;
        try
          dataTypeSize = this.dataTypeHandler.getSize(dataType);
        catch e
          switch (e.identifier)
            case 'TargetsComms_DataTypeHandler:getNumMemoryUnits'
              error('CCPExternalMode_ExternalModeOpen:signalSelect', [sprintf('\n') 'It' ...
                ' is not possible to setup signal ' matchedSig{1}.symbolName ...
                ' for logging because the transfer of data between the target' ...
                ' and host with data type ''' dataType ''' is not supported.' ...
                ' Supported data type are: ' ...
                this.dataTypeHandler.getSupportedDataTypes()]);
            otherwise
              rethrow(e);
          end
        end
        try
          this.ccpComms.setupDAQSignal(address, dataTypeSize, eventChannel);
        catch e
          % This code trys to handle the error that occurs when we run out
          % of ODTs
          switch (e.identifier)
            case 'TargetsComms_ExternalModeCCP:setupDAQSignal'
              numEventChannels = this.asap2.getNumEventChannels();
              maxNumSymbols = 0;
              for eventChannel=1:numEventChannels
                symbols = this.tuneableModelData.getSymbolsWithEventChannel(eventChannel);
                numSymbols = length(symbols);
                if numSymbols > maxNumSymbols
                  maxNumSymbols = numSymbols;
                end
              end
              requiredNumODTs = maxNumSymbols * numEventChannels;
              error('CCPExternalMode_ExternalModeOpen:signalSelect', ...
                [sprintf('\n') 'There were not enough ODTs available to log the selected' ...
                ' signals. To resolve this error, disconnect from external' ...
                ' mode, increase the number of ODTs or reduce the number of' ...
                ' signals selected for logging and rebuild the model. ' ...
                num2str(requiredNumODTs) ' ODTs are required to log all the' ...
                ' DAQ signals in the model.']);
            otherwise
              rethrow(e);
          end
        end
      else
        error('CCPExternalMode_ExternalModeOpen:signalSelect', [sprintf('\n') 'A signal' ...
          ' selected for logging ' matchedSig{1}.symbolName ' is not a ' ...
          ' canlib.Signal. Signals selected for logging must be canlib.Signal.' ...
          ' If the signal ' matchedSig{1}.symbolName ' selected for logging' ...
          ' is a canlib.Signal then it has been added since the model was' ...
          ' last built and the model needs to be rebuilt.']);
      end
    end % function

    function signalSelectFloating(this)
    end % function

    function triggerArm(this)
      this.ccpComms.startDAQ();
    end % function

    function triggerArmFloating(this)
    end % function

    function cancelLogging(this)
      this.ccpComms.stopDAQ()
    end % function

    function cancelLoggingFloating(this)
    end % function

    function targetStart(this)
    end % function

    function targetStop(this)
      this.disconnectAll();
    end % function

    function targetPause(this)
    end % function

    function targetStep(this)
    end % function

    function targetContinue(this)
    end % function

    function getTime(this)
    end % function

    function success = connect(this)
      success = this.ccpComms.connect();
    end % function

    function disconnect(this)
      this.disconnectAll();
    end % function disconnect

    function disconnectImmediate(this)
      this.disconnectAll();
    end % function disconnectImmediate

    function disconnectConfirmed(this)
    end % function disconnectConfirmed

    function targetStopped(this)
    end % function targetStopped

    function [time data] = checkData(this, sig, lastDataPoint)
      matchedSig = this.tuneableModelData.getSymbolsWithName(sig);
      address = matchedSig{1}.address;
      dataType = matchedSig{1}.dataType;
      % Get the data from the DAQ list and process into host representation
      rawData = this.ccpComms.getDAQData(address);
      time = [];
      data = [];
      if ~isempty(rawData)
        % Create a data vector
        values = [rawData{:}];
        data = this.dataTypeHandler.getHostValue(values, dataType);
        % Create the time vector
        numSamples = length(data);
        sampleTime = matchedSig{1}.sampleTime;
        time = (lastDataPoint + sampleTime):sampleTime:((lastDataPoint + sampleTime) + ((numSamples - 1) * sampleTime));
      end
    end % function checkData

  end % methods    
    
  methods(Access = 'protected')
  
    function disconnectAll(this)
      try
        this.ccpComms.stopDAQ();
        this.ccpComms.disconnect();
      catch e
        switch (e.identifier)
          case 'MATLAB:class:InvalidHandle'
            % deleted object
          otherwise
            rethrow(e);
        end
      end
    end

  end % methods

end % classdef