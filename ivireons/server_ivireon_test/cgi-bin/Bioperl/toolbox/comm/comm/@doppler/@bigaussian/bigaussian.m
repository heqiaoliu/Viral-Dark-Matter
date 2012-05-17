function dopplerSpectrum = bigaussian(varargin)
%BIGAUSSIAN  Construct a bi-Gaussian Doppler spectrum object, to be used 
%            as part of a channel object.
%
%   H = DOPPLER.BIGAUSSIAN(PROPERTY1, VALUE1, ...) constructs a bi-Gaussian
%   Doppler spectrum object with properties as specified by PROPERTY/VALUE
%   pairs. 
%
%   A bi-Gaussian Doppler spectrum object has the following properties. All
%   the properties are writable except for the SpectrumType property. The
%   maximum Doppler shift referred to in some of the properties is equal to
%   the MaxDopplerShift property of the associated channel object.
%   
%   SpectrumType        - Doppler spectrum type: 'BiGaussian' (read-only).
%   SigmaGaussian1      - Standard deviation of first Gaussian function,
%                         normalized by the maximum Doppler shift.
%                         Must be a strictly positive real finite scalar.
%   SigmaGaussian2      - Standard deviation of second Gaussian function,
%                         normalized by the maximum Doppler shift.
%                         Must be a strictly positive real finite scalar.
%   CenterFreqGaussian1 - Center frequency of first Gaussian function, 
%                         normalized by the maximum Doppler shift.
%                         Must be a real scalar between -1 and 1.
%   CenterFreqGaussian2 - Center frequency of second Gaussian function, 
%                         normalized by the maximum Doppler shift.
%                         Must be a real scalar between -1 and 1.
%   GainGaussian1       - Power gain of first Gaussian function (linear scale).
%                         Must be a non-negative real finite scalar.
%   GainGaussian2       - Power gain of second Gaussian function (linear scale).
%                         Must be a non-negative real finite scalar.
%
%   The theoretical bi-Gaussian Doppler spectrum is given analytically by: 
%
%   S(f) = gainG1 * 1/sqrt(2*pi*sigmaG1^2) * exp(-(f - freqG1)^2/(2*sigmaG1^2))
%        + gainG2 * 1/sqrt(2*pi*sigmaG2^2) * exp(-(f - freqG2)^2/(2*sigmaG2^2))     
%
%   in which gainG1, gainG2, sigmaG1, sigmaG2, freqG1 and freqG2 are
%   related to the properties of the bi-Gaussian Doppler spectrum object as
%   follows: SigmaGaussian1 = sigmaG1/fd, SigmaGaussian2 = sigmaG2/fd,
%   CenterFreqGaussian1 = freqG1/fd, CenterFreqGaussian2 = freqG2/fd,
%   GainGaussian1 = gainG1, GainGaussian2 = gainG2, where fd is the maximum
%   Doppler shift (MaxDopplerShift property) of the associated channel
%   object.
%
%   H = DOPPLER.BIGAUSSIAN constructs a bi-Gaussian Doppler spectrum object
%   with default properties. The constructed Doppler spectrum is equivalent
%   to a single Gaussian Doppler spectrum centered at zero frequency. The
%   equivalent command with property/value pairs is:
%   H = DOPPLER.BIGAUSSIAN('SigmaGaussian1', 1/sqrt(2),  ...
%                          'SigmaGaussian2', 1/sqrt(2), ...
%                          'CenterFreqGaussian1', 0, ...
%                          'CenterFreqGaussian2', 0, ...
%                          'GainGaussian1', 0.5, ...
%                          'GainGaussian2', 0.5)
%
%   EXAMPLE:
%
%   % Construct a bi-Gaussian Doppler spectrum object with the same
%   % parameters as that of a COST 207 GAUS1 Doppler spectrum, and then
%   % assign it to the DopplerSpectrum property of a constructed Rayleigh
%   % channel object.
%   dop = doppler.bigaussian('SigmaGaussian1', 0.05, ...
%                            'SigmaGaussian2', 0.1, ...
%                            'CenterFreqGaussian1', -0.8, ...
%                            'CenterFreqGaussian2', 0.4, ...
%                            'GainGaussian1', 1, ...
%                            'GainGaussian2', 1/10);
%   chan = rayleighchan(1e-4, 100);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.ajakes, doppler.flat, doppler.rounded, doppler.gaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:16 $

dopplerSpectrum = doppler.bigaussian;
dopplerSpectrum.SpectrumType = 'BiGaussian';

if nargin ~= 0
    initObject(dopplerSpectrum, varargin{:});
end

% Setup listener
l = handle.listener(dopplerSpectrum, ...
    [dopplerSpectrum.findprop('SigmaGaussian1'), ...
     dopplerSpectrum.findprop('SigmaGaussian2'), ...
     dopplerSpectrum.findprop('CenterFreqGaussian1'), ...
     dopplerSpectrum.findprop('CenterFreqGaussian2'), ...
     dopplerSpectrum.findprop('GainGaussian1'), ...
     dopplerSpectrum.findprop('GainGaussian2')], ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');
