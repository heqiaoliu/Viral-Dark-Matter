function delsamplefromcollection(this,method,value)

% Copyright 2005-2006 The MathWorks, Inc.

cacheTimes = this.TsValue.Time;
this.TsValue = delsamplefromcollection(this.TsValue,method,value);
[junk,I] = setdiff(cacheTimes,this.TsValue.Time);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,...
    'delsamplefromcollection',I));