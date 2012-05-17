function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:59:44 $

%#function fmethod.firlsdifford
designobj.firls = 'fmethod.firlsdifford';

if isfdtbxinstalled
   %#function fdfmethod.eqripdifford
    designobj.equiripple = 'fdfmethod.eqripdifford';
else
   %#function fmethod.eqripdifford
    designobj.equiripple = 'fmethod.eqripdifford';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
