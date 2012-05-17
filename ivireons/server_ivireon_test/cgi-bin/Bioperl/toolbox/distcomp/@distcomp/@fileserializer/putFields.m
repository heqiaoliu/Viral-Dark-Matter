function putFields(obj, entity, names, values)
; %#ok Undocumented
%putFields 
%
%  PUTFIELDS(SERIALIZER, LOCATION, NAMES, VALUES)

% Copyright 2004-2006 The MathWorks, Inc.

obj.pPutFields(entity, names, values, '-append');