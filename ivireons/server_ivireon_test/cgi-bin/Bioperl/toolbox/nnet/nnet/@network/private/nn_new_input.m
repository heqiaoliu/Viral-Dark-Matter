function net = nn_new_input(net,i)
%NN_NEW_INPUT Insert new input into network.

% Copyright 2010 The MathWorks, Inc.

if i > (net.numInputs+1)
  nnerr.throw('Cannot insert new input more than 1 index over net.numInputs.');
end

% Increment any output-to-input feedback connections
% that connect to original input i or greater.
for j=find(net.outputConnect)
  if net.outputs{j}.feedbackInput >= i
    net.outputs{j}.feedbackInput = net.outputs{j}.feedbackInput + 1;
  end
end

% Insert new input i
n = 1:(i-1);
m = i:(net.numInputs-1);
net.numInputs = net.numInputs + 1;
net.inputs = [net.inputs(n); {nnetInput}; net.inputs(m)];
net.inputConnect = ...
  [net.inputConnect(:,n) false(net.numLayers,1) net.inputConnect(:,m)];
net.inputWeights = ...
  [net.inputWeights(:,n) cell(net.numLayers,1) net.inputWeights(:,m)];
net.IW = [net.IW(:,n) cell(net.numLayers,1) net.IW(:,m)];
