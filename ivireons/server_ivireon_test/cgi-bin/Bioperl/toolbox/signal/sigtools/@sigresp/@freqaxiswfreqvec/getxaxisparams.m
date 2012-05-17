function hPrm = getxaxisparams(hObj)
%GETXAXISPARAMS Get the axis parameters for each analysis.

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:29:18 $

% Call "super" method to find the relevant parameters.
hPrm = freqaxis_getxaxisparams(hObj);

% Append the frequency vector parameter.
hPrm = union(hPrm, getparameter(hObj, 'freqvec'));

% [EOF]
