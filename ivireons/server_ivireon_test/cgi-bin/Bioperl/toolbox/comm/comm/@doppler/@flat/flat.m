function dopplerSpectrum = flat
%FLAT  Construct a flat Doppler spectrum object, to be used as part of a
%      channel object.
%
%   H = DOPPLER.FLAT constructs a flat Doppler spectrum object.
%
%   The theoretical flat Doppler spectrum is given analytically by: 
%
%       S(f) = 1/(2*fd)    -fd <= f <= fd
%
%   where fd is the maximum Doppler shift (MaxDopplerShift property) of the
%   associated channel object.
%
%   A flat Doppler spectrum object has a single property:
%
%   SpectrumType        - Doppler spectrum type: 'Flat' (read-only).
%
%   See also doppler, doppler/types, doppler.jakes, doppler.rjakes,
%   doppler.ajakes, doppler.rounded, doppler.gaussian, doppler.bigaussian,
%   doppler.bell, rayleighchan, ricianchan.

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2008/09/13 06:46:17 $

dopplerSpectrum = doppler.flat;
dopplerSpectrum.SpectrumType = 'Flat';
