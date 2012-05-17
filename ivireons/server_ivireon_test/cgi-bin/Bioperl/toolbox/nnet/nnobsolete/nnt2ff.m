function net = nnt2ff(pr,w,b,tf,btf,blr,pf)
%NNT2FF Update NNT 2.0 feed-forward network.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = nnt2ff(pr,{w1 w2 ...},{b1 b2 ...},{tf1 tf2 ...},btf,blr,pf)
%
%  Description
%
%    NNT2FF(PR,{W1 W2 ...},{B1 B2 ...},{TF1 TF2 ...},BTF,BLR,PF) takes these arguments,
%      PR - Rx2 matrix of min and max values for R input elements.
%      Wi  - Weight matrix for the ith layer.
%      Bi  - Bias vector for the ith layer.
%      TFi - Transfer function of ith layer, default = 'tansig'.
%      BTF - Backprop network training function, default = 'traingdx'.
%      BLF - Backprop weight/bias learning function, default = 'learngdm'.
%      PF  - Performance function, default = 'mse'.
%    and returns a feed-forward network.
%
%    The training function BTF can be any of the backprop training
%    functions such as TRAINGD, TRAINGDM, TRAINGDA, TRAINGDX, or TRAINLM.
%
%    The learning function BLF can be either of the backpropagation
%    learning functions such as LEARNGD, or LEARNGDM.
%
%    The performance function can be any of the differentiable performance
%    functions such as MSE or MSEREG.
%
%    Once a network has been updated it can be simulated,
%    initialized, or trained with SIM, INIT, ADAPT, and TRAIN.
%
%  See also NEWFF, NEWCF, NEWFFTD, NEWELM.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

% Check
if nargin<3, nnerr.throw('Not enough input arguments.'), end
numLayers = length(w);
if length(b) ~= numLayers
  nnerr.throw('Must provide same number of biases as weights.')
end
if (nargin > 3) && (length(tf) ~= length(b))
  nnerr.throw('Must provide same number of transfer functions as weights and biases.')
end

% Defaults
if nargin < 4, tf = {'tansig'}; tf = [tf(ones(1,numLayers))]; end
if nargin < 5, btf = 'traingdx'; end
if nargin < 6, blr = 'learngdm'; end
if nargin < 7, pf = 'mse'; end

% Update
s = zeros(1,numLayers);
for i=1:numLayers
  s(i) = size(b{i},1);
end

ws = warning('off','NNET:Obsolete');
net = newff(pr,s,tf,btf,blr,pf);
warning(ws)

net.iw{1,1} = w{1};
for i=1:numLayers
  net.b{i} = b{i};
end
for i=2:numLayers
  net.lw{i,i-1} = w{i};
end

