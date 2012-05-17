function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Copyright  The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:48:56 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriphphbmin
    %#function fdfmethod.kaiserhphbmin
    %#function fdfmethod.elliphphalfbandmin
    %#function fdfmethod.butterhphalfbandmin
    %#function fdfmethod.iirhphalfbandeqripmin
    designobj.equiripple = 'fdfmethod.eqriphphbmin';
    designobj.kaiserwin  = 'fdfmethod.kaiserhphbmin';
    designobj.ellip      = 'fdfmethod.elliphphalfbandmin';
    designobj.butter     = 'fdfmethod.butterhphalfbandmin';
    designobj.iirlinphase = 'fdfmethod.iirhphalfbandeqripmin';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
