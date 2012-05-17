function dopplerSpectrum = jakes
%JAKES  Construct a Jakes Doppler spectrum object, to be used as part of a
%       channel object.
%
%   H = DOPPLER.JAKES constructs a Jakes Doppler spectrum object.
%
%   The theoretical Jakes Doppler spectrum is given analytically by: 
%
%       S(f) = 1/(pi*fd*sqrt(1-(f/fd)^2))    -fd <= f <= fd
%
%   where fd is the maximum Doppler shift (MaxDopplerShift property) of the
%   associated channel object.
%
%   A Jakes Doppler spectrum object has a single property:
%
%   SpectrumType        - Doppler spectrum type: 'Jakes' (read-only).
%
%   See also doppler, doppler/types, doppler.rjakes, doppler.ajakes,
%   doppler.flat, doppler.rounded, doppler.gaussian, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:19 $

dopplerSpectrum = doppler.jakes;
dopplerSpectrum.SpectrumType = 'Jakes';
