function disassociate(h)
%DISASSOCIATE Disassociate the specs frame from it's graphical frame.
%   DISASSOCIATE(H) Disassociate the specs frame from it's graphical frame.
%   This will not remove the listeners.  It will only set the handles property
%   to [] thereby rendering the listeners useless.  Calling ASSOCIATE will
%   reattach the handles and reactivate the listeners.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.4.4.2 $  $Date: 2005/06/16 08:38:57 $

if ~isrendered(h),
    error(generatemsgid('objectNotRendered'), ...
        'Only a rendered object can be disassociated from it''s graphical components');
end

for hindx = allchild(h)
    disconnect(hindx);
end

% [EOF]
