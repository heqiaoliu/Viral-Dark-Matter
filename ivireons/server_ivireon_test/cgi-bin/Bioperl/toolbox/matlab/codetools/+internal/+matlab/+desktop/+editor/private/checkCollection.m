function checkCollection(collection)
%checkList checks that the given variable is a java.util.Collection. 

% Copyright 2009 The MathWorks, Inc.

    if (~isa(collection, 'java.util.Collection'))
        throw(MException('MATLAB:editor:NotACollection', ...
            'Collection should be a java.util.Collection.'));
    end
end