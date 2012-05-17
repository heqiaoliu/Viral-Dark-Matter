function chan = ricianchan(varargin)
%RICIANCHAN   Construct a Rician fading channel object.
%   CHAN = RICIANCHAN(TS, FD, K) constructs a frequency-flat ("single
%   path") Rician fading channel object.  TS is the sample time of the
%   input signal, in seconds.  FD is the maximum Doppler shift, in Hertz. K
%   is the Rician K-factor in linear scale.  You can model the effect of
%   the channel CHAN on a signal X by using the syntax Y = FILTER(CHAN, X).
%   Type 'help channel/filter' for more information.
%
%   CHAN = RICIANCHAN(TS, FD, K, TAU, PDB) constructs a frequency-selective
%   ("multiple paths") fading channel object. If K is a scalar, then the
%   first discrete path is a Rician fading process (it contains a
%   line-of-sight component) with a K-factor of K, while the remaining
%   discrete paths are independent Rayleigh fading processes (no
%   line-of-sight component). If K is a vector of the same size as TAU,
%   then each discrete path is a Rician fading process with a K-factor
%   given by the corresponding element of the vector K. TAU is a vector of
%   path delays, each specified in seconds. PDB is a vector of average path
%   gains, each specified in dB.  
%
%   CHAN = RICIANCHAN(TS, FD, K, TAU, PDB, FDLOS) specifies FDLOS as the
%   Doppler shift(s) of the line-of-sight component(s) of the discrete
%   path(s), in Hertz. FDLOS must be the same size as K. If K and FDLOS are
%   scalars, the line-of-sight component of the first discrete path has a
%   Doppler shift of FDLOS, while the remaining discrete paths are
%   independent Rayleigh fading processes. If FDLOS is a vector of the same
%   size as K, the line-of-sight component of each discrete path has a
%   Doppler shift given by the corresponding element of the vector FDLOS.
%   By default, FDLOS is 0. The initial phase(s) of the line-of-sight
%   component(s) can be set through the property DirectPathInitPhase.
%
%   CHAN = RICIANCHAN sets the maximum Doppler shift to 0, the Rician
%   K-factor to 1, and the Doppler shift and initial phase of the
%   line-of-sight component to 0. This is a static frequency-flat channel
%   (see below).  In this trivial case, the sample time of the signal is
%   unimportant.
%
%   The Rician fading channel object has the following properties:
%             ChannelType: 'Rician'
%       InputSamplePeriod: Input signal sample period (s)
%         DopplerSpectrum: Doppler spectrum object(s)
%         MaxDopplerShift: Maximum Doppler shift (Hz)
%                 KFactor: Rician K-factor scalar or vector
%              PathDelays: Discrete path delay vector (s)
%           AvgPathGaindB: Average path gain vector (dB)
%  DirectPathDopplerShift: Doppler shift(s) of line-of-sight component(s) (Hz)
%     DirectPathInitPhase: Initial phase(s) of line-of-sight component(s) (rad)
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
%   CHAN.KFactor = 10).  To view the properties of an object CHAN, 
%   type CHAN.
%
%   If MaxDopplerShift is 0 (the default), the channel object CHAN models a
%   static channel. Use the syntax RESET(CHAN) to generate a new channel
%   realization.  Type 'help channel/reset' for more information.
%    
%   For information on other properties, type 'help rayleighchan'.
%
%   See also RAYLEIGHCHAN, CHANNEL/FILTER, CHANNEL/PLOT, CHANNEL/RESET,
%   DOPPLER, DOPPLER/TYPES.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $  $Date: 2007/09/14 15:57:41 $

% This function is a wrapper for an object constructor (channel.rayleigh)

error(nargchk(0, 6, nargin,'struct'));
if nargin==1 || nargin==2
    error('comm:ricianchan:numargs', ...
        'Number of arguments must be 0, 3, 4, 5, or 6.');
end
chan = channel.rician(varargin{:});
