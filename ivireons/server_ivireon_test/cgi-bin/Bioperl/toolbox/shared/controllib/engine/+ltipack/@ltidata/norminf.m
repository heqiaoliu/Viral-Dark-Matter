function [gpeak,fpeak] = norminf(D,tol)
% Compute the peak gain of the frequency response

%   Copyright 1986-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:23 $
[gpeak,fpeak] = norminf(ss(D),tol);