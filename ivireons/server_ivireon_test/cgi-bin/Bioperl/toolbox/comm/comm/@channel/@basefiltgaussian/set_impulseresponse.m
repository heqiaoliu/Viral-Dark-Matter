function IR = set_impulseresponse(h, IR);
%SET_IMPULSERESPONSE

% Note that changing the length of the impulse response or the number of
% channels will reset the source.  This will change LastOutputs, State, and
% WGNState.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/10 19:19:00 $

check_object_locked(h, 'filter impulse response')
h.PrivateData.ImpulseResponse = IR;
if h.Constructed, h.initialize; end