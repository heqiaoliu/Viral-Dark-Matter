function net = nnt2lin(pr,w,b,lr)
%NNT2LIN Update NNT 2.0 linear layer.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = nnt2lin(pr,w,b,lr)
%
%  Description
%
%    NNT2LIN(PR,W,B) takes these arguments,
%      PR - Rx2 matrix of min and max values for R input elements.
%      W  - SxR weight matrix.
%      B  - Sx1 bias vector
%      LR - Learning rate, default = 0.01;
%    and returns a linear layer.
%
%    Once a network has been updated it can be simulated, initialized,
%    adapted, or trained with SIM, INIT, ADAPT, and TRAIN.
%
%  See also NEWLIN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

% Check
if size(pr,1) ~= size(w,2), nnerr.throw('PR and W sizes do not match.'), end
if size(pr,2) ~= 2, nnerr.throw('PR must have two columns.'), end
if size(w,1) ~= size(b,1), nnerr.throw('W and B sizes do not match.'), end
if size(b,2) ~= 1, nnerr.throw('B must have one column.'), end

% Defaults
if nargin < 4, lr = 0.01; end

% Update
net = newlin(pr,length(b),[0],lr);
net.iw{1,1} = w;
net.b{1} = b;
