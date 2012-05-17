function a = competsl(n)
%COMPETSL Competitive transfer function used by SIMULINK.
%
% Obsoleted in R2010b NNET 7.0.  Last used in R2010a NNET 6.0.4.
%
%  Syntax
%
%    a = competsl(n)
%
%  Warning!!
%
%    This function may be altered or removed in future
%    releases of the Neural Network Toolbox. We recommend
%    you do not write code which calls this function.

% Mark Beale, 11-31-97
% Copyright 1992-2010 The MathWorks, Inc.
% $Revision: 1.1.8.1 $

[maxn,indn] = max(n,[],1);
a = zeros(size(n));
a(indn) = 1;
