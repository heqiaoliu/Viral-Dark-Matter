function varargout = magresp(this, varargin)
%MAGRESP   Calculate the magnitude response.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/02/23 02:47:56 $

% 
hopts = uddpvparse('dspopts.freqresp', varargin{:});

inputs = freqzinputs(hopts);

% Calculate the frequency response.
[h, w] = base_resp(this, 'computefreqz', inputs{:});

% Convert the response to a magnitude.
h = abs(h);

opts = {};
if ~hopts.NormalizedFrequency
    opts = {'Fs', hopts.Fs};
end

if strcmpi(hopts.FrequencySpecification, 'NFFT')
    opts = {opts{:}, 'SpectrumRange', hopts.SpectrumRange};
end

% Create the response object.
h = dspdata.magresp(h, w, opts{:});

if nargout
    
    % If an output is requested, return the response object.
    varargout = {h};
else
    
    % If no output is requested, plot the response object.
    plot(h);
end

% [EOF]
