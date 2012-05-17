function net = narx2sp(net)
%NARX2SP Convert a parallel NARX network to series-parallel (feed-forward) form.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = narx2sp(NET)
%
%  Description
%
%    NARX2SP(NET) takes,
%      NET - Original NARX network in parallel (feedback) form
%    and returns an NARX network in series-parallel (feed-forward) form.
%
%  Examples
%
%    Here a parallel narx network is created.  The network's input ranges
%    from [-1 to 1].  The first layer has five TANSIG neurons, the
%    second layer has one PURELIN neuron.  The TRAINLM network
%    training function is to be used.
%
%      net = newnarx({[-1 1] [-1 1]},[1 2],[1 2],[5 1],{'tansig' 'purelin'});
%
%    Here the network is converted from parallel to series parallel narx.
%
%       net2 = narx2sp(net);
%
%  See also NEWNARXSP, NEWNARX

% Orlando De Jesús, Martin Hagan, 7-20-05
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

if nargin < 1, nnerr.throw('Not enough input arguments'), end

% 2nd input connection replaces feedback connection
Nl = net.numLayers;
net.numInputs = 2;
net.inputConnect(1,2) = 1;
net.inputWeights(1,Nl).delays = net.inptWeights{1,2}.delays;
net.IW{1,2} = net.LW{1,Nl};
net.layerConnect(1,Nl) = 0;

