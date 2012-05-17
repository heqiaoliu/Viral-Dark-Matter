function empty(hStack)
%EMPTY Empties the stack

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:11 $

% Clear out the stack
set(hStack,'Data',{});

% Notify listeners
send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]
