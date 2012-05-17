function fb = bandwidth(D,drop)
% Bandwidth of state-space models.

%   Author(s): P. Gahinet 
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:43 $

% Tolerance for jw-axis mode detection
toljw1 = 100 * eps;       % for simple roots
toljw2 = 10 * sqrt(eps);  % for double root

% Compute DC gain
dc = dcgain(D);
if isinf(dc)
   fb = NaN;   return
elseif dc==0
   % Set to Inf using the definition: how long gain > dc - drop
   fb = Inf;  return
elseif isnan(getIODelay(D))
   % Internal delays -> use interpolation
   [mag,junk,w] = freqresp(D,4,[],false);
   fb = bandwidth(frd([abs(dc) ; mag],[0 ; w],0),drop);
   return
end

% Crossover gain value
gcross = abs(dc) * 10^(drop/20);

% Compute crossover frequency
[a,b,c,d,e] = getABCDE(D);

% Normalization to gcross=1
d = d/gcross;
b = b/gcross;

% Form related Hamiltonian/symplectic pencil (for gamma=1)
if ~any(b) || ~any(c),
    % Static gain
    fb = Inf;  return
elseif D.Ts~=0
    % Discrete-time
    heigs = speig(a,b,c,d,e);
    mag = abs(heigs);
    % Detect unit-circle eigs
    uceig = heigs(abs(1-mag) < toljw2+toljw1*max(mag));
    f = abs(angle(uceig))/abs(D.Ts);
else
    % Continuous-time
    heigs = hpeig(a,b,c,d,e);
    mag = abs(heigs);
    % Detect jw-axis eigs
    jweig = heigs(abs(real(heigs)) < toljw2*(1+mag)+toljw1*max(mag));
    f = abs(imag(jweig));
end

% Evaluate gain at candidate frequencies
% RE: Needed because nonminimal modes may introduce parasitic jw-axis eigs
%     e.g., sys = tf([2 0 2],[1 -2 1 -2])
g = abs(fresp(D,f));
fb = min(f(abs(g(:)-gcross)<0.01*gcross));
if isempty(fb)
    % No crossing -> bandwidth = Inf (assuming no numerical problem with eigs)
    fb = Inf;
end



