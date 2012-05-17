function allPrm = freqaxiswfreqvec_construct(hObj,varargin)
%FREQAXISWFREQVEC_CONSTRUCT Check the inputs

%   Author(s): P. Pacheco
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:20:57 $


allPrm = hObj.freqaxiswnfft_construct(varargin{:});

% Create parameters for the frequency axis w/ freq. vector object.
createparameter(hObj, allPrm, 'Frequency Vector', 'freqvec', @checkfreqvec, linspace(0, 1, 256));

% ---------------------------------------------------------------------------
function checkfreqvec(freqvec)

if ~isnumeric(freqvec),
    error(generatemsgid('MustBeNumeric'),'The Frequency Vector must be numeric.');
end

% [EOF]
