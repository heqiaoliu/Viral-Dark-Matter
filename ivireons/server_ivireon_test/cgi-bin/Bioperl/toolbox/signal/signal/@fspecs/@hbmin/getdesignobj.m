function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2005/10/14 16:28:27 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriphbmin
    %#function fdfmethod.kaiserhbmin
    %#function fdfmethod.elliphalfbandmin
    %#function fdfmethod.butterhalfbandmin
    %#function fdfmethod.iirhalfbandeqripmin
    designobj.equiripple = 'fdfmethod.eqriphbmin';
    designobj.kaiserwin  = 'fdfmethod.kaiserhbmin';
    designobj.ellip      = 'fdfmethod.elliphalfbandmin';
    designobj.butter     = 'fdfmethod.butterhalfbandmin';
    designobj.iirlinphase = 'fdfmethod.iirhalfbandeqripmin';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
