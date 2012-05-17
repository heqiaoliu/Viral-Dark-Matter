function out1=netsum(varargin)
%NETSUM Sum net input function.
%
% Net input functions combine a layer's weighted inputs and biases to form
% the layer's net input.
%
% <a href="matlab:doc netsum">netsum</a>({Z1,Z2,...,Zn}) takes a variable number of SxQ weighted inputs,
% and combines them, by summing them, to form the SxQ net input.
%
% Here two 4x5 weighted inputs are defined and combined:
%
%   z1 = <a href="matlab:doc rands">rands</a>(4,5);
%   z2 = <a href="matlab:doc rands">rands</a>(4,5);
%   n = <a href="matlab:doc netsum">netsum</a>({z1,z2})
%
% <a href="matlab:doc netsum">netsum</a>('dn_dzj',j,{Z1,...Zn}) returns the derivative of net input
% with respect to the jth weighted input Zj.
%
%   dz1 = <a href="matlab:doc netsum">netsum</a>('dn_dzj',1,{z1,z2},n)
%
% To set a network's ith layer to calculate net input with this function:
%
%   net.<a href="matlab:doc nnproperty.net_layers">layers</a>{i}.<a href="matlab:doc nnproperty.layer_netInputFcn">netInputFcn</a> = '<a href="matlab:doc netsum">netsum</a>'
%
%	See also NETPROD.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.5.2.1 $

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
  
  % NNET 4.0 Compatibility
  if (nargin > 1) && isnumeric(varargin{end})
    out1 = apply(varargin,INFO.defaultParam);
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

function name = function_name, name = 'Sum'; end
function flag = is_continuous, flag = true; end
function param = parameters, param = []; end

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
  end
end

function d = dn_dzj(j,z,n,param)
  d = ones(size(n));
end

function p = simulink_params(param)
  p = {};
end
