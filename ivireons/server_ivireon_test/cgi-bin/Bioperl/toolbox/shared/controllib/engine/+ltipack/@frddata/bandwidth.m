function fb = bandwidth(D,drop)
% Bandwidth of FRD models.
% Note: Assumes first frequency point is a good approximation of DC mag

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:29:13 $
mag = abs(D.Response(:));
w = D.Frequency;

% Crossover mag value
gcross = mag(1) * 10^(drop/20);

% Find first crossing and interpolate
idx = find(mag<gcross,1);
if isempty(idx)
   fb = Inf;
else
   if mag(idx)>0
      % log-based interp
      t = log(gcross/mag(idx))/log(mag(idx-1)/mag(idx));
      fb = w(idx) * (w(idx-1)/w(idx))^t;
   else
      % linear interp
      % bandwidth(frd(tf([1 0 1],[1 2 3]),logspace(-2,2,5)))
      t = (gcross-mag(idx))/(mag(idx-1)-mag(idx));
      fb = w(idx) * (w(idx-1)/w(idx))^t;
   end
   fb = unitconv(fb,D.FreqUnits,'rad/s');
end
