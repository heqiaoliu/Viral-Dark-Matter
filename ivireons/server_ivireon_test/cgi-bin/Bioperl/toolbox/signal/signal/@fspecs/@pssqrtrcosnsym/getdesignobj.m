function designobj = getdesignobj(this, str)
%GETDESIGNOBJ Get the design object
%   OUT = GETDESIGNOBJ(ARGS) <long description>

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/10/31 07:03:24 $

designobj.window = 'fmethod.sqrtrcoswin';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
