classdef ( Sealed = true ) Subset
%Subset defines a part of a MATLAB array.
%   Subset(TYPE, INDEX) is an class that describes an indexing operation
%   into part of a MATLAB array.
%
%   TYPE is a string corresponding to the type of indexing operation to
%   perform.  The options are '()' for standard array indexing, '{}' for
%   cell array dereferencing, and '.' for structure field indexing. 
%
%   For '()' and '{}', INDEX is a cell array with range bounds for every
%   dimension in an array.  The bounds are either a pair, [dimStart
%   dimEnd], or a triple, [dimStart step dimEnd], of numbers.
%
%   For '.', INDEX is a cell array with fieldnames. Fieldnames must be
%   valid MATLAB structure fieldnames.
%
%   For example, the following produces a 6-by-5 aSubset.
%     aSubset = internal.matlab.language.Subset('()',{[5 10], [1 5 26]})
%
%   See also VariableSubset, SAVE, LOAD

% Copyright 2009 The MathWorks, Inc.

properties (SetAccess = private)
    Type;
    Index;
end % properties

methods
    function obj = set.Type(obj,aType)
        if  ischar(aType) && ~isempty(regexp(aType, '^(\.|\(\)|{})$', 'ONCE'))
            obj.Type = aType;
        else
            throwAsCaller(MException('MATLAB:Subset:ImproperType',...
                'Type must be one of the following strings ''()'', ''.'', ''{}''.'));
        end
    end
    
    function obj = set.Index(obj, index)
        if ~iscell(index)
            throwAsCaller(MException('MATLAB:Subset:indexNotCell',...
                'Index must be a cell array.'));
        end
      
        if ~strcmp(obj.Type,'.')
            % Check that index is a row vector.
            if ~(size(index,2) >= 2 && size(index,1)==1 && ndims(index) == 2)
                throwAsCaller(MException('MATLAB:Subset:ImproperIndexCell',...
                    'Index cell array must specify the extent of all dimensions of the variable. Linear indexing is not supported.'));
            end
        
            % Validate that the pairs and triples in the Index satisfy all the
            % conditions.
            for i = 1:length(index)
                % Validate that indices in the bounds are numeric, integer,
                % nonnegative, and a row vector
                boundsInvalid = validateBounds(index{i}, i, class(obj));
                if ~isempty(boundsInvalid)
                    throwAsCaller(boundsInvalid);
                end

                % Validate that bounds are a pair or triple
                if length(index{i}) < 2 || length(index{i}) > 3
                    throwAsCaller(MException('MATLAB:Subset:ImproperIndexBounds',...
                        'Index bounds must be a set of pairs or triples of numbers.'));
                end

                % Validate that the bounds' max > min.
                if (index{i}(1) > index{i}(end))
                    throwAsCaller(MException('MATLAB:Subset:MinMax',...
                        'The start of an Index bound must be less than the end of the Index bound.'));
                end
            end
        else
            for i = 1:length(index)
                % Check that index is a row vector.
                if ~(size(index,2) >= 1 && size(index,1)==1 && ndims(index) == 2)
                    throwAsCaller(MException('MATLAB:Subset:ImproperIndexCellForStructs',...
                        'Index cell array must be a row vector of valid MATLAB variable names.'));
                end
                if ~isvarname(index{i})
                    throwAsCaller(MException('MATLAB:Subset:indexNotFieldname',...
                        'The Index element, %d, is not a valid MATLAB variable name.',i));
                end
            end
        end
        
        obj.Index = index;
    end
    
    function obj = Subset(aType, index)
        obj.Type = aType;
        obj.Index =  index;
    end
end % methods

end % classdef

% Helper functions
function boundsInvalid = validateBounds(index, i, funName)
    boundsInvalid = MException.empty;
    try
        validateattributes(index, {'numeric'},{'integer', 'positive', 'row'}, funName)
    catch validateException
        boundsInvalid = MException('MATLAB:Subset:IndexBoundsInvalid',...
            'The index bounds for dimension %d is not a valid bound. \nSee the cause below for more info.', i);
        boundsInvalid = addCause(boundsInvalid, validateException);
    end
end
