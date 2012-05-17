function dopplerSpectrum = ajakes(freqMinMaxAJakes)
%AJAKES  Construct an asymmetrical Jakes Doppler spectrum object, to be used
%        as part of a channel object.
%
%   H = DOPPLER.AJAKES(FREQMINMAXAJAKES) constructs an asymmetrical Jakes
%   Doppler spectrum object, with minimum and maximum normalized Doppler
%   frequencies given by the elements of FREQMINMAXAJAKES. The frequencies
%   are normalized by the MaxDopplerShift property of the associated
%   channel object.
%
%   An asymmetrical Jakes Doppler spectrum object has the following properties:
%
%   SpectrumType        - Doppler spectrum type: 'AJakes' (read-only).
%   FreqMinMaxAJakes    - Vector containing the minimum and maximum
%                         Doppler frequencies, normalized by the maximum
%                         Doppler shift.
%                         Must be a row vector of two real numbers between
%                         -1 and 1.
%
%   The theoretical asymmetrical Jakes Doppler spectrum is given
%   analytically by: 
%
%       S(f) = 1/(pi*fd*sqrt(1-(f/fd)^2))    fmin <= f <= fmax
%
%   where fd is the maximum Doppler shift (MaxDopplerShift property) of the
%   associated channel object, and fmin and fmax are related to the
%   properties of the asymmetrical Jakes Doppler spectrum object as follows:
%   FreqMinMaxAJakes(1) = fmin/fd, FreqMinMaxAJakes(2) = fmax/fd.
%
%   H = DOPPLER.AJAKES constructs an asymmetrical Jakes Doppler spectrum
%   object with a default FREQMINMAXAJAKES = [0 1]. This is equivalent to
%   constructing a Jakes Doppler spectrum which is non-zero only for
%   positive frequencies.
%
%   Note: When an asymmetrical Jakes Doppler spectrum object is used as part
%   of a channel object, FreqMinMaxAJakes(1) and FreqMinMaxAJakes(2) should
%   be spaced by more than 1/50. Assigning a smaller spacing will result in
%   FreqMinMaxAJakes being reset to the default value of [0 1].  
%
%   EXAMPLE:
%
%   % Construct an asymmetrical Jakes Doppler spectrum object with
%   % normalized minimum and maximum Doppler frequencies of -0.2 and 0.8,
%   % respectively, and assign it to a Rayleigh channel object whose
%   % maximum Doppler shift is equal to 100 Hz. The minimum and maximum
%   % Doppler frequencies of the channel are then equal to -0.2 * 100 = -20 Hz 
%   % and 0.8 * 100 = 80 Hz, respectively. The Doppler spectrum of the
%   % channel is nonzero for frequencies f such that -20 Hz <= f <= 80 Hz.
%   dop = doppler.ajakes([-0.2 0.8]);
%   chan = rayleighchan(1e-4, 100);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.flat, doppler.rounded, doppler.gaussian, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/09/13 06:46:12 $

error(nargchk(0, 1, nargin,'struct'));

dopplerSpectrum = doppler.ajakes;
dopplerSpectrum.SpectrumType = 'AJakes';

if nargin == 1, dopplerSpectrum.FreqMinMaxAJakes = freqMinMaxAJakes; end

% Setup listener
l = handle.listener(dopplerSpectrum, ...
    dopplerSpectrum.findprop('FreqMinMaxAJakes'), ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');
