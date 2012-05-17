function [b,iw,lw] = separatewb(net,wb)
%SEPARATEWB Separate biases and weights from a weight/bias vector.
%
%  [B,IW,LW] = <a href="matlab:doc separatewb">separatewb</a>(NET,WB) takes a network NET and a single
%  vector of biases and weights and returns separated biases, input
%  weights and layer weights.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.  The single vector
%  is then redivided into the original biases and weights.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc formwb">formwb</a>(net,net.b,net.iw,net.lw)
%    [b,iw,lw] = <a href="matlab:doc separatewb">separatewb</a>(net,wb)
%
%  See also formwb, getwb, setwb.

% Copyright 2010 The MathWorks, Inc.

% Shortcuts
net = nn.hints(net);

inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

b = cell(net.numLayers,1);
iw = cell(net.numLayers,net.numInputs);
lw = cell(net.numLayers,net.numLayers);

for i=1:net.numLayers
  if biasLearn(i)
    b{i} = reshape(wb(biasInd{i}),...
      net.biases{i}.size,1);
  end
  for j=find(inputLearn(i,:))
    iw{i,j} = reshape(wb(inputWeightInd{i,j}),...
      net.inputWeights{i,j}.size);
  end
  for j=find(layerLearn(i,:))
    lw{i,j} = reshape(wb(layerWeightInd{i,j}),...
      net.layerWeights{i,j}.size);
  end
end
