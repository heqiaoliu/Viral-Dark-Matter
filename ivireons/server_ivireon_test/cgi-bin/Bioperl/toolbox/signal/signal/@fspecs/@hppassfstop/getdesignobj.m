function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2007/10/23 18:49:09 $

designobj = [];
if isfdtbxinstalled
    %#function fmethod.elliphpfstop
    %#function fdfmethod.eqriphpfstop
    designobj.ellip      = 'fmethod.elliphpfstop';
    designobj.equiripple = 'fdfmethod.eqriphpfstop';
    if nargin > 1
        designobj = designobj.(str);
    end
end


% [EOF]
