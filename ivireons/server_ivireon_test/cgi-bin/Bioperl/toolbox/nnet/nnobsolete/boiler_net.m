%BOILER_NET Boilerplate script for net input functions.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2005-2010 The MathWorks, Inc.

if nargin < 1,nnerr.throw('Not enough input arguments.'); end
in1 = varargin{1};
num = length(varargin);

% NNT4 SUPPORT
if ~(ischar(in1) || iscell(in1))
  if isa(varargin{end},'struct')
    in1 = varargin(1:(end-1));
    varargin = { in1, varargin{end} };
    num = 2;
  else
    in1 = varargin;
    varargin = { in1 };
    num = 1;
  end
elseif ischar(in1)
  if strcmp(in1,'deriv')
    out1 = ['d' fn];
    nnerr.obs_use(fn,['Use ' upper(fn) ' to calculate transfer function derivatives.'], ...
      'Net input functions now calculate their own derivatives.')
    return
  end
end

if ischar(in1)
  switch in1
    
    case 'info'
      try
        out1 = get_info;
      catch
        info.function = fn;
        info.name = name;
        info.type = 'Net Input';
        info.version = 6.0;
        out1 = info;
      end
      return
      
  % NNT 6.0 Support
  case 'name'
    out1 = name;
  case 'type'
    out1 = 'net_input_function';
  case 'fpnames'
     if (num > 1), nnerr.throw('Too many input arguments for action ''fpnames''.'), end
    out1 = param_names;
  case 'fpdefaults'
    if (num > 1), nnerr.throw('Too many input arguments for action ''fpdefaults''.'), end
    out1 = param_defaults;
  case 'fpcheck'
    if (num > 2), nnerr.throw('Too many input arguments for action ''fpcheck''.'), end
    err = param_check(varargin{2});
    if (nargout > 0)
      out1 = err;
    elseif ~isempty(err)
      nnerr.throw(err);
    end
  case 'dz',
    if (num > 5), nnerr.throw('Too many input arguments for action ''dz''.'), end
    if (num < 3), nnerr.throw('Not enough input arguments for action ''dz''.'), end
    if (num < 5) || isempty(varargin{5}), varargin{5} = param_defaults; elseif isa(varargin{5},'cell'), varargin{5}=nnt_fpc2s(varargin{5},param_defaults); end
    if (num < 4), varargin{4} = apply(varargin{[3,5]}); end
    out1 = derivative_dn_dzj(varargin{2:end});
  otherwise, nnerr.throw(['Unrecognized code: ''' in1 ''''])
  end
  return
end
if (num > 2), nnerr.throw('Too many input arguments'), end
if (num < 2), varargin{2} = param_defaults; elseif isa(varargin{2},'cell'), varargin{2}=nnt_fpc2s(varargin{2},param_defaults);end
out1 = apply(varargin{1:2});
