function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/10/23 18:48:59 $

if isfdtbxinstalled
    
    %#function fdfmethod.windowhphbord
    %#function fdfmethod.butterhphalfband
    designobj.window = 'fdfmethod.windowhphbord';
    designobj.butter = 'fdfmethod.butterhphalfband';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]