function net = nn_delete_output(net,i)
%NN_DELETE_OUTPUT Delete input from network.

% Copyright 2010 The MathWorks, Inc.

if i > net.numLayers
  nnerr.throw('Output index is out of range.');
end
if ~net.outputConnect(i)
  nnerr.throw('Output index is for layer without an output.');
end

% Remove open or closed feedback connection
switch net.outputs{i}.feedbackMode
  case 'open', net = nn_feedback_open2none(net,i);
  case 'closed', net = nn_feedback_closed2none(net,i);
end

% Delete output
net.numOutputs = net.numOutputs - 1;
net.outputConnect(i) = false;
net.outputs{i} = [];
