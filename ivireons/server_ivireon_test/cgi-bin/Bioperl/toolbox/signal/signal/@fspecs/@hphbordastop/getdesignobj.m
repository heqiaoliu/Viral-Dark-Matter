function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:49:01 $

if isfdtbxinstalled
    
    %#function fdfmethod.kaiserhphbastop
    %#function fdfmethod.eqriphphbastop
    %#function fdfmethod.elliphphalfbandastop
    %#function fdfmethod.iirhphalfbandeqripastop
    designobj.kaiserwin  = 'fdfmethod.kaiserhphbastop';
    designobj.equiripple = 'fdfmethod.eqriphphbastop';
    designobj.ellip      = 'fdfmethod.elliphphalfbandastop';
    designobj.iirlinphase = 'fdfmethod.iirhphalfbandeqripastop';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
