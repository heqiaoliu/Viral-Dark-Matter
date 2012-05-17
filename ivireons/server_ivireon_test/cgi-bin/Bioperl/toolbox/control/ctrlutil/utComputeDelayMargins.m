function [Dm,Wcp] = utComputeDelayMargins(Pm,Wcp,Ts,Td,rtol)
% Utility to calculate delay margins
% Pm is in rads
% Wcp is in rad/s
% Ts is sample time
% Td is total delay
% rtol is relative accuracy on computed crossings/margins

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:48:35 $

if nargin < 5
    rtol = 0;
end

% Delay margins: contributions from jw-axis or unit circle
Dm = zeros(size(Pm));
posf = (Wcp>0);
Dm(:,~posf) = Inf;
Dm(:,~posf & abs(Pm)<rtol) = 0;   % for Pm=0 at wc0=0
Dm(:,posf) = Pm(:,posf) ./ Wcp(:,posf);  % where wc0>0...
acausal = (posf & Pm<-Td*Wcp-rtol);  % allow for roundoff
Dm(:,acausal) = Dm(:,acausal) + 2*pi./Wcp(:,acausal);  % enforce Dm>=-Td
Dm(:,~acausal) = max(-Td,Dm(:,~acausal));
if Ts
   % Express Dm has a (fractional) multiple of the sample period
   Dm = Dm/Ts;
end

