function postDeserializePins(hThis)
% After serialization, repin an object based on the "PinExists" property
% and the pin affordances. In 2-D, this is based on the "PinAff" property.

%   Copyright 2006 The MathWorks, Inc.

if hThis.PinExists
    hThis.pinAtAffordance(hThis.PinAff);
end