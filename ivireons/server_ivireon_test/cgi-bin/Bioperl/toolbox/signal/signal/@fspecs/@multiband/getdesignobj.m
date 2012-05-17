function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/10/14 16:29:13 $

%#function fmethod.firlsmultiband
designobj.firls = 'fmethod.firlsmultiband';

if isfdtbxinstalled
    
    %#function fdfmethod.eqripmultiband
    designobj.equiripple = 'fdfmethod.eqripmultiband';
    [F, A] = getmask(this);
    if all(F>=0),
        %#function fdfmethod.lpnormmultiband1
        designobj.iirlpnorm = 'fdfmethod.lpnormmultiband1';
    end
else
    
    %#function fmethod.eqripmultiband
    designobj.equiripple = 'fmethod.eqripmultiband';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
