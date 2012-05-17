function N = modifyord(this,N)
%MODIFYORD   

%   Author(s): R. Losada
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:54:11 $

% For allpass structures, order must be forced to the next odd number
N = lphpmodifyord(this,N);

% [EOF]
