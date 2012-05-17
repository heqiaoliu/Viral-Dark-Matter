function isViolated = evalAssert(this, val)

%   Copyright 1997-2009 The MathWorks, Inc.
try
isViolated = ~evalDec(this, val);

catch MEx %#ok<NASGU>
    Mex.message;
end