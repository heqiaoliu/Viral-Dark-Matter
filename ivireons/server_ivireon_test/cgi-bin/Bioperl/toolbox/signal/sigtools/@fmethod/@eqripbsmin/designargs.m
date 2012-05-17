function args = designargs(this, hspecs)
%DESIGNARGS   Return the inputs for the FIRPM design function.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/12/04 23:24:22 $

hs = copy(hspecs);

dpass1 = convertmagunits(hs.Apass1, 'db', 'linear', 'pass');
dstop  = convertmagunits(hs.Astop,  'db', 'linear', 'stop');
dpass2 = convertmagunits(hs.Apass2, 'db', 'linear', 'pass');

% If transition widths are not equal, use the smallest one
TW1 = hs.Fstop1-hs.Fpass1;
TW2 = hs.Fpass2-hs.Fstop2;
if TW1<TW2,
    hs.Fstop2 = hs.Fpass2-TW1;
elseif TW1>TW2,
    hs.Fstop1 = hs.Fpass1+TW2;
end

F = [hs.Fpass1 hs.Fstop1 hs.Fstop2 hs.Fpass2];
R = [dpass1 dstop dpass2];

args = firpmord(F, [1 0 1], R, 2, 'cell');

% Test that the spec is met. firpmord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
% Notice that although we may have changed the transition widths so that
% they are symmetrical, we still compare if specs are met with respect to
% the original asymmetric specs kept in hspecs
args = postprocessminorderargs(this,args,hspecs);

% [EOF]
