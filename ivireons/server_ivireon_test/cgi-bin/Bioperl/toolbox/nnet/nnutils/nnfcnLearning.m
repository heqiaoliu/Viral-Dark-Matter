classdef nnfcnLearning < nnfcnInfo
%NNLAYERINITFCNINFO Layer initialization function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
    learnBias = true;
    learnInputWeight = false;
    learnLayerWeight = false;
    needGradient = false;
  end
  
  % TODO - Methods for getting and checking initial settings
  
  methods
    
    function x = nnfcnLearning(mfunction,name,version,subfunctions,...
        b,iw,lw,g,param)
      if nargin < 8, nnerr.throw('Args','Not enough input arguments.'); end
      if ~nntype.bool_scalar('isa',b),nnerr.throw('Args','learnBias must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',iw),nnerr.throw('Args','learnInputWeight must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',lw),nnerr.throw('Args','learnLayerWeight must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',g),nnerr.throw('Args','needGradient must be a logical scalar.'); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        nnerr.throw('Args','Parameters must be an nnetParamInfo array.');
      end
      
      x = x@nnfcnInfo(mfunction,name,'nntype.learning_fcn',version,subfunctions);
      
      x.learnBias = b;
      x.learnInputWeight = iw;
      x.learnLayerWeight = lw;
      x.needGradient = g;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnLearning">Learning Function Info</a>')
      fprintf('\n')
      %=======================:
      disp(['        learnBias: ' nnstring.bool2str(x.learnBias)]);
      disp([' learnInputWeight: ' nnstring.bool2str(x.learnInputWeight)]);
      disp([' learnLayerWeight: ' nnstring.bool2str(x.learnLayerWeight)]);
      disp(['     needGradient: ' nnstring.bool2str(x.needGradient)]);
      disp(['       parameters: ' nnstring.params2str(x.parameters)]);
    end
    
    % NNET 6.0 Compatibility
    function ng = needg(x)
      ng = x.needGradient;
    end
      
  end
  
end
