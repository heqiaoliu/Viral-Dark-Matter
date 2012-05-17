classdef (Sealed = true) VariableSubset
%VariableSubset defines a part of a MATLAB array.
%   VariableSubset(NAME, SUBSETS) is a class that describes a part of a
%   MATLAB array.  NAME is a string corresponding to the name of the
%   array and must be a legal MATLAB variable name.  SUBSETS is an object
%   that defines an index into part of the array NAME.
%
%   For example, the following produces a 6-by-5 VariableSubset, varSub.
%     subsets = internal.matlab.language.Subset('()',{[5 10], [1 5 26]})
%     varSub = internal.matlab.language.VariableSubset('aVarName',subsets)
%
%   See also Subset, SAVE, LOAD

% Copyright 2009 The MathWorks, Inc.

properties (SetAccess = private)
    Name;
    Subsets@internal.matlab.language.Subset;
end % properties

methods
    function obj = set.Name(obj, name)
        if ~ischar(name) 
            throwAsCaller(MException('MATLAB:VariableSubset:nameNotChar',...
                'The Name argument must be a char array'));
        end
        if ~isvarname(name)
            throwAsCaller(MException('MATLAB:VariableSubset:notAVariableName',...
                'The specified Name, ''%s'', must be a valid variable name.',name));
        end
        obj.Name = name;
    end

    function obj = VariableSubset(name, subsets)
        obj.Name = name;
        obj.Subsets = subsets;
    end
end % methods

end % classdef
