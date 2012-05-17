function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:02:29 $

%#function fdfmethod.butternotchbw

designobj.butter = 'fdfmethod.buttercombbw';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
