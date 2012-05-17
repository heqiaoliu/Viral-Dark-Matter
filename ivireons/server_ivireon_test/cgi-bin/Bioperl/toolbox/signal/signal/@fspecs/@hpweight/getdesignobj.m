function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/10/31 07:02:56 $

%#function fmethod.eqriphp
designobj.equiripple = 'fmethod.eqriphp';
%#function fmethod.firlshp
designobj.firls      = 'fmethod.firlshp';

if isfdtbxinstalled
    %#function fdfmethod.lpnormhp1
    designobj.iirlpnorm = 'fdfmethod.lpnormhp1';
    %#function fdfmethod.eqriphp
    designobj.equiripple = 'fdfmethod.eqriphp';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
