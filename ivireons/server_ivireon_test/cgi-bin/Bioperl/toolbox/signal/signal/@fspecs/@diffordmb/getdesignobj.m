function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:59:45 $

%#function fmethod.firlsdiffordmb
designobj.firls = 'fmethod.firlsdiffordmb';

if isfdtbxinstalled
   %#function fdfmethod.eqripdiffordmb
    designobj.equiripple = 'fdfmethod.eqripdiffordmb';
else
   %#function fmethod.eqripdiffordmb
    designobj.equiripple = 'fmethod.eqripdiffordmb';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
