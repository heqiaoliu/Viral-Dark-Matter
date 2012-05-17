function [f,g]=filtfun(xfree,x,xmask,n,h,maxbin)
%FILTFUN Returns frequency response and roots for DFILDEMO.

%   Copyright 1990-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/08/03 21:31:46 $

x(xmask)  = xfree;
h2=abs(freqz(x(1:n), x(n+1:2*n), 128));
f= h2 - h;     
% Make sure its stable
g=[abs(roots(x(n+1:2*n)))-1];
