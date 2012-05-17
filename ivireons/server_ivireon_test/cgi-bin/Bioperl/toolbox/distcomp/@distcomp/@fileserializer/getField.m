function value = getField(obj, entities, name)
; %#ok Undocumented
%getField 
%
%  GETFIELD(SERIALIZER, LOCATION, NAME)

% Copyright 2004-2006 The MathWorks, Inc.

%  $Revision: 1.1.10.3 $    $Date: 2006/06/27 22:36:09 $

value = getFields(obj, entities, {name});

if numel(entities) == 1
    value = value{1};
end