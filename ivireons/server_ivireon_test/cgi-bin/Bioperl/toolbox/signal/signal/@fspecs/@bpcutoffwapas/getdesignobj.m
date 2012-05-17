function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2006/06/27 23:36:24 $
  
%#function fdfmethod.ellipbpcutoffwapas
designobj.ellip = 'fdfmethod.ellipbpcutoffwapas';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
