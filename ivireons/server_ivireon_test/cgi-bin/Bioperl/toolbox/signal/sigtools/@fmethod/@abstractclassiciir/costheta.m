function [cs,theta] = costheta(h,N)
% Compute cosine of angles of stable poles.
% Used for butterworth, cheby1 and cheby2.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/12/26 22:19:18 $


k = (1:floor(N/2)).';
theta = pi/(2*N)*(N-1+2*k);

cs = cos(theta);
