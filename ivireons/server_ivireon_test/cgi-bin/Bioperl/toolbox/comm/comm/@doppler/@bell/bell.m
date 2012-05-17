function dopplerSpectrum = bell(coeffBell)
%BELL  Construct a bell Doppler spectrum object, to be used 
%      as part of a channel object.
%
%   H = DOPPLER.BELL(COEFFBELL) constructs a bell Doppler spectrum
%   object, with a coefficient given by COEFFBELL. 
%
%   The theoretical bell Doppler spectrum is given analytically by: 
%
%       S(f) = 1/(1 + A*(f/fd)^2)    -fd <= f <= fd
%
%   where COEFFBELL = A is a positive finite real scalar, and fd is the
%   maximum Doppler shift (MaxDopplerShift property) of the associated
%   channel object.
%
%   A bell Doppler spectrum object has the following properties:
%   
%   SpectrumType        - Doppler spectrum type: 'Bell' (read-only).
%   CoeffBell           - Coefficient of the Doppler spectrum.
%                         Must be a positive finite real scalar.
%
%   H = DOPPLER.BELL constructs a bell Doppler spectrum object with a
%   default coefficient of 9.
%
%   EXAMPLE:
%
%   % Construct a bell Doppler spectrum object with a coefficient of 8.5,
%   % and assign it to a Rayleigh channel object with one path.
%   dop = doppler.bell(8.5);
%   chan = rayleighchan(1e-5, 10);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.ajakes, doppler.flat, doppler.rounded, doppler.gaussian,
%   doppler.bigaussian, rayleighchan, ricianchan.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/09/13 06:46:13 $

error(nargchk(0, 1, nargin, 'struct'));

dopplerSpectrum = doppler.bell;
dopplerSpectrum.SpectrumType = 'Bell';

if nargin == 1, dopplerSpectrum.CoeffBell = coeffBell; end

% Setup listener
l = handle.listener(dopplerSpectrum, ...
    dopplerSpectrum.findprop('CoeffBell'), ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');

