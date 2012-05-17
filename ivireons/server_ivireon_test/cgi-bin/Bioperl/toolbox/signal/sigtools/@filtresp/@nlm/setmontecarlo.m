function t = setmontecarlo(this, t)
%SETMONTECARLO   Set Function for the number of trials.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:20:37 $

hPrm = getparameter(hObj, 'montecarlo');
if ~isempty(hPrm), setvalue(hPrm, t); end

% [EOF]
