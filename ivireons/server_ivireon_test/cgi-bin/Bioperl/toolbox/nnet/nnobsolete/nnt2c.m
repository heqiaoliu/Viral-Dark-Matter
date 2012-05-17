function net = nnt2c(pr,w,klr,clr)
%NNT2C Update NNT 2.0 competitive layer.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    net = nnt2c(pr,w,klr,clr)
%
%  Description
%
%    NNT2C(PR,W,KLR,CLR) takes these arguments,
%      PR  - Rx2 matrix of min and max values for R input elements.
%      W   - SxR weight matrix.
%      KLR - Kohonen learning rate, default = 0.01.
%      CLR - Conscience learning rate, default = 0.001.
%    and returns a competitive layer.
%
%    Once a network has been updated it can be simulated, initialized
%    adapted, or trained with SIM, INIT, ADAPT, and TRAIN.
%    
%  See also NEWC.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

% Check
if nargin < 2, nnerr.throw('Not enough input arguments.'), end
if size(pr,1) ~= size(w,2), nnerr.throw('PR and W sizes do not match.'), end
if size(pr,2) ~= 2, nnerr.throw('PR must have two columns.'), end

% Defaults
if nargin < 3, klr = 0.01; end
if nargin < 4, clr = 0.001; end

% Update
net = newc(pr,size(w,1),klr,clr);
net.iw{1,1} = w;
net.b{1} = initcon(size(w,1));
