function [out1,out2] = processpca(varargin)
%PROCESSPCA Processes rows of matrix with principal component analysis.
%  
% <a href="matlab:doc processpca">processpca</a> process data so that the rows become uncorrelated and are
% ordered in terms of their contribution to total variation. In addition,
% rows whose contribution is too weak may be removed.
%
% [Y,settings] = <a href="matlab:doc processpca">processpca</a>(X) takes neural data and returns it transformed
% with the settings used to make the transform.
%
% [Y,settings] = <a href="matlab:doc processpca">processpca</a>(X,'maxfrac',maxfrac) takes an optional
% parameter overriding the default fraction of variance contribution (0)
% used to determine which rows to remove.
%
% Here is data in which only two rows actually contribute information.
%
%   x1 = rand(2,20);
%   x1 = [x1; (x1(1,:)+x1(2,:))*0.5];
%   [y1,settings] = <a href="matlab:doc processpca">processpca</a>(x1,'maxfrac',0.01)
%
% <a href="matlab:doc processpca">processpca</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = rand(2,20);
%   x2 = [x2; (x2(1,:)+x2(2,:))*0.5];
%   y2 = <a href="matlab:doc processpca">processpca</a>('apply',x2,settings)
%
% <a href="matlab:doc processpca">processpca</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc processpca">processpca</a>('reverse',y1,settings)
%
% <a href="matlab:doc processpca">processpca</a>('dy_dx',X,Y,settings) returns the transformation derivative
% of Y with respect to X.
%
% <a href="matlab:doc processpca">processpca</a>('dx_dy',X,Y,settings) returns the reverse transformation
% derivative of X with respect to Y.%
%
% See also MAPMINMAX, MAPSTD, REMOVECONSTANTROWS

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.13 $

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

function name = function_name, name = 'Principle Components'; end
function flag = process_inputs, flag = true; end
function flag = process_outputs, flag = false; end
function flag = is_continuous, flag = true; end

function param = parameters
  param = nnetParamInfo('maxfrac','Maximum Fraction','nntype.pos_scalar',1e-10,...
    'Minimum fraction of total variable for a row to be kept.');
end

function err = check_param(param)
  mf = param.maxfrac;
  if ~isa(mf,'double') || any(size(mf)~=[1 1]) || ~isreal(mf) || ~isfinite(mf) || (mf<0) || (mf>=1)
    err = 'maxfrac must be a real scalar value between 0 and 1.';
  else
    err = '';
  end
end

function [y,settings] = create(x,param)
  % Remove samples with NaN
  [~,j] = find(isnan(x));
  j = unique(j);
  x(:,j) = [];
  [R,Q]=size(x);
  settings.name = 'processpca';
  settings.xrows = R;
  settings.maxfrac = param.maxfrac;
  if (R == 0) || (R == 1) || (Q == 0) || (R > Q) || any(any(isinf(x)))
    y = x;
    settings.yrows = R;
    settings.transform = eye(R);
    settings.no_change = true;
    return;
  end
  % Use the singular value decomposition to compute the principal components
  [transform,s] = svd(x,0);
  % Compute the variance of each principal component
  var = diag(s).^2/(Q-1);
  % Compute total variance and fractional variance
  total_variance = sum(var,1);
  frac_var = var./total_variance;
  % Find the components which contribute more than min_frac of the total variance
  yrows = sum(frac_var >= param.maxfrac);
  % Reduce the transformation matrix appropriately
  settings.yrows = yrows;
  settings.transform = transform(:,1:yrows)';
  settings.no_change = false; % TODO
  y = apply(x,settings);
end

function y = apply(x,settings)
  y = settings.transform * x;
end

function x = reverse(y,settings)
  x = pinv(settings.transform) * y;
end

function d = dy_dx(x,y,settings)
  Q = size(x,2);
  d = cell(1,Q);
  d(:) = {settings.transform};
end

function d = dx_dy(x,y,settings)
  Q = size(x,2);
  inverse = pinv(settings.transform);
  d = cell(1,Q);
  d(:) = {inverse};
end

function p = simulink_params(settings)
  p = {'transform',mat2str(settings.transform)};
end

function p = simulink_reverse_params(settings)
  inverse_transform = pinv(settings.transform);
  p = {'inverse_transform',mat2str(inverse_transform);};
end
