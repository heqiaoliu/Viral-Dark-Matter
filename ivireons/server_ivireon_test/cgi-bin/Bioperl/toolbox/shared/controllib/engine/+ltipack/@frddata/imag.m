function D = imag(D)
% Computes imaginary part of frequency response (including delays).

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:29 $
D = elimDelay(D);
D.Response = imag(D.Response);
