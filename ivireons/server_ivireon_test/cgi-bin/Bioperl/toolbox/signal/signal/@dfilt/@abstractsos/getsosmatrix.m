function sosm = getsosmatrix(hObj, sosm)
%GETSOSMATRIX Get the sosmatrix from the object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/12 23:52:20 $

sosm = getsosmatrix(hObj.filterquantizer, get(hObj, 'privNum'), get(hObj, 'privDen'));

% [EOF]
