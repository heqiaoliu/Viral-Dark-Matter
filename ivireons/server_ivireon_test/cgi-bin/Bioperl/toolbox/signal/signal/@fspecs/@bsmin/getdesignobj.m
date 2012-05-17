function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:48:27 $


%#function fmethod.butterbsmin
%#function fmethod.cheby1bsmin
%#function fmethod.cheby2bsmin
%#function fmethod.ellipbsmin
designobj.butter     = 'fmethod.butterbsmin';
designobj.cheby1     = 'fmethod.cheby1bsmin';
designobj.cheby2     = 'fmethod.cheby2bsmin';
designobj.ellip      = 'fmethod.ellipbsmin';

if isfdtbxinstalled
    %#function fdfmethod.eqripbsmin
    designobj.equiripple = 'fdfmethod.eqripbsmin';
else
    %#function fmethod.eqripbsmin
    designobj.equiripple = 'fmethod.eqripbsmin';
end


%#function fmethod.kaiserbsmin
designobj.kaiserwin  = 'fmethod.kaiserbsmin';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
