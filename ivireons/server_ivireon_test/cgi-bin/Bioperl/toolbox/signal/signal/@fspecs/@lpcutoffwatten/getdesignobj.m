function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/12 21:36:44 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriplpcutoff
    designobj.equiripple = 'fdfmethod.eqriplpcutoff';
else
    designobj = [];
end
%#function fmethod.firclslp
designobj.fircls = 'fmethod.firclslp';
if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
