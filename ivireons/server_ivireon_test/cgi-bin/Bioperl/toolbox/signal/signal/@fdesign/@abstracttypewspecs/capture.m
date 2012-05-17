function capture(this)
%CAPTURE   Capture the state of the object.

%   Author(s): J. Schickler
%   Copyright 1999-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2005/06/16 08:21:57 $

% This should be a protected method.

p = propstocopy(this);

p = [{'Specification'} p];

for indx = 1:length(p),
    c.(p{indx}) = get(this, p{indx});
end

allSpecs = get(this, 'AllSpecs');

for indx = 1:length(allSpecs)
    f = strrep(class(allSpecs(indx)), '.', '_');
    c.(f) = getstate(allSpecs(indx));
end

set(this, 'CapturedState', c);

% [EOF]
