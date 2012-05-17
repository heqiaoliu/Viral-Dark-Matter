function [closedLowerLimit, closedUpperLimit] = toLowerAndUpperLimit(isSigned, wordSize)
% calculate the closed set stored integer min/max values

%   Copyright 2010 The MathWorks, Inc.
    
closedUpperLimit = ( 2^(wordSize - isSigned) - 1);
    
if (isSigned)
    closedLowerLimit = -2^(wordSize-1);
else
    closedLowerLimit = 0;
end




