function fireDataChangedEvent(datatype,varargin)

ed = NonlinBlackBoxPack.DataChangeEvent(this,datatype);
this.send('datachange',ed);
