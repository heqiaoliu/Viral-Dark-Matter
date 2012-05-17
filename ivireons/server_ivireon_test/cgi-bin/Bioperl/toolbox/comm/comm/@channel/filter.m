function y = filter(chan, x)
%FILTER Filter signal with channel object.
%  Y = FILTER(CHAN, X) processes the baseband signal vector X with the
%  channel object CHAN.  The result is the signal vector Y.  You can
%  construct CHAN using either RAYLEIGHCHAN or RICIANCHAN.  The filter
%  function assumes X is sampled at frequency 1/TS, where TS equals the
%  InputSamplePeriod property of CHAN.
%
%  If CHAN.ResetBeforeFiltering is 0, then FILTER uses the existing state
%  information in CHAN when starting the filtering operation.  As a result,
%  FILTER(CHAN, [X1 X2]) is equivalent to 
%  [FILTER(CHAN, X1) FILTER(CHAN, X2)].  To reset CHAN manually, apply the
%  RESET function to CHAN.
%
%  If CHAN.ResetBeforeFiltering is 1, then FILTER resets CHAN before
%  starting the filtering operation, overwriting any previous state.
%  
%  See also RAYLEIGHCHAN, RICIANCHAN, CHANNEL/RESET.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/09/14 15:57:57 $

id = 'comm:channel_filter:InvalidChanFilter';
msg = sprintf([...
    'To pass a signal X through a channel CHAN, use Y=FILTER(CHAN, X) \n',...
    'where CHAN is a channel object.\n', ...
    'For more information, type ''help channel/filter'' in MATLAB.']);
error(id,msg)