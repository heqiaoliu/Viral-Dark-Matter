function data = getData(this, startTime, endTime)
%GETDATA  Get the data.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:47 $

rawValues = this.DataHandler.getFrameData;
data.values = rawValues(:);
data.time   = this.Data.Time;

dims = this.Data.Dimensions;
if strcmp(this.Data.ColorSpace, 'rgb')
    dims = [dims 3];
end

data.dimensions = dims(:);

% [EOF]
