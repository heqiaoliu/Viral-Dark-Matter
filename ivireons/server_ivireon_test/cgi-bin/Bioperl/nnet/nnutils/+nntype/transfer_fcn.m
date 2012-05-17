function [out1,out2] = transfer_fcn(in1,in2,in3)
%NN_TRANSFER_FCN Transfer function type.

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
  info = nnfcnFunctionType(mfilename,'Transfer Function',7,...
    7,fullfile('nnet','nntransfer'));
end

function err = type_check(fcn)
  err = nntest.fcn(fcn,false);
  if ~isempty(err), return; end
  info = feval(fcn,'info');
  if ~strcmp(info.type,'nntype.transfer_fcn')
    err = ['VALUE info.type is not nntype.transfer_fcn.'];
    return;
  end
  info = feval(fcn,'info');
  
  rs = RandStream('mrg32k3a','seed',pi);
  
  % y = f(x)
  n = rs.rand(4,5);
  a = feval(fcn,n);
  if (ndims(a) ~= ndims(n)) || (any(size(a) ~= size(n)))
    err = 'VALUE does not return outputs of same size as inputs.';
  end
  ind = rs.randperm(5);
  n2 = n(:,ind);
  a2 = feval(fcn,n2);
  if any(any(a2 ~= a(:,ind)))
    err = 'VALUE does not return same outputs when samples are permuted.';
  end
  
  % y = f(x,param)
  param = info.defaultParam;
  ap = feval(fcn,n,param);
  if (ndims(ap) ~= ndims(a)) || (any(size(ap) ~= size(a))) ...
    || any(any(a ~= ap))
    err = 'VALUE returns different values when parameters are supplied.';
  end
  
  % y = f(x), NaN
  n = rs.rand(4,5);
  n(3,2) = NaN;
  a = feval(fcn,n);
  nann = isnan(n);
  nana = isnan(a);
  if any(nann ~= nana)
    err = 'VALUE does not return NaN values in same position as NaN inputs.';
  end
  
  % y = f(x), NaN, not scalar
  if ~info.isScalar
    n = rs.rand(4,5);
    n(3,2) = NaN;
    a = feval(fcn,n);
    nann = repmat(any(isnan(n),1),4,1);
    nana = isnan(a);
    if any(nann ~= nana)
      err = 'VALUE info.isCompetitive is true, but returns non-NaN in columns where input has NaN.';
    end
  end
  
  % da_dn = fcn('da_dn',n,a), scalar
  if info.isScalar
    n = rand(4,5);
    a = feval(fcn,n);
    da_dn = feval(fcn,'da_dn',n,a);
    if (ndims(da_dn) ~= ndims(n)) || (any(size(da_dn)~=size(n)))
      err = 'VALUE does not return derivatives the same size as inputs.';
    end
    d = 1e-7;
    n1 = n - (d/2);
    n2 = n + (d/2);
    a1 = feval(fcn,n1);
    a2 = feval(fcn,n2);
    da_dn_num = (a2-a1)./(n2-n1);
    diff = max(max(abs(da_dn - da_dn_num)));
    if (diff > 1e-5)
      err = 'VALUE derivatives do not pass numerical calculations.';
      return;
    end
  end
  
  % da_dn = fcn('da_dn',n,a), not scalar
  if ~info.isScalar
    n = rand(4,5);
    a = feval(fcn,n);
    da_dn = feval(fcn,'da_dn',n,a);
    if ~iscell(da_dn)
      err = 'VALUE''s info.isScalar is false, but derivative is not cell array.';
    end
    if (ndims(da_dn) ~= 2) || any(size(da_dn) ~= [1 5])
      err = 'VALUE''s info.isScalar is false, but derivative is not 1xQ cell array.';
    end
    for i=1:5
      if (ndims(da_dn{i}) ~= 2) || (any(size(da_dn{i})~=[4 4]))
        err = 'VALUE''s info.isScalar is false, but derivative has cell element that is not SxS.';
      end
    end
    da_dn_num = feval(fcn,'da_dn_num',n,a);
    diff = max(max(abs(cell2mat(da_dn) - cell2mat(da_dn_num))));
    if (diff > 1e-5)
      err = 'VALUE derivatives do not pass numerical calculations.';
      return;
    end
  end
  
end

function fcn = strict_format(fcn)
  fcn = nntype.modular_fcn('format',fcn);
end
