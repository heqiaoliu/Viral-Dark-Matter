function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/10/23 18:48:28 $

%#function fmethod.cheby1bs
designobj.cheby1 = 'fmethod.cheby1bs';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
