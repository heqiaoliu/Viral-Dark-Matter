function t=pre_targets(net,t,fcns)
%PROCESSTARGETS Applies a network's preprocessing settings to target values
%
% Syntax
%   
%   t2 = nnproc.pre_targets(net,t1)
%
% Description
%
%   PROCESSTARGETS(net,t1) takes a network and target values (either a
%   matrix or a cell array of matrices) and returns those values after
%   applying the network's preprocessing settings.
%
%   If T is a cell array, it may have as many rows as network targets,
%   or as many rows as network layers.

% Copyright 2007-2010 The MathWorks, Inc.

ismatrix = isnumeric(t);
if ismatrix, t = {t}; end

rows = size(t,1);
compact = (rows == net.numOutputs);
output2layer = find(net.outputConnect);
  
if compact
  % A has as many rows as targets
  for i=1:net.numOutputs
    t(i,:) = nnproc.forward(fcns.outputs(i).process,t(i,:));
  end
else
  % A has as many rows as layers
  for i=1:net.numOutputs
    j = output2layer(i);
    t(j,:) = nnproc.forward(fcns.outputs(i).process,t(j,:));
  end
end

if ismatrix, t = t{1}; end
