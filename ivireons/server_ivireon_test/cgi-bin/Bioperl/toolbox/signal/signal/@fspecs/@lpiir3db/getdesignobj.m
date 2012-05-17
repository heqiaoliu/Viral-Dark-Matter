function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/04/21 16:30:47 $

%#function fmethod.iirmaxflat
designobj.butter = 'fmethod.iirmaxflatlp';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
