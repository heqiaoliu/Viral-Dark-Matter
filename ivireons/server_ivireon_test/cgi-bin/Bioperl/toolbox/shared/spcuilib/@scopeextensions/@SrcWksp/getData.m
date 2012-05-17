function data = getData(this, startTime, endTime)
%GETDATA  Get the data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:43 $

data.values = this.DataHandler.getFrameData;
data.time   = this.Data.Time;

data.dimensions = size(data.values)';

% [EOF]
