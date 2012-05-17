function args = designargs(this, hs)
%DESIGNARGS   

%   Author(s): J. Schickler
%   Copyright 1999-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/12/26 22:19:41 $

args = {hs.FilterOrder, [0 hs.Fpass hs.Fstop 1], [1 1 0 0], [this.Wpass this.Wstop]};

% [EOF]
