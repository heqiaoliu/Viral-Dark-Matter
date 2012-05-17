function linkout = trainbr_performfcn_sse
%Training function TRAINBR requires the performance function be SSE.
%
%  Bayesian regularization assumes a performance function of SSE.
%  TRAINBR, will set NET.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> to MSE (Mean Squared Error), if
%  its originally value was not SSE.
%
%    net.<a href="matlab:doc nnproperty.net_performFcn">performFcn</a> = 'sse'.
%
%  The training function is then able to update the network
%  according to performance.
%  
%  See also SSE, TRAINBR

% Copyright 2010 The MathWorks, Inc.

link = nnlink.warning_link('NET.performFcn has been set to SSE.',mfilename);
if nargout == 0, disp(link); else linkout = link; end
