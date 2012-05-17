function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:27:29 $

%#function fdfmethod.butterpeakq

designobj.butter = 'fdfmethod.butterpeakq';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
