function filterType_listener(h,d)
%FILTERTYPE_LISTENER Callback for type specific actions.

%   Author(s): R. Losada
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:09:16 $

% Disable the bandwidth property at startup, rolloff is the default
enabdynprop(d,'q','off');

