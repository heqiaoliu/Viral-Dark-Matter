function chan = rayleighchan(varargin)
%RAYLEIGHCHAN   Construct a Rayleigh fading channel object.
%   CHAN = RAYLEIGHCHAN(TS, FD) constructs a frequency-flat ("single path")
%   Rayleigh fading channel object.  TS is the sample time of the input
%   signal, in seconds.  FD is the maximum Doppler shift, in Hertz. You
%   can model the effect of the channel CHAN on a signal X by using the
%   syntax Y = FILTER(CHAN, X).  Type 'help channel/filter' for more
%   information.
%
%   CHAN = RAYLEIGHCHAN(TS, FD, TAU, PDB) constructs a frequency-selective
%   ("multiple path") fading channel object that models each discrete path
%   as an independent Rayleigh fading process.  TAU is a row vector of path
%   delays, each specified in seconds.  PDB is a row vector of average path
%   gains, each specified in dB.
%
%   CHAN = RAYLEIGHCHAN sets the maximum Doppler shift to zero.  This is a
%   static frequency-flat channel (see below).  In this trivial case, the
%   sample time of the signal is unimportant.
%
%   The Rayleigh fading channel object has the following properties:
%             ChannelType: 'Rayleigh'
%       InputSamplePeriod: Input signal sample period (s)
%         DopplerSpectrum: Doppler spectrum object(s)
%         MaxDopplerShift: Maximum Doppler shift (Hz)
%              PathDelays: Discrete path delay vector (s)
%           AvgPathGaindB: Average path gain vector (dB)
%      NormalizePathGains: Normalize path gains (0 or 1)
%            StoreHistory: Store channel state information (0 or 1)
%          StorePathGains: Store current complex path gain vector (0 or 1)
%               PathGains: Current complex path gain vector
%      ChannelFilterDelay: Channel filter delay (samples)
%    ResetBeforeFiltering: Resets channel state every call (0 or 1)
%     NumSamplesProcessed: Number of samples processed
%
%   To access or set the properties of the object CHAN, use the syntax
%   CHAN.Prop, where 'Prop' is the property name (for example,
%   CHAN.MaxDopplerShift = 50).  To view the properties of an object CHAN,
%   type CHAN.
%
%   DopplerSpectrum must be assigned either a single object from the
%   DOPPLER package, or a vector of such objects. If DopplerSpectrum is
%   assigned a single Doppler object, all paths will have the same
%   specified Doppler spectrum. The possible choices are:
%       CHAN.DopplerSpectrum = DOPPLER.JAKES    (default)
%       CHAN.DopplerSpectrum = DOPPLER.FLAT
%       CHAN.DopplerSpectrum = DOPPLER.RJAKES(...)
%       CHAN.DopplerSpectrum = DOPPLER.AJAKES(...)
%       CHAN.DopplerSpectrum = DOPPLER.ROUNDED(...)
%       CHAN.DopplerSpectrum = DOPPLER.GAUSSIAN(...)
%       CHAN.DopplerSpectrum = DOPPLER.BIGAUSSIAN(...)
%   If DopplerSpectrum is assigned a vector of Doppler objects (which can
%   be chosen from any of those listed above), each path will have the
%   Doppler spectrum specified by the corresponding Doppler object in the
%   vector. In this case the length of DopplerSpectrum must be equal to
%   the length of the PathDelays vector property.
%   The maximum Doppler shift value necessary to specify the DOPPLER
%   object(s) is given by the MaxDopplerShift property of the CHAN object.
%
%   If MaxDopplerShift is 0 (the default), the channel object CHAN models a
%   static channel that comes from a Rayleigh distribution.  Use the syntax
%   RESET(CHAN) to generate a new channel realization.  Type 'help
%   channel/reset' for more information.
%    
%   If NormalizePathGains is 1 (the default), the fading processes are
%   normalized such that the total power of the path gains, averaged over
%   time, is 1.
%
%   If StoreHistory is 1 (the default value is 0), CHAN stores channel state
%   information as the channel filter function processes the signal.  You
%   can then visualize this state information via a graphical user interface by
%   using the syntax PLOT(CHAN).  Type 'help channel/plot' for more
%   information. 
%   Note that setting StoreHistory to 1 will result in a slower simulation.
%   If you do not wish to visualize channel state information using the
%   PLOT method, but you still wish to access the complex path gains, then
%   set StorePathGains to 1, while keeping StoreHistory as 0.
%
%   PathGains is initialized to a random channel realization.  After the
%   channel filter function processes a signal, PathGains holds the complex
%   path gains of the underlying fading process.  If both StoreHistory and
%   StorePathGains are 0, PathGains holds the last complex path gains.  If
%   either of StoreHistory or StorePathGains is 1, PathGains holds a matrix
%   of complex path gains.  Each row of this matrix corresponds to a sample
%   of the input signal.
%
%   For frequency-selective fading, the channel is implemented as a finite
%   impulse response (FIR) filter with uniformly spaced taps and an
%   automatically computed delay given by ChannelFilterDelay.  Note,
%   however, that the underlying complex path gains may introduce
%   additional delay.
%
%   If ResetBeforeFiltering is 1 (the default), the channel state is reset
%   each time you call the channel filter function.  Otherwise, the fading
%   process maintains continuity over calls (type 'help channel/filter' for
%   more information).  For instance, PathGains and NumSamplesProcessed are
%   reset every call if ResetBeforeFiltering is 1; otherwise they begin
%   with their previous values.
%
%   If the values of the properties InputSamplePeriod, MaxDopplerShift, or
%   PathDelays are changed, or if DopplerSpectrum is set to any DOPPLER
%   object(s), the channel state is reset.
%
%   See also RICIANCHAN, CHANNEL/FILTER, CHANNEL/PLOT, CHANNEL/RESET,
%   DOPPLER, DOPPLER/TYPES.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2007/09/14 15:57:40 $

% This function is a wrapper for an object constructor (channel.rayleigh)

error(nargchk(0, 4, nargin,'struct'));
if nargin==1
    error('comm:rayleighchan:numargs', ...
        'Number of arguments must be 0, 2, 3, or 4.');
end
chan = channel.rayleigh(varargin{:});
