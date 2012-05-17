classdef nnfcnTraining < nnfcnInfo
%NNTRAININGFCNINFO Training function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    isSupervised = false;
    usesGradient = false;
    usesJacobian = false;
    usesDerivative = false;
    usesValidation = false;
    states = [];
  end
  
  % TODO - Stop/Start training with savable settings
  % TODO - Error/Out of Memory stopping criteria
  
  methods
    
    function x = nnfcnTraining(mfunction,name,version, ...
        isSupervised,usesValidation,param,states)
      
      if nargin < 4, nnerr.throw('Not enough input arguments.'); end
      if ~nntype.bool_scalar('isa',isSupervised)
        nnerr.throw('isSupervised must be a logical scalar.');
      elseif ~nntype.bool_scalar('isa',usesValidation)
        nnerr.throw('usesValidation must be a logical scalar.');
      end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        nnerr.throw('Parameters must be an nnetParamInfo array.');
      end
      
      x = x@nnfcnInfo(mfunction,name,'nntype.training_fcn',version);
      
      x.isSupervised = isSupervised;
      x.usesGradient = true; % MAKE THIS AN ARGUMENT;
      x.usesJacobian = true; % MAKE THIS AN ARGUMENT;
      x.usesDerivative = x.usesGradient || x.usesJacobian;
      x.usesValidation = usesValidation;
      x.states = states;
      x.setupParameters(param);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      disp@nnfcnInfo(x)
      disp([nnlink.prop2link('isSupervised') nnstring.bool2str(x.isSupervised)]);
      disp([nnlink.prop2link('usesValidation') nnstring.bool2str(x.usesValidation)]);
      disp([nnlink.prop2link('trainingStates') nnlink.states2str(x.states)]);
      if (isLoose), fprintf('\n'), end
    end
    
    % NNET 6.0 Compatibility
    function gd = gdefaults(x)
      gd = 'defaultderiv';
    end
  end
  
end


