function pPutField(obj, entities, name, value, saveFlags)
; %#ok Undocumented
%pPutField private put field function which has flags to save
%
%  PPUTFIELD(SERIALIZER, LOCATION, NAME, VALUE)

% Copyright 2004-2006 The MathWorks, Inc.


obj.pPutFields(entities, {name}, {value}, saveFlags);
