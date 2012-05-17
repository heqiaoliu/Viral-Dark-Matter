function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2007/10/23 18:49:16 $

%#function fmethod.cheby2lp
designobj.cheby2 = 'fmethod.cheby2lp';

if isfdtbxinstalled
    %#function fdfmethod.elliplpcutoffwas
    designobj.ellip  = 'fdfmethod.elliplpcutoffwas';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
