function Dfrd = frd(D,freqs,units)
% Converts to FRD

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:11 $

% Compute frequency response, keeping I/O delays separate to get correct
% phase shift in Bode plots and PID tuning
Delay = D.Delay;
[ny,nu] = iosize(D);
D.Delay = ltipack.utDelayStruct(ny,nu,false);
Dfrd = ltipack.frddata(fresp(D,unitconv(freqs,units,'rad/s')),freqs,D.Ts);
Dfrd.FreqUnits = units;
Dfrd.Delay = Delay;
