function I = eq(e1,e2)
%EQ Compare event objects
%
%   E1 == E2 performs element-wise comparisons between tsdata.event arrays
%   E1 and E2.  E1 and E2 must be of the same dimensions unless one is a scalar.
%   The result is a logical array of the same dimensions, where each
%   element is an element-wise equality result.
%
%   If one of E1 or E2 is scalar, scalar expansion is performed and the 
%   result will match the dimensions of the array that is not scalar.
%
%   I = EQ(E1, E2) stores the result in a logical array of the same 
%   dimensions.

%   Copyright 2005-2009 The MathWorks, Inc.

% First, if e2 is empty, return false instead of error message
if isempty(e2)
    I = false;
    return
end

if numel(e1) == numel(e2)
    for k=numel(e1):-1:1
        I(k) = localCompare(e1(k),e2(k));
    end
    I = reshape(I,size(e1));
elseif isscalar(e2)
    for k=numel(e1):-1:1
        I(k) = localCompare(e1(k),e2);
    end
    I = reshape(I,size(e1));
elseif isscalar(e1)
    for k=numel(e2):-1:1
        I(k) = localCompare(e1,e2(k));
    end
    I = reshape(I,size(e2));
else
    error('event:isequal:sizeMismatch',...
        'Two event arrays must have the same size.')
end


function result = localCompare(e1,e2)

% If e2 is empty, return false instead of error message
if isa(e2,'tsdata.event')
    if isequal(e1.EventData,e2.EventData) && strcmp(e1.Name,e2.Name) && ...
            strcmp(getTimeStr(e1),getTimeStr(e2))
        result = true;
    else
        result = false;
    end
else
    result = false;
end