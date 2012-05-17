function net = nn_configure_layer_weight(net,i,j,x)

% Copyright 2010 The MathWorks, Inc.

% Input Data
numDelays = length(net.layerWeights{i,j}.delays);
if nargin < 4
  x = net.layers{i}.range;
  x = repmat(x,numDelays,1);
end

% Configure Size
rows = net.layers{i}.size;
cols = net.layers{j}.size * numDelays;
newSize = feval(net.layerWeights{i,j}.weightFcn,...
  'size',rows,cols,net.layerWeights{i,j}.weightParam);
net.layerWeights{i,j}.size = newSize;
if any(size(net.LW{i,j}) ~= newSize)
  net.LW{i,j} = zeros(newSize);
end

% Configure Initialization
if ~isempty(net.initFcn)
  net.layerWeights{i,j}.initSettings = ...
    feval(net.initFcn,'configure',net,'LW',i,j,x);;
else
  net.inputWeights{i,j}.initSettings = struct;
end
