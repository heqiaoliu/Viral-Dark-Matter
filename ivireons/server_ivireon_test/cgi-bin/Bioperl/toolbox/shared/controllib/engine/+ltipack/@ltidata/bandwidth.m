function [fb,NaNflag] = bandwidth(D,drop)
% Bandwidth of LTI models (default algorithm, adapted from ALLMARGIN).

%   Author(s): P. Gahinet 
%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:10 $
NaNflag = false;
rtol = 1e-3;  % relative accuracy on computed crossings/margins

% Compute DC gain
dc = dcgain(D);
if isinf(dc)
   fb = NaN;   NaNflag=true;   return
elseif dc==0
   % Set to Inf using the definition: how long gain > dc - drop
   fb = Inf;  return
end

% Computes poles and zeros
[z,p,k] = iodynamics(D);
Ts = abs(D.Ts);

% Crossover gain value
gcross = abs(dc) * 10^(drop/20);
k = k/gcross;  % Normalize to reduce problem to finding 0dB crossings

% Cancel allpass pole/zero pairs (for better convergence)
[z,p] = cancelzp(z{1},p{1},Ts,rtol);

% Compute 0dB gain crossings
if isempty(z) && isempty(p)
   % Allpass system
   fb = Inf;
else
   if Ts==0,
      fb = min(gaincross(z,p,k,rtol));
   else
      fb = min(dgaincross(z,p,k,Ts,rtol));
   end
   if isempty(fb)
      fb = Inf;
   end
end
