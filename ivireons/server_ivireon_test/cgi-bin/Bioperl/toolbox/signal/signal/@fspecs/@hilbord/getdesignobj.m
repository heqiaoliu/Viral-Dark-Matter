function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the designobj.

%   Author(s): P. Costa
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 17:59:46 $

%#function fmethod.eqriphilbord
%#function fmethod.firlshilbord
designobj.equiripple = 'fmethod.eqriphilbord';
designobj.firls      = 'fmethod.firlshilbord';

if isfdtbxinstalled
    
    %#function fdfmethod.eqriphilbord
    %#function fdfmethod.elliphilbertfpass
    %#function fdfmethod.iirlinphasehilbertfpass    
    designobj.equiripple =  'fdfmethod.eqriphilbord';
    designobj.ellip       = 'fdfmethod.elliphilbertfpass';
    designobj.iirlinphase = 'fdfmethod.iirlinphasehilbertfpass';    
end

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
