classdef nnfcnWeight < nnfcnInfo
%NNWEIGHTFCNINFO Weight function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    isContinuous = true;
    inputDerivType = 0;
    weightDerivType = 0;
  end
  
  methods
    
    function x = nnfcnWeight(name,title,version,subfunctions, ...
        isContinuous,inputDerivType,weightDerivType,param)
      
      if nargin < 6,nnerr.throw('Not enough input arguments.'); end
      if ~nntype.pos_int_scalar('isa',inputDerivType), nnerr.throw('inputDerivType must be 0, 1 or 2.'); end
      if ~nntype.pos_int_scalar('isa',weightDerivType), nnerr.throw('weightDerivType must be 0, 1 or 2.'); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        nnerr.throw('Parameters must be an nnetParamInfo array.');
      end
      
      x = x@nnfcnInfo(name,title,'nntype.weight_fcn',version,subfunctions);
      x.isContinuous = isContinuous;
      x.inputDerivType = inputDerivType;
      x.weightDerivType = weightDerivType;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnWeight">nnfcnWeight</a>')
      fprintf('\n')
      %=======================:
      disp(['     isContinuous: ' nnstring.bool2str(x.isContinuous)]);
      disp(['   inputDerivType: ' nnstring.num2str(x.inputDerivType)]);
      disp(['  weightDerivType: ' nnstring.num2str(x.weightDerivType)]);
      disp(['       parameters: ' nnstring.params2str(x.parameters)]);
    end
    
  end
  
end
