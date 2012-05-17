function D = real(D)
% Computes real part of frequency response (including delays).

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:50 $
D = elimDelay(D);
D.Response = real(D.Response);
