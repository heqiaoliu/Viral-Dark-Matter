function initialize(h)
%INITIALIZE  Initialize interpolating-filtered Gaussian source object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/05/23 07:48:56 $

s = h.FiltGaussian;

if s.NumChannels ~= h.InterpFilter.NumChannels
    error('comm:channel_intfiltgaussian_initialize:numchannels', ...
            ['Filtered Gaussian source and interpolating filter ' ...
           'must have same number of channels.']);
end

% Reset source, including random state.
if (legacychannelsim || s.PrivLegacyMode)
    WGNState = 0;
    reset(h, WGNState);
else
    reset(h);
end