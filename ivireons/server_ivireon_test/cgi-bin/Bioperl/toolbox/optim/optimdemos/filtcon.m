function [c,ceq]=filtcon(xfree,x,xmask,n,h,maxbin)
%FILTCON Returns roots for DFILDEMO.

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:31:45 $

x(xmask)  = xfree;
% Make sure its stable
c=[abs(roots(x(n+1:2*n)))-1];
ceq = [];
