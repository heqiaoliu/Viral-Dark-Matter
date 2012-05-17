function init(this,varargin)

% Copyright 2005-2006 The MathWorks, Inc.

this.TsValue = init(this.TsValue);
this.fireDataChangeEvent(tsdata.dataChangeEvent(this,'init',[]));