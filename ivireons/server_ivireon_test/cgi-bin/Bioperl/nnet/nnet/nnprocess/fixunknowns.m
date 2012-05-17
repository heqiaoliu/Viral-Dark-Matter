function [out1,out2] = fixunknowns(varargin)
%FIXUNKNOWNS Processes matrix rows with unknown values.
%
% <a href="matlab:doc fixunknowns">fixunknowns</a> should only be used to process inputs, not outputs or
% targets.
%	
%	<a href="matlab:doc fixunknowns">fixunknowns</a> processes data by replacing each row containing
% unknown values (represented by NaN) with two rows. The first row contains
% the original row, with NaN values replaced by the row's mean.  The second
% row contains 1 and 0 values, indicating which values in the first row
% were known or unknown, respectively. Using FIXUNKNOWNS as an input
% processing function allows a network to use data with unknowns, and
% even perhaps use the existence of unknowns as useful information.
%
% [Y,settings] = <a href="matlab:doc fixunknowns">fixunknowns</a>(X) takes matrix or cell array neural network
% input data, transforms it, and returns the result and the settings used
% to perform the transform.
%
% Here some data with unknowns is processed into more usable form:
%
%   x1 = [1 2 3 4; 4 NaN 6 5; NaN 2 3 NaN]
%   [y1,settings] = <a href="matlab:doc fixunknowns">fixunknowns</a>(x1)
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('apply',X,settings) transforms X consistent with settings
% returned by a previous transformation.
%
%   x2 = [4 5 3 2; NaN 9 NaN 2; 4 9 5 2]
%   y2 = <a href="matlab:doc fixunknowns">fixunknowns</a>('apply',x2,settings)
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('reverse',Y,settings) reverse transforms Y consistent with
% settings returned by a previous transformation.
%
%   x1_again = <a href="matlab:doc fixunknowns">fixunknowns</a>('reverse',y1,settings)
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('dy_dx',X,Y,settings) returns the transformation derivative
% of Y with respect to X.
%
% <a href="matlab:doc fixunknowns">fixunknowns</a>('dx_dy',X,Y,settings) returns the reverse transformation
% derivative of X with respect to Y.
%   Here is how to format a matrix with a mixture of known and
%   unknown values in its second row.
%
%  See also MAPMINMAX, MAPSTD, PROCESSPCA, REMOVECONSTANTROWS.

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

function name = function_name, name = 'Fix Unknowns'; end
function flag = process_inputs, flag = true; end
function flag = process_outputs, flag = false; end
function flag = is_continuous, flag = true; end
function param = parameters, param = []; end

function err = check_param(param)
  err = '';
end

function [y,settings] = create(x,param)
  settings.name = 'fixunknowns';
  unknown_rows = ~isfinite(sum(x,2))';
  settings.xrows = size(x,1);
  settings.yrows = settings.xrows + sum(unknown_rows);
  settings.unknown = find(unknown_rows);
  settings.known = find(~unknown_rows);
  settings.shift = [0 cumsum(unknown_rows(1:(end-1)))];
  settings.xmeans = zeros(settings.xrows,1);
  for i=1:settings.xrows
    finite_unknowns = isfinite(x(i,:));
    if any(finite_unknowns)
      settings.xmeans(i) = mean(x(i,finite_unknowns));
    else
      settings.xmeans(i) = 0;
    end
  end
  settings.no_change = isempty(settings.unknown);
  y = apply(x,settings);
end

function y = apply(x,settings)
  q = size(x,2);
  y = zeros(settings.yrows,q);
  y(settings.known+settings.shift(settings.known),:) = x(settings.known,:);
  unknown_rows = x(settings.unknown,:);
  is_known = isfinite(unknown_rows);
  is_not_known = ~is_known;
  unknown_means = settings.xmeans(settings.unknown,ones(1,q));
  unknown_rows(is_not_known) = unknown_means(is_not_known);
  y(settings.unknown + settings.shift(settings.unknown),:) = unknown_rows;
  y(settings.unknown + settings.shift(settings.unknown)+1,:) = is_known;
end

function x = reverse(y,settings)
  q = size(y,2);
  x = zeros(settings.xrows,q);
  x(settings.known,:) = y(settings.known + settings.shift(settings.known),:);
  unknown_rows = y(settings.unknown + settings.shift(settings.unknown),:);
  is_unknown = y(settings.unknown + settings.shift(settings.unknown)+1,:) == 0;
  unknown_rows(is_unknown) = NaN;
  x(settings.unknown,:) = unknown_rows;
end

function d = dy_dx(x,y,settings)
  % Derivatives for Known rows - same for all Q
  dknown = zeros(settings.yrows,settings.xrows);
  for k=1:length(settings.known)
    j = settings.known(k);
    i = j+settings.shift(settings.known(k));
    dknown(i,j) = 1;
  end
  % Derivatives for Unknown rows - different for each q in Q
  Q = size(x,2);
  d = cell(1,Q);
  for q=1:Q
    dq = dknown;
    for k=1:length(settings.unknown)
    j = settings.unknown(k);
    i = j+settings.shift(settings.unknown(k));
      dq(i,j) = y(i+1,q);
    end
    d{q} = dq;
  end
end

function d = dx_dy(x,y,settings)
  d = dy_dx(x,y,settings);
  for q=1:length(d), d{q} = d{q}'; end
end

function p = simulink_params(settings)
  indices = zeros(1,settings.yrows);
  indices(settings.known + settings.shift(settings.known)) = settings.known;
  indices(settings.unknown + settings.shift(settings.unknown)) = settings.unknown;
  p = ...
    { ...
    'inputSize',mat2str(settings.xrows);
    'indices',mat2str(indices);
    };
end

function p = simulink_reverse_params(settings)
  p = ...
    { ...
    'inputSize',mat2str(settings.xrows);
    'indices',mat2str(settings.known);
    };
end

