function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/10/14 16:29:19 $

%#function fmethod.freqsamparbmag
%#function fmethod.firlssbarbmag
designobj.freqsamp = 'fmethod.freqsamparbmag';
designobj.firls = 'fmethod.firlssbarbmag';
if isfdtbxinstalled
    %#function fdfmethod.eqripsbarbmag
    designobj.equiripple = 'fdfmethod.eqripsbarbmag';
    if all(this.Frequencies>=0),
        %#function fdfmethod.lpnormsbarbmag1
        designobj.iirlpnorm = 'fdfmethod.lpnormsbarbmag1';
    end
else
    %#function fmethod.eqripsbarbmag
    designobj.equiripple = 'fmethod.eqripsbarbmag';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
