function res = evalDec(this, val)

%   Copyright 1997-2009 The MathWorks, Inc.
try
res = false(numel(this.m_handles));

for idx = 1:numel(this.m_handles)
    cp = this.m_handles{idx};
    if isa(cp,'Sldv.Point')
        val = reshape(val,size(cp.getFlatValue));
        res(idx) = isItTrue(isequal(val,cp.getFlatValue));
    else
        lVal = cp.getFlatLow;
        hVal = cp.getFlatHigh;
        tr = (isItTrue(lVal  < val) && isItTrue(val < hVal)) || ...
             (cp.highIncluded && isItTrue(isequal(val, hVal))) || ...
             (cp.lowIncluded && isItTrue(isequal(val, lVal)));
        res(idx) = tr; 
    end
end
catch Mex
    Mex.message;
end
%===========================
function res = isItTrue(val)
res = any(val(:));

