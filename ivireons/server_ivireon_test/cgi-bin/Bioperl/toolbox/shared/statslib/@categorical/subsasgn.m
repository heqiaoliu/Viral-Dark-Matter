function a = subsasgn(a,s,b)
%SUBSASGN Subscripted assignment for a categorical array.
%     A = SUBSASGN(A,S,B) is called for the syntax A(I)=B.  S is a structure
%     array with the fields:
%         type -- string containing '()' specifying the subscript type.
%                 Only parenthesis subscripting is allowed.
%         subs -- Cell array or string containing the actual subscripts.
%
%   See also CATEGORICAL, CATEGORICAL/SUBSREF.

%   Copyright 2006-2009 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2009/05/07 18:27:16 $

creating = isequal(a,[]);
if creating
    a = feval(class(b));
    a = addlevels(a,getlabels(b));
end

switch s(1).type
case '()'
    % Make sure nothing follows the () subscript
    if ~isscalar(s)
        error('stats:categorical:subsasgn:InvalidSubscripting', ...
              '()-indexing must appear last in an index expression.');
    end
    if isa(b,class(a))
        % Get a's codes for b's data
        convert = zeros(1,length(b.labels)+1,class(a.codes));
        levelsAdded = false;
        for i = 1:length(b.labels)
            found = find(strcmp(b.labels{i},a.labels));
            if ~isempty(found) % a unique match
                convert(i+1) = found;
            else % no match
                levelsAdded = true;
                a.labels = [a.labels b.labels(i)];
                convert(i+1) = length(a.labels);
            end
        end
        if length(a.labels) > categorical.maxCode
            error('stats:categorical:subsasgn:MaxNumLevelsExceeded', ...
                  'Too many categorical levels.');
        elseif levelsAdded
            warning('stats:categorical:subsasgn:NewLevelsAdded', ...
                    'New categorical levels being added.');
        end
        bcodes = reshape(convert(b.codes+1), size(b.codes));
        a.codes(s.subs{:}) = bcodes;

    elseif ischar(b)
        if (size(b,1) == 1) && (ndims(b) == 2) && ~isempty(b)
            b = strtrim(b);
            bcode = find(strcmp(b,a.labels));
            if ~isempty(bcode)
                % unique match, nothing to do
            else
                warning('stats:categorical:subsasgn:NewLevelsAdded', ...
                        'Categorical level ''%s'' being added.',b);
                a.labels{end+1} = b;
                if length(a.labels) > categorical.maxCode
                    error('stats:categorical:subsasgn:MaxNumLevelsExceeded', ...
                          'Too many categorical levels.');
                end
                bcode = length(a.labels);
            end
            a.codes(s.subs{:}) = bcode;
        elseif isempty(b)
            a.codes(s.subs{:}) = 0;
        else
            error('stats:categorical:subsref:MultipleStringAssignmentNotAllowed', ...
                  'Multiple assignment of strings to a categorical array is not supported.');
        end
        
    elseif issqrbrktliteral(b)
        a.codes(s.subs{:}) = [];
        
    else
        error('stats:categorical:subsref:InvalidRHS', ...
              'Invalid RHS for assignment to a %s array.',class(a));
    end
    
case '{}'
    error('stats:categorical:subsref:CellAssignmentNotAllowed', ...
          'Cell contents assignment to a non-cell array object.')
    
case '.'
    error('stats:categorical:subsref:FieldAssignmentNotAllowed', ...
          'Attempt to assign field of non-structure array.')
end
