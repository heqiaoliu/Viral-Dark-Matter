function out = isValidContainerMap(table)

%   Copyright 2010 The MathWorks, Inc.

    out = isa(table,'containers.Map') && isvalid(table);
end

