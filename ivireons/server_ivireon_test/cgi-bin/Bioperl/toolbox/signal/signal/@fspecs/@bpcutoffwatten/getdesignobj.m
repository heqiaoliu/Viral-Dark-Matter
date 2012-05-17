function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/05/12 21:36:25 $

%#function fmethod.firclsbp
designobj.fircls = 'fmethod.firclsbp';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
