function disp_problem(net,x,xi,ai,t,seed)
%DISP Display network/data test problem

% Copyright 2010 The MathWorks, Inc.

if nargin == 1
  seed = net;
  [net,x,xi,ai,t] = nntest.rand_problem(seed);
end

[Ni,Q,TS] = nnfast.nnsize(x);
No = nnfast.nnsize(t);

if (net.numInputDelays + net.numLayerDelays + net.numFeedbackDelays) == 0
  type = 'Static';
else
  type = 'Dynamic';
end

disp(['[net,x,xi,ai,t] = nntest.rand_problem(' num2str(seed) ')']);
disp(' ');
disp(['Network Mode = ' type]);
disp(' ')
disp(['Number of inputs: ' num2str(net.numInputs)]);
disp(['Number of layers: ' num2str(net.numLayers)]);
disp(['Number of outputs: ' num2str(net.numOutputs)]);
disp(['Number of weights: ' num2str(sum(sum([net.inputConnect net.layerConnect])))]);
disp(['Number of biases: ' num2str(sum(net.biasConnect))]);
disp(' ')
disp(['Number of input delays: ' num2str(sum(net.numInputDelays))]);
disp(['Number of layer delays: ' num2str(sum(net.numLayerDelays))]);
disp(' ')
disp(['Number of wb values: ' num2str(net.numWeightElements)]);
disp(' ')
disp(['Number of input elements: ' num2str(sum(Ni))]);
disp(['Number of output elements: ' num2str(sum(No))]);
disp(' ')
disp(['Number of samples: ' num2str(Q)]);
disp(['Number of timesteps: ' num2str(TS)]);
