function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/10/14 16:28:22 $

%#function fdfmethod.eqripdiffminmb
designobj.equiripple = 'fdfmethod.eqripdiffminmb';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
