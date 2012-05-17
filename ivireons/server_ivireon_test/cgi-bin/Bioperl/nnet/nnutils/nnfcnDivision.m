classdef nnfcnDivision < nnfcnInfo
%NNDIVISIONFCNINFO Data Division function info.

% Copyright 2010 The MathWorks, Inc.

  properties (SetAccess = private)
  end
  
  methods
    
    function x = nnfcnDivision(name,title,version,param)
      
      if nargin < 4, nnerr.throw('Not enough input arguments.'); end
      if ~isempty(param) && ~isa(param,'nnetParamInfo')
        nnerr.throw('Parameters must be an nnetParamInfo array.');
      end
      
      x = x@nnfcnInfo(name,title,'nntype.division_fcn',version);
      x.setupParameters(param);
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnDivision">nnfcnDivision</a>')
      fprintf('\n')
      %=======================:
      disp(['       parameters: ' params2str(x.parameters)]);
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
