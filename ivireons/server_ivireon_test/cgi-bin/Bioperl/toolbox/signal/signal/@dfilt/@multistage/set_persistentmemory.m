function persistentmemory = set_persistentmemory(Hd, persistentmemory)
%SET_PERSISTENTMEMORY   PreSet function for the 'persistentmemory' property.

%   Author(s): V. Pellissier
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:08:40 $

for i=1:length(Hd.Stage),
    Hd.Stage(i).PersistentMemory=persistentmemory;
end

% [EOF]
