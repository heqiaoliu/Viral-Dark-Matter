function args = designargs(this, hs)
%DESIGNARGS   Returns a cell to be passed to the design function.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/06/13 15:30:05 $

dpass = convertmagunits(hs.Apass, 'db', 'linear', 'pass');
dstop = convertmagunits(hs.Astop, 'db', 'linear', 'stop');

F = [hs.Fpass hs.Fstop];
A = [1 0];
R = [dpass dstop];

args = firpmord(F, A, R, 2, 'cell');

% Test that the spec is met. firpmord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
args = postprocessminorderargs(this,args,hs);

% [EOF]
