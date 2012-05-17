function h = baseInitCommonProp(h, dstFieldNames, refObj)
%BASEINITCOMMONPROP Initialize common properties between modulator and
% demodulator objects defined by fieldNames

%   @modem/@baseclass

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/06 15:46:46 $

% Determine the scrFieldNames based on dstFieldNames and object types
srcFieldNames = dstFieldNames;

if isa(h, 'modem.abstractMod')
    % Copy to a mod object
    if isa(refObj, 'modem.abstractDemod')
        % Copy from a demod object
        srcFieldNames{strcmp(srcFieldNames, 'InputType')} = 'OutputType';
    end
else
    if isa(refObj, 'modem.abstractMod')
        % Copy from a mod object
        srcFieldNames{strcmp(srcFieldNames, 'OutputType')} = 'InputType';
    else
        if ~strcmpi(refObj.DecisionType, 'hard decision')
            % DecisionType = 'LLR' or 'Approximate LLR'
            % add NoiseVariance property to properties to copy
            srcFieldNames{end+1} = 'NoiseVariance';
            dstFieldNames{end+1} = 'NoiseVariance';
        end;
    end
end

% Copy from destination to source
for p=1:length(dstFieldNames)
    set(h, dstFieldNames{p}, get(refObj, srcFieldNames{p}));
end;

%-------------------------------------------------------------------------------
% [EOF]