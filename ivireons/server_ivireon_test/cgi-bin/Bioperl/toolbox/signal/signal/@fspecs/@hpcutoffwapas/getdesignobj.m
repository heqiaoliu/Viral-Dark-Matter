function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/10/23 18:48:51 $


%#function fmethod.elliphpastop
designobj.ellip = 'fmethod.elliphpastop';

if nargin > 1
    designobj = designobj.(str);
end


% [EOF]
