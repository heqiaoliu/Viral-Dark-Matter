function net = hints(net)

% Copyright 2010 The MathWorks, Inc.

if net.hint.ok, return; end

% INPUTS
% inputSizes{i}
% totalInputSize
hint.inputSizes = zeros(net.numInputs,1);
for i=1:net.numInputs
  hint.inputSizes(i) = net.inputs{i}.size;
end
hint.totalInputSize = sum(hint.inputSizes);

% LAYERS
% layerSizes{i}
% totalLayerSize
hint.layerSizes = zeros(net.numLayers,1);
for i=1:net.numLayers
  hint.layerSizes(i) = net.layers{i}.size;
end
hint.totalLayerSize = sum(hint.layerSizes);


% INDEX CONVERSION
% output2layer
% layer2output
hint.output2layer = find(net.outputConnect);
hint.layer2output = cumsum(net.outputConnect) .* net.outputConnect;

% OUTPUTS
% outputInd (same as output2layer)
% outputSizes{i}
% totalOutputSize
% processedOutputSizes(i)
% totalProcessedOutputSize
hint.outputInd = find(net.outputConnect);
hint.outputSizes = zeros(net.numOutputs,1);
hint.processedOutputSizes = zeros(net.numOutputs,1);
for i=1:net.numOutputs
  hint.outputSizes(i) = net.outputs{hint.outputInd(i)}.size;
  hint.processedOutputSizes(i) = net.outputs{hint.outputInd(i)}.processedSize;
end
hint.totalOutputSize = sum(hint.outputSizes);
hint.totalProcessedOutputSize = sum(hint.processedOutputSizes);

% CONNECTIONS
% inputConnectFrom{i}
% inputConnectTo{i}
% layerConnectFrom{i}
% layerConnectTo{i}
hint.inputConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hint.inputConnectFrom{i} = find(net.inputConnect(i,:));
end
hint.inputConnectTo = cell(net.numInputs,1);
for i=1:net.numInputs
  hint.inputConnectTo{i} = find(net.inputConnect(:,i)');
end
hint.layerConnectFrom = cell(net.numLayers,1);
hint.layerConnectTo = cell(net.numLayers,1);
for i=1:net.numLayers
  hint.layerConnectFrom{i} = find(net.layerConnect(i,:));
  hint.layerConnectTo{i} = find(net.layerConnect(:,i)');
end

% biasConnectTo, biasConnectFrom
hint.biasConnectFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hint.biasConnectFrom{i} = find(net.biasConnect(i));
end
hint.biasConnectTo = find(net.biasConnect)';

% LAYER ORDERS & ERROR CONDITIONS
% simLayerOrder
% bpLayerOrder
% zeroDelay (ERROR: indicates network has zero delay loop)
% noWeights (WARNING: indicates layer with no weights)
[hint.simLayerOrder,hint.zeroDelay] = simlayorder(net);
hint.bpLayerOrder=fliplr(hint.simLayerOrder);
hint.noWeights = find(~any([net.inputConnect net.layerConnect],2));

% DELAYS
% inputDelays{i,j}
% inputConnectOnlyZeroDay{i,j}
% inputConnectWithZeroDelay{i,j}
% layerDelays{i,j}
% layerConnectOZD{i,j}
% layerConnectWZD{i,j}
% layerConnectToOZD
% layerConnectToWZD
hint.inputDelays = cell(net.numLayers,net.numLayers);
hint.inputConnectOnlyZeroDay = false(net.numLayers,net.numLayers);
hint.inputConnectWithZeroDelay = false(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=hint.inputConnectFrom{i}
    delays = net.inputWeights{i,j}.delays;
    hint.inputDelays{i,j} = delays;
    hint.inputConnectOnlyZeroDay(i,j) = ~isempty(delays) && all(delays==0);
    hint.inputConnectWithZeroDelay(i,j) = ~isempty(delays) && any(delays==0) && ~all(delays==0);
  end
end
hint.layerDelays = cell(net.numLayers,net.numLayers);
hint.layerConnectOZD = false(net.numLayers,net.numLayers);
hint.layerConnectWZD = false(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=hint.layerConnectFrom{i}
    delays = net.layerWeights{i,j}.delays;
    hint.layerDelays{i,j} = delays;
    hint.layerConnectOZD(i,j) = ~isempty(delays) && all(delays == 0);
    hint.layerConnectWZD(i,j) = ~isempty(delays) && any(delays == 0) && ~all(delays == 0);
  end
end
hint.layerConnectToZD = cell(1,net.numLayers);
hint.layerConnectToWZD = cell(1,net.numLayers);
for i=1:net.numLayers
  hint.layerConnectToOZD{i} = find(hint.layerConnectOZD(:,i)');
  hint.layerConnectToWZD{i} = find(hint.layerConnectWZD(:,i)');
end

% SIMULATION FUNCTIONS
% inputProcessingFcn
% inputProcessingParam
% inputWeightFcn
% layerWeightFcn
% netInputFcn
% transferFcn
% outputProcessingFcn
hint.inputWeightFcn = cell(net.numLayers,net.numInputs);
hint.layerWeightFcn = cell(net.numLayers,net.numInputs);
hint.dLayerWeightFcn = hint.layerWeightFcn;
hint.netInputFcn = cell(net.numLayers,1);
hint.transferFcn = cell(net.numLayers,1);
for i=1:net.numLayers
  for j=hint.inputConnectFrom{i}
    hint.inputWeightFcn{i,j} = str2func(net.inputWeights{i,j}.weightFcn);
  end
  for j=hint.layerConnectFrom{i}
    hint.layerWeightFcn{i,j} = str2func(net.layerWeights{i,j}.weightFcn);
  end
  hint.netInputFcn{i} = str2func(net.layers{i}.netInputFcn);
  hint.transferFcn{i} = str2func(net.layers{i}.transferFcn);
end

% WEIGHT & BIAS LEARNING RULES
% ============================
% hint.needGradient
hint.needGradient = 0;
if (~isdeployed)
  for i=1:net.numLayers
    for j=find(net.inputConnect(i,:))
    learnFcn = net.inputWeights{i,j}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        hint.needGradient = 1;
        break;
      end
    end
    if (hint.needGradient), break, end
    for j=find(net.layerConnect(i,:))
    learnFcn = net.layerWeights{i,j}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        hint.needGradient = 1;
      break;
      end
    end
    if (hint.needGradient), break, end
    if net.biasConnect(i)
    learnFcn = net.biases{i}.learnFcn;
      if ~isempty(learnFcn) && feval(learnFcn,'needg');
        hint.needGradient = 1;
      end
    end
  end
end

% WEIGHT & BIASES COLUMNS
% =======================
hint.inputWeightCols = zeros(net.numLayers,net.numInputs);
hint.layerWeightCols = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))  
    hint.inputWeightCols(i,j) = net.inputWeights{i,j}.size(2);
  end
  for j=find(net.layerConnect(i,:)) 
    hint.layerWeightCols(i,j) = net.layerWeights{i,j}.size(2);
  end
end

% WEIGHT & BIASES LEARNING
% ========================

% inputLearn, layerLearn, biasLearn
hint.inputLearn = net.inputConnect;
hint.layerLearn = net.layerConnect;
hint.biasLearn = net.biasConnect;
for i=1:net.numLayers
  for j=find(net.inputConnect(i,:))
    hint.inputLearn(i,j) = net.inputWeights{i,j}.learn;
  end
  for j=find(net.layerConnect(i,:))
    hint.layerLearn(i,j) = net.layerWeights{i,j}.learn;
  end
  if (net.biasConnect(i))
    hint.biasLearn(i) = net.biases{i}.learn;
  end
end

% inputLearnFrom, layerLearnFrom
hint.inputLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hint.inputLearnFrom{i} = find(hint.inputLearn(i,:));
end
hint.layerLearnFrom = cell(net.numLayers,1);
for i=1:net.numLayers
  hint.layerLearnFrom{i} = find(hint.layerLearn(i,:));
end

% WEIGHT & BIAS INDICES INTO X VECTOR
% ===================================
hint.inputWeightInd = cell(net.numLayers,net.numInputs);
hint.layerWeightInd = cell(net.numLayers,net.numLayers);
hint.biasInd = cell(1,net.numLayers);
hint.xLen = 0;
for i=1:net.numLayers
  for j=find(hint.inputLearn(i,:))
    cols = net.inputWeights{i,j}.size(2);
    len = net.inputWeights{i,j}.size(1) * cols;
    hint.inputWeightInd{i,j} = hint.xLen + (1:len);
    hint.xLen = hint.xLen + len;
  end
  for j=find(hint.layerLearn(i,:))
    cols = net.layerWeights{i,j}.size(2);
    len = net.layerWeights{i,j}.size(1) * cols;
    hint.layerWeightInd{i,j} = hint.xLen + (1:len);
    hint.xLen = hint.xLen + len;
  end
  if (hint.biasLearn(i))
    len = net.layers{i}.size;
    hint.biasInd{i} = hint.xLen + (1:len);
    hint.xLen = hint.xLen + len;
  end
end


% Input Processing Fcn/Param
hint.inputProcessSteps = zeros(1,net.numInputs);
hint.inputProcessFcns = cell(1,net.numInputs);
hint.processSettings = cell(1,net.numInputs);
for i = 1:net.numInputs
  pf = net.inputs{i}.processFcns;
  ps = net.inputs{i}.processSettings;
  numSteps = length(ps);
  keep = true(1,numSteps);
  for j=1:numSteps
    keep(j) = ~ps{j}.no_change;
  end
  hint.inputProcessSteps(i) = sum(keep);
  hint.inputProcessFcns{i} = pf(keep);
  hint.processSettings{i} = ps(keep);
end

% Output Processing
hint.outputProcessSteps = zeros(1,net.numOutputs);
hint.outputProcessFcns = cell(1,net.numOutputs);
hint.processSettings = cell(1,net.numOutputs);
for i = 1:net.numOutputs
  ii = hint.output2layer(i);
  pf = net.outputs{ii}.processFcns;
  ps = net.outputs{ii}.processSettings;
  numSteps = length(ps);
  keep = true(1,numSteps);
  for j=1:numSteps
    keep(j) = ~ps{j}.no_change;
  end
  hint.outputProcessSteps(i) = sum(keep);
  hint.outputProcessFcns{i} = fliplr(pf(keep));
  hint.processSettings{i} = fliplr(ps(keep));
end

% Hints up to date
hint.ok = true;
net.hint = hint;

% ===========================================================
function [order,zeroDelay]=simlayorder(net)
%SIMLAYORDER Order to simulate layers in.

% INITIALIZATION
order = zeros(1,net.numLayers);
unordered = ones(1,net.numLayers);

% FIND ZERO-DELAY CONNECTIONS BETWEEN LAYERS
dependancies = zeros(net.numLayers,net.numLayers);
for i=1:net.numLayers
  for j=find(net.layerConnect(i,:))
    if any(net.layerWeights{i,j}.delays == 0)
      dependancies(i,j) = 1;
    end
  end
end

% FIND LAYER ORDER
for k=1:net.numLayers
  for i=find(unordered)
    if ~any(dependancies(i,:))
      dependancies(:,i) = 0;
      order(k) = i;
      unordered(i) = 0;
      break;
    end
  end
end

% CHECK THAT ALL LAYERS WERE ORDERED
zeroDelay = any(unordered);
