function N = bpbsmodifyord(this,N)
%LPHPMODIFYORD   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:46:39 $


% For allpass structures, order must be twice an odd number
if rem(N,4) == 0, N = N + 2; end

% [EOF]
