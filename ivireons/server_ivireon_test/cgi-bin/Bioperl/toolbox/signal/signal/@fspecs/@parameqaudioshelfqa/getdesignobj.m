function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2009/01/20 15:35:54 $

%#function fdfmethod.ellipparameqaudioshelfqa

designobj.ellip = 'fdfmethod.ellipparameqaudioshelfqa';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
