function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/05/09 23:45:16 $

designobj.lagrange = 'fdfmethod.lagrange';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
