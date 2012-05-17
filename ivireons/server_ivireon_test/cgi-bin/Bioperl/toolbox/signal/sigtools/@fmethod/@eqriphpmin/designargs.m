function args = designargs(this, hs)
%DESIGNARGS   Return the inputs for the FIRPM design function.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/06/13 15:30:03 $

dstop = convertmagunits(hs.Astop, 'db', 'linear', 'stop');
dpass = convertmagunits(hs.Apass, 'db', 'linear', 'pass');

F = [hs.Fstop hs.Fpass];
A = [0 1];
R = [dstop dpass];

args = firpmord(F, A, R, 2, 'cell');

% Test that the spec is met. firpmord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
args = postprocessminorderargs(this,args,hs);

% [EOF]
