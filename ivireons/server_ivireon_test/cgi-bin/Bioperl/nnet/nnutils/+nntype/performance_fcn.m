function [out1,out2] = performance_fcn(in1,in2,in3)
%NN_PERFORMANCE_FCN Training function type.

% Copyright 2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Type Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if nargin < 1, nnerr.throw('Not enough input arguments.'); end
  if ischar(in1)
    switch (in1)
      
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'isa'
        % this('isa',value)
        out1 = isempty(type_check(in2));
        
      case {'check','assert','test'}
        % [*err] = this('check',value,*name)
        nnassert.minargs(nargin,2);
        if nargout == 0
          err = type_check(in2);
        else
          try
            err = type_check(in2);
          catch me
            out1 = me.message;
            return;
          end
        end
        if isempty(err)
          if nargout>0,out1=''; end
          return;
        end
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout==0, err = nnerr.value(err,'Value'); end
        if nargout > 0
          out1 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'format'
        % [x,*err] = this('format',x,*name)
        err = type_check(in2);
        if isempty(err)
          out1 = strict_format(in2);
          if nargout>1, out2=''; end
          return
        end
        out1 = in2;
        if nargin>2, err = nnerr.value(err,in3); end
        if nargout < 2, err = nnerr.value(err,'Value'); end
        if nargout>1
          out2 = err;
        else
          throwAsCaller(MException(nnerr.tag('Type',2),err));
        end
        
      case 'check_param'
        out1 = '';
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
  else
    nnerr.throw('Unrecognized input.')
  end
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info
  info = nnfcnFunctionType(mfilename,'Performance Function',7,...
    7,fullfile('nnet','nnperformance'));
end

function err = type_check(x)
  err = nntest.fcn(x,false);
  if ~isempty(err), return; end
  info = feval(x,'info');
  if ~strcmp(info.type,'nntype.performance_fcn')
    err = [upper(x) '(''type'') is not nntype.performance_fcn.'];
    return;
  end
  
  % Random stream
  saveRandStream = RandStream.getDefaultStream;
  RandStream.setDefaultStream(RandStream('mt19937ar','seed',pi));
  
  % Performance
  [X,T] = simplefit_dataset;
  net = feedforwardnet;
  net = configure(net,X,T);
  Y = net(X);
  perf = feval(x,net,T,Y);
  perfy = feval(x,'perf_y',net,T,Y);
  perfwb = feval(x,'perf_wb',net,T,Y);
  if abs(perf - (perfy + perfwb)) > 1e-10
    err = [upper(x) ' does not return output and weight performances that sum to performance.'];
    return
  end
  
  % Derivatives of Y
  dy = feval(x,'dperf_dy',net,T,Y,{1},perf);
  if (ndims(dy) ~= ndims(Y)) || any(size(dy) ~= size(Y))
    err = [upper(x) ' returns derivatives of y of different size than y.'];
    return
  end
  
  % Derivatives of WB
  dy = feval(x,'dperf_dwb',net,T,Y,{1},perf);
  if (ndims(dy) ~= 2) || any(size(dy) ~= [net.numWeightElements 1])
    err = [upper(x) ' derivatives of wb do not have size [net.numWeightElements 1].'];
    return
  end
  
  % TODO - test derivatives numerically
  % TODO - test regularization/normalization parameter combinations
  
  % Random Stream
  RandStream.setDefaultStream(saveRandStream);
end

function x = strict_format(x)
  x = lower(x);
end


