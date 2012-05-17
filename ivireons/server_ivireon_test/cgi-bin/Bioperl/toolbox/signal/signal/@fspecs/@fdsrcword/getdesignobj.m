function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/11/17 22:44:30 $

designobj.lagrange = 'fdfmethod.lagrangesrc';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
