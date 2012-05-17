function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:42 $

designobj.firls = 'fmethod.firlsmultibandarbmagnphase';
designobj.equiripple = 'fmethod.eqripmultibandarbmagnphase';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
