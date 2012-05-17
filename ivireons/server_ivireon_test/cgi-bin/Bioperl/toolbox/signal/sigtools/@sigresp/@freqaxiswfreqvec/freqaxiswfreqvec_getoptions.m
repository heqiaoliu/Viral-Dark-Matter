function [opts, xunits] = freqaxiswfreqvec_getoptions(this)
%FREQAXISWFREQVEC_GETOPTIONS Get the input options for the analysis functions 
%which allows specifying a frequency vector.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:29:14 $

fs = getmaxfs(this);

% Only do this if using a response that allows you to specify a freq vector.
if strcmpi(get(this, 'FrequencyRange'),'specify freq. vector'),
    
    if isempty(fs) || strcmpi(this.NormalizedFrequency, 'on')
        boolflag = true;
    else
        boolflag = false;
    end
    
    if boolflag,
        if ~isempty(fs),
            opts = {get(this, 'FrequencyVector')*fs/(2*pi)};
        else
            opts = {get(this, 'FrequencyVector')};
        end
    else
        opts = {get(this, 'FrequencyVector')};
    end
else
   opts = freqaxis_getoptions(this);
end

if ~isempty(fs),
    [fs, m, xunits] = engunits(fs);
    xunits = sprintf('%sHz', xunits);
else
    xunits = 'rad/sample';
end

% [EOF]
