function net = nnt2rb(pr,w1,b1,w2,b2)
%NNT2RB Update NNT 2.0 radial basis network.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = nnt2rb(pr,w1,b1,w2,b2)
%
%  Description
%
%    NNT2RB(PR,W1,B1,W2,B2) takes these arguments,
%      PR - Rx2 matrix of min and max values for R input elements.
%      W1 - S1xR weight matrix.
%      B1 - S1x1 bias vector.
%      W2 - S2xS1 weight matrix.
%      B2 - S2x1 bias vector.
%    and returns a radial basis network.
%
%    Once a network has been updated it can be simulated, initialized,
%    adapted, or trained with SIM, INIT, ADAPT, and TRAIN.
%
%  See also NEWRB, NEWRBE, NEWGRNN, NEWPNN.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

% Check
if size(pr,2) ~= 2, nnerr.throw('PR must have two columns.'), end
if size(pr,1) ~= size(w1,2), nnerr.throw('PR and W1 sizes do not match.'), end
if size(w1,1) ~= size(b1,1), nnerr.throw('W1 and B1 sizes do not match.'), end
if size(b1,2) ~= 1, nnerr.throw('B1 must have one column.'), end
if size(w1,1) ~= size(w2,2), nnerr.throw('W1 and W2 sizes do not match.'), end
if size(w2,1) ~= size(b2,1), nnerr.throw('W2 and B2 sizes do not match.'), end
if size(b2,2) ~= 1, nnerr.throw('B2 must have one column.'), end

% Update
net = network(1,2,[1;1],[1;0],[0 0;1 0],[0 1],[0 1]);
net.inputs{1}.range = pr;
net.layers{1}.size = size(b1,1);
net.layers{2}.size = size(b2,1);
net.inputWeights{1,1}.weightFcn = 'dist';
net.layers{1}.netInputFcn = 'netprod';
net.layers{1}.transferFcn = 'radbas';
net.iw{1,1} = w1;
net.b{1} = b1;
net.lw{2,1} = w2;
net.b{2} = b2;
