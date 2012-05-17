classdef nnfcnWeightInit < nnfcnInfo
%NNLAYERINITFCNINFO Weight/bias initialization function info.

% Copyright 2010 The MathWorks, Inc.
  
  properties
    initBias = true;
    initInputWeight = true;
    initLayerWeight = true;
    initFromRows = true;
    initFromRowsCols = true;
    initFromRowsRange = true;
    initFromRowsInput = true;
    irregularWeights = false;
  end
  
  methods
    
    function x = nnfcnWeightInit(name,title,version,b,iw,lw,ir,irc,irr,iri,irw)
      if nargin < 6, nnerr.throw('Unsupported','Not enough input arguments.'); end
      
      if ~nntype.bool_scalar('isa',b),nnerr.throw('initBias must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',iw),nnerr.throw('initInputWeight must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',lw),nnerr.throw('initLayerWeight must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',ir),nnerr.throw('initFromRows must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',irc),nnerr.throw('initFromRowsCols must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',irr),nnerr.throw('initFromRowsRange must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',iri),nnerr.throw('initFromRowsInput must be a logical scalar.'); end
      if ~nntype.bool_scalar('isa',irw),nnerr.throw('irregularWeights must be a logical scalar.'); end
      
      x = x@nnfcnInfo(name,title,'nntype.weight_init_fcn',version);
      
      x.initBias = b;
      x.initInputWeight = iw;
      x.initLayerWeight = lw;
      x.initFromRows = ir;
      x.initFromRowsCols = irc;
      x.initFromRowsRange = irr;
      x.initFromRowsInput = iri;
      x.irregularWeights = irw;
    end
    
    function disp(x)
      disp@nnfcnInfo(x)
      fprintf('\n')
      disp(' <a href="matlab:doc nnfcnWeightInit">Weight/Bias Initialization Function Info</a>')
      fprintf('\n')
      %=======================:
      disp(['         initBias: ' nnstring.bool2str(x.initBias)]);
      disp(['  initInputWeight: ' nnstring.bool2str(x.initInputWeight)]);
      disp(['  initLayerWeight: ' nnstring.bool2str(x.initLayerWeight)]);
      disp([     'initFromRows: ' nnstring.bool2str(x.initFromRows)]);
      disp([ 'initFromRowsCols: ' nnstring.bool2str(x.initFromRowsCols)]);
      disp(['initFromRowsRange: ' nnstring.bool2str(x.initFromRowsRange)]);
      disp(['initFromRowsInput: ' nnstring.bool2str(x.initFromRowsInput)]);
      disp([ 'irregularWeights: ' nnstring.bool2str(x.irregularWeights)]);
    end
    
  end
  
end

