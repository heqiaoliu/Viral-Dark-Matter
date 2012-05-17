function args = designargs(this, hspecs)
%DESIGNARGS   Return a cell of inputs to pass to FIR1.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2008/06/13 15:30:11 $

F = [hspecs.Fstop hspecs.Fpass];
A = [convertmagunits(hspecs.Astop, 'db', 'linear', 'stop') ...
     convertmagunits(hspecs.Apass, 'db', 'linear', 'pass')];

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord(F, [0 1], A);

% Test that the spec is met. kaiserord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
args = postprocessargs(this,hspecs,N,Wn,TYPE,BETA);

% [EOF]
