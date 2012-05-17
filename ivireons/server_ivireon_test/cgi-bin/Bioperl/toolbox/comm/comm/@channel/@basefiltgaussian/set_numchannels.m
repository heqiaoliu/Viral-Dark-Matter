function N = set_numchannels(h, N);
%SET_NUMCHANNELS

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:01 $

check_object_locked(h, 'number of channels')
h.PrivateData.NumChannels = N;
if h.Constructed, h.initialize; end
