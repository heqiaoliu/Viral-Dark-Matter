function children = getCreatedChildren(hThis) %#ok
% Returns the handles of children created by the objects' constructor as a
% column-vector. This must be implemented by the subclasses

%   Copyright 2006 The MathWorks, Inc.

error('MATLAB:scribe:purevirtual',...
    'Pure virtual function. Must be implemented by a subclass.');