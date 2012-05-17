function putField(obj, entity, name, value)
; %#ok Undocumented
%createFields 
%
%  CREATEFIELDS(SERIALIZER, LOCATION, NAMES, VALUES)

% Copyright 2004-2006 The MathWorks, Inc.

obj.pPutField(entity, name, value, '-append');