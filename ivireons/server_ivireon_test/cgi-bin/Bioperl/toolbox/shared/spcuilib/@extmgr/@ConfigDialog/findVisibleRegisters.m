function hRegisters = findVisibleRegisters(this, type)
%FINDVISIBLEREGISTERS Return all visible registers for the type.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/27 19:53:52 $

% Only show the visible extensions.
hRegisters = findRegister(this.Driver.RegisterDb, type);
hRegisters = find(hRegisters, 'Visible', true);

% If we've specified no HiddenExtensions, then return early.
hiddenExtensions = this.HiddenExtensions;
if isempty(hiddenExtensions)
    return;
end

% Loop over all the Registers and remove any that match the
% HiddenExtensions values.
indx = 1;
while indx <= length(hRegisters)
    if any(strcmp(hRegisters(indx).getFullName, hiddenExtensions))
        hRegisters(indx) = [];
    else
        indx = indx+1;
    end
end

% [EOF]
