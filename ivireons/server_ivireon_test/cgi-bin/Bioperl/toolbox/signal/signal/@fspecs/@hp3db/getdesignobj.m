function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): J. Schickler
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/04/21 16:30:43 $

%#function fmethod.butterhp
designobj.butter = 'fmethod.butterhp';

if isfdtbxinstalled
    %#function fdfmethod.firmaxflathp
    designobj.maxflat = 'fdfmethod.firmaxflathp';
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
