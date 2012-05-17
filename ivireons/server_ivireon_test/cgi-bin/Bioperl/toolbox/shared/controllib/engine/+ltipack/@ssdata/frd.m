function Dfrd = frd(D,freqs,units)
% Converts to FRD

%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2010/02/08 22:47:39 $

% Compute frequency response, keeping I/O delays separate to get correct
% phase shift in Bode plots
Delay = D.Delay;
[ny,nu] = iosize(D);
D.Delay = ltipack.utDelayStruct(ny,nu,true);
D.Delay.Internal = Delay.Internal;
Dfrd = ltipack.frddata(fresp(D,unitconv(freqs,units,'rad/s')),freqs,D.Ts);
Dfrd.FreqUnits = units;
Dfrd.Delay = ltipack.utDelayStruct(ny,nu,false);
Dfrd.Delay.Input = Delay.Input;
Dfrd.Delay.Output = Delay.Output;
