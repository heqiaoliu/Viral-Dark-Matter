function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/31 07:02:24 $

%#function fmethod.eqripbs
%#function fmethod.firlsbs
designobj.equiripple = 'fmethod.eqripbs';
designobj.firls      = 'fmethod.firlsbs';

if isfdtbxinstalled
    %#function fdfmethod.lpnormbs1
    designobj.iirlpnorm  = 'fdfmethod.lpnormbs1';
    %#function fdfmethod.eqripbs
    designobj.equiripple = 'fdfmethod.eqripbs';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
