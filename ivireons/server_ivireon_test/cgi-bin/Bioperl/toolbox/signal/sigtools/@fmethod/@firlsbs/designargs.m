function args = designargs(this, hs)
%DESIGNARGS   Returns the inputs to the design function.

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:19:45 $

args = {hs.FilterOrder, [0 hs.Fpass1 hs.Fstop1 hs.Fstop2 hs.Fpass2 1], ...
    [1 1 0 0 1 1], [this.Wpass1 this.Wstop this.Wpass2]};

% [EOF]
