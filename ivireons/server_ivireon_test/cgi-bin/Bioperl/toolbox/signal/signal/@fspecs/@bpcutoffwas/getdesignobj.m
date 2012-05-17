function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/10/23 18:48:12 $

%#function fmethod.cheby2bp
designobj.cheby2 = 'fmethod.cheby2bp';

if isfdtbxinstalled
    %#function fdfmethod.ellipbpcutoffwas
    designobj.ellip  = 'fdfmethod.ellipbpcutoffwas';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
