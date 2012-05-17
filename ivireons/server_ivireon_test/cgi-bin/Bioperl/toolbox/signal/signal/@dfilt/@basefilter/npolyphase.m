function n = npolyphase(this)
%NPOLYPHASE   Return the number of polyphases for this filter.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/12 23:53:00 $

n = [];
for indx = 1:length(this)
    n = [n thisnpolyphase(this(indx))];
end

% [EOF]
