function tf = isPositiveIntegerValuedNumeric(values,zeroAllowed)
%ISPOSITIVEINTEGERVALUEDNUMERIC  Private utility function for parallel

%isPositiveIntegerValuedNumeric return if all elements have
%   positive, numeric integer values.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.8.5 $  $Date: 2010/05/10 17:07:05 $

if nargin < 2
   zeroAllowed = false;
end

% Exit early for non-numeric data since isnumeric checks the 
% whole array in one call, without looping.  
if ~isnumeric( values )
    tf = false;
    return;
else
    tf = true;
end

for i = 1 : numel(values)
    value = values(i);
    if ~isfinite(value)
        tf = false;
        return;
    end
    if zeroAllowed
        if value < 0
            tf = false;
            return;
        end
    else
        if value <= 0
            tf = false;
            return;
        end
    end
    if round(value) ~= value
        tf = false;
        return;
    end
end
