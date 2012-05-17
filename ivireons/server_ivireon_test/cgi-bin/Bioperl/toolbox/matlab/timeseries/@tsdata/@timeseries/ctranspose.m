function ctranspose(this)

%   Copyright 2005-2009 The MathWorks, Inc.

swarn = warning('off','timeseries:ctranspose:dep_ctrans');
this.TsValue = ctranspose(this.Tsvalue);
warning(swarn);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'ctranspose',[]));



