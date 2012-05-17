function out1 = tansig2(varargin)
%TANSIG2 Test symmetric sigmoid transfer function with parameters.

% Copyright 2010 The MathWorks, Inc.

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Transfer Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end,
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    nntype.string('check',in1,'First argument');
    switch(in1)
      
      % User Functionality
      
      case 'apply'
        % this('apply',n,...*param...)
        % Apply transfer function to net inputs
        % Equivalent to: this(n,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 1, nnerr.throw('Not enough input arguments.'); end
        n = nntype.matrix_data('format',args{1},'Net input');
        out1 = apply(n,param);
      
      case 'da_dn'
        % this('da_dn',n,*a,...*param...)
        % Calculate da/dn analytically
        % Derivative may be returned in matrix form (for scalar functions)
        % or cell form (for general functions).
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 1, nnerr.throw('Not enough input arguments.'); end
        n = nntype.matrix_data('format',args{1},'Net input');
        if nargs < 2
          a = apply(n,INFO.defaultParam);
        else
          a = nntype.matrix_data('format',args{2},'Layer output');
          if any(size(n) ~= size(a))
            nnerr.throw('Dimensions of net inputs N and outputs A do not match.');
          end
        end
        out1 = da_dn(n,a,param);
      
      % Testing
      
      case 'da_dn_full'
        % this('da_dn_full',n,*a,...*param...)
        % Calculate da/dn analytically, return in full cell form
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 1, nnerr.throw('Not enough input arguments.'); end
        n = nntype.matrix_data('format',args{1},'Net input');
        if nargs < 2
          a = apply(n,INFO.defaultParam);
        else
          a = nntype.matrix_data('format',args{2},'Layer output');
          if any(size(n) ~= size(a))
            nnerr.throw('Dimensions of net inputs N and outputs A do not match.');
          end
        end
        d = da_dn(n,a,param);
        if iscell(d)
          out1 = d;
        else
          Q = size(d,2);
          out1 = cell(1,Q);
          for i=1:Q
            out1{i} = diag(d(:,i));
          end
        end
      
      case 'da_dn_num'
        % this('da_dn_num',n,*a,...*param...)
        % Calculate da/dn numerically, return in full cell form
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 1, nnerr.throw('Not enough input arguments.'); end
        n = nntype.matrix_data('format',args{1},'Net input');
        if nargs < 2
          a = apply(n,INFO.defaultParam);
        else
          a = nntype.matrix_data('format',args{2},'Layer output');
          if any(size(n) ~= size(a))
            nnerr.throw('Dimensions of net inputs N and outputs A do not match.');
          end
        end
        out1 = da_dn_num(n,a,param);
      
      % Implementation
      
      case 'info'
        % this('info')
        % Return this functions information object.
        out1 = INFO;
      
      case 'check_param'
        % this('checkparam',...*param...)
        % Check parameter types and consistency.
        [~,param,~] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        [out1,param] = nntest.param_types(INFO.parameters,param);
        if isempty(out1), out1 = check_param(param); end
        
      % Simulink
      
      case 'simulink_params'
        % this('simulink_params',...*param...)
        [~,param,~] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        out1 = simulink_params(param);
        
      % NNET 6.0 Compatibility
      
      case 'dn'
        if nargin < 4
          param = INFO.defaultParam;
        else
          param = varargin{4};
        end
        out1 = da_dn(varargin{2:3},param);
      case 'check'
        out1 = feval(mfilename,'check_param',varargin{2});
      case 'fullderiv'
        out1 = ~INFO.isScalar;
      
      % Implementation
      
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' in1]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized argument: ''' in1 ''''])
        end
    end
    return
  end
  
  % User Functionality
  
  % this(n,...*param...)
  % equivalent to: this('apply',n,...*param)
  [args,param,nargs] = nnparam.extract_param(varargin,INFO.defaultParam);
  if nargs < 1, nnerr.throw('Not enough input arguments.'); end
  n = nntype.matrix_data('format',args{1},'Net input');
  out1 = apply(n,param);
end

function d = da_dn_full(n,a,param)
  d = da_dn(n,a,param);
  if ~iscell(d)
    Q = size(n,2);
    dfull = cell(1,Q);
    for q=1:Q, dfull{q} = diag(d(:,q)); end
    d = dfull;
  end
end

function d = da_dn_num(n,a,param)
  delta = 1e-6;
  [S,Q] = size(n);
  d = cell(1,Q);
  for q=1:Q
    nq = n(:,q);
    dq = zeros(S,S);
    for i=1:S
      a1 = apply(addn(nq,i,+2*delta),param);
      a2 = apply(addn(nq,i,+delta),param);
      a3 = apply(addn(nq,i,-delta),param);
      a4 = apply(addn(nq,i,-2*delta),param);
      dq(:,i) = (-a1 + 8*a2 - 8*a3 + a4) / (12*delta);
    end
    d{q} = dq;
  end
end

function n = addn(n,i,v)
  n(i) = n(i) + v;
end

function sf = subfunctions
  sf.is_scalar = is_scalar;
  sf.apply = @apply;
  sf.da_dn = @da_dn;
  sf.da_dn_full = @da_dn_full;
  sf.da_dn_num = @da_dn_num;
end

function info = get_info
  info = nnfcnTransfer(...
    mfilename,function_name,7,subfunctions,...
    output_range,active_input_range,is_continuous,...
    is_smooth,is_monotonic,is_scalar,is_basis,is_competitive,...
    parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Sigmoid Symmetric Test 2'; end
function range = output_range, range = [-1 1]; end
function range = active_input_range, range = [-2 2]; end
function flag = is_continuous, flag = true; end
function flag = is_smooth, flag = true; end
function flag = is_monotonic, flag = true; end
function flag = is_scalar, flag = true; end
function flag = is_basis, flag = false; end
function flag = is_competitive, flag = false; end

function param = parameters
  param = ...
    [...
    nnetParamInfo('alpha','Alpha','nntype.real_scalar',2,...
    'Gain on net sum.'),...
    nnetParamInfo('beta','Beta','nntype.real_scalar',1,...
    'Offset for net sum.'),...
    ];
end

function a = apply(n,param)
  a = 2*param.beta ./ (param.beta + exp(-2*n*param.alpha)) - 1;
  i = find(~isfinite(a));
  a(i) = sign(n(i));
end

function d = da_dn(n,a,param)
  d = param.alpha*(1-(a.*a));
end

function p = simulink_params(param)
  p = 'TANSIG2 does not have a Simulink block.';
end
