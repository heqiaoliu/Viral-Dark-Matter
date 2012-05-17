function [out1,out2] = lvqoutputs(varargin)
%LVQOUTPUTS Define settings for LVQ outputs, without changing values.
%
% <a href="matlab:doc lvqoutputs">lvqoutputs</a> is only intended to be used as an output processing function
% by LVQ networks.
%
% [Y,settings] = <a href="matlab:doc lvqoutputs">lvqoutputs</a>(X) takes matrix or cell array neural network
% data and returns it unchanged, but stores class ratio information
% in the settings, useful for initializing weights to LVQ network output
% layers.
%
% Here some 1-of-N data X1 is defined, representing 1000 samples of
% categorizations into one of four classes.  <a href="matlab:doc lvqoutputs">lvqoutputs</a> will record
% the prevalence of each of the four classes in this data.
%
%   x1 = compet(rand(4,1000));
%   [y1,settings] = <a href="matlab:doc lvqoutputs">lvqoutputs</a>(x1)
%
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('apply',X,settings) returns X unchanged.
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('reverse',Y,settings) returns Y unchanged.
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('dy_dx',X,Y,settings) returns ones.
% <a href="matlab:doc lvqoutputs">lvqoutputs</a>('dx_dy',X,Y,settings) returns ones.
%
%  See also LVQNET.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Processing Functions.
  
  persistent INFO;
  if isempty(INFO), INFO = get_info; end,
  if (nargin < 1), nnerr.throw('Not enough arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    switch (in1)
      
      case 'create'
        % this('create',x,param)
        [args,param] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        [x,ii,jj,wasCell] = nncell2mat(args{1});
        [out1,out2] = create(x,param);
        if (wasCell), out1 = mat2cell(out1,ii,jj); end
        
      case 'apply'
        % this('apply',x,settings)
        out2 = varargin{3};
        if out2.no_change
          out1 = varargin{2};
        else
          [in2,ii,jj,wasCell] = nncell2mat(varargin{2});
          out1 = apply(in2,out2);
          if (wasCell), out1 = mat2cell(out1,ii,jj); end
        end
        
      case 'reverse'
        % this('reverse',y,settings)
        out2 = varargin{3};
        if out2.no_change
          out1 = varargin{2};
        else
          [in2,ii,jj,wasCell] = nncell2mat(varargin{2});
          out1 = reverse(in2,out2);
          if (wasCell), out1 = mat2cell(out1,ii,jj); end
        end
        
      case 'dy_dx'
        % this('dy_dx',x,y,settings)
        out1 = dy_dx(varargin{2:4});
        
      case 'dy_dx_num'
        % this('dy_dx_num',x,y,settings)
        out1 = dy_dx_num(varargin{2:4});
        
      case 'dx_dy'
        % this('dx_dy',x,y,settings)
        out1 = dx_dy(varargin{2:4});
        
      case 'dx_dy_num'
        % this('dx_dy_num',x,y,settings)
        out1 = dx_dy_num(varargin{2:4});
        
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'check_param'
        % this('check_param',param)
        out1 = check_param(varargin{2});
        
      case 'simulink_params'
        % this('simulink_params',settings)
        out1 = simulink_params(varargin{2});
        
      case 'simulink_reverse_params'
        % this('simulink_reverse_params',settings)
        out1 = simulink_reverse_params(varargin{2});
        
      % NNET 6.0 Compatibility
      case 'dx', out1 = dy_dx(varargin{2:4});
      case 'pcheck', out1 = check_param(varargin{2});
        
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me %#ok<NASGU>
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  end
  [args,param] = nnparam.extract_param(varargin,INFO.defaultParam);
  [x,ii,jj,wasCell] = nncell2mat(args{1});
  [out1,out2] = create(x,param);
  if (wasCell), out1 = mat2cell(out1,ii,jj); end
end

function d = dy_dx_num(x,y,settings)
  delta = 1e-7;
  [N,Q] = size(x);
  M = size(y,1);
  d = cell(1,Q);
  for q=1:Q
    dq = zeros(M,N);
    xq = x(:,q);
    for i=1:N
      y1 = apply(addx(xq,i,-2*delta),settings);
      y2 = apply(addx(xq,i,-delta),settings);
      y3 = apply(addx(xq,i,+delta),settings);
      y4 = apply(addx(xq,i,+2*delta),settings);
      dq(:,i) = (y1 - 8*y2 + 8*y3 - y4) / (12*delta);
    end
    d{q} = dq;
  end
end

function d = dx_dy_num(x,y,settings)
  delta = 1e-7;
  [N,Q] = size(x);
  M = size(y,1);
  d = cell(1,Q);
  M = size(y,1);
  for q=1:Q
    dq = zeros(N,M);
    yq = y(:,q);
    for i=1:M
      x1 = reverse(addx(yq,i,-2*delta),settings);
      x2 = reverse(addx(yq,i,-delta),settings);
      x3 = reverse(addx(yq,i,+delta),settings);
      x4 = reverse(addx(yq,i,+2*delta),settings);
      dq(:,i) = (x1 - 8*x2 + 8*x3 - x4) / (12*delta);
    end
    dq(~isfinite(dq)) = 0;
    d{q} = dq;
  end
end

function x = addx(x,i,v)
  x(i) = x(i) + v;
end

function sf = subfunctions
  sf.create = @create;
  sf.apply = @apply;
  sf.reverse = @reverse;
  sf.dy_dx = @dy_dx;
  sf.dx_dy = @dx_dy;
  sf.dy_dx_num = @dy_dx_num;
  sf.dx_dy_num = @dx_dy_num;
end

function info = get_info
  info = nnfcnProcessing(mfilename,function_name,7,subfunctions,...
    process_inputs,process_outputs,is_continuous,parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'LVQ Outputs'; end
function flag = process_inputs, flag = false; end
function flag = process_outputs, flag = true; end
function flag = is_continuous, flag = true; end
function param = parameters, param = []; end

function err = check_param(param)
err = '';
end

function [y,settings] = create(x,param)
  settings.name = 'lvqoutputs'; % TODO - put this in boiler
  settings.no_change = true;
  settings.xrows = size(x,1);
  settings.yrows = size(x,1);
  settings.classRatios = sum(compet(x),2);
  y = x;
end

function y = apply(x,settings)
  y = x;
end

function x = reverse(y,settings)
  x = y;
end

function d = dy_dx(x,y,settings)
  Q = size(x,2);
  d = cell(1,Q);
  d(:) = {eye(settings.xrows)};
end

function d = dx_dy(x,y,settings);
  d = dy_dx(x,y,settings);
  for q=1:length(d), d{q} = d{q}'; end
end

function p = simulink_params(ps)
  p = {};
end

function p = simulink_reverse_params(ps)
  p = {};
end

