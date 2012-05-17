function wb = formwb(net,b,iw,lw)
%FORMWB Form bias and weights into single vector.
%
%  <a href="matlab:doc formwb">formwb</a>(NET,B,IW,LW) takes a network NET, bias vectors B, input weights
%  IW and layer weights LW and forms the biases and weights into a single
%  vector.
%
%  Here a feed forward network is trained to fit some data, then its
%  bias and weight values formed into a vector.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc train">train</a>(net,x,t);
%    wb = <a href="matlab:doc formwb">formwb</a>(net,net.b,net.iw,net.lw)
%
%  See also GETWB, SETWB, SEPARATEWB.

% Mark Beale, Created from FORMGX, 5-25-98
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2.2.1 $  $Date: 2010/07/14 23:39:25 $

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

wb = zeros(net.hint.xLen,1);
for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    wb(inputWeightInd{i,j}) = iw{i,j}(:);
  end
  for j=find(layerLearn(i,:))
    wb(layerWeightInd{i,j}) = lw{i,j}(:);
  end
  if biasLearn(i)
    wb(biasInd{i}) = b{i}(:);
  end
end
