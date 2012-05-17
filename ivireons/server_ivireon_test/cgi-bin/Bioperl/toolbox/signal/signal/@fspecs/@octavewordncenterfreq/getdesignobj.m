function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:30 $

designobj.butter = 'fdfmethod.butteroctave';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
