function h = initCommonProp(h, refObj)
%INITCOMMONPROP Initialize common properties
%   between object H and object REFOBJ

%   @modem/@mskmod

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/09/14 15:59:17 $

% Common properties that need to be copied in the correct order
dstFieldNames = {'M', ...
    'Precoding', ...
    'SamplesPerSymbol', ...
    'InputType'};

baseInitCommonProp(h, dstFieldNames, refObj);

% Update relevant state information: Adjust expected number of channels.
if strcmpi(refObj.Precoding, 'off')
    InitDiffBit = refObj.PrivInitDiffBit;
    nChan = size(InitDiffBit, 2);
    reset(h, nChan);
else
    if isa(refObj, 'modem.mskmod')
        initY = refObj.PrivInitY;
        nChan = size(initY, 2);
        reset(h, nChan);
    else
        demodStates = refObj.PrivDecimFilterI.States;
        nChan = size(demodStates, 2);
        reset(h, nChan);
    end
end

%-------------------------------------------------------------------------------
% [EOF]