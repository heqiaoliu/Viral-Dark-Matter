function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/05/12 21:36:41 $

if isfdtbxinstalled
    
    %#function fdfmethod.eqriphpcutoff
    designobj.equiripple = 'fdfmethod.eqriphpcutoff';
else
    designobj = [];
end
%#function fmethod.firclshp
designobj.fircls = 'fmethod.firclshp';
if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
