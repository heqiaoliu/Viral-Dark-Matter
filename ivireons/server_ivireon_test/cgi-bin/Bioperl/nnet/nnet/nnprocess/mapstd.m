function [out1,out2] = mapstd(varargin)
%MAPSTD Map matrix row means and deviations to standard values.
%  
% <a href="matlab:doc mapstd">mapstd</a> processes input and target data by mapping its mean and
% standard deviations to 0 and 1 respectively.
%
% [Y,settings] = <a href="matlab:doc mapstd">mapstd</a>(X) takes matrix or cell array neural data,
% returns it transformed with the settings used to perform the transform.
%
% Here data with non-standard mean/deviations in each row is transformed.
%
%   x1 = [log(rand(1,20)*5-1); rand(1,20)*20-10; rand(1,20)-1];
%   [y1,settings] = <a href="matlab:doc mapstd">mapstd</a>(x1)
%
% <a href="matlab:doc mapstd">mapstd</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = [log(rand(1,20)*5-1); rand(1,20)*20-10; rand(1,20)-1];
%   y2 = <a href="matlab:doc mapstd">mapstd</a>('apply',x2,settings)
%
% <a href="matlab:doc mapstd">mapstd</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc mapstd">mapstd</a>('reverse',y1,settings)
%
% <a href="matlab:doc mapstd">mapstd</a>('dy_dx',X,Y,settings) returns the transformation derivative
% of Y with respect to X.
%
% <a href="matlab:doc mapstd">mapstd</a>('dx_dy',X,Y,settings) returns the reverse transformation
% derivative of X with respect to Y.
%
% See also MAPMINMAX, PROCESSPCA, REMOVECONSTANTROWS.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.14 $

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

function name = function_name, name = 'Map Mean and Standard Deviation'; end
function flag = process_inputs, flag = true; end
function flag = process_outputs, flag = true; end
function flag = is_continuous, flag = true; end

function param = parameters
  param = [ ...
    nnetParamInfo('ymean','Y Mean','nntype.num_scalar',0,...
    'Mean for each row of Y.'), ...
    nnetParamInfo('ystd','Y Standard Deviation','nntype.pos_scalar',1,...
    'Standard deviation for each row of Y.'), ...
    ];
end

function err = check_param(param)
  err = '';
end

function [y,settings] = create(x,param)
  xrows = size(x,1);
  settings.name = 'mapstd';
  settings.xrows = xrows;
  settings.yrows = xrows;
  settings.xmean = zeros(settings.xrows,1);
  settings.xstd = zeros(settings.xrows,1);
  for i=1:settings.xrows
    xi = x(i,:);
    xi(isnan(xi)) = [];
    xi(~isfinite(xi)) = NaN;
    settings.xmean(i) = mean(xi);
    settings.xstd(i) = std(xi);
  end
  % Assert: xstd & xmean will be NaN for infinite or unknown ranges
  settings.ymean = param.ymean;
  settings.ystd = param.ystd;
  
  % Convert from settings values to safe processing values
  % and check whether safe values result in x<->y change.
  xmean = settings.xmean;
  xstd = settings.xstd;
  gain = settings.ystd ./ xstd;
  fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
  gain(fix) = 1;
  xmean(fix) = settings.ymean;
  settings.no_change = (settings.xrows == 0) || ...
    all(gain == 1) && all(xmean == settings.ymean);
  
  y = apply(x,settings);
end

% APPLY and REVERSE avoid numerical rounding problems if
% the means are subtracted and added separately, as apposed
% to using a simpler multiply and offset transformation.

function y = apply(x,settings)
  % Safe processing version of settings
  xmean = settings.xmean;
  xstd = settings.xstd;
  gain = settings.ystd ./ xstd;
  fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
  gain(fix) = 1;
  xmean(fix) = settings.ymean;
  
  Q = size(x,2);
  copyQ = ones(1,Q);
  y = (x - xmean(:,copyQ)) .* gain(:,copyQ) + settings.ymean;
end

function x = reverse(y,settings)
  % Safe processing version of settings
  xmean = settings.xmean;
  xstd = settings.xstd;
  gain = xstd ./ settings.ystd;
  fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
  gain(fix) = 1;
  xmean(fix) = settings.ymean;
  
  Q = size(y,2);
  copyQ = ones(1,Q);
  x = (y - settings.ymean) .* gain(:,copyQ) + xmean(:,copyQ);
end

% DY_DX and DX_DY must calculate GAIN in exactly the same
% way as APPLY and REVERSE for reliable numerical testing.

function d = dy_dx(x,y,settings)
  % Safe processing version of gain
  xmean = settings.xmean;
  xstd = settings.xstd;
  gain = settings.ystd ./ xstd;
  fix = ~isfinite(xmean) |~isfinite(xstd) | (xstd == 0);
  gain(fix) = 1;
  
  Q = size(x,2);
  d = cell(1,Q);
  d(:) = {diag(gain)};
end

function d = dx_dy(x,y,settings)
  % Safe processing version of gain
  xmean = settings.xmean;
  xstd = settings.xstd;
  gain = xstd ./ settings.ystd;
  fix = ~isfinite(xmean) |~isfinite(xstd) | (xstd == 0);
  gain(fix) = 1;
  
  Q = size(x,2);
  d = cell(1,Q);
  d(:) = {diag(gain)};
end

function p = simulink_params(settings)
  xmean = settings.xmean;
  xstd = settings.xstd;
  fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
  xmean(fix) = settings.ymean;
  xstd(fix) = settings.ystd;
  p = ...
    { ...
    'xmean',mat2str(xmean,30);
    'xstd',mat2str(xstd,30);
    'ymean',mat2str(settings.ymean,30);
    'ystd',mat2str(settings.ystd,30);
    };
end

function p = simulink_reverse_params(settings)
  xmean = settings.xmean;
  xstd = settings.xstd;
  fix = find(~isfinite(xmean) |~isfinite(xstd) | (xstd == 0));
  xmean(fix) = settings.ymean;
  xstd(fix) = settings.ystd;
  p = ...
    { ...
    'xmean',mat2str(xmean,30);
    'xstd',mat2str(xstd,30);
    'ymean',mat2str(settings.ymean,30);
    'ystd',mat2str(settings.ystd,30);
    };
end

