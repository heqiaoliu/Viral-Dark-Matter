function rawData = getRawData(this, portIndex)
%GETRAWDATA Get the rawData.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:59 $

rawData = this.RawData;
if nargin > 1
    rawData = rawData{portIndex};
end

% [EOF]
