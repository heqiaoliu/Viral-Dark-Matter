function out1 = normprod(varargin)
%NORMPROD Normalized dot product weight function.
%
%	 Weight functions apply weights to an input to get weighted inputs.
%
%	 <a href="matlab:doc normprod">normprod</a>(W,P) takes an SxR weight matrix and an RxQ input matrix and
%  returns the SxQ normalized dot product.
%
%  <a href="matlab:doc normprod">normprod</a>('size',S,R,FP) takes the layer dimension S, input dimension R,
%  and function parameters, and returns the weight size [SxR].
%
%  <a href="matlab:doc normprod">normprod</a>('dp',W,P,Z,FP) returns the derivative of Z with respect to P.
%  <a href="matlab:doc normprod">normprod</a>('size',S,R,FP) returns the derivative of Z with respect to W.
%
%	 Here we define a random weight matrix W and input vector P
%	 and calculate the corresponding weighted input Z.
%
%	   W = rand(4,3);
%	   P = rand(3,1);
%	   Z = <a href="matlab:doc normprod">normprod</a>(W,P)
%
%	See also DOTPROD.

% Mark Beale, 11-31-97
% Mark Hudson Beale, improvements, 01-08-2001
% Orlando De Jesus, code fix, 02-12-2002
% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.7 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Weight Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end,
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    nntype.string('check',in1,'First argument');
    switch (in1)
      
      % User Functionality
      
      case 'apply'
        % this('apply',w,p,...*param...)
        % Calculate net input from weights and input
        % Equivalent to: this(w,p,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        w = nntype.matrix_data('format',args{1},'Weight');
        p = nntype.matrix_data('format',args{2},'Inputs');
        out1 = apply(w,p,param);
      
      case 'dz_dp'
        % this('dz_dp',w,p,z,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        w = nntype.matrix_data('format',args{1},'Weight');
        p = nntype.matrix_data('format',args{2},'Inputs');
        if nargin < 3
          z = apply(w,p,INFO.defaultParam);
        else
          z = nntype.matrix_data('format',args{2},'Net input');
        end
        out1 = dz_dp(w,p,z,param);
        
      case 'dz_dw'
        % this('dz_dw',w,p,z,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        w = nntype.matrix_data('format',args{1},'Weight');
        p = nntype.matrix_data('format',args{2},'Inputs');
        if nargin < 3
          z = apply(w,p,INFO.defaultParam);
        else
          z = nntype.matrix_data('format',args{2},'Net input');
        end
        out1 = dz_dw(w,p,z,param);
      
      % Simulink
      
      case 'simulink_params'
        % this('simulink_params',...*param...)
        [~,param,~] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        out1 = simulink_params(param);
        
      % Testing
      
      case 'dz_dp_num'
        % this('dz_dp_num',w,p,z,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        w = nntype.matrix_data('format',args{1},'Weight');
        p = nntype.matrix_data('format',args{2},'Inputs');
        if nargin < 3
          z = apply(w,p,INFO.defaultParam);
        else
          z = nntype.matrix_data('format',args{2},'Net input');
        end
        out1 = dz_dp_num(w,p,z,param);
        
      case 'dz_dw_num'
        % this('dz_dw_num',w,p,z,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        w = nntype.matrix_data('format',args{1},'Weight');
        p = nntype.matrix_data('format',args{2},'Inputs');
        if nargin < 3
          z = apply(w,p,INFO.defaultParam);
        else
          z = nntype.matrix_data('format',args{2},'Net input');
        end
        out1 = dz_dw_num(w,p,z,param);
        
      % Implementation
        
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'check_param'
        % this('checkparam',...*param...)
        % Check parameter types and consistency.
        [~,param,~] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        [out1,param] = nntest.param_types(INFO.parameters,param);
        if isempty(out1), out1 = check_param(param); end
        
      case 'size',
        % this('size',numNeurons,numInputs')
        % Weight size
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        s = nntype.pos_int_scalar('format',args{1},'Layer size');
        r = nntype.pos_int_scalar('format',args{2},'Input size');
        out1 = weight_size(s,r,param);
      
      % NNET 6.0 Compatibility
      
      case 'pfullderiv', out1 = p_deriv;
      case 'wfullderiv', out1 = w_deriv;
      case 'check',
        if nargin < 2,nnerr.throw('Not enough arguments for action ''check''.'); end
        out1 = check_param(varargin{2});      
      case 'dp'
        if nargin < 4,nnerr.throw('Not enough arguments for action ''dp''.'); end
        if nargin < 5, varargin{5} = INFO.defaultParam; end
        out1 = dz_dp(varargin{2:5});
      case 'dw'
        if nargin < 4,nnerr.throw('Not enough arguments for action ''dw''.'); end
        if nargin < 5, varargin{5} = INFO.defaultParam; end
        out1 = dz_dw(varargin{2:5});
       
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
  % this(w,p,...*param...)
  % Calculate net input from weights and input
  % Equivalent to: this('apply',w,p,...*param...)
  [args,param,nargs] = nnparam.extract_param(varargin,INFO.defaultParam);
  if nargs < 2, nnerr.throw('Not enough input arguments.'); end
  w = nntype.matrix_data('format',args{1},'Weight');
  p = nntype.matrix_data('format',args{2},'Inputs');
  out1 = apply(w,p,param);
end

function d = dz_dp_num(w,p,z,param)
  delta = 1e-7;
  [S,R] = size(w);
  [R,Q] = size(p);
  d = cell(1,Q);
  for q=1:Q
    pq = p(:,q);
    dq = zeros(S,R);
    for i=1:R
      z1 = apply(w,addp(pq,i,+2*delta),param);
      z2 = apply(w,addp(pq,i,+delta),param);
      z3 = apply(w,addp(pq,i,-delta),param);
      z4 = apply(w,addp(pq,i,-2*delta),param);
      dq(:,i) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
    end
    d{q} = dq;
  end
end

function n = addp(n,i,v)
  n(i) = n(i) + v;
end

function d = dz_dw_num(w,p,z,param)
  delta = 1e-7;
  [S,R] = size(w);
  Q = size(p,2);
  d = cell(1,S);
  for i=1:S
    wi = w(i,:);
    di = zeros(R,Q);
    for j=1:R
      z1 = apply(addw(wi,j,+2*delta),p,param);
      z2 = apply(addw(wi,j,+delta),p,param);
      z3 = apply(addw(wi,j,-delta),p,param);
      z4 = apply(addw(wi,j,-2*delta),p,param);
      di(j,:) = (-z1 + 8*z2 - 8*z3 + z4) / (12*delta);
    end  
    d{i} = di;
  end
end

function n = addw(n,i,v)
  n(i) = n(i) + v;
end

function sf = subfunctions
  sf.is_dotprod = strcmp(mfilename,'dotprod');
  sf.p_deriv = p_deriv;
  sf.w_deriv = w_deriv;
  sf.weight_size = @weight_size;
  sf.apply = @apply;
  sf.dz_dp = @dz_dp;
  sf.dz_dw = @dz_dw;
  sf.dz_dp_num = @dz_dp_num;
  sf.dz_dw_num = @dz_dw_num;
end

function info = get_info
  info = nnfcnWeight(mfilename,function_name,7,...
    subfunctions,is_continuous,p_deriv,w_deriv,parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Dot Product Normalized'; end
function flag = is_continuous, flag = true; end
function d = p_deriv, d = 1; end
function d = w_deriv, d = 0; end
function param = parameters, param = []; end

function err = check_param(param)
  err = '';
end

function dim = weight_size(s,r,param)
  dim = [s r];
end

function z = apply(w,p,param)
  [R,Q] = size(p);
  sump = sum(abs(p),1);
  dividep = 1 ./ sump;
  dividep(sump == 0) = 0;
  z = w * (p .* dividep(ones(1,R),:));
  
  % Multiplying by the reciprocal of sump instead of
  % dividing by sump produces more accurate results and
  % a better match with numerical derivatives.
end

function d = dz_dp(w,p,z,param)
  [S,R] = size(w);
  Q = size(p,2);
  d = cell(1,Q);
  if (R == 1)
    d(:) = {zeros(S,R)};
  else
    sump = sum(abs(p),1);
    dividep = 1 ./ sump;
    dividep(sump == 0) = 0;
    signp = sign(p);
    rZeros = zeros(1,R);
    sZeros = zeros(1,S);
    for q=1:Q
      d{q} = (w - signp(:,q+sZeros)' .* z(:,q+rZeros)) * dividep(q);
    end
  end
end

function d = dz_dw(w,p,z,param)
  [R,Q] = size(p);
  if (R == 1)
    d = sign(p);
  else
    sump = sum(abs(p),1);
    dividep = 1 ./ sump;
    dividep(sump == 0) = 0;
    d = p .* dividep(ones(1,R),:);
  end
end

function p = simulink_params(param)
  p = {};
end
