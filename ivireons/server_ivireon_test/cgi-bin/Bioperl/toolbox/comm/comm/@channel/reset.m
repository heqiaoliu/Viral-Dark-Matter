function reset(chan, randomstate) %#ok<INUSD>
%RESET  Reset channel object.
%   RESET(CHAN) resets the channel object CHAN, initializing the PathGains
%   and NumSamplesProcessed properties as well as internal filter states.
%   This syntax is useful when you want the effect of creating a new
%   channel.
%
%   RESET(CHAN, RANDSTATE) resets the channel object CHAN and initializes
%   the state of the random number generator that the channel uses.
%   RANDSTATE is a two-element column vector or a scalar integer (for more
%   information, type 'help randn').  This syntax is useful when you want to
%   repeat previous numerical results that started from a particular state.
%   RESET(CHAN, RANDSTATE) will not accept RANDSTATE in a future release.  See
%   LEGACYCHANNELSIM function for more information.
%  
%   See also RAYLEIGHCHAN, RICIANCHAN, CHANNEL/FILTER, CHANNEL/PLOT, RANDN,
%            LEGACYCHANNELSIM. 

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/06/11 15:56:54 $

id = 'comm:channel_reset:InvalidResetChan';
error(id,[...
    'To reset a channel CHAN, use RESET(CHAN), \n',...
    'where CHAN is a channel object.\n', ...
    'For more information, type ''help channel/reset'' in MATLAB.'])