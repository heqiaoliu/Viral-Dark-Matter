function data = peek(hStack)
%PEEK Show the last entered data

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2007/12/14 15:21:36 $

% If the stack is empty cannot peek
if isempty(hStack),
    error(generatemsgid('Empty'),'Stack is empty.');
end

% Return the last entry
allData = get(hStack,'Data');
data    = allData{end};

% [EOF]
