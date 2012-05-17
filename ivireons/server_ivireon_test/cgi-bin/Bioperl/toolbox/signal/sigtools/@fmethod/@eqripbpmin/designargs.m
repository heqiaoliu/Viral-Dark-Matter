function args = designargs(this, hspecs)
%DESIGNARGS   Return the inputs for the FIRPM design function.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/12/04 23:24:19 $

hs = copy(hspecs);

% Convert all units to linear for FIRPM.
dstop1 = convertmagunits(hs.Astop1, 'db', 'linear', 'stop');
dpass  = convertmagunits(hs.Apass,  'db', 'linear', 'pass');
dstop2 = convertmagunits(hs.Astop2, 'db', 'linear', 'stop');

% If transition widths are not equal, use the smallest one
TW1 = hs.Fpass1-hs.Fstop1;
TW2 = hs.Fstop2-hs.Fpass2;
if TW1<TW2,
    hs.Fstop2 = hs.Fpass2+TW1;
elseif TW1>TW2,
    hs.Fstop1 = hs.Fpass1-TW2;
end

F = [hs.Fstop1 hs.Fpass1 hs.Fpass2 hs.Fstop2];
R = [dstop1 dpass dstop2];

args = firpmord(F, [0 1 0], R, 2, 'cell');

% Test that the spec is met. firpmord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
% Notice that although we may have changed the transition widths so that
% they are symmetrical, we still compare if specs are met with respect to
% the original asymmetric specs kept in hspecs
args = postprocessminorderargs(this,args,hspecs);

% [EOF]
