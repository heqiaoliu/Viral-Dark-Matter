function net=setwb(net,x)
%SETWB Set all network weight and bias values with a single vector.
%
%  <a href="matlab:doc setwb">setwb</a>(NET,WB) returns a network NET after setting its bias and
%  weight values from a single vector of values.
%
%  Here a feed forward network is configured for some data, then its
%  bias and weight values replaced with zeros.
%  
%    [x,t] = <a href="matlab:doc simplefit_dataset">simplefit_dataset</a>;
%    net = <a href="matlab:doc feedforwardnet">feedforwardnet</a>(10);
%    net = <a href="matlab:doc configure">configure</a>(net,x,t);
%    net = <a href="matlab:doc setwb">setwb</a>(net,zeros(1,net.numWeightElements));
%
%  See also GETWB, FORMWB, SEPARATEWB.

% Mark Beale, 11-31-97
% Mark Beale, Updated help, 5-25-98
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.10.2.2.1 $ $Date: 2010/07/14 23:39:33 $

% Shortcuts
inputLearn = net.hint.inputLearn;
layerLearn = net.hint.layerLearn;
biasLearn = net.hint.biasLearn;
inputWeightInd = net.hint.inputWeightInd;
layerWeightInd = net.hint.layerWeightInd;
biasInd = net.hint.biasInd;

for i=1:net.numLayers
  for j=find(inputLearn(i,:))
    net.IW{i,j}(:) = x(inputWeightInd{i,j});
  end
  for j=find(layerLearn(i,:))
    net.LW{i,j}(:) = x(layerWeightInd{i,j});
  end
  if biasLearn(i)
    net.b{i}(:) = x(biasInd{i});
  end
end
