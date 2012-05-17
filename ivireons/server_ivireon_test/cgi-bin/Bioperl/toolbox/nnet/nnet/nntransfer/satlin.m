function out1 = satlin(varargin)
%SATLIN Positive saturating linear transfer function.
%	
% Transfer functions convert a neural network layer's net input into
% its net output.
%	
% A = <a href="matlab:doc satlin">satlin</a>(N) takes an SxQ matrix of S N-element net input column
% vectors and returns an SxQ matrix A of output vectors where each element
% of A is 1 where N is 1 or greater, N where N is in the interval [0 1],
% and 0 where N is 0 or less.
%
% <a href="matlab:doc satlin">satlin</a>('da_dn',N,A) returns the derivative of layer outputs A with
% respect to net inputs N.
%
% Here a layer output is calculate from a single net input vector:
%
%   n = [0; 1; -0.5; 0.5];
%   a = <a href="matlab:doc satlin">satlin</a>(n);
%
% Here is a plot of this transfer function:
%
%   n = -5:0.01:5;
%   plot(n,<a href="matlab:doc satlin">satlin</a>(n))
%   set(gca,'dataaspectratio',[1 1 1],'xgrid','on','ygrid','on')
%
% Here this transfer function is assigned to the ith layer of a network:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_transferFcn">transferFcn</a> = '<a href="matlab:doc satlin">satlin</a>';
%
%	See also PURELIN, POSLIN, SATLINS.

% Mark Beale, 1-31-92
% Revised 12-15-93, MB
% Revised 11-31-97, MB
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5.2.1 $  $Date: 2010/07/14 23:40:47 $

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
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 1), nnerr.throw('Not enough input arguments.'); end
        s = nntype.pos_int_scalar('format',args{1});
        out1 = simulink_params(s,param);
        
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

function name = function_name, name = 'Linear Saturating'; end
function range = output_range, range = [0 1]; end
function range = active_input_range, range = [0 1]; end
function flag = is_continuous, flag = true; end
function flag = is_smooth, flag = false; end
function flag = is_monotonic, flag = true; end
function flag = is_scalar, flag = true; end
function flag = is_basis, flag = false; end
function flag = is_competitive, flag = false; end
function param = parameters, param = []; end

function err = check_param(parameters)
  err = '';
end

function a = apply(n,parameters)
  a = max(0,min(1,n));
  a(isnan(n)) = nan;
end

function d = da_dn(n,a,parameters)
  d = double((n >= 0) & (n <= 1));
  d(isnan(n)) = nan;
end

function p = simulink_params(s,param)
  p = {};
end
