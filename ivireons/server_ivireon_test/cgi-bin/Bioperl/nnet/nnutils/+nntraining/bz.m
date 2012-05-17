function bz = bz(net,Q)
%CALCBZ Calculate batch of biases

% Copyright 2010 The MathWorks, Inc.

bz = cell(net.numLayers,1);
ones1xQ = ones(1,Q);
for i = net.hint.biasConnectTo
  bz{i} = net.b{i}(:,ones1xQ);
end
