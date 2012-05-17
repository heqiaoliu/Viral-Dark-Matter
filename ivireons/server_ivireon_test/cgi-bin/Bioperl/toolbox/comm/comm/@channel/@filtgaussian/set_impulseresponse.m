function IR = set_impulseresponse(h, IR)

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/06/08 15:51:59 $

% This method overrides the set method for channel.basefiltgaussian.

check_object_locked(h, 'impulse response');

if h.LockImpulseResponse
    error('comm:channel_filtgaussian_set_impulseresponse:ir', ...
        'ImpulseResponse must be set via registered impulse response function (ImpulseResponseFcn).');
end

h.PrivateData.ImpulseResponse = IR;
