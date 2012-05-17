function postDeserializePins(hThis)
% After serialization, repin an object based on the "PinExists" property
% and the pin affordances. In 1-D, the affordances are found using the
% "PinExists" property entirely.

%   Copyright 2006 The MathWorks, Inc.

pinAffs = find(hThis.PinExists);
for i = pinAffs
    hThis.pinAtAffordance(i);
end