%TARGETSEXTERNALMODE_EXTERNALMODEOPEN class representing external mode user functions
%   TARGETSEXTERNALMODE_EXTERNALMODEOPEN class representing target independent
%   functionality implementing external mode user functions

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/11/15 15:04:35 $

classdef TargetsExternalMode_ExternalModeOpen < handle

  properties(SetAccess = 'protected', GetAccess = 'protected')
    modelName;
    tuneableModelData;
  end

  methods
    function this = TargetsExternalMode_ExternalModeOpen(varargin)
      % Define constructors
      sigs{1} = {'modelName'};

      % Parse arguments
      args = targets_parse_argument_pairs(sigs{end}, varargin);

      n = targets_find_signature(sigs, args);

      switch n
        % Constructor functions
        case 1
          this.modelName = args.modelName;
        otherwise
          error('TargetsExternalMode_ExternalModeOpen:Constructor', 'Unknown constructor, a recognised constructor signature was not found');
      end

    end

    function setParameter(this, param, value)
      % Get parameter from tunableModelData
      matchedParameter = this.tuneableModelData.getSymbolsWithName(param);
      % Was a matching parameter found
      if isempty(matchedParameter)
        % This parameter does not exist so add it to tunableModelData
        this.tunableModelData.addSymbol(parameter);
      else
        % The parameter is already exists in tunableModelData so check the
        % data type
        if ~(strcmp(param.dataType, matchedParameter{1}.dataType))
          % data type is not the same so set it
          matchedParameter{1}.dataType = param.dataType;
        end
      end
    end % function setParameter

    function getParameter(this)
    end % function getParameter

    function signalSelect(this, sig)
      % Get signal from tunableModelData
      matchedSig = this.tuneableModelData.getSymbolsWithName(sig);
      % Was a matching signal found
      if isempty(matchedSig)
        % This signal does not exist so add it to tunableModelData
        this.tuneableModelData.addSymbol(sig);
      else
        % The signal is already exists in tunableModelData 
        % Check the data type
        if ~(strcmp(sig.dataType, matchedSig{1}.dataType))
          % Data type is not the same so set it
          matchedSig{1}.dataType = sig.dataType;
        end
        % Check and update the sample time
        if sig.sampleTime ~= matchedSig{1}.sampleTime
          % Sample time is not the same so set it
          matchedSig{1}.sampleTime = sig.sampleTime;
        end
      end      
    end % function signalSelect

    function signalSelectFloating(this)
    end % function

    function triggerArm(this)
    end % function

    function triggerArmFloating(this)
    end % function

    function cancelLogging(this)
    end % function

    function cancelLoggingFloating(this)
    end % function

    function targetStart(this)
    end % function

    function targetStop(this)
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
    end % function
        
    function disconnect(this)
    end % function

    function disconnectImmediate(this)
    end % function

    function disconnectConfirmed(this)
    end % function

    function targetStopped(this)
    end % function

    function checkData(this)
    end % function

  end % methods

end % classdef