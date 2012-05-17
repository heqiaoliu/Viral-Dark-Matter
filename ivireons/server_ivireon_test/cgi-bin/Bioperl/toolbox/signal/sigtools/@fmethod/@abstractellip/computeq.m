function [q,k] = computeq(h,Wp);
%COMPUTEQ   

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2004/12/26 22:19:29 $

Ws = 1/Wp;
k = Wp/Ws;

k1 = sqrt(1 - k^2);
q0 = 0.5*(1 - sqrt(k1))/(1 + sqrt(k1));
q = q0 + 2*q0^5 + 15*q0^9 + 150*q0^13;

% [EOF]
