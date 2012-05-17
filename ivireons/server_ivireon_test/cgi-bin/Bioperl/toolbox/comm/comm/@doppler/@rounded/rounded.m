function dopplerSpectrum = rounded(coeffRounded)
%ROUNDED  Construct a rounded Doppler spectrum object, to be used 
%         as part of a channel object.
%
%   H = DOPPLER.ROUNDED(COEFFROUNDED) constructs a rounded Doppler spectrum
%   object, with polynomial coefficients given by COEFFROUNDED. 
%
%   The theoretical rounded Doppler spectrum is given analytically by a
%   polynomial in frequency f of order 4, where only the even powers of f
%   are retained: 
%
%       S(f) = a0 + a2*(f/fd)^2 + a4*(f/fd)^4    -fd <= f <= fd
%
%   where COEFFROUNDED = [a0 a2 a4] is the vector of polynomial
%   coefficients, and fd is the maximum Doppler shift (MaxDopplerShift
%   property) of the associated channel object.
%
%   A rounded Doppler spectrum object has the following properties:
%   
%   SpectrumType        - Doppler spectrum type: 'Rounded' (read-only).
%   CoeffRounded        - Polynomial coefficients of the Doppler spectrum.
%                         Must be a 1x3 finite real vector.
%
%   H = DOPPLER.ROUNDED constructs a rounded Doppler spectrum object with a
%   default vector of polynomial coefficients given by COEFFROUNDED = [1
%   -1.72 0.785].
%
%   EXAMPLE:
%
%   % Construct a rounded Doppler spectrum object with polynomial
%   % coefficients given by a0 = 1, a2 = -1, a4 = 0.5, and assign it to a
%   % Rician channel object with three paths.
%   dop = doppler.rounded([1 -1 0.5]);
%   chan = ricianchan(1e-5, 3, 2, [0 1e-6 1.5e-6], [0 0.5 0.1]);
%   chan.DopplerSpectrum = dop;
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.ajakes, doppler.flat, doppler.gaussian, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:21 $

error(nargchk(0, 1, nargin,'struct'));

dopplerSpectrum = doppler.rounded;
dopplerSpectrum.SpectrumType = 'Rounded';

if nargin == 1, dopplerSpectrum.CoeffRounded = coeffRounded; end


% Setup listener
l = handle.listener(dopplerSpectrum, ...
    dopplerSpectrum.findprop('CoeffRounded'), ...
    'PropertyPostSet', @(hSrc, eData) lclSend(dopplerSpectrum));
set(dopplerSpectrum, 'PropertyListener', l);

% ------------------------
function lclSend(dopplerSpectrum)

send(dopplerSpectrum, 'DopplerSpectrumPropertiesChanged');
