function serialized = copy(hThis)
% Copies a scribe object

%   Copyright 2006 The MathWorks, Inc.

if ismethod(hThis,'preserialize')
   olddata = hThis.preserialize();
end
serialized = handle2struct(double(hThis));
if ismethod(hThis,'postserialize')
   hThis.postserialize(olddata);
end