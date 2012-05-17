function x=getwb(net)
%GETWB Get all network weight and bias values as a single vector.
%
%  <a href="matlab:doc getwb">getwb</a>(NET) returns network NET's biases and weights as a single vector.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc getwb">getwb</a>(net,net.b,net.iw,net.lw)
%
%  See also SETWB, FORMWB, SEPARATEWB.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2.2.1 $ $Date: 2010/07/14 23:39:27 $

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

x = zeros(net.hint.xLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    x(inputWeightInd{i,j}) = net.IW{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    x(layerWeightInd{i,j}) = net.LW{i,j}(:);
  end
  if biasLearn(i)
    x(biasInd{i}) = net.b{i};
  end
end
