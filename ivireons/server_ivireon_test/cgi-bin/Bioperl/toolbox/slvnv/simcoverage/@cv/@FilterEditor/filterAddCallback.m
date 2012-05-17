 function filterAddCallback(this)

%   Copyright 2009-2010 The MathWorks, Inc.
propIdx = this.filterPropertyNameIdx + 1;
valueIdx = this.filterPropertyValueIdx + 1;
if this.filterState.isKey(propIdx)
   this.filterState(propIdx) = unique([this.filterState(propIdx) valueIdx]);
else
   this.filterState(propIdx) = valueIdx;
end
