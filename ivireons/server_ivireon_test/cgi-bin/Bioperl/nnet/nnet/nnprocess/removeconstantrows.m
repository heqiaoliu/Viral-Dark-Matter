function [out1,out2] = removeconstantrows(varargin)
%REMOVECONSTANTROWS Remove matrix rows with constant values.
%	
% <a href="matlab:doc removeconstantrows">removeconstantrows</a> processes input and target data by removing rows
% with constant values. Constant values do not provide a network with any
% information and can cause numerical problems for some algorithms.
%
% [Y,settings] = <a href="matlab:doc removeconstantrows">removeconstantrows</a>(X) takes matrix or cell array data,
% returns it transformed with the settings used to perform the transform.
%
% Here is data with whose second row is constant.
%
%   x1 = [rand(1,20)*5-1; ones(1,20)+6; rand(1,20)-1];
%   [y1,settings] = <a href="matlab:doc removeconstantrows">removeconstantrows</a>(x1)
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('apply',X,settings) transforms X consistent with
% settings returned by a previous transformation.
%
%   x2 = [rand(1,20)*5-1; ones(1,20)+6; rand(1,20)-1];
%   y2 = <a href="matlab:doc removeconstantrows">removeconstantrows</a>('apply',x2,settings)
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('reverse',Y,settings) reverse transforms Y consistent
% with settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc removeconstantrows">removeconstantrows</a>('reverse',y1,settings)
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('dy_dx',X,Y,settings) returns the transformation
% derivative of Y with respect to X.
%
% <a href="matlab:doc removeconstantrows">removeconstantrows</a>('dx_dy',X,Y,settings) returns the reverse
% transformation derivative of X with respect to Y.
%
% See also REMOVEROWS, FIXUNKNOWNS.

% Copyright 1992-2010 The MathWorks, Inc.

% Mark Hudson Beale, 4-16-2002, Created

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

function name = function_name, name = 'Remove Constants'; end
function flag = process_inputs, flag = true; end
function flag = process_outputs, flag = true; end
function flag = is_continuous, flag = true; end

function param = parameters
  param = nnetParamInfo('max_range','Maximum Range','nntype.pos_scalar',0,...
    'Maximum range of values for a row to be removed.');
end

function err = check_param(param)
  mr = param.max_range;
  if ~isa(mr,'double') || any(size(mr)~=[1 1]) || (mr < 0) || ~isreal(mr) || ~isfinite(mr)
    err = 'max_range must be 0 or greater.';
  else
    err = '';
  end
end

function [y,settings] = create(x,param)
  % Replace NaN with finite values in same row
  rows = size(x,1);
  for i=1:rows
    finiteInd = find(full(~isnan(x(i,:))),1);
    if isempty(finiteInd)
      xfinite = 0;
    else
      xfinite = x(finiteInd);
    end
    nanInd = isnan(x(i,:));
    x(i,nanInd) = xfinite;
  end
  settings.name = 'removeconstantrows';
  settings.max_range = param.max_range;
  settings.keep = 1:size(x,1);
  maxx = max(x,[],2);
  minx = min(x,[],2);
  midx = (maxx + minx) / 2;
  settings.remove = find((maxx-minx) <= settings.max_range)';
  settings.keep(settings.remove) = [];
  settings.value = midx(settings.remove);
  settings.xrows = size(x,1);
  settings.yrows = settings.xrows - length(settings.remove);
  settings.constants = mean(x(settings.remove,:),2);
  settings.no_change = isempty(settings.remove);
  y = apply(x,settings);
end

function y = apply(x,settings)
  if isempty(settings.remove)
    y = x;
  else
    y = x(settings.keep,:);
  end
end

function x = reverse(y,settings)
  if isempty(settings.remove)
    x = y;
  else
    q = size(y,2);
    x = zeros(settings.xrows,q);
    x(settings.remove,:) = settings.value(:,ones(1,q));
    x(settings.keep,:) = y;
  end
end

function d = dy_dx(x,y,settings)
  Q = size(x,2);
  dq = zeros(settings.yrows,settings.xrows);
  for i=1:length(settings.keep)
    dq(i,settings.keep(i)) = 1;
  end
  d = cell(1,Q);
  d(:) = {dq};
end

function d = dx_dy(x,y,settings)
  d = dy_dx(x,y,settings);
  for i=1:length(d), d{i} = d{i}'; end
end

function p = simulink_params(settings)
  p = ...
    { ...
    'inputSize',mat2str(settings.xrows);
    'keep',mat2str(settings.keep);
    };
end

function p = simulink_reverse_params(settings)
  recreate = zeros(1,settings.xrows);
  recreate(settings.keep) = 1:length(settings.keep);
  recreate(settings.remove) = ...
    (1:length(settings.remove)) + length(settings.keep);
  p = ...
    { ...
    'inputSize',mat2str(settings.xrows);
    'constants',mat2str(settings.constants);
    'rearrange',mat2str(recreate);
    };
end
