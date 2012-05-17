function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:19:43 $

args = {hs.FilterOrder, [0 hs.Fstop1 hs.Fpass1 hs.Fpass2 hs.Fstop2 1], ...
    [0 0 1 1 0 0], [this.Wstop1 this.Wpass this.Wstop2]};

% [EOF]
