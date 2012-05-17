function propVal = setInternalProp(h,eventData,propName)

% Copyright 2006 The MathWorks, Inc.

% Byspass using susref for performance
if numel(h.TsValue)>0
   h.TsValue = set(h.TsValue,propName,eventData);
end

% Fire a datachange event even though the new property value has not yet
% been assigned. It's ok because property values will be read from
% tsValue, which is up to date
h.fireDataChangeEvent(tsdata.dataChangeEvent(h,propName,[]));
propVal = eventData; 