function push(hStack, data)
%PUSH Add an entry to the database

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:21:37 $

% If the stack is full, cannot push
if isfull(hStack),
    error(generatemsgid('GUIErr'),'Stack is full');
end

allData = get(hStack,'Data');

% Add the data to the stack
allData{end+1} = data;
set(hStack,'Data',allData);

% Notify listeners
send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]
