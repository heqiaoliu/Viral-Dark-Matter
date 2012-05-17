function N = lphpmodifyord(this,N)
%LPHPMODIFYORD   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:46:47 $


% For allpass structures, order must be odd
if rem(N,2) == 0, N = N + 1; end

% [EOF]
