function h = removets(h, tsname)

% Copyright 2004-2006 The MathWorks, Inc.

h.TsValue = removets(h.TsValue,tsname);
h.fireDataChangeEvent(tsdata.dataChangeEvent(h,'removets',[]));