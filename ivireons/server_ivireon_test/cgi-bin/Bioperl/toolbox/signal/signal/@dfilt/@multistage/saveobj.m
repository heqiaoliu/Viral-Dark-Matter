function s = saveobj(this)
%SAVEOBJ   Save this object.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2005/06/30 17:33:33 $

s = savemetadata(this);

s.class = class(this);
s.version = this.version;

s.PersistentMemory    = this.PersistentMemory;
s.NumSamplesProcessed = this.NumSamplesProcessed;

for indx = 1:nstages(this)
    s.Stage(indx) = this.Stage(indx);
end

% [EOF]
