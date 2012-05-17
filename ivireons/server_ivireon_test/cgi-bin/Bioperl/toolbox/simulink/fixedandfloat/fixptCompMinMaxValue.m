function retVal = fixptCompMinMaxValue( DblValue, TotalBits, IsSigned, FixExp, FracSlope, Bias)
% fixptCompMinMaxValue
% 
%   Determine whether the input DblValue with the maximum value or 
% minimum value represented by the fixed point data type.
%
%   Returned value 1 means input value is larger than or equal to the fixed
% point maximum value. if the returned value -1 means that the input value
% is less than or equal to minimun value.
%
%   This function can compare fixed point value which can not be held by double.
%
% Usage:
%   retVal = fixptCompMinMaxValue( DblValue, TotalBits, IsSigned, FixExp, FracSlope, Bias)

%   Copyright 2007 The MathWorks, Inc.

if nargin < 6
    DAStudio.error('Shared:numericType:fixptCompValue');
else
    retVal = compDblWithMinMaxFixPtValue(DblValue,double(TotalBits), double(IsSigned),...
                                         double(FixExp), double(FracSlope), double(Bias));
end    
