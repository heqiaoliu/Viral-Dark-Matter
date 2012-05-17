function args = designargs(this, hspecs)
%DESIGNARGS   Return a cell of inputs to pass to FIR1.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:30:14 $

F = [hspecs.Fpass hspecs.Fstop];
A = [convertmagunits(hspecs.Apass, 'db', 'linear', 'pass') ...
     convertmagunits(hspecs.Astop, 'db', 'linear', 'stop')];

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord(F, [1 0], A);

% Test that the spec is met. kaiserord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
args = postprocessargs(this,hspecs,N,Wn,TYPE,BETA);

% [EOF]
