function children = getCreatedChildren(hThis) 
% Returns the handles of children created by the objects' constructor as a
% column-vector. This must be implemented by the subclasses

%   Copyright 2006 The MathWorks, Inc.

children = [hThis.RectHandle;hThis.TextHandle];