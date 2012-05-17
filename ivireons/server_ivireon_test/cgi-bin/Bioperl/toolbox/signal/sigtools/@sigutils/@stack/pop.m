function data = pop(hStack)
%POP Retrieve an entry from the database

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:31:15 $

% Return the end of the list
data         = peek(hStack);

% Erase the end of the list
allData      = get(hStack,'Data');
allData(end) = [];
set(hStack,'Data',allData);

% Notify listeners
send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]
