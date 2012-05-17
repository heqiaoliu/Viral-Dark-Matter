function rawData = getRawData(this, ~)
%GETRAWDATA Get the rawData.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:41:51 $

rawData = getFrameData(this.DataHandler);

if nargin < 2
    rawData = {rawData};
end

% [EOF]
