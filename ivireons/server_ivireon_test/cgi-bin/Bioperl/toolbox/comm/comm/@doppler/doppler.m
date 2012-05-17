function varargout = doppler(varargin)
%DOPPLER Doppler spectrum package
%   H = DOPPLER.<TYPE>(...) constructs a Doppler spectrum object of a
%   particular TYPE for use with channel objects. Type "help doppler/types"
%   to get the complete help of <a href="matlab:help doppler/types">types</a>.
%   
%   The returned Doppler spectrum object H has a set of properties based on
%   its TYPE. Type "help doppler.<TYPE>" to get the complete help on a
%   specific TYPE of Doppler spectrum object.
%
%   After a Doppler spectrum object is constructed, it can be assigned to
%   the DopplerSpectrum property of a constructed Rayleigh or Rician
%   channel object. In doing so, a copy of the Doppler spectrum object is
%   written to the DopplerSpectrum property of the channel object, such
%   that subsequently modifying the original Doppler spectrum object will
%   not modify the DopplerSpectrum property of the channel object.
%
%   % EXAMPLE: Construct a flat Doppler spectrum object to be used with a
%   % Rician channel object.
%   dopflat = doppler.flat;         % Doppler spectrum object is constructed.
%   chan = ricianchan(1e-4, 100,1); % Rician channel object is constructed.
%   chan.DopplerSpectrum = dopflat; % A flat Doppler spectrum is specified for 
%                                   % the Rician channel object.

% @doppler/
%
%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/08/01 12:18:00 $

error('comm:doppler:InvalidUse', ['Use DOPPLER.<TYPE> to create a Doppler spectrum object.\n' ... 
                    'For example,\n h = doppler.flat']);