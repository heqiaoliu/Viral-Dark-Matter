function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/10/31 07:02:22 $

%#function fmethod.eqripbp
%#function fmethod.firlsbp
designobj.equiripple = 'fmethod.eqripbp';
designobj.firls      = 'fmethod.firlsbp';

if isfdtbxinstalled
    %#function fdfmethod.lpnormbp1
    designobj.iirlpnorm  = 'fdfmethod.lpnormbp1';
    %#function fdfmethod.eqripbp
    designobj.equiripple = 'fdfmethod.eqripbp';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
