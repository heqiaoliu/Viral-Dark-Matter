function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/10/14 16:28:31 $



%#function fdfmethod.elliphilbertmin
%#function fdfmethod.eqriphilbmin
%#function fdfmethod.iirlinphasehilbertmin
designobj.ellip      = 'fdfmethod.elliphilbertmin';
designobj.equiripple = 'fdfmethod.eqriphilbmin';
designobj.iirlinphase = 'fdfmethod.iirlinphasehilbertmin';


if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
