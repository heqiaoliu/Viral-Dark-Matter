function [out1,out2] = trainbr(varargin)
%TRAINBR Bayesian Regulation backpropagation.
%
%  <a href="matlab:doc trainbr">trainbr</a> is a network training function that updates the weight and
%  bias values according to Levenberg-Marquardt optimization.  It
%  minimizes a combination of squared errors and weights
%  and, then determines the correct combination so as to produce a
%  network which generalizes well.  The process is called Bayesian
%  regularization.
%
%  <a href="matlab:doc trainbr">trainbr</a> trains a network with weight and bias learning rules
%  with batch updates. The weights and biases are updated at the end of
%  an entire pass through the input data.
%  
%  [NET,TR] = <a href="matlab:doc trainbr">trainbr</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show        25  Epochs between displays
%    showCommandLine 0 generate command line output
%    showWindow   1 show training GUI
%    epochs     100  Maximum number of epochs to train
%    goal         0  Performance goal
%    mu       0.005  Marquardt adjustment parameter
%    mu_dec     0.1  Decrease factor for mu
%    mu_inc      10  Increase factor for mu
%    mu_max    1e10  Maximum value for mu
%    max_fail     5  Maximum validation failures
%    min_grad 1e-10  Minimum performance gradient
%    time       inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbr';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP,
%           TRAINBFG.

% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.14.2.2 $ $Date: 2010/07/23 15:40:15 $

%% =======================================================
%  BOILERPLATE_START
%  This code is the same for all Training Functions.

  persistent INFO;
  if isempty(INFO), INFO = get_info; end
  nnassert.minargs(nargin,1);
  in1 = varargin{1};
  if ischar(in1)
    switch (in1)
      case 'info'
        out1 = INFO;
      case 'check_param'
        nnassert.minargs(nargin,2);
        param = varargin{2};
        err = nntest.param(INFO.parameters,param);
        if isempty(err)
          err = check_param(param);
        end
        if nargout > 0
          out1 = err;
        elseif ~isempty(err)
          nnerr.throw('Type',err);
        end
      otherwise,
        try
          out1 = eval(['INFO.' in1]);
        catch me, nnerr.throw(['Unrecognized first argument: ''' in1 ''''])
        end
    end
    return
  end
  nnassert.minargs(nargin,2);
  net = nn.hints(nntype.network('format',in1,'NET'));
  oldTrainFcn = net.trainFcn;
  oldTrainParam = net.trainParam;
  if ~strcmp(net.trainFcn,mfilename)
    net.trainFcn = mfilename;
    net.trainParam = INFO.defaultParam;
  end
  [args,param] = nnparam.extract_param(varargin(2:end),net.trainParam);
  err = nntest.param(INFO.parameters,param);
  if ~isempty(err), nnerr.throw(nnerr.value(err,'NET.trainParam')); end
  if INFO.isSupervised && isempty(net.performFcn) % TODO - fill in MSE
    nnerr.throw('Training function is supervised but NET.performFcn is undefined.');
  end
  if INFO.usesGradient && isempty(net.derivFcn) % TODO - fill in
    nnerr.throw('Training function uses derivatives but NET.derivFcn is undefined.');
  end
  if net.hint.zeroDelay, nnerr.throw('NET contains a zero-delay loop.'); end
  [X,T,Xi,Ai,EW] = nnmisc.defaults(args,{},{},{},{},{1});
  X = nntype.data('format',X,'Inputs X');
  T = nntype.data('format',T,'Targets T');
  Xi = nntype.data('format',Xi,'Input states Xi');
  Ai = nntype.data('format',Ai,'Layer states Ai');
  EW = nntype.nndata_pos('format',EW,'Error weights EW');
  % Prepare Data
  [net,data,tr,message,err] = nntraining.setup(net,mfilename,X,Xi,Ai,T,EW);
  if ~isempty(err), nnerr.throw('Args',err), end
  if ~isempty(message)
    %disp([nnlink.fcn2ulink(mfilename) ': ' message]);
  end
  % Train
  net = struct(net);
  fcns = nn.subfcns(net);
  [net,tr] = train_network(net,tr,data,fcns,param);
  tr = nntraining.tr_clip(tr);
  if isfield(tr,'perf')
    tr.best_perf = tr.perf(tr.best_epoch+1);
  end
  if isfield(tr,'vperf')
    tr.best_vperf = tr.vperf(tr.best_epoch+1);
  end
  if isfield(tr,'tperf')
    tr.best_tperf = tr.tperf(tr.best_epoch+1);
  end
  net.trainFcn = oldTrainFcn;
  net.trainParam = oldTrainParam;
  out1 = network(net);
  out2 = tr;
end

%  BOILERPLATE_END
%% =======================================================

function info = get_info()
  info = nnfcnTraining(mfilename,'Bayesian Regulation',7.0,true,false,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_scalar',1000,...
    'Maximum number of training iterations before training is stopped.') ...
    nnetParamInfo('time','Maximum Training Time','nntype.pos_inf_scalar',inf,...
    'Maximum time in seconds before training is stopped.') ...
    ...
    nnetParamInfo('goal','Performance Goal','nntype.pos_scalar',0,...
    'Performance goal.') ...
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-5,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('mu','Mu','nntype.strict_pos_scalar',0.005,...
    'Mu.'), ...
    nnetParamInfo('mu_dec','Mu Decrease Ratio','nntype.strict_pos_scalar',0.1,...
    'Ratio to decrease mu.'), ...
    nnetParamInfo('mu_inc','Mu Increase Ratio','nntype.strict_pos_scalar',10,...
    'Ratio to increase mu.'), ...
    nnetParamInfo('mu_max','Maximum mu','nntype.strict_pos_scalar',1e10,...
    'Maximum mu before training is stopped.'), ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('mu','Mu','continuous','log') ...
    nntraining.state_info('gamk','Num Parameters','continuous','linear') ...
    nntraining.state_info('ssX','Sum Squared Param','continuous','log') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  % Checks
  if isempty(net.performFcn)
    disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.empty_performfcn_corrected]);
    net.performFcn = 'sse';
    net.performParam = sse('defaultParam');
    tr.performFcn = net.performFcn;
    tr.performParam = net.performParam;
  end
  if ~strcmp(net.performFcn,'sse')
    disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.trainbr_performfcn_sse]);
    net.performFcn = 'sse';
    net.performParam = sse('defaultParam');
    tr.performFcn = net.performFcn;
    tr.performParam = net.performParam;
  end
  if isfield(net.performParam,'regularization')
    if net.performParam.regularization ~= 0
      disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.adaptive_reg_override])
      net.performParam.regression = 0;
    end
  end
  if ~isempty(data.val.indices)
    disp([nnlink.fcn2ulink('trainbr') ': ' nnwarning.trainbr_disable_val])
    for i=1:numel(data.train.mask)
      data.train.mask{i}(isnan(data.val.mask{i})) = 1;
    end
    data.train.indices = sort([data.train.indices data.val.indices]);
    data.val.enabled = false;
    data.val.mask = {0};
    data.val.indices = [];
    % TODO - update training record
  end
  fcns = nn.subfcns(net);
  
  % Initialize
  startTime = clock;
  original_net = net;
  [ssE,vperf,tperf,je,jj,gradient] = nntraining.perfs_jejj(net,data,fcns);
  [best,val_fail] = nntraining.validation_start(net,ssE,vperf);
  X = getwb(net);
  mu = param.mu;
  numParameters = length(X);
  ii = sparse(1:numParameters,1:numParameters,ones(1,numParameters));
  
  % Initialize regularization parameters
  numErrors = nntraining.num_train_t(data);
  gamk = numParameters;
  if ssE == 0, beta = 1; else beta = (numErrors - gamk)/(2*ssE); end
  if beta <=0, beta = 1; end
  ssX = X'*X;
  alph = gamk/(2*ssX);
  perf = beta*ssE + alph*ssX;

  %% Training Record
  tr.best_epoch = 0;
  tr.goal = param.goal;
  tr.states = {'epoch','time','perf','vperf','tperf','mu','gradient','gamk','ssX'};

  %% Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    nntraining.status('Performance','','log','continuous',ssE,param.goal,ssE) ...
    nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
    nntraining.status('Mu','','log','continuous',mu,param.mu_max,mu) ...
    nntraining.status('Effective # Param','','linear','continuous',gamk,0,gamk) ...
    nntraining.status('Sum Squared Param','','log','continuous',ssX,0,ssX) ...
    ];
  nn_train_feedback('start',net,status);

  % Train
  for epoch=0:param.epochs

    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.'; net = best.net;
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (ssE <= param.goal), tr.stop = 'Performance goal met.'; net = best.net;
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; net = best.net;
    elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; net = best.net;
    elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; net = best.net;
    elseif (mu >= param.mu_max), tr.stop = 'Maximum MU reached.'; net = best.net;
    elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; net = best.net;
    end

    % Feedback
    tr = nntraining.tr_update(tr,[epoch current_time ssE vperf tperf mu gradient gamk ssX]);
    nn_train_feedback('update',net,status,tr,data, ...
      [epoch,current_time,ssE,gradient,mu,gamk,ssX]);

    % Stop
    if ~isempty(tr.stop), break, end

    % APPLY LEVENBERG MARQUARDT: INCREASE MU TILL ERRORS DECREASE
    while (mu <= param.mu_max)
      % CHECK FOR SINGULAR MATRIX
      [msgstr,msgid] = lastwarn;
      lastwarn('MATLAB:nothing','MATLAB:nothing')
      warnstate = warning('off','all');
      dX = -(beta*jj + ii*(mu+alph)) \ (beta*je + alph*X);
      [msgstr1,msgid1] = lastwarn;
      flag_inv = isequal(msgid1,'MATLAB:nothing');
      if flag_inv, lastwarn(msgstr,msgid); end;
      warning(warnstate);
      X2 = X + dX;
      ssX2 = X2'*X2;
      net2 = setx(net,X2);

      ssE2 = nntraining.train_perf(net2,data,fcns);
      perf2 = beta*ssE2 + alph*ssX2;

      if (perf2 < perf) && ( ( sum(isinf(dX)) + sum(isnan(dX)) ) == 0 ) && flag_inv
        X = X2; net = net2; ssE = ssE2; ssX = ssX2; perf = perf2;
        mu = mu * param.mu_dec;
        if (mu < 1e-20), mu = 1e-20; end
        break
      end
      mu = mu * param.mu_inc;
    end
    [ssE,vperf,tperf,je,jj,gradient] = nntraining.perfs_jejj(net,data,fcns);
    
    if (mu <= param.mu_max)
      % Update regularization parameters and performance function
      warnstate = warning('off','all');
      gamk = numParameters - alph*trace(inv(beta*jj+ii*alph));
      warning(warnstate);
      if ssX==0, alph = 1; else alph = gamk/(2*(ssX)); end
      if ssE==0, beta = 1; else beta = (numErrors - gamk)/(2*ssE); end
      perf = beta*ssE + alph*ssX;
    end
    
    if true %(ssE < best.perf)
      best.net = net;
      best.perf = ssE;
      tr.best_epoch = epoch+1;
    end
  end
end
