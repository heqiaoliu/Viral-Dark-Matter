function [net,data,tr,message,err] = setup(net,trainFcn,X,Xi,Ai,T,EW)

% Copyright 2010 The MathWorks, Inc.

% Configure network inputs and outputs, fill in basic data
for i=1:numel(X),X{i} = double(X{i}); end
for i=1:numel(Xi),Xi{i} = double(Xi{i}); end
for i=1:numel(Ai),Ai{i} = double(Ai{i}); end
for i=1:numel(T),T{i} = double(T{i}); end
for i=1:numel(EW),EW{i} = double(EW{i}); end
[net,X,Xi,Ai,T,EW,message,err] = nntraining.config(net,X,Xi,Ai,T,EW);
if ~isempty(err)
  data = [];
  tr = [];
  message = [];
  return;
end

% This must happen after configuration above
% has determined function settings
fcns = nn.subfcns(net);

[~,Q,TS] = nnfast.nnsize(X);

% Optimizations
data.options.cachedDelayedInputs = net.efficiency.cacheDelayedInputs && ...
  (net.numInputDelays > 0);
data.options.flattenedTime = net.efficiency.flattenTime && ...
  (TS>1) && (net.numLayerDelays == 0) && ...
  ((net.numInputDelays == 0) || net.efficiency.cacheDelayedInputs) && ...
  (~strcmp(net.trainFcn,'trains'));
data.options.dividedData = feval(trainFcn,'usesValidation') && ~isempty(net.divideFcn);

% Preprocessing Inputs and Input States
P = nnproc.pre_inputs(fcns,[Xi X]);

[P,T] = nntraining.fix_nan_inputs(net,P,Ai,T,Q,TS);

% Delayed Inputs
if data.options.cachedDelayedInputs
  Pd = nnsim.pd(net,P);
  P = {};
else
  Pd = {};
end

% Data Structure
data.X = X;
data.Xi = Xi;
data.P = P;
data.Pd = Pd;
data.Ai = Ai;
data.T = T;
data.EW = EW;
data.Q = Q;
data.TS = TS;

% Divide Data
% TODO - Split samples mode
% TODO - Handle low-count or 0-count validation and test sets
% TODO - Handle data division properly despite flattening time
outputN = nnfast.numelements(T);
if data.options.dividedData
  divideFcn = net.divideFcn;
  switch net.divideMode
    case 'none'
      trainInd = 1:Q;
      valInd = [];
      testInd = [];
      data.train = all_data('Training',trainInd);
      data.val = disabled_data('Validation');
      data.test = disabled_data('Test');
    case 'sample'
      [trainInd,valInd,testInd] = feval(net.divideFcn,Q,net.divideParam);
      data.train = share_samples(data,trainInd,'Training',outputN);
      data.val = share_samples(data,valInd,'Validation',outputN);
      data.test = share_samples(data,testInd,'Test',outputN);
    case 'time',
      [trainInd,valInd,testInd] = feval(net.divideFcn,TS,net.divideParam);
      data.train = share_timesteps(data,trainInd,'Training',outputN);
      data.val = share_timesteps(data,valInd,'Validation',outputN);
      data.test = share_timesteps(data,testInd,'Test',outputN);
    case 'sampletime',
      Q_TS = Q * TS;
      [trainInd,valInd,testInd] = feval(net.divideFcn,Q_TS,net.divideParam);
      data.train = share_sampleTimesteps(data,trainInd,'Training',outputN);
      data.val = share_sampleTimesteps(data,valInd,'Validation',outputN);
      data.test = share_sampleTimesteps(data,testInd,'Test',outputN);
    case 'value',
      N_Q_TS = sum(outputN)*Q*TS;
      [trainInd,valInd,testInd] = feval(net.divideFcn,N_Q_TS,net.divideParam);
      data.train = share_general(data,trainInd,'Training',outputN);
      data.val = share_general(data,valInd,'Validation',outputN);
      data.test = share_general(data,testInd,'Test',outputN);
  end
else
  divideFcn = 'dividetrain';
  trainInd = 1:Q;
  valInd = [];
  testInd = [];
  data.train = all_data('Training',trainInd);
  data.val = disabled_data('Validation');
  data.test = disabled_data('Test');
end

% Training record
tr = nnetTrainingRecord(net);
tr.divideFcn = divideFcn;
tr.divideMode = net.divideMode;
tr.trainInd = trainInd;
tr.valInd = valInd;
tr.testInd = testInd;
tr.trainMask = data.train.mask;
tr.valMask = data.val.mask;
tr.testMask = data.test.mask;

% Flatten Time
% ------------
% Save unflattened data
% This is for plotting functions with need
% the original unflattened data.
% They don't need unflattened P or Pd
% because X and Xi are available unflattened.
% They don't need unflattened Ai because
% flatting only occurs when Ai is empty.
% TODO - make flattening transparent to plots
data.TSu = TS;
data.Qu = Q;
data.Tu = T;
data.train.masku = data.train.mask;
data.val.masku = data.val.mask;
data.test.masku = data.test.mask;
% Optionally create flattened versions
if data.options.flattenedTime
  data.P = nnfast.seq2con(data.P);
  data.Pd = nnsim.seq2con3(data.Pd);
  data.T = nnfast.seq2con(data.T);
  data.EW = nnfast.seq2con(data.EW);
  data.Q = data.Q*data.TS;
  data.TS = 1;
  data.train.mask = nnfast.seq2con(data.train.mask);
  data.val.mask = nnfast.seq2con(data.val.mask);
  data.test.mask = nnfast.seq2con(data.test.mask);
end

% Split Calcuations
data = set_split_info(net,data);

function y = all_data(name,indices)
y.name = name;
y.enabled = true;  % TODO - rename as none (vs. all)
y.all = true;
y.masked = false; % TODO - remove this
y.indices = indices; % TODO - define this
y.mask = {1};
y.sampleMask = []; % TODO - remove this

function y = share_samples(data,indices,name,outputN)
if isempty(indices)
  y = disabled_data(name); return;
elseif length(indices) == data.Q
  y = all_data(name,indices); return;
end
mask = nan(sum(outputN),data.Q*data.TS);
[ts,q] = meshgrid(1:data.TS,indices);
indices2 = (ts(:)-1)*data.Q+q(:);
mask(:,indices2) = 1;
y.name = name;
y.enabled = true;
y.all = false;
y.indices = indices;
y.masked = true;
y.mask = mat2cell(mask,outputN,data.Q*ones(1,data.TS));
y.sampleMask = mask2sampleMask(mask,data);

function y = share_timesteps(data,indices,name,outputN)
if isempty(indices)
  y = disabled_data(name); return;
end
mask = nan(sum(outputN),data.Q*data.TS);
[ts,q] = meshgrid(indices,1:data.Q);
indices2 = (ts(:)-1)*data.Q+q(:);
mask(:,indices2) = 1;
y.name = name;
y.enabled = true;
y.all = false;
y.masked = true;
y.indices = indices;
y.mask = mat2cell(mask,outputN,data.Q*ones(1,data.TS));
y.sampleMask = mask2sampleMask(mask,data);

function y = share_sampleTimesteps(data,indices,name,outputN)
if isempty(indices)
  y = disabled_data(name); return;
end
mask = nan(sum(outputN),data.Q*data.TS);
mask(:,indices) = 1;
y.name = name;
y.enabled = true;
y.all = false;
y.masked = true;
y.indices = indices;
y.mask = mat2cell(mask,outputN,data.Q*ones(1,data.TS));
y.sampleMask = mask2sampleMask(mask,data);

function y = share_general(data,indices,name,outputN)
if isempty(indices)
  y = disabled_data(name); return;
end
mask = nan(sum(outputN),data.Q*data.TS);
mask(indices) = 1;
y.name = name;
y.enabled = true;
y.all = false;
y.masked = true;
y.indices = indices;
y.mask = mat2cell(mask,outputN,data.Q*ones(1,data.TS));
y.sampleMask = mask2sampleMask(mask,data);

function y = disabled_data(name)
y.name = name;
y.enabled = false;
y.all = false;
y.masked = false;
y.indices = [];
y.mask = {0};
y.sampleMask = {0};

function data = set_split_info(net,data)
Q = data.Q;
data.split.count = min(Q,net.efficiency.memoryReduction);
data.split.maxSize = ceil(Q/data.split.count);
data.split.sizes = zeros(1,data.split.count);
data.split.indices = cell(1,data.split.count);
index = 0;
for i=1:data.split.count
  if (Q-index) >= data.split.maxSize
    data.split.sizes(i) = data.split.maxSize;
    data.split.indices{i} = index + (1:data.split.maxSize);
    index = index + data.split.maxSize;
  else
    data.split.sizes(i) = Q-index;
    data.split.indices{i} = (index+1):Q;
  end
end

function sampleMask = mask2sampleMask(mask,data)
sampleMask = prod(mask,1);
sampleMask = reshape(sampleMask,data.Q,data.TS);
sampleMask = isfinite(prod(sampleMask,2)');
