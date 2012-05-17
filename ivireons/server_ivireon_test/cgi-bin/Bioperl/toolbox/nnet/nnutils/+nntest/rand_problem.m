function [net,x,xi,ai,t,seed] = rand_problem(net,seed)
%RAND_PROBLEM Random network/data problem

% Copyright 2010 The MathWorks, Inc.

if nargin < 1, nnerr.throw('Not enough input arguments.'); end

% Seed & Network
if (nargin == 1)
  seed = net;
  net = nntest.rand_net(seed);
end

% Data
[x,t] = nntest.rand_data(seed);

% Configure
net = configure(net,x,t);

% Prepare Data
[x,xi,ai,t] = preparets(net,x,t);
if rand < 0.01
  for i=1:numel(ai)
    ind = find(~isfinite(ai{i}));
    ai{i}(ind) = rands(1,numel(ind));
  end
end

% TODO Generate EW, train/val/ind masks
