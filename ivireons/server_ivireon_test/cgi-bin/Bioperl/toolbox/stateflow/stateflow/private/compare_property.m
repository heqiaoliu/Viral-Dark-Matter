function result = compare_property(ids, property, value)

% Copyright 2005 The MathWorks, Inc.
    
result = false;

if isempty(ids)
    return;
end

for id = ids
    try
        if isempty(sf('find',id, property, value))
            return;
        end
    catch
        return;
    end
end

result = true;