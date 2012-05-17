function rawData = getRawData(this, index)
%GETRAWDATA Get the rawData.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/03/31 18:42:33 $

hRTBlock = this.RunTimeBlock;

% If we are in rapid-accel or external mode, we need to make sure that we
% have a valid runtime object to work with.
if ~isa(hRTBlock, 'Simulink.RunTimeBlock')
    hRTBlock = this.BlockHandle.RunTimeObject;
end

if isempty(hRTBlock)
    rawData = this.RawDataCache;
    if nargin > 1
        rawData = rawData{index};
    end
elseif nargin > 1
    rawData = hRTBlock.InputPort(index).Data;
else
    numInputs = getNumInputs(this);
    rawData = cell(1, numInputs);
    for indx = 1:numInputs
        rawData{indx} = hRTBlock.InputPort(indx).Data;
    end
end

% [EOF]
