function dopplerSpectrum = gaussian(sigmaGaussian)
%GAUSSIAN  Construct a Gaussian Doppler spectrum object, to be used 
%          as part of a channel object.
%
%   H = DOPPLER.GAUSSIAN(SIGMAGAUSSIAN) constructs a Gaussian Doppler
%   spectrum object, with a normalized standard deviation of SIGMAGAUSSIAN.
%   The standard deviation SIGMAGAUSSIAN is normalized by the
%   MaxDopplerShift property of the associated channel object.   
%
%   The theoretical Gaussian Doppler spectrum is given analytically by: 
%
%       S(f) = 1/sqrt(2*pi*sigmaG^2) * exp(-f^2/(2*sigmaG^2))  
%
%   where sigmaG is the standard deviation of the Gaussian function, and is
%   related to the normalized standard deviation SIGMAGAUSSIAN through
%   SIGMAGAUSSIAN = sigmaG/fd, where fd is the maximum Doppler shift
%   (MaxDopplerShift property) of the associated channel object.
%
%   A Gaussian Doppler spectrum object has the following properties:
%   
%   SpectrumType        - Doppler spectrum type: 'Gaussian' (read-only).
%   SigmaGaussian       - Standard deviation of Gaussian function,
%                         normalized by the maximum Doppler shift.
%                         Must be a real positive scalar.
%
%   H = DOPPLER.GAUSSIAN constructs a Gaussian Doppler spectrum object with
%   a default normalized standard deviation of SIGMAGAUSSIAN = 1/sqrt(2).
%
%   EXAMPLE:
%
%   % Construct a Gaussian Doppler spectrum object with a normalized
%   % standard deviation of 0.1, and assign it to a Rayleigh channel object
%   % whose maximum Doppler shift is equal to 120 Hz. The standard
%   % deviation of the Doppler spectrum is then 0.1 * 120 = 12 Hz. 
%   dop = doppler.gaussian(0.1);
%   chan = rayleighchan(1e-4, 120);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.ajakes, doppler.flat, doppler.rounded, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:18 $

error(nargchk(0, 1, nargin,'struct'));

dopplerSpectrum = doppler.gaussian;
dopplerSpectrum.SpectrumType = 'Gaussian';

if nargin >= 1, dopplerSpectrum.SigmaGaussian = sigmaGaussian; end

% Setup listener
l = handle.listener(dopplerSpectrum, ...
    dopplerSpectrum.findprop('SigmaGaussian'), ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');
