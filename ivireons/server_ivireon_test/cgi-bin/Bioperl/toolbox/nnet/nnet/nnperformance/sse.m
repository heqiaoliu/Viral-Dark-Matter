function [out1,out2] = sse(varargin)
%SSE Sum squared error performance function.
%
% <a href="matlab:doc sse">sse</a>(net,targets,outputs,errorWeights,...parameters...) calculates a
% network performance given targets, outputs, error weights and parameters
% as the sum of squared errors.
%
% Only the first three arguments are required.  The default error weight
% is {1}, which weights the importance of all targets equally.
%
% Parameters are supplied as parameter name and value pairs:
%
% 'regularization' - a fraction between 0 (the default) and 1 indicating
%    the proportion of performance attributed to weight/bias values. The
%    larger this value the network will be penalized for large weights,
%    and the more likely the network function will avoid overfitting.
%
% 'normalization' - this can be 'none' (the default), or 'standard', which
%   results in outputs and targets being normalized to [-1, +1], and
%   therefore errors in the range [-2, +2), or 'percent' which normalizes
%   outputs and targets to [-0.5, 0.5] and errors to [-1, 1].
%
% Here a network's performance with 0.1 regularization is calculated.
%
%   perf = <a href="matlab:doc sse">sse</a>(net,targets,outputs,{1},'regularization',0.1)
%
% SSE('dperf_dy',net,targets,outputs,errorWeights,perf,...parameters...)
% returns the derivative of performance with respect to outputs Y.
%
%   dy = <a href="matlab:doc sse">sse</a>('dperf_dy',net,targets,outputs,{1},'regularization',0.1)
%
% SSE(net,targets,outputs,errorWeights,perf,...parameters...) returns the
% derivative of performance with respect to the network weights and biases.
%
%   dwb = <a href="matlab:doc sse">sse</a>('dperf_dwb',net,targets,outputs,{1},'regularization',0.1)
%
% To setup a network to us the same performance measure during training:
%
%   net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = '<a href="matlab:doc sse">sse</a>';
%   net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.regularization">regularization</a> = 0.1;
%   net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.normalization">normalization</a> = 'none';
%   net.<a href="matlab:doc nnproperty.net_performParam">performParam</a>.<a href="matlab:doc nnparam.squaredWeighting">squaredWeighting</a> = true;
%
% See also MSE, MAE, SAE.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.11.2.1 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Performance Functions.

  persistent INFO;
  if isempty(INFO),INFO = get_info; end
  if nargin < 1,nnerr.throw('Not enough input arguments.'); end
  in1 = varargin{1};
  if ischar(in1)
    switch lower(in1)
      
      % User Functionality
      
      case 'apply'
        % this('apply',net,t,y,*ew,...*param...)
        % Same as calling: this(net,t,y,*ew,...*param...)
        % Calculate performance
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 3, nnerr.throw('Not enough input arguments.'); end
        [net,err] = nntype.network_or_struct('format',args{1},'NET');
        if ~isempty(err), nnerr.throw(err); end
        [t,err] = nntype.data('format',args{2},'targets T');
        if ~isempty(err), nnerr.throw(err); end
        [y,err] = nntype.data('format',args{3},'Output data Y');
        if ~isempty(err), nnerr.throw(err); end
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if nargs < 4
          ew = {1};
        else
          [ew,err] = nntype.nndata_pos('format',varargin{4},'Error weights EW');
          if ~isempty(err), nnerr.throw(err); end
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        out1 = apply(net,t,y,ew,param);
      
      case 'dperf_dy',
        % this('dperf_dy',net,t,y,*ew,*perf,...*param...)
        % Derivative of performance with respect to network outputs
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        if (nargs < 5)
          perf = apply(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_dy(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'dperf_dwb',
        % this('dperf_dwb',net,...*param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        nnassert.minargs(nargs,1);
        net = nntype.network('format',args{1},'NET');
        out1 = dperf_dwb(net,param);
        
      % Implementation
      
      case 'e'
        % this('e',net,t,y,*ew,...*param...)
        % Errors taking into account error weights and normalization
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3},args{4});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        out1 = adjusted_errors(net,t,y,ew,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'perf_y'
        % this('perf_y',net,t,y,*ew,...*param...)
        % Performance due to network outputs
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{1},args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        [out1,out2] = performance_y(net,t,y,ew,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'perf_wb'
        % this('perf_y',net,...param...)
        % Performance due to weights and biases
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 1), nerr('Not enough input arguments.'); end
        net = nntype.network('format',args{1},'NET');
        [out1,out2] = performance_wb(net,param);
        
      case 'dperf_de',
        % this('dperf_de',net,t,y,*ew,*perf,...*param...)
        % Derivative of performance with respect to errors
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        if (nargs < 5)
          perf = performance(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_de(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
      
      % Testing
      
      case 'dperf_dy_num',
        % this('dperf_dy',net,t,y,*ew,*perf,...*param...)
        % Derivative of perfor
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          ew = nntype.nndata_pos('format',args{4},'Error weights EW');
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        if (nargs < 5)
          perf = performance(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_dy_num(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
      
      case 'dperf_de_num',
        % this('dperf_de',net,t,y,ew,perf,...param...)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if (nargs < 3), nerr('Not enough input arguments.'); end
        wasMatrix = nnmisc.ismat(args{2},args{3});
        net = nntype.network('format',args{1},'NET');
        t = nntype.data('format',args{2},'targets T');
        y = nntype.data('format',args{3},'Output data Y');
        [Nt,Qt,TSt] = nnsize(t);
        [Ny,Qy,TSy] = nnsize(y);
        if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
          nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
        end
        if (nargs < 4)
          ew = {1};
        else
          [ew,err] = nntype.nndata_pos('format',args{4},'Error weights EW');
          if ~isempty(err),nnerr.throw(err); end
          [Ne,Qe,TSe] = nnsize(ew);
          if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
          if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
            nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
          end
        end
        if (nargs < 5)
          perf = performance(net,t,y,ew,param);
        else
          perf = nntype.pos_scalar('format',args{5},'Performance PERF');
        end
        out1 = dperf_de_num(net,t,y,ew,perf,param);
        if (wasMatrix), out1 = out1{1}; end
        
      case 'combine'
        % this('combine',net,x1,n1,x2,n2,param)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 5
          nnerr.throw('Not enough input arguments.');
        end
        [net,err] = nntype.network('format',args{1});
        if ~isempty(err), nnerr.throw(nnerr.value(err,'NET')); end
        [x1,n1,x2,n2] = deal(args(2:end));
        out1 = combine_perf_y_or_grad(net,x1,n1,x2,n2,param);
        
      case 'weight'
        % this('weight',net,x1,n1,nTotal,param)
        [args,param,nargs] = nnparam.extract_param(varargin(2:end),INFO.defaultParam);
        if nargs < 4
          nnerr.throw('Not enough input arguments.');
        end
        [net,err] = nntype.network('format',args{1});
        if ~isempty(err), nnerr.throw(nnerr.value(err,'NET')); end
        [x1,n1,nTotal] = deal(args(2:end));
        out1 = weight_perf_y_or_grad(net,x1,n1,nTotal,param);
        
      case 'info'
        % this('info')
        out1 = INFO;
        
      case 'check_param'
        % this('check_param',param)
        out1 = check_param(varargin{2});
        
      % NNET 6.0 Compatibility
      
      case 'dy'
        % this('dy',e,y,x,perf,pp)
        if nargin < 6, param = INFO.defaultParam; else param = varargin{6}; end
        if isempty(param), param = INFO.defaultParam; end
        e = varargin{2};
        y = varargin{3};
        perf = varargin{5};
        wasMatrix = ~iscell(e);
        if wasMatrix, e = {e}; y = {y}; end
        t = gadd(e,y);
        out1 = gnegate(dperf_dy([],t,y,{1},perf,param));
        if (wasMatrix), out1 = out1{1}; end
        
      case 'dx'
        % this('dx',e,y,x,perf,param)
        if nargin < 6, param = INFO.defaultParam; else param = varargin{6}; end
        if isempty(param), param = INFO.defaultParam; end
        x = varargin{4};
        out1 = dperf_dwb(x,param);
        
      % Implementation
      
      % Info field access
      otherwise,
        % Quick info field access
        try
          out1 = eval(['INFO.' in1]);
        catch %#ok<CTCH>
          nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  end
 
  % NNET 4.0 and 6.0 Compatibility
      
  in1 = varargin{1};
  if ~(isa(in1,'network') || isstruct(in1))
    e = in1;
    if ~iscell(e), e = {e}; end
    if isstruct(varargin{end}) || isa(varargin{end},'nnetParam')
      param = varargin{end};
      varargin(end) = [];
    else
      param = INFO.defaultParam;
    end
    if length(varargin) < 3, wb = 0; else wb = varargin{3}; end
    if length(varargin) == 1
      t = e;
      y = {0};
    elseif ~iscell(varargin{2}) && (size(varargin{2},2)==1)
      t = e;
      y = {0};
      wb = varargin{2};
    else
      y = varargin{2};
      t = gadd(e,y);
    end
    out1 = apply(wb,t,y,{1},param);
    return
  end
  
  % User Functionality
  
  % this(net,t,y,ew,...*param...)
  % Same as calling: this('apply',net,t,y,ew,...*param...)
  % Calculate performance
  [args,param,nargs] = nnparam.extract_param(varargin,INFO.defaultParam);
  if nargs < 3, nnerr.throw('Not enough input arguments.'); end
  [net,err] = nntype.network_or_struct('format',args{1},'NET');
  if ~isempty(err), nnerr.throw(err); end
  [t,err] = nntype.data('format',args{2},'targets T');
  if ~isempty(err), nnerr.throw(err); end
  [y,err] = nntype.data('format',args{3},'Output data Y');
  if ~isempty(err), nnerr.throw(err); end
  [Nt,Qt,TSt] = nnsize(t);
  [Ny,Qy,TSy] = nnsize(y);
  if (numel(Nt) ~= numel(Ny)) || any([Nt;Qt;TSt] ~= [Ny;Qy;TSy])
    nnerr.throw('Dimensions of targets T and network outputs Y do not match.');
  end
  if nargs < 4
    ew = {1};
  else
    [ew,err] = nntype.nndata_pos('format',args{4},'Error weights EW');
    if ~isempty(err), nnerr.throw(err); end
    [Ne,Qe,TSe] = nnsize(ew);
    if ((numel(Ne)==numel(Ny)) && any((Ne ~= Ny) && (Ne ~= 1))) || (numel(Ne) ~= 1)
      nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
    end
    if ((Qe ~= Qy) && (Qe ~= 1)) || ((TSe ~= TSy) && (TSe ~= 1))
      nnerr.throw('Dimensions of error weights EW and network outputs Y do not match.');
    end
  end
  out1 = apply(net,t,y,ew,param);
end

function perf = apply(net,t,y,ew,param)
  perfy = performance_y(net,t,y,ew,param);
  perfwb = performance_wb(net,param);
  perf = perfy + perfwb;
end

function d = dperf_dy_num(net,t,y,ew,perf,param)
  delta = 1e-7;
  [N,Q,TS,M] = nnsize(y);
  ew = gmultiply(ew,nndata(N,Q,TS,1));
  d = nndata(N,Q,TS,0);
  nTotal = numfinite(gsubtract(t,y));
  for ts=1:TS
    for q=1:Q
      for i=1:M
        for j=1:N(i)
          tt = t{i,ts}(j,q);
          yy = y{i,ts}(j,q);
          n1 = numfinite(gsubtract(tt,yy));
          eww = ew{i,ts}(j,q);
          perf1 = performance_y(net,tt,yy+2*delta,eww,param);
          perf2 = performance_y(net,tt,yy+delta,eww,param);
          perf3 = performance_y(net,tt,yy-delta,eww,param);
          perf4 = performance_y(net,tt,yy-2*delta,eww,param);
          dd = (-perf1 + 8*perf2 - 8*perf3 + perf4) ./ (12*delta);
          d{i,ts}(j,q) = weight_perf_y_or_grad(dd,n1,nTotal,param);
        end
      end
    end
  end
end

function d = dperf_de(net,t,y,ew,perf,param)
  d = gnegate(dperf_dy(net,t,y,ew,perf,param));
end

function d = dperf_de_num(net,t,y,ew,perf,param)
  d = gnegate(dperf_de_num(net,t,y,ew,perf,param));
end

function d = dperf_dwb_num(wb,param)
  delta = 1e-7;
  if ~isnumeric(wb), wb = getwb(wb); end
  numVar = length(wb);
  d = zeros(numVar,1);
  for i=1:numVar
    perf1 = performance_wb(addwb(wb,i,2*delta),param);
    perf2 = performance_wb(addwb(wb,i,+delta),param);
    perf3 = performance_wb(addwb(wb,i,-delta),param);
    perf4 = performance_wb(addwb(wb,i,-2*delta),param);
    d(i) = (-perf1 + 8*perf2 - 8*perf3 + perf4) / (12*delta);
  end
end

function wb = addwb(wb,i,v)
  wb(i) = wb(i) + v;
end

function sf = subfunctions
  sf.apply = @apply;
  sf.adjust_error = @adjust_error;
  sf.adjusted_errors = @adjusted_errors;
  sf.performance_y = @performance_y;
  sf.performance_wb = @performance_wb;
  sf.combine_perf_y_or_grad = @combine_perf_y_or_grad;
  sf.weight_perf_y_or_grad = @weight_perf_y_or_grad;
  sf.dperf_dy = @dperf_dy;
  sf.dperf_de = @dperf_de;
  sf.dperf_dwb = @dperf_dwb;
  sf.dperf_dy_num = @dperf_dy_num;
  sf.dperf_de_num = @dperf_de_num;
  sf.dperf_dwb_num = @dperf_dwb_num;
end

function info = get_info
  info = nnfcnPerformance(mfilename,function_name,7,subfunctions,...
    parameters);
end

%  BOILERPLATE_END
%% =======================================================

function name = function_name, name = 'Sum Squared Error'; end

function param = parameters
  param = [...
    nnetParamInfo('regularization','Regularization Ratio','nntype.real_0_to_1',0,...
    'Fraction of performance associated with regularization.'),...
    nnetParamInfo('normalization','Normalization','nntype.error_norm_mode','none',...
    'The kind of error normalization relative to target ranges.'),...
    nnetParamInfo('squaredWeighting','Squared Weighting','nntype.bool_scalar',true,...
    'The kind of error normalization relative to target ranges.'),...
    ];
end


function err = check_param(param)
  err = '';
end

function e = adjust_error(net,e,ew,param)
  switch param.normalization
    case 'none', % no change required
    case 'standard', e = nnperf.norm_err(net,e);
    case 'percent', e = nnperf.perc_err(net,e);
  end
  if param.squaredWeighting
    e = gmultiply(e,gsqrt(ew));
  else
    e = gmultiply(e,ew);
  end
end

function e = adjusted_errors(net,t,y,ew,param)
  e = gsubtract(t,y);
  e = adjust_error(net,e,ew,param);
end

function [perfy,n] = performance_y(net,t,y,ew,param)
  e = adjusted_errors(net,t,y,ew,param);
  [perfy,n] = sumsqr(e);
  perfy = perfy * (1-param.regularization);
end

function [perfwb,n] = performance_wb(net,param)
  if isnumeric(net)
    [perfwb,n] = sumsqr(net);
  else
    [perfwb,n] = sumsqr([net.IW net.LW net.b]);
  end
  perfwb = perfwb * param.regularization;
end

function [x,n] = combine_perf_y_or_grad(x1,n1,x2,n2,param)
  n = n1 + n2;
  x = x1 + x2;
end

function x = weight_perf_y_or_grad(x1,n1,nTotal,param)
  x = x1;
end

function d = dperf_dy(net,t,y,ew,perf,param)
  e = adjusted_errors(net,t,y,ew,param);
  d = cell(size(e));
  m = -2 * (1-param.regularization);
  for i=1:numel(d)
    di = m * e{i};
    di(~isfinite(di)) = 0;
    d{i} = di;
  end
end

function d = dperf_dwb(wb,param)
  if param.regularization == 0
    if isnumeric(wb)
      d = zeros(size(wb));
    else
      d = zeros(wb.numWeightElements,1);
    end
  else
    if ~isnumeric(wb), wb = getwb(wb); end
    d = (-2*param.regularization) * wb;
  end
end
