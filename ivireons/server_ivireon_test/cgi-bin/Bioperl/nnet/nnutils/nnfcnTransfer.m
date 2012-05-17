classdef nnfcnTransfer < nnfcnInfo

% Copyright 2010 The MathWorks, Inc.
  
  properties (SetAccess = private)
    outputRange = [-inf inf];
    activeInputRange = [-inf inf];
    isScalar = true;
    isContinuous = false;
    isSmooth = false;
    isMonotonic = false;
    isBasis = false;
    isCompetitive = false;
    simulinkBlock = '';
  end
  
  methods
    
    function x = nnfcnTransfer(mfunction,name,version,subfunctions,...
        outputRange,activeInputRange,...
        isContinuous,isSmooth,...
        isMonotonic,isScalar,isBasis,isCompetitive, ...
        parameters)
      
      % TODO - pass in fullDerivative
      % = isa('da_dn',zeros(3,4),zeros(3,4),x.defaultParam),'cell');
  
      if nargin < 11,nnerr.throw('Not enough input arguments.'); end
      if ~nntype.interval('isa',outputRange), nnerr.throw('OutputRange must be an interval.'); end
      if ~nntype.interval('isa',activeInputRange), nnerr.throw('ActiveInputRange must be an interval.'); end
      if ~nntype.bool_scalar('isa',isScalar), nnerr.throw('isScalar must be a boolean scalar.'); end
      if ~nntype.bool_scalar('isa',isContinuous), nnerr.throw('isContinuous must be a boolean scalar.'); end
      if ~nntype.bool_scalar('isa',isMonotonic), nnerr.throw('isMonotonic must be a boolean scalar.'); end
      if ~nntype.bool_scalar('isa',isBasis), nnerr.throw('isBasis must be a boolean scalar.'); end
      if ~nntype.bool_scalar('isa',isCompetitive), nnerr.throw('isCompetitive must be a boolean scalar.'); end
      if ~isempty(parameters) && ~isa(parameters,'nnetParamInfo')
        nnerr.throw('Parameters must be an nnetParamInfo array.');
      end
      
      if (isScalar && isCompetitive), nnerr.throw('A competitive transfer function cannot be scalar.'); end
      if (~isScalar && isBasis), nnerr.throw('A basis transfer function must be scalar.'); end
      
      x = x@nnfcnInfo(mfunction,name,'nntype.transfer_fcn',version,subfunctions);
      x.outputRange = outputRange;
      x.activeInputRange = activeInputRange;
      x.isContinuous = isContinuous;
      x.isSmooth = isSmooth;
      x.isMonotonic = isMonotonic;
      x.isScalar = isScalar;
      x.isBasis = isBasis;
      x.isCompetitive = isCompetitive;
      x.simulinkBlock = mfunction;
      
      x.setupParameters(parameters);
    end
    
    function disp(x)
      isLoose = strcmp(get(0,'FormatSpacing'),'loose');
      disp@nnfcnInfo(x)
      disp([nnlink.prop2link('outputRange') nnstring.interval2str(x.outputRange)]);
      disp([nnlink.prop2link('activeInputRange') nnstring.interval2str(x.activeInputRange)]);
      disp([nnlink.prop2link('isContinuous') nnstring.bool2str(x.isContinuous)]);
      disp([nnlink.prop2link('isSmooth') nnstring.bool2str(x.isSmooth)]);
      disp([nnlink.prop2link('isMonotonic') nnstring.bool2str(x.isMonotonic)]);
      disp([nnlink.prop2link('isScalar') nnstring.bool2str(x.isScalar)]);
      disp([nnlink.prop2link('isBasis') nnstring.bool2str(x.isBasis)]);
      disp([nnlink.prop2link('isCompetitive') nnstring.bool2str(x.isCompetitive)]);
      disp([nnlink.prop2link('simulinkBlock') ...
        nnlink.block2linkstr(x.simulinkBlock,'Transfer Functions')]);
      if (isLoose), fprintf('\n'), end
    end
    
    % NNET 6.0 Compatibility
    function or = output(x)
      or = x.outputRange;
    end
    function air = active(x)
      air = x.activeInputRange;
    end
    function fd = fullderiv(x)
      fd = x.fullDerivative;
    end
  end
end

