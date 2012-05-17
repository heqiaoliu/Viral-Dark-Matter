classdef nnfcnProcessing < nnfcnInfo
%NNPROCESSINGFCNINFO Data pre/post-processing function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    processInputs = true;
    processOutputs = true;
    isContinuous = true;
  end
  
  methods
    
    function x = nnfcnProcessing(name,title,version,subfunctions,...
      processInputs,processOutputs,isContinuous,param)
      if nargin < 8, nnerr.throw('Not enough input arguments.'); end
      x = x@nnfcnInfo(name,title,'nntype.processing_fcn',version,subfunctions);
      x.processInputs = processInputs;
      x.processOutputs = processOutputs;
      x.isContinuous = isContinuous;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(['    processInputs: ' nnstring.bool2str(x.processInputs)]);
      disp(['   processOutputs: ' nnstring.bool2str(x.processOutputs)]);
      disp(['     isContinuous: ' nnstring.bool2str(x.isContinuous)]);
    end
    
  end
  
end
