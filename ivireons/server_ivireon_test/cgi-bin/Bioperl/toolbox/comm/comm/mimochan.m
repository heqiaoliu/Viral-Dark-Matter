function chan = mimochan(varargin)
%MIMOCHAN   MIMO fading channel
%   CHAN = MIMOCHAN(NT, NR, TS, FD) returns a multiple-input multiple-output
%   (MIMO) frequency-flat ("single path") Rayleigh fading channel.  NT is the
%   number of transmit antennas. NR is the number of receive antennas. NT and NR
%   can assume integer values from 1 to 8. TS is the sample time of the input
%   signal, in seconds.  FD is the maximum Doppler shift, in Hertz. You can
%   model the effect of the channel CHAN on a signal X by using the syntax Y =
%   FILTER(CHAN, X). Type 'help mimo.channel/filter' for more information.
%
%   CHAN = MIMOCHAN(NT, NR, TS, FD, TAU) returns a MIMO frequency-selective
%   ("multiple path") fading channel that models each discrete path as an
%   independent Rayleigh fading process, with the same average gain. TAU is a
%   row vector of path delays, each specified in seconds.  
%
%   CHAN = MIMOCHAN(NT, NR, TS, FD, TAU, PDB) specifies PDB as a row vector
%   of average path gains, each in dB.
%
%   The MIMO fading channel has the following properties:
%             ChannelType: 'MIMO'
%           NumTxAntennas: Number of transmit antennas
%           NumRxAntennas: Number of receive antennas
%       InputSamplePeriod: Input signal sample period (s)
%         DopplerSpectrum: Doppler spectrum object(s)
%         MaxDopplerShift: Maximum Doppler shift (Hz)
%              PathDelays: Discrete path delay vector (s)
%           AvgPathGaindB: Average path gain vector (dB)
%     TxCorrelationMatrix: Transmit correlation matrix (or 3-D array)
%     RxCorrelationMatrix: Receive correlation matrix (or 3-D array)
%                 KFactor: Rician K-factor scalar or vector (linear scale)
%  DirectPathDopplerShift: Doppler shift(s) of line-of-sight component(s) (Hz)
%     DirectPathInitPhase: Initial phase(s) of line-of-sight component(s) (rad)
%    ResetBeforeFiltering: Resets channel state every call (0 or 1)
%      NormalizePathGains: Normalize path gains (0 or 1)
%          StorePathGains: Store current complex path gain array (0 or 1)
%               PathGains: Current complex path gain array
%      ChannelFilterDelay: Channel filter delay (samples)
%     NumSamplesProcessed: Number of samples processed
%
%   To access or set the properties of the MIMO channel CHAN, use the syntax
%   CHAN.Prop, where 'Prop' is the property name (for example,
%   CHAN.MaxDopplerShift = 50).  To view the properties of a MIMO channel CHAN,
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
%       CHAN.DopplerSpectrum = DOPPLER.BELL(...)
%       CHAN.DopplerSpectrum = DOPPLER.GAUSSIAN(...)
%       CHAN.DopplerSpectrum = DOPPLER.BIGAUSSIAN(...)
%   If DopplerSpectrum is assigned a vector of Doppler objects (which can be
%   chosen from any of those listed above), each path will have the Doppler
%   spectrum specified by the corresponding Doppler object in the vector. In
%   this case the length of DopplerSpectrum must be equal to the length of the
%   PathDelays vector property. The maximum Doppler shift value necessary to
%   specify the DOPPLER object(s) is given by the MaxDopplerShift property of
%   the MIMO channel CHAN.
%
%   If MaxDopplerShift is 0 (the default), the channel object CHAN models a
%   static channel that comes from a Rayleigh distribution.  Use the syntax
%   RESET(CHAN) to generate a new channel realization.  Type 'help
%   mimo.channel/reset' for more information.
%    
%   If the channel is frequency-flat (i.e. PathDelays is a scalar),
%   TxCorrelationMatrix is the transmit correlation matrix of size NT x NT,
%   while RxCorrelationMatrix is the receive correlation matrix of size NR x NR,
%   where NT is the number of transmit antennas and NR is the number of receive
%   antennas. The main diagonal elements must be all ones, while the
%   off-diagonal elements must be real or complex numbers with a magnitude
%   smaller than or equal to one.   
%
%   If the channel is frequency-selective (i.e. PathDelays is a vector of length
%   L), TxCorrelationMatrix and RxCorrelationMatrix can be specified as
%   matrices, in which case each path has the same pair or transmit/receive
%   correlation matrices. Alternatively, they can be specified as 3-D arrays of
%   sizes NT x NT x L, and NR x NR x L, respectively, in which case each path
%   can have its own different pair of transmit/receive correlation matrices.
%
%   A Rician channel is obtained when KFactor is a non-zero scalar or vector.
%   The properties DirectPathDopplerShift and DirectPathInitPhase must have the
%   same length as KFactor. If KFactor is a scalar, the first discrete path is a
%   Rician fading process with a Rician K-factor of KFactor, and its
%   line-of-sight component has a Doppler shift of DirectPathDopplerShift and an
%   initial phase of DirectPathInitPhase; the remaining discrete paths are
%   independent Rayleigh fading processes. If KFactor is a vector, each discrete
%   path is an independent Rician fading process with a Rician K-factor given by
%   the corresponding element of the vector KFactor, and its line-of-sight
%   component has a Doppler shift and an initial phase given by the
%   corresponding elements of the vectors DirectPathDopplerShift and
%   DirectPathInitPhase, respectively. By default, KFactor,
%   DirectPathDopplerShift, and DirectPathInitPhase are 0, i.e. the channel is
%   Rayleigh fading. 
%
%   If ResetBeforeFiltering is 1 (the default), the channel state is reset
%   each time you call the channel filter function.  Otherwise, the fading
%   process maintains continuity over calls (type 'help mimo.channel/filter' for
%   more information).  For instance, PathGains and NumSamplesProcessed are
%   reset every call if ResetBeforeFiltering is 1; otherwise they begin
%   with their previous values.
%
%   If NormalizePathGains is 1 (the default), the fading processes are
%   normalized such that the total power of the path gains, averaged over
%   time, is 1.
%
%   PathGains is initialized to a random channel realization.  After the
%   channel filter function processes a signal, PathGains holds the complex
%   path gains of the underlying fading process.  
%   If StorePathGains is 0, PathGains holds the last complex path gains, as
%   a 4-D array of size 1 x L x NT x NR, where NT is the number of transmit
%   antennas, NR is the number of receive antennas, and L is the number of
%   paths (i.e. the length of PathDelays).
%   If StorePathGains is 1, PathGains holds a 4-D array of complex path
%   gains, of size NS x L x NT x NR, where NS is the number of processed
%   samples.
%
%   For frequency-selective fading, the channel is implemented as a finite
%   impulse response (FIR) filter with uniformly spaced taps and an
%   automatically computed delay given by ChannelFilterDelay.  Note, however,
%   that the underlying complex path gains may introduce additional delay.
%
%   If the values of the properties NumTxAntennas, NumRxAntennas,
%   InputSamplePeriod, MaxDopplerShift, PathDelays, TxCorrelationMatrix or
%   RxCorrelationMatrix are changed, or if DopplerSpectrum is set to any
%   DOPPLER object(s), the channel state is reset.
%
%   See also MIMO.CHANNEL/FILTER, MIMO.CHANNEL/RESET, RAYLEIGHCHAN, RICIANCHAN,
%   DOPPLER, DOPPLER/TYPES.

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/01/05 17:45:05 $

% This function is a wrapper for an object constructor (mimo.channel)

if nargin<4 || nargin>6
    error('comm:mimochan:numargs', ...
        'Number of arguments must be 4, 5, or 6.');
end
chan = mimo.Channel(varargin{:});
