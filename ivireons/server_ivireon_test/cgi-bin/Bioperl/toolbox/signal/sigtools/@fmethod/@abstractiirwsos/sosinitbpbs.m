function [s,g] = sosinitbpbs(h,N,ai1,ai2,ai3,ai4,fog)
%SOSINITBPBS   Initialize SOS matrix and scalevals vector for
%              bandpass/bandstop cases.

%   Author(s): R. Losada
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/10/16 06:42:45 $

% Order must be even
if rem(N,2),
    error(generatemsgid('invalidSpec'), 'Filter order must be even.');
end

% Initialize sos matrix
ms = N/2;
msf = 2*floor(N/4);
s = zeros(ms,6);
s(1:ms,1)=ones(ms,1);

% Initialize scale vals
g = ones(ms,1);

% Set leading coeff of denominators
s(1:ms,4) = ones(ms,1);

% Form SOS denominators from 4th-order section denom coeffs
M = [ones(msf/2,1),ai1,ai2,ai3,ai4];
for k = 1:2:msf-1,
    r = roots(M(ceil(k/2),:));
    p1 = poly(r(1:2));
    p2 = poly(r(3:4));
    s(k,5:6) = p1(2:3);
    s(k+1,5:6) = p2(2:3);
end

% Compute sos gains from 4th-order gains
sfog = sqrt(fog); % Split fog in two
sfogrep = [sfog sfog]; % Replicate for each sos
tsfogrep = sfogrep'; % Make replicated values columns
g(1:msf) = tsfogrep(:);


% [EOF]
