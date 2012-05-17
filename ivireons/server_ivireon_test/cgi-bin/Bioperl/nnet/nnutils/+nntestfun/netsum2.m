function out1=netsum2(varargin)
%NETSUM2 Sum net input function with parameters.
%
%	Syntax
%
%	N = netsum2({Z1,Z2,...,Zn},FP)
%   dN_dZj = netsum2('dz',j,Z,N,FP)
%	INFO = netsum2(CODE)
%
%	Description
%
%	  NETSUM2 is a net input function.  Net input functions calculate
%	  a layer's net input by combining its weighted inputs and bias.
%
%	  NETSUM2({Z1,Z2,...,Zn},FP) takes Z1-Zn and optional function parameters,
%	    Zi - SxQ matrices in a row cell array.
%	    FP - Row cell array of function parameters (ignored).
%	  Returns element-wise sum of Z1 to Zn.
%
%   NETSUM2('dz',j,{Z1,...,Zn},N,FP) returns the derivative of N with
%   respect to Zj.  If FP is not supplied the default values are used.
%   if N is not supplied, or is [], it is calculated for you.
%
%	NETSUM2('name') returns the name of this function.
%	NETSUM2('type') returns the type of this function.
%   NETSUM2('fpnames') returns the names of the function paramters.
%   NETSUM2('fpdefaults') returns default function paramter values.
%   NETSUM2('fpcheck',FP) throws an error for illegal function parameters.
%	NETSUM2('fullderiv') returns 0 or 1, if the derivate is SxQ or NxSxQ.
%
%	Examples
%
%	  Here NETSUM2 combines two sets of weighted input vectors and a bias.
%   We must use CONCUR to make B the same dimensions as Z1 and Z2. 
%
%	    z1 = [1 2 4; 3 4 1]
%	    z2 = [-1 2 2; -5 -6 1]
%	    b = [0; -1]
%	    n = netsum2({z1,z2,concur(b,3)})
%
%	  Here we assign this net input function to layer i of a network.
%
%     net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_netInputFcn">netInputFcn</a> = 'netsum2';
%
%	See also NETPROD, NETSUM

% Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.2.2.1 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Net Input Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    nntype.string('check',in1,'First argument');
    switch(in1)
      
      % User Functionality
      
      case 'apply'
        % this('apply',{z1,...,zn},...*param...)
        % Equivalent to this({z1,...,zn},...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 1, nnerr.throw('Not enough input arguments.'); end
        z = args{1};
        out1 = apply(z,param);
        
      case 'dn_dzj'
        % this('dn_dzj',j,{z1,...,zn},n,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        j = nntype.pos_int_scalar('format',args{1},'Input index');
        z = args{2};
        if nargs < 3
          n = apply(z,param);
        else
          n = nntype.matrix_data('format',args{3},'Net input');
        end
        out1 = dn_dzj(j,z,n,param);
        
      % Simulink
      
      case 'simulink_params'
        % this('simulink_params',...*param...)
        [~,param,~] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        out1 = simulink_params(param);
        
      % Testing
        
      case 'dn_dzj_num'
        % this('dn_dzj',j,{z1,...,zn},n,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 2, nnerr.throw('Not enough input arguments.'); end
        j = nntype.pos_int_scalar('format',args{1},'Input index');
        z = args{2};
        if nargs < 3
          n = apply(z,param);
        else
          n = nntype.matrix_data('format',args{3},'Net input');
        end
        out1 = dn_dzj_num(j,z,n,param);
      
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
        
      % NNET 6.0 Compatibility
      
      case 'fpcheck'
        out1 = feval(mfilename,'check_param',varargin{2:4});
      case 'dz',
        if (nargin < 5) || isempty(varargin{5}), varargin{5} = INFO.defaultParam; end
        out1 = dn_dzj(varargin{2:5});
        
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
  % this({z1,...,zn},...*param...)
  % Equivalent to this('apply',{z1,...,zn},...*param...)
  [args,param,nargs] = nnparam.extract_param(varargin,INFO.defaultParam);
  if nargs < 1, nnerr.throw('Not enough input arguments.'); end
  z = args{1};
  out1 = apply(z,param);
end

function d = dn_dzj_num(j,z,n,param)
  delta = 1e-6;
  n1 = apply(addzj(z,j,+2*delta),param);
  n2 = apply(addzj(z,j,+delta),param);
  n3 = apply(addzj(z,j,-delta),param);
  n4 = apply(addzj(z,j,-2*delta),param);
  d = (-n1 + 8*n2 - 8*n3 + n4) / (12*delta);
end

function z = addzj(z,j,v)
  z{j} = z{j} + v;
end

function sf = subfunctions
  sf.is_netsum = strcmp(mfilename,'netsum');
  sf.apply = @apply;
  sf.dn_dzj = @dn_dzj;
  sf.dn_dzj_num = @dn_dzj_num;
end

function info = get_info
  info = nnfcnNetInput(mfilename,function_name,7,subfunctions,...
    is_continuous,parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Test Sum 2'; end
function flag = is_continuous, flag = true; end

function param = parameters
  param = ...
    [...
    nnetParamInfo('alpha','Alpha Multiplier','nntype.real_scalar',2,...
    'Gain on net sum.'),...
    nnetParamInfo('beta','Beta Offset','nntype.real_scalar',1,...
    'Offset for net sum.'),...
    ];
end

function err = check_param(param)
  err = '';
end

function n = apply(z,param)
  if isempty(z)
    n = 0;
  else
    n = z{1};
    for i=2:length(z)
      n = n + z{i};
    end
    n = param.alpha * n + param.beta;
  end
end

function d = dn_dzj(j,z,n,param)
  d = ones(size(n))*param.alpha;
end

function p = simulink_params(param)
  p = 'NETSUM2 does not have a Simulink block version.';
end
