function designobj = getdesignobj(this, str)
%GETDESIGNOBJ   Get the design object.

%   Author(s): V. Pellissier
%   Copyright 2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/08/20 13:27:59 $

designobj.freqsamp = 'fmethod.freqsamparbmagnphase';
designobj.iirls = 'fmethod.invfreqz';
designobj.firls = 'fmethod.firlssbarbmagnphase';
designobj.equiripple = 'fmethod.eqripsbarbmagnphase';

if nargin > 1
    designobj = designobj.(str);
end

% [EOF]
