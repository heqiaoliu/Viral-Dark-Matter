function args = designargs(this, hs)
%DESIGNARGS   Return the design inputs.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/06/16 08:44:49 $

N = get(hs, 'FilterOrder');

args = {N, [0 hs.Fstop hs.Fpass 1], [0 0 1 1], [this.Wstop this.Wpass]};

% If the filter order requested is odd, we need to append 'h' to design a
% hilbert transformer and avoid erroring.
if rem(N, 2) == 1
    args{end+1} = 'h';
end

% [EOF]
