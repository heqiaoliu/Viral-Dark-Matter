function filterType_listener(h,d)
%FILTERTYPE_LISTENER Callback for type specific actions.

%   Author(s): R. Losada
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/15 00:10:54 $

% Disable the bandwidth property at startup, rolloff is the default
enabdynprop(d,'bandwidth','off');

