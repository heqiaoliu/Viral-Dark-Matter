function [out1,out2] = trainbfg(varargin)
%TRAINBFG BFGS quasi-Newton backpropagation.
%
%  <a href="matlab:doc trainbfg">trainbfg</a> is a network training function that updates weight and
%  bias values according to the BFGS quasi-Newton method.
%
%  <a href="matlab:doc trainbfg">trainbfg</a> trains a network with weight and bias learning rules
%  with batch updates. The weights and biases are updated at the end of
%  an entire pass through the input data.
%  
%  [NET,TR] = <a href="matlab:doc trainbfg">trainbfg</a>(NET,X,T,Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    epochs          100  Maximum number of epochs to train
%    show             25  Epochs between displays
%    showCommandLine   0 generate command line output
%    showWindow        1 show training GUI
%    goal              0  Performance goal
%    time            inf  Maximum time to train in seconds
%    min_grad       1e-6  Minimum performance gradient
%    max_fail          5  Maximum validation failures
%     searchFcn 'srchcha'  Name of line search routine to use.
%
%  Parameters related to line search methods (not all used for all methods):
%    scal_tol         20  Divide into delta to determine tolerance for linear search.
%    alpha         0.001  Scale factor which determines sufficient reduction in perf.
%    beta            0.1  Scale factor which determines sufficiently large step size.
%    delta          0.01  Initial step size in interval location step.
%    gama            0.1  Parameter to avoid small reductions in performance. Usually set
%                                        to 0.1. (See use in SRCH_CHA.)
%    low_lim         0.1  Lower limit on change in step size.
%    up_lim          0.5  Upper limit on change in step size.
%    maxstep         100  Maximum step length.
%    minstep      1.0e-6  Minimum step length.
%    bmax             26  Maximum step size.
%    batch_frag        0  In case of multiple batches they are considered independent.
%                                        Any non zero value implies a fragmented batch, so final layers
%                                        conditions of a previous trained epoch are used as initial 
%                                        conditions for next epoch.
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainbfg';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM,
%           TRAINRP, TRAINCGF, TRAINCGB, TRAINSCG, TRAINCGP,
%           TRAINOSS.

% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.14.2.1 $ $Date: 2010/07/14 23:40:18 $

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
  info = nnfcnTraining(mfilename,'BFGS Quasi-Newton',7.0,true,true,...
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
    nnetParamInfo('min_grad','Minimum Gradient','nntype.pos_scalar',1e-6,...
    'Minimum performance gradient before training is stopped.') ...
    nnetParamInfo('max_fail','Maximum Validation Checks','nntype.strict_pos_int_scalar',6,...
    'Maximum number of validation checks before training is stopped.') ...
    ...
    nnetParamInfo('searchFcn','Line search function','nntype.search_fcn','srchbac',...
    'Line search function used to optimize performance each epoch.') ...
    nnetParamInfo('scale_tol','Scale Tolerance','nntype.strict_pos_scalar',20,...
    'Scale tolerance used for line search.') ...
    ...
    nnetParamInfo('alpha','Alpha','nntype.pos_scalar',0.001,...
    'Alpha.') ...
    nnetParamInfo('beta','Beta','nntype.pos_scalar',0.1,...
    'Beta.') ...
    nnetParamInfo('delta','Delta','nntype.pos_scalar',0.01,...
    'Delta.') ...
    nnetParamInfo('gama','Gamma','nntype.pos_scalar',0.1,...
    'Gamma.') ...]) ...
    nnetParamInfo('low_lim','Lower Limit','nntype.pos_scalar',0.1,...
    'Lower limit.') ...
    nnetParamInfo('up_lim','Upper Limit','nntype.pos_scalar',0.5,...
    'Upper limit.') ...
    nnetParamInfo('max_step','Maximum Step','nntype.pos_scalar',100,...
    'Maximum step.') ...
    nnetParamInfo('min_step','Minimum Step','nntype.pos_scalar',1.0e-6,...
    'Minimum step.') ...
    nnetParamInfo('bmax','B Max','nntype.pos_scalar',26,...
    'B Max.') ...
    nnetParamInfo('batch_frag','Batch Frag','nntype.pos_scalar',0,...
    'Batch Frag.')], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    nntraining.state_info('resets','Resets','discrete','linear') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  % Checks
  if isempty(net.performFcn)
    warning('nnet:trainbfg:Performance',nnwarn_empty_performfcn_corrected);
    net.performFcn = 'mse';
  end

  % Initialize
  startTime = clock;
  original_net = net;
  [perf,vperf,tperf,gWB,gradient] = nntraining.perfs_grad(net,data,fcns);
  gWB = -gWB;
  [best,val_fail] = nntraining.validation_start(net,perf,vperf);
  WB = getwb(net);
  num_WB = length(WB);
  
  delta = param.delta;
  tol = param.delta/param.scale_tol;
  a = 0;
  cons_a0 = 0;
  trainT = gmultiply(data.T,data.train.mask);
  
  % Training Record
  tr.best_epoch = 0;
  tr.goal = param.goal;
  tr.states = {'epoch','time','perf','vperf','tperf','gradient','val_fail','dperf','tol','delta','a','resets'};

  % Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    nntraining.status('Performance','','log','continuous',perf,param.goal,perf) ...
    nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
    nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
    nntraining.status('Resets','','log','continuous',0,4,0) ...
    ];
  nn_train_feedback('start',net,status);

  % Train
  for epoch=0:param.epochs
    
    % Performance, Gradient and Search Direction
    % If a is smaller that tolerance we restart algorithm
    
    if (a <= tol)
      % First search iteration
      % Initial performance
      perf_old = perf;
      ch_perf = perf;
      sum1 = 0; sum2 = 0;
      % Initial gradient and norm of gradient
      gWB_old = gWB;
      % Initial search direction and initial slope
      II = eye(num_WB);
      H = II;
      dWB  = -gWB;
      dperf = gWB'*dWB;
    else
      % After first search iteration
      % Calculate change in gradient
      dgWB = gWB - gWB_old;
      % Calculate change in performance and save old performance
      ch_perf = perf - perf_old;
      perf_old = perf;
      % Calculate new Hessian approximation
      % If H is rank defficient, use previous H matrix.
      H_ant = H;
      den1 = gWB_old'*dWB;
      den2 = dgWB'*WB_step;
      if (den1 ~= 0), H = H + gWB_old*gWB_old'/den1; end
      if (den2 ~= 0), H = H + dgWB*dgWB'/den2; end        
      if any(isnan(H(:))) || (rank(H) ~= num_WB), H = H_ant; end
      % Calculate new search direction
      dWB = -H\gWB;
      % Check for a descent direction
      dperf = gWB'*dWB;
      if dperf > 0
        H = II;
        dWB = -gWB;
        dperf = gWB'*dWB;
      end
      % Save old norm of gradient
      gradient = sqrt(gWB'*gWB);
      gWB_old = gWB;
    end
    
    cons_a0 = (cons_a0 + 1) * ((epoch > 1) && (a == 0));
    
    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.'; net = best.net;
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (perf <= param.goal), tr.stop = 'Performance goal met.';
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; net = best.net;
    elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; net = best.net;
    elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; net = best.net;
    elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; net = best.net;
    elseif any(~isfinite(dWB)), tr.stop = 'Precision problems in matrix inversion.'; net = best.net;
    elseif (cons_a0 >= 4), tr.stop = 'Line search resets did not produce a new minimum.'; net = best.net;
    end

    % Feedback
    tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf gradient val_fail dperf tol delta a cons_a0]);
    nn_train_feedback('update',net,status,tr,data, ...
      [epoch,current_time,best.perf,gradient,val_fail,cons_a0]);
    
    % Stop
    if ~isempty(tr.stop), break, end

    % Minimize the performance along the search direction
    % We use previous delta for next line search
    [a,gWB,perf,retcode,delta,tol] = ...
      feval(param.searchFcn,net,WB,data.P,data.Pd,data.Ai,trainT,data.EW,...
      data.Q,data.TS,dWB,gWB,perf,dperf,delta,tol,ch_perf,fcns);
    
    % Temporal Q movement. ****
    if param.batch_frag && (Q > 1)
      data2 = nntraining.y_all(net,data,fcns);
      Ac = data2.Ac;
      data2 = [];
      Aisize = size(data.Ai);
      data.Ai = cell(Aisize(1),Aisize(2));
      Aisize = size(data.Ai);
      Acsize = size(Ac,2);
      for k1=1:Aisize(1)
        for k2=1:Aisize(2)
          data.Ai{k1,k2}(:,2:Q) = Ac{k1,Acsize-Aisize(2)+k2}(:,1:Q-1);
        end
      end
    end

    % Keep track of the number of function evaluations
    sum1 = sum1 + retcode(1);
    sum2 = sum2 + retcode(2);

    % Update WB
    WB_step = a*dWB;
    WB = WB + WB_step;
    net = setwb(net,WB);

    % Validation
    if (a <= tol) || param.batch_frag
      [perf,vperf,tperf,gWB,gradient] = nntraining.perfs_grad(net,data,fcns);
      gWB = -gWB;
    else
      [perf,vperf,tperf] = nntraining.perfs(net,data,fcns);
    end
    [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,net,perf,vperf,epoch);
  end
end
