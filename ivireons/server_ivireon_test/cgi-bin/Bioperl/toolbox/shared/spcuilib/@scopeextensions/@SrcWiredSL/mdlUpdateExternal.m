function mdlUpdateExternal(this, hRTBlock)
%MDLUPDATEEXTERNAL mdlUpdate for non-normal modes

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:38 $

% This exists so that we can fix the portHandle field of the databuffer
% which is invalidated after mdlStart when running in external mode.
this.NewData = false;
this.RunTimeBlock = hRTBlock;
dataBuffer = this.DataBuffer;
this.DataBuffer = [];

rawData = cell(1, numel(dataBuffer));

for indx = 1:numel(dataBuffer)
    dataBuffer(indx).portHandle = hRTBlock.InputPort(indx);
    rawData{indx} = dataBuffer(indx).portHandle.Data;
end

this.DataBuffer = dataBuffer;

% When we are not in normal mode, we need to save the rawdata immediately
% because it will be gone when the visual updates asynchronously.
this.RawDataCache = rawData;

mdlUpdate(this, hRTBlock);

% [EOF]
