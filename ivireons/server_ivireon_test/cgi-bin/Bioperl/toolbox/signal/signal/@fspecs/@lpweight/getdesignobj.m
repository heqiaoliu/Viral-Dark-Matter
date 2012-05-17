function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/10/14 16:29:12 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriplp
    %#function fdfmethod.lpnormlp1
    designobj.equiripple = 'fdfmethod.eqriplp';
    designobj.iirlpnorm  = 'fdfmethod.lpnormlp1';
else
    
    %#function fmethod.eqriplp
    designobj.equiripple = 'fmethod.eqriplp';
end

%#function fmethod.firlslp
designobj.firls = 'fmethod.firlslp';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
