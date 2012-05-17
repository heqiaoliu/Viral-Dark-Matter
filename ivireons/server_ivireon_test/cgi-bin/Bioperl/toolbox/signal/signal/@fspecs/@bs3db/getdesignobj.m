function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:48:21 $

%#function fmethod.butterbs
designobj.butter = 'fmethod.butterbs';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
