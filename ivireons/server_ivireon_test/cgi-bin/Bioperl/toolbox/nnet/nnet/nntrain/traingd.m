function [out1,out2] = traingd(varargin)
%TRAINGD Gradient descent backpropagation.
%
%  <a href="matlab:doc traingd">traingd</a> is a network training function that updates weight and
%  bias values according to gradient descent.
%
%  [NET,TR] = <a href="matlab:doc traingd">traingd</a>(NET,X,T) takes a network NET, input data X
%  and target data T and returns the network after training it, and a
%  a training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trainc">trainc</a>(NET,X,T,Xi,Ai,EW) takes additional optional
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
%    epochs      10  Maximum number of epochs to train
%    goal         0  Performance goal
%    lr        0.01  Learning rate
%    max_fail     5  Maximum validation failures
%    min_grad 1e-10  Minimum performance gradient
%    time       inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'traingd';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWFF, NEWCF, TRAINGDM, TRAINGDA, TRAINGDX, TRAINLM.

% Updated by Orlando De Jesús, Martin Hagan, 7-20-05
% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.6.12.2.1 $ $Date: 2010/07/14 23:40:26 $

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

function info = get_info
  info = nnfcnTraining(mfilename,'Gradient Descent',7.0,true,true,...
    [ ...
    nnetParamInfo('showWindow','Show Training Window Feedback','nntype.bool_scalar',true,...
    'Display training window during training.'), ...
    nnetParamInfo('showCommandLine','Show Command Line Feedback','nntype.bool_scalar',false,...
    'Generate command line output during training.') ...
    nnetParamInfo('show','Command Line Frequency','nntype.strict_pos_int_inf_scalar',25,...
    'Frequency to update command line.'), ...
    ...
    nnetParamInfo('epochs','Maximum Epochs','nntype.pos_int_scalar',1000,...
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
    nnetParamInfo('lr','Learning Rate','nntype.pos_scalar',0.01,...
    'Learning rate.') ...
    ], ...
    [ ...
    nntraining.state_info('gradient','Gradient','continuous','log') ...
    nntraining.state_info('val_fail','Validation Checks','discrete','linear') ...
    ]);
end

function err = check_param(param)
  err = '';
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  % Checks
  if isempty(net.performFcn)
    warning('nnet:traingd:Performance',nnwarn_empty_performfcn_corrected);
    net.performFcn = 'mse';
  end
  
  % Initialize
  startTime = clock;
  original_net = net;
  [perf,vperf,tperf,gWB,gradient] = nntraining.perfs_grad(net,data,fcns);
  [best,val_fail] = nntraining.validation_start(net,perf,vperf);
  WB = getwb(net);
  
  %% Training Record
  tr.best_epoch = 0;
  tr.goal = param.goal;
  tr.states = {'epoch','time','perf','vperf','tperf','gradient','val_fail'};

  %% Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    nntraining.status('Performance','','log','continuous',perf,param.goal,perf) ...
    nntraining.status('Gradient','','log','continuous',gradient,param.min_grad,gradient) ...
    nntraining.status('Validation Checks','','linear','discrete',0,param.max_fail,0) ...
    ];
  nn_train_feedback('start',net,status);

  %% Train
  for epoch=0:param.epochs

    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.'; net = best.net;
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (perf <= param.goal), tr.stop = 'Performance goal met.'; net = best.net;
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.'; net = best.net;
    elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.'; net = best.net;
    elseif (gradient <= param.min_grad), tr.stop = 'Minimum gradient reached.'; net = best.net;
    elseif (val_fail >= param.max_fail), tr.stop = 'Validation stop.'; net = best.net;
    end

    % Training record & feedback
    tr = nntraining.tr_update(tr,[epoch current_time perf vperf tperf gradient val_fail]);
    nn_train_feedback('update',net,status,tr,data, ...
      [epoch,current_time,best.perf,gradient,val_fail]);

    % Stop
    if ~isempty(tr.stop), return, end

    % Gradient Descent
    dWB = param.lr * gWB;
    WB = WB + dWB;
    net = setwb(net,WB);
    [perf,vperf,tperf,gWB,gradient] = nntraining.perfs_grad(net,data,fcns);
    
    % Validation
    [best,tr,val_fail] = nntraining.validation(best,tr,val_fail,net,perf,vperf,epoch);
  end
end

