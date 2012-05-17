function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2006/10/18 03:26:02 $

%#function fdfmethod.cheby1notchbw

designobj.cheby1 = 'fdfmethod.cheby1notchbw';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
