function [s,g] = sosinitlphp(h,N)
%SOSINITLPHP   Initialize SOS matrix and scalevals vector for
%              lowpass/highpass cases.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:46 $

% Initialize sos matrix
ms = ceil(N/2);
msf = floor(N/2);
s = zeros(ms,6);
s(1:ms,1)=ones(ms,1);
s(1:msf,3)=ones(msf,1); % In case there is a first order section

% Initialize scale vals
g = ones(ms,1);

% Set leading coeff of denominators
s(1:ms,4) = ones(ms,1);


% [EOF]
