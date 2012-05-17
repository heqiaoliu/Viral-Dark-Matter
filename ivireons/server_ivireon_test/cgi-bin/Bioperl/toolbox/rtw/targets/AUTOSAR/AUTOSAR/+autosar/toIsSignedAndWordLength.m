function [isSigned, wordSize] = toIsSignedAndWordLength(lowerLimit, upperLimit)
% lowerLimit and upperLimit are stored-integer values.
% When lowerLimit is < 0 then we are dealing with a signed integer
%
% For SInt8: lowerLimit = -128
%            upperLimit = 127
% wordSize can be taken from lowerLimit => abs(lowerLimit)*2 = 256
% taking log2 of this => 8
% or from upperLimit => (abs(upperLimit)+1)*2 = 256
% taking log2 of this => 8

%   Copyright 2010 The MathWorks, Inc.
    
isSigned = false;

if lowerLimit < 0
    isSigned = true;
end

if ~isSigned
    dataStepCount = upperLimit+1;
else
    if abs(lowerLimit) > abs(upperLimit)
        dataStepCount = abs(lowerLimit)*2;
    else
        dataStepCount = (abs(upperLimit)+1)*2;
    end
end

% Get the ideal wordSize
wordSize = ceil(log2(dataStepCount));

% LocalWords:  SInt
