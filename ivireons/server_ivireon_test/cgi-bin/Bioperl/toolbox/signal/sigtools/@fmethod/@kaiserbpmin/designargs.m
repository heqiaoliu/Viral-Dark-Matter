function args = designargs(this, hs)
%DESIGNARGS   Return a cell of inputs to pass to FIR1.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/12/04 23:24:29 $

hspecs = copy(hs);

% If transition widths are not equal, use the smallest one
TW1 = hspecs.Fpass1-hspecs.Fstop1;
TW2 = hspecs.Fstop2-hspecs.Fpass2;
if TW1<TW2,
    hspecs.Fstop2 = hspecs.Fpass2+TW1;
elseif TW1>TW2,
    hspecs.Fstop1 = hspecs.Fpass1-TW2;
end

F = [hspecs.Fstop1 hspecs.Fpass1 hspecs.Fpass2 hspecs.Fstop2];

A = [convertmagunits(hspecs.Astop1, 'db', 'linear', 'stop') ...
     convertmagunits(hspecs.Apass, 'db', 'linear', 'pass') ...
     convertmagunits(hspecs.Astop2, 'db', 'linear', 'stop')];

% Calculate the order from the parameters using KAISERORD.
[N,Wn,BETA,TYPE] = kaiserord(F, [0 1 0], A);

% Test that the spec is met. kaiserord sometimes under estimate the order
% e.g. when the transition band is near f = 0 or f = fs/2.
% Notice that although we may have changed the transition widths so that
% they are symmetrical, we still compare if specs are met with respect to
% the original asymmetric specs kept in hs.
args = postprocessargs(this,hs,N,Wn,TYPE,BETA);

% [EOF]
