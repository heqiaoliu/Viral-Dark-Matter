function resetoperations(this)
%RESETOPERATIONS Reset the operations

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:27:38 $

s = getstate(this);
c = allchild(this);

for indx = 1:length(c)
    n{indx} = get(classhandle(c(indx)), 'Name');
end

set(this, 'PreviousState', rmfield(s, n));

% [EOF]
