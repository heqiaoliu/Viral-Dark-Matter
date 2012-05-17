function datatypes = getAllTypes()
; %#ok Undocumented
% Returns all the data types that we have information about.

%   Copyright 2007 The MathWorks, Inc.

obj = distcomp.typechecker.pGetInstance();
datatypes = {obj.PropertyInfo.Type};
    
