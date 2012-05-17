function h = loadobj(s)

% Copyright 2006 The MathWorks, Inc.

if isstruct(s)
    h = s.objH.TsValue;
else
    h = s;
end