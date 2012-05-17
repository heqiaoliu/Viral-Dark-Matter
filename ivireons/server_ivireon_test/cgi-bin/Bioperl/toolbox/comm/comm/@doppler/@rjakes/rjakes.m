function dopplerSpectrum = rjakes(freqMinMaxRJakes)
%RJAKES  Construct a restricted Jakes Doppler spectrum object, to be used
%        as part of a channel object.
%
%   H = DOPPLER.RJAKES(FREQMINMAXRJAKES) constructs a symmetrical
%   restricted Jakes Doppler spectrum object, with minimum and maximum
%   normalized Doppler frequencies given by the elements of
%   FREQMINMAXRJAKES. The frequencies are normalized by the MaxDopplerShift
%   property of the associated channel object
%
%   A restricted Jakes Doppler spectrum object has the following properties:
%
%   SpectrumType        - Doppler spectrum type: 'RJakes' (read-only).
%   FreqMinMaxRJakes    - Vector containing the minimum and maximum
%                         Doppler frequencies, normalized by the maximum
%                         Doppler shift.
%                         Must be a row vector of two real numbers between
%                         0 and 1.
%
%   The theoretical restricted Jakes Doppler spectrum is given analytically by: 
%
%       S(f) = 1/(pi*fd*sqrt(1-(f/fd)^2))    -fmax <= f <= -fmin, and
%                                             fmin <= f <= fmax
%
%   where fd is the maximum Doppler shift (MaxDopplerShift property) of the
%   associated channel object, and fmin and fmax are related to the
%   properties of the restricted Jakes Doppler spectrum object as follows:
%   FreqMinMaxRJakes(1) = fmin/fd, FreqMinMaxRJakes(1) = fmax/fd.
%
%   H = DOPPLER.RJAKES constructs a restricted Jakes Doppler spectrum
%   object with a default FREQMINMAXRJAKES = [0 1]. This is equivalent to
%   constructing a classical Jakes Doppler spectrum.
%
%   Note: When a restricted Jakes Doppler spectrum object is used as part
%   of a channel object, FreqMinMaxRJakes(1) and FreqMinMaxRJakes(2) should
%   be spaced by more than 1/50. Assigning a smaller spacing will result in
%   FreqMinMaxRJakes being reset to the default value of [0 1].  
%
%   EXAMPLE:
%
%   % Construct a symmetrical restricted Jakes Doppler spectrum object with
%   % normalized minimum and maximum Doppler frequencies of 0.75 and 0.95,
%   % respectively, and assign it to a Rayleigh channel object whose
%   % maximum Doppler shift is equal to 100 Hz. The minimum and maximum
%   % Doppler frequencies of the channel are then equal to 0.75 * 100 = 75 Hz 
%   % and 0.95 * 100 = 95 Hz, respectively. The Doppler spectrum of the
%   % channel is nonzero for frequencies f such that -95 Hz <= f <= -75 Hz
%   % and 75 Hz <= f <= 95 Hz.
%   dop = doppler.rjakes([0.75 0.95]);
%   chan = rayleighchan(1e-4, 100);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.ajakes,
%   doppler.flat, doppler.rounded, doppler.gaussian, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:20 $

error(nargchk(0, 1, nargin,'struct'));

dopplerSpectrum = doppler.rjakes;
dopplerSpectrum.SpectrumType = 'RJakes';

if nargin == 1, dopplerSpectrum.FreqMinMaxRJakes = freqMinMaxRJakes; end

% Setup listener
l = handle.listener(dopplerSpectrum, ...
    dopplerSpectrum.findprop('FreqMinMaxRJakes'), ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');
