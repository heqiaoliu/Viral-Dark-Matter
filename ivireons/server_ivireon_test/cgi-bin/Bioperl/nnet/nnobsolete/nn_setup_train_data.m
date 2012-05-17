function [net,signals,err] = nn_setup_train_data(net,X,T,Xi,Ai,EW)
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.

% Copyright 2010 The MathWorks, Inc.

signals = struct;

% Input
% Missing inputs filled in with 0 column values
if isempty(X)
  X = cell(net.numInputs,1);
  for i=1:net.numInputs
    X{i} = zeros(net.inputs{i}.size,0);
  end
end
err = nntype.data('check',X);
if ~isempty(err), err = ['Inputs: ' err]; return; end
[Xn,Xq,Xts,Xs] = nnfast.nnsize(X);
if (Xs ~= net.numInputs)
  err = 'Number of inputs does not match net.numInputs.'; return;
end  

% Target
% Missing targets filled in with NaN values
% TODO - Dimensionally expand targets
if isempty(T)
  T = cell(net.numOutputs,Xts);
end
targetIndices = find(net.outputConnect);
for i=1:net.numOutputs
  ii = targetIndices(i);
  for ts = 1:Xts
    if isempty(T{i,ts})
      T{i,ts} = nan(net.outputs{ii}.size,Xq);
    end
  end
end
err = nntype.data('check',T);
if ~isempty(err), err = ['Targets: ' err]; return; end
[Tn,Tq,Tts,Ts] = nnfast.nnsize(T);
if (Ts ~= net.numOutputs)
  err = 'Number of targets does not match net.numOutputs.'; return;
end
if (Tts ~= Xts)
  err = 'Inputs and targets have different numbers of timesteps.'; return
end

% Check Configuration
configuredInput = false;
unconfiguredInput = false;
inconsistentInput = false;
mismatchedInput = 0;
for i=1:Xs
  if (net.inputs{i}.size == 0) && (Xn(i) ~= 0)
    unconfiguredInput = true;
    if mismatchedInput == 0, mismatchedInput = i; end
  elseif Xn(i) ~= net.inputs{i}.size
    inconsistentInput = true;
    if mismatchedInput == 0, mismatchedInput = i; end
  elseif Xn(i) ~= 0
    configuredInput = true;
  end
end
configuredTarget = false;
unconfiguredTarget = false;
inconsistentTarget = false;
mismatchedTarget = 0;
Tindices = find(net.outputConnect);
for i=1:Ts
  ii = Tindices(i);
  if (net.outputs{ii}.size == 0) && (Tn(i) ~= 0)
    unconfiguredTarget = true;
    if (mismatchedTarget == 0), mismatchedTarget = i; end
  elseif Tn(i) ~= net.outputs{ii}.size
    inconsistentTarget = true;
    if (mismatchedTarget == 0), mismatchedTarget = i; end
  elseif Tn(i) ~= 0
    configuredTarget = true;
  end
end
if (unconfiguredInput || unconfiguredTarget) && ...
    (configuredInput || configuredTarget)
  if mismatchedInput
    inconsistentInput = true;
  else
    inconsistentTarget = true;
  end
end
if (unconfiguredInput && configuredInput) || inconsistentInput
  istr = num2str(iconsistentIndex);
  err = ['Input ' istr ' size does not match net.inputs{' istr '}.size.'];
  return;
end
if (unconfiguredTarget && configuredTarget) || inconsistentTarget
  istr = num2str(mismatchedTarget);
  ii = Tindices(mismatchedTarget);
  iistr = num2str(ii);
  err = ['Target ' istr ' size does not match net.outputs{' iistr '}.size.'];
  return;
end

% Configure
% TODO - Configure on individual input/output basis
configured = unconfiguredInput || unconfiguredTarget;
if configured
  if unconfiguredTarget
    net = configure(net,X,T);
  elseif unconfiguredInput
    net = configure(net,X);
  end
end

% Input States
% Missing input states filled in with zeros
% TODO - Dimensionally expand
if isempty(Xi)
  Xi = cell(net.numInputs,net.numInputDelays);
  for i=1:net.numInputs
    xi = zeros(net.inputs{i}.size,Xq);
    for j=1:net.numInputDelays, Xi{i,j} = xi; end
  end
end
err = nntype.data('check',Xi);
if ~isempty(err), err = ['Input states: ' err]; return; end
[Xin,Xiq,Xits,Xis] = nnfast.nnsize(Xi);
if (Xis ~= net.numInputs)
  err = 'Number of input states does not match net.numInputs.'; return;
end
if (Xits ~= net.numInputDelays)
  err = 'Number of input state timesteps does not match net.numInputDelays.'; return
end
if (Xis > 0) && (Xits > 0)
  for i=1:Xis
    if Xin(i) ~= net.inputs{i}.size
      err = 'Input state sizes does not match net.inputs{:}.size.'; return;
    end
  end
end

% Layer States
% Missing layer states filled in with zeros
% TODO - Dimensionally expand
if isempty(Ai)
  Ai = cell(net.numLayers,net.numLayerDelays);
  for i=1:net.numLayers
    ai = zeros(net.layers{i}.size,Xq);
    for j=1:net.numLayerDelays, Ai{i,j} = ai; end
  end
end
err = nntype.data('check',Ai);
if ~isempty(err), err = ['Layer states: ' err]; return; end
[Ain,Aiq,Aits,Ais] = nnfast.nnsize(Ai);
if (Ais ~= net.numLayers)
  err = 'Number of layer states does not match net.numLayers.'; return;
end
if (Aits ~= net.numLayerDelays)
  err = 'Number of layer state timesteps does not match net.numLayerDelays.'; return
end
if (Ais > 0) && (Aits > 0)
  for i=1:Ais
    if Ain(i) ~= net.layers{i}.size
      err = 'Layer state size does not match net.layers{:}.size.'; return;
    end
  end
end

% Initialization if Configured
if configured
  disp('Network configured and initialized.');
  % TODO - need to do this? Initialization happens with configuration.
  net = init(net);
end

signals.name = 'All';
signals.Q = Xq;
signals.indices = 1:Xq;
signals.TS = Xts;
signals.X = X;
signals.Xi = Xi;
signals.Ai = Ai;
signals.T = T;
signals.isFlattened = false;
signals.isSeparate = false;
signals.TSunflat = signals.TS;

% TODO - Check EW
signals.EW = EW;
