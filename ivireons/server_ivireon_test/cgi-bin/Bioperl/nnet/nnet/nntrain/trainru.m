function [out1,out2] = trainru(varargin)
%TRAINRU Unsupervised random order weight/bias training.
%
%  <a href="matlab:doc trainru">trainru</a> trains a network with weight and bias unsupervised learning
%  rules with incremental updates after each presentation of an input.
%  Inputs are presented in random order.
%
%  [NET,TR] = <a href="matlab:doc trainru">trainru</a>(NET,X) takes a network NET, input data X
%  and returns the network after training it, and training record TR.
%  
%  [NET,TR] = <a href="matlab:doc trainru">trainru</a>(NET,X,{},Xi,Ai,EW) takes additional optional
%  arguments suitable for training dynamic networks and training with
%  error weights.  Xi and Ai are the initial input and layer delays states
%  respectively and EW defines error weights used to indicate
%  the relative importance of each target value.
%
%  Training occurs according to training parameters, with default values.
%  Any or all of these can be overridden with parameter name/value argument
%  pairs appended to the input argument list, or by appending a structure
%  argument with fields having one or more of these names.
%    show            25  Epochs between displays
%    showCommandLine 0 generate command line output
%    showWindow      1 show training GUI
%    epochs          100  Maximum number of epochs to train
%    goal            0  Performance goal
%    time            inf  Maximum time to train in seconds
%
%  To make this the default training function for a network, and view
%  and/or change parameter settings, use these two properties:
%
%    net.<a href="matlab:doc nnproperty.net_trainFcn">trainFcn</a> = 'trainru';
%    net.<a href="matlab:doc nnproperty.net_trainParam">trainParam</a>
%
%  See also NEWP, NEWLIN, TRAIN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.3.2.1 $  $Date: 2010/07/14 23:40:34 $

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
  info = nnfcnTraining(mfilename,'Random Weight/Bias Rules',7.0,false,false,...
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
    ], ...
    []);
end

function err = check_param(param)
  err = '';
end

function [net,tr] = train_network(net,tr,data,fcns,param)

  % Initialize
  startTime = clock;
  original_net = net;
  BP = 1;
  IWLS = cell(net.numLayers,net.numInputs);
  LWLS = cell(net.numLayers,net.numLayers);
  BLS = cell(net.numLayers,1);
  trainInd = find(data.train.sampleMask);
  trainQ = length(trainInd);
  
  %% Training Record
  tr.best_epoch = 0;
  tr.goal = NaN;
  tr.states = {'epoch','time'};

  %% Status
  status = ...
    [ ...
    nntraining.status('Epoch','iterations','linear','discrete',0,param.epochs,0), ...
    nntraining.status('Time','seconds','linear','discrete',0,param.time,0), ...
    ];
  nn_train_feedback('start',net,status);

  %% Train
  for epoch=0:param.epochs

    % Stopping Criteria
    current_time = etime(clock,startTime);
    [userStop,userCancel] = nntraintool('check');
    if userStop, tr.stop = 'User stop.';
    elseif userCancel, tr.stop = 'User cancel.'; net = original_net;
    elseif (epoch == param.epochs), tr.stop = 'Maximum epoch reached.';
    elseif (current_time >= param.time), tr.stop = 'Maximum time elapsed.';
    end

    % Feedback
    tr = nntraining.tr_update(tr,[epoch current_time]);
    nn_train_feedback('update',net,status,tr,data,[epoch,current_time]);

    % Stop
    if ~isempty(tr.stop), break, end

    % Each vector (or sequence of vectors) in random order
    for qq=1:trainQ

      % Choose one from batch
      q = trainInd(fix(rand*trainQ)+1);
      divData = nntraining.split_data(data,q);
      divData = nntraining.y_all(net,divData,fcns);
      
      % Update with Weight and Bias Learning Functions
      for ts=1:data.TS
        for i=1:net.numLayers

          % Update Input Weight Values
          for j=find(net.inputConnect(i,:))
            learnFcn = fcns.inputWeights(i,j).learn;
            if learnFcn.exist
              Pd = nntraining.pd(net,1,divData.P,divData.Pd,i,j,ts);
              [dw,IWLS{i,j}] = learnFcn.apply(net.IW{i,j}, ...
                Pd,divData.Zi{i,j},divData.N{i},divData.Ac{i,ts+net.numLayerDelays},...
                divData.Tl{i,ts},divData.El{i,ts},[],...
                [],net.layers{i}.distances,learnFcn.param,IWLS{i,j});
              net.IW{i,j} = net.IW{i,j} + dw;
            end
          end

          % Update Layer Weight Values
          for j=find(net.layerConnect(i,:))
            learnFcn = fcns.layerWeights(i,j).learn;
            if learnFcn.exist
              Ad = cell2mat(divData.Ac(j,ts+net.numLayerDelays-net.layerWeights{i,j}.delays)');
              [dw,LWLS{i,j}] = learnFcn.apply(net.LW{i,j}, ...
                Ad,divData.Zl{i,j},divData.N{i},divData.Ac{i,ts+net.numLayerDelays},...
                divData.Tl{i,ts},divData.El{i,ts},[],...
                [],net.layers{i}.distances,learnFcn.param,LWLS{i,j});
              net.LW{i,j} = net.LW{i,j} + dw;
            end
          end

          % Update Bias Values
          if net.biasConnect(i)
            learnFcn = fcns.biases(i).learn;
            if learnFcn.exist
             [db,BLS{i}] = learnFcn.apply(net.b{i}, ...
                BP,divData.Zb{i},divData.N{i},divData.Ac{i,ts+net.numLayerDelays},...
                divData.Tl{i,ts},divData.El{i,ts},[],...
                [],net.layers{i}.distances,learnFcn.param,BLS{i});
              net.b{i} = net.b{i} + db;
            end
          end
        end
      end
    end
  end
  
  % Finish
  tr.best_epoch = param.epochs;
  tr = nntraining.tr_clip(tr);
end
