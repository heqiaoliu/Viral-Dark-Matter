classdef nnfcnNetInput < nnfcnInfo
%NNNETINPUTFCNINFO Net Input function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
    isContinuous = false;
  end
  
  methods
    
    function x = nnfcnNetInput(name,title,version,subfunctions,...
        isContinuous,param)
      
      if nargin < 4, nnerr.throw('Not enough input arguments.'); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        nnerr.throw('Parameters must be an nnetParamInfo array.');
      end
      
      x = x@nnfcnInfo(name,title,'nntype.net_input_fcn',version,subfunctions);
      x.isContinuous = isContinuous;
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp([nnlink.prop2link('isContinuous') nnstring.bool2str(x.isContinuous)]);
    end
    
  end
  
end

function s = params2str(p)
  n = length(p);
  if n == 0
    s = '(none)';
  else
    s = ['[1x' num2str(n) ' <a href="matlab:doc nnetParamInfo">nnetParamInfo</a> array]'];
  end
end
