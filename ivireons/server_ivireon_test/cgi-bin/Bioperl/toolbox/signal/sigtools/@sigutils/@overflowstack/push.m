function push(hStack, data)
%PUSH Add an entry to the database

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/05/31 23:28:47 $

allData = get(hStack,'Data');

% If the stack is full destroy the first entry and warn
if isfull(hStack),
    
    % Notify listeners that an overflow has occurred and send the lost data.
    send(hStack,'OverflowOccurred', ....
        sigutils.sigeventdata(hStack,'OverflowOccurred', allData{1}));
    allData(1) = [];
    warning(generatemsgid('GUIWarn'),'Stack is full.  Overflow has occurred.');
end

% Add the data to the stack
allData{end+1} = data;
set(hStack,'Data',allData);

send(hStack,'TopChanged',handle.EventData(hStack,'TopChanged'));

% [EOF]
