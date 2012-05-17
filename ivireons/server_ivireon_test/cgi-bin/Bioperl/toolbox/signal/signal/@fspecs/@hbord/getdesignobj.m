function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/10/14 16:28:28 $

if isfdtbxinstalled
    
    %#function fdfmethod.windowhbord
    %#function fdfmethod.butterhalfband
    designobj.window = 'fdfmethod.windowhbord';
    designobj.butter = 'fdfmethod.butterhalfband';
else
    designobj = [];
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
