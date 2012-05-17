function base_loadpublicinterface(this, s)
%BASE_LOADPUBLICINTERFACE   

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/12/26 22:03:26 $

if s.version.number < 2
    if isfield(s, 'PersistentMemory')
        set(this, 'PersistentMemory', s.PersistentMemory);
    else
        set(this, 'PersistentMemory', strcmpi(s.ResetBeforeFiltering, 'off'));
    end
else
    set(this, 'PersistentMemory', s.PersistentMemory);
end

set(this, 'NumSamplesProcessed', s.NumSamplesProcessed);

% [EOF]
