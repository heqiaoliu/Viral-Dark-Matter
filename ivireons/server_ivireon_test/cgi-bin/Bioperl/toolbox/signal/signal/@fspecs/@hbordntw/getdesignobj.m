function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/10/23 18:48:46 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriphbordntw
    %#function fdfmethod.kaiserhbordntw
    %#function fdfmethod.firlshbordntw
    %#function fdfmethod.elliphalfbandfpass
    %#function fdfmethod.iirhalfbandeqripfpass
    designobj.equiripple  = 'fdfmethod.eqriphbordntw';
    designobj.kaiserwin   = 'fdfmethod.kaiserhbordntw';
    designobj.firls       = 'fdfmethod.firlshbordntw';
    designobj.ellip       = 'fdfmethod.elliphalfbandfpass';
    designobj.iirlinphase = 'fdfmethod.iirhalfbandeqripfpass';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
