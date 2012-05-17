function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2005/10/14 16:28:20 $

%#function fdfmethod.designcicinterp
designobj.multisection = 'fdfmethod.designcicinterp';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
