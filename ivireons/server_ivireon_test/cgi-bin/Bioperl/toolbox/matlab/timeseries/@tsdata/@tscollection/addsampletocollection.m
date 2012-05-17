function addsampletocollection(this,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

cacheTimes = this.TsValue.Time;
this.TsValue = addsampletocollection(this.TsValue,varargin{:});
[junk,I] = setdiff(this.TsValue.Time,cacheTimes);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'addsampletocollection',I));