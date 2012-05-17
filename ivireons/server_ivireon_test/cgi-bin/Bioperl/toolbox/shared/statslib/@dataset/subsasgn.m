function a = subsasgn(a,s,b)
%SUBSASGN Subscripted assignment to a dataset array.
%   A = SUBSASGN(A,S,B) is called for the syntax A(I,J)=B, A{I,J}=B, or
%   A.VAR=B when A is a dataset array.  S is a structure array with the
%   fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.
%
%   A(I,J) = B assigns the contents of the dataset array B to a subset of the
%   observations and variables in the dataset array A.  I and J are positive
%   integers, vectors of positive integers, observation/variable names, cell
%   arrays containing one or more observation/variable names, or logical
%   vectors.  The assignment does not use observation names, variable names,
%   or any other properties of B to modify properties of A; however properties
%   of A are extended with default values if the assignment expands the number
%   of observations or variables in A. Elements of B are assigned into A by
%   position, not by matching names.
%
%   A{I,J} = B assigns the value B into an element of the dataset array A.  I
%   and J are positive integers, or logical vectors.  Cell indexing cannot
%   assign into multiple dataset elements, that is, the subscripts I and J
%   must each refer to only a single observation or variable.  B is cast to
%   the type of the target variable if necessary.  If the dataset element
%   already exists, A{I,J} may also be followed by further subscripting as
%   supported by the variable.
%
%   For dataset variables that are cell arrays, assignments such as
%   A{1,'CellVar'} = B assign into the contents of the target dataset element
%   in the same way that {}-indexing of an ordinary cell array does.
%
%   For dataset variables that are N-D arrays, i.e., each observation is a
%   matrix or array, assignments such as A{1,'ArrayVar'} = B assigns into the
%   second and following dimensions of the target dataset element, i.e., the
%   assignment adds a leading singleton dimension to B to account for the
%   observation dimension of the dataset variable.
%
%   A.VAR = B or A.(VARNAME) = B assigns B to a dataset variable.  VAR is a
%   variable name literal, or VARNAME is a character variable containing a
%   variable name.  If the dataset variable already exists, the assignment
%   completely replaces that variable.  To assign into an element of the
%   variable, A.VAR or A.(VARNAME) may be followed by further subscripting as
%   supported by the variable.  In particular, A.VAR(OBSNAMES,...) = B and
%   A.VAR{OBSNAMES,...} = B (when supported by VAR) provide assignment into a
%   dataset variable using observation names.
%
%   A.PROPERTIES.PROPERTYNAME = P assigns to a dataset property.  PROPERTYNAME
%   is 'ObsNames', 'VarNames', 'Description', 'VarDescription', 'Units',
%   'DimNames', or 'UserData'.  To assign into an element of the property,
%   A.PROPERTIES.PROPERTYNAME may also be followed by further subscripting as
%   supported by the property.
%
%
%   LIMITATIONS:
%
%      You cannot assign multiple values into dataset variables or properties
%      using assignments such as [A.CellVar{1:2}] = B,
%      [A.StructVar(1:2).field] = B, or [A.Properties.ObsNames{1:2}] = B.  Use
%      multiple assignments of the form A.CellVar{1} = B instead.
%
%      Similarly, if a dataset variable is a cell array with multiple columns
%      or is an N-D cell array, then the contents of that variable for a
%      single observation consists of multiple cells, and you cannot assign to
%      all of them using the syntax A{1,'CellVar'} = B.  Use multiple
%      assignments of the form [A.CellVar{1,1}] = B instead.
%
%   See also DATASET, DATASET/SUBSREF, DATASET/SET.

%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2010/02/08 22:53:54 $

creating = isequal(a,[]);
if creating
    a = dataset;
end

switch s(1).type
case '()'
    % '()' is assignment into a subset of obs/vars from another dataset.  No
    % cascaded subscripts are allowed to follow this.

    if numel(s(1).subs) ~= a.ndims
        error('stats:dataset:subsasgn:NDSubscript', ...
              'Dataset array subscripts must be two-dimensional.');
    elseif ~isscalar(s)
        error('stats:dataset:subsasgn:InvalidSubscriptExpr', ...
              '()-indexing must appear last in a dataset array index expression.');
    end
    
    
    % If a new dataset is being created, or if the LHS is 0x0, then interpret
    % ':' as the size of the corresponding dim from the RHS, not as nothing.
    deleting = issqrbrktliteral(b);
    colonFromRHS = ~deleting && (creating || max(size(a))==0);
    
    % Translate observation (row) names into indices (leave ':' alone)
    if colonFromRHS && iscolon(s(1).subs{1})
        obsIndices = 1:b.nobs;
        numObsIndices = b.nobs;
        maxObsIndex = b.nobs;
        newObsNames = {};
    else
        [obsIndices,numObsIndices,maxObsIndex,newObsNames] = ...
                                  getobsindices(a, s(1).subs{1}, ~deleting);
    end

    % Translate variable (column) names into indices (translate ':' to 1:nvars)
    if colonFromRHS && iscolon(s(1).subs{2})
        varIndices = 1:b.nvars;
        newVarNames = b.varnames;
    else
        [varIndices,newVarNames] = getvarindices(a, s(1).subs{2}, ~deleting);
    end

    % Syntax:  a(obsIndices,:) = []
    %          a(:,varIndices) = []
    %          a(obsIndices,varIndices) = [] is illegal
    %
    % Deletion of complete observations or entire variables.
    if deleting
        % Delete observations across all variables
        if iscolon(s(1).subs{2})
            if isnumeric(obsIndices)
                obsIndices = unique(obsIndices);
                numObsIndices = numel(obsIndices);
            end
            newNobs = a.nobs - numObsIndices;
            for j = 1:a.nvars
                var_j = a.data{j};
                if ndims(var_j) == 2
                    var_j(obsIndices,:) = []; % without using reshape, may not be one
                else
                    sizeOut = size(var_j); sizeOut(1) = newNobs;
                    var_j(obsIndices,:) = [];
                    var_j = reshape(var_j,sizeOut);
                end
                a.data{j} = var_j;
            end
            if ~isempty(a.obsnames), a.obsnames(obsIndices) = []; end
            a.nobs = newNobs;

        % Delete entire variables
        elseif iscolon(s(1).subs{1})
            varIndices = unique(varIndices); % getvarindices converts all varindex types to numeric
            a.data(varIndices) = [];
            a.varnames(varIndices) = [];
            a.nvars = a.nvars - numel(varIndices);
            % Var-based properties need to be shrunk.
            if ~isempty(a.props.VarDescription), a.props.VarDescription(varIndices) = []; end
            if ~isempty(a.props.Units), a.props.Units(varIndices) = []; end

        else
            error('stats:dataset:subsasgn:InvalidEmptyAssignment', ...
                  'At least one subscript must be '':'' for empty assignment.');
        end

    % Syntax:  a(obsIndices,varIndices) = b
    %
    % Assignment from a dataset.  This operation is supposed to replace or
    % grow at the level of the _dataset_.  So no internal reshaping of
    % variables is allowed -- we strictly enforce sizes. In other words, the
    % existing dataset has a specific size/shape for each variable, and
    % assignment at this level must respect that.
    elseif isa(b,'dataset')
        if b.nobs ~= numObsIndices
            error('stats:dataset:subsasgn:ObsDimensionMismatch', ...
                  'The number of dataset observations in an assignment must match.');
        end
        if b.nvars ~= length(varIndices)
            error('stats:dataset:subsasgn:VarDimensionMismatch', ...
                  'The number of dataset variables in an assignment must match.');
        end

        existingVarLocs = find(varIndices <= a.nvars);
        for j = existingVarLocs
            var_j = a.data{varIndices(j)};
            % The size of the RHS has to match what it's going into.
            sizeLHS = size(var_j); sizeLHS(1) = numObsIndices;
            if ~isequal(sizeLHS, size(b.data{j}))
                error('stats:dataset:subsasgn:DimensionMismatch', ...
                      'Subscripted assignment dimension mismatch for dataset variable ''%s''.',a.varnames{j});
            end
            if iscolon(obsIndices)
                var_j = b.data{j};
            else
                try
                    var_j(obsIndices,:) = b.data{j}(:,:);
                catch ME, throw(ME); end
            end
            % No need to check for size change, RHS and LHS are identical sizes.
            a.data{varIndices(j)} = var_j;
        end

        % Add new variables if necessary
        newVarLocs = find(varIndices > a.nvars);
        if ~isempty(newVarLocs)
            genvalidnames(newVarNames,false); % error if any invalid

            a.data = [a.data cell(1,length(newVarNames))];
            for j = 1:length(newVarNames)
                var_b = b.data{newVarLocs(j)};
                if iscolon(obsIndices)
                    var_j = var_b;
                else
                    % Start the new variable out as 0-by-(trailing size of b),
                    % then let the assignment add rows.
                    var_j = repmat(var_b,[0 ones(1,ndims(var_b)-1)]);
                    var_j(obsIndices,:) = var_b(:,:);
                end
                % A new var may need to grow to fit the dataset
                if size(var_j,1) < a.nobs
                    warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                            'Observations with default values added to dataset variable ''%s''.',newVarNames{j});
                    var_j = lengthenVar(var_j, a.nobs);
                end
                a.data{a.nvars+j} = var_j;
            end
            LHSVars = 1:a.nvars;
            RHSVars = 1:b.nvars;
            a.varnames = [a.varnames newVarNames];
            a.nvars = a.nvars + length(newVarNames);
            % Var-based properties need to be extended.
            a.props.VarDescription = catVarProps(a.props.VarDescription,b.props.VarDescription,LHSVars,RHSVars);
            a.props.Units = catVarProps(a.props.Units,b.props.Units,LHSVars,RHSVars);
        end

        if (maxObsIndex > a.nobs)
            % Don't warn if a had no variables originally
            if a.nvars > b.nvars
                warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                        'Observations with default values added to dataset variables.');
            end
            a = fillInDataset(a,maxObsIndex,newObsNames);
        end

    else
        % There's no compelling reason to accept raw values with the '()'
        % subscripting syntax:  with a single element, you can use '{}'
        % subscripting to assign raw values, or with a single variable, you
        % can use dot subscripting.  With multiple variables, you'd have to
        % wrap them up either in a dataset, which we do accept above, or in
        % something like a structure or cell array, and that's a bit arcane.
        error('stats:dataset:subsasgn:InvalidRHS', ...
              'Right hand side must be a dataset array.');
    end

case '{}'
    % '{}' is assignment of raw values into a dataset element.  Could be any
    % sort of subscript following that.  The shape of the element differs,
    % depending on the dimensionality of the var: if the var is nxp, the
    % element is 1xp, while if the var is nxpxqx..., the element is pxqx... .
    % This is much like time series behavior.  Also, if the var is a column of
    % cells, then the element is technically a scalar cell, but it seems
    % sensible to do one extra "contents of", and not force callers to say
    % a{i,j}{1}.
    if numel(s(1).subs) ~= a.ndims
        error('stats:dataset:subsasgn:NDSubscript', ...
              'Dataset array subscripts must be two-dimensional.');
    end

    % Translate observation (row) names into indices (leaves ':' alone)
    [obsIndex,numObsIndices,maxObsIndex,newObsNames] = ...
                            getobsindices(a, s(1).subs{1}, true);

    % Translate variable (column) names into indices (translates ':').  Do not
    % allow variable creation with {}-indexing.
    varIndex = getvarindices(a, s(1).subs{2}, false);

    if numObsIndices > 1 || ~isscalar(varIndex)
        error('stats:dataset:subsasgn:MultipleElementAssignment', ...
              'Cannot assign to multiple dataset elements using {} indexing.');
    end

    % Extract an existing var
    var_j = a.data{varIndex};

    % Syntax:  a{obsIndex,varIndex} = b
    %
    % Assignment to an element of a dataset.
    if isscalar(s)
        if issqrbrktliteral(b) && ~iscell(var_j)
            error('stats:dataset:subsasgn:InvalidEmptyAssignmentToElement', ...
                  'Cannot assign [] to an element of a non-cell dataset variable.');
        elseif iscell(var_j)
            if numel(var_j) == size(var_j,1)
                % If the element is a scalar cell, assign into its contents.
                var_j{obsIndex,:} = b;
            else
                error('stats:dataset:subsasgn:MultipleCellAssignment', ...
                      'Assignment to multiple cells not allowed.');
            end
        else
            % Set up a subscript expression that will assign to the entire
            % element for the specified observation/variable.  Size checks
            % will be handled by a{i,j}'s subsasgn.
            subs{1} = obsIndex; subs{2:ndims(var_j)} = ':';
            try
                var_j(subs{:}) = b;
            catch ME, throw(ME); end
            % *** this error may not even be possible ***
            if size(var_j,1) ~= a.nobs
                error('stats:dataset:subsasgn:InvalidVarReshape', ...
                      ['You may not change the number of observations in a dataset variable\n' ...
                       'by an assignment to an element.']);
            end
        end

    % Syntax:  a{obsIndex,varIndex}(...) = b
    %          a{obsIndex,varIndex}{...} = b
    %          a{obsIndex,varIndex}.name = b
    %
    % Assignment into an element of a dataset.  This operation is allowed
    % to change the shape of the variable, as long as the number of rows
    % does not change.
    else % ~isscalar(s)
        if iscell(var_j)
            if numel(var_j) == size(var_j,1)
                % If the element is a scalar cell, assign into its contents
                s(1).subs = {obsIndex}; % s(1).type is already '{}'
            else
                error('stats:dataset:subsasgn:MultipleCellAssignment', ...
                      'Assignment to multiple cells not allowed.');
            end

        else
            % Transfer the observation index from the dataset-level
            % subscript expression to the beginning of the existing
            % element subscript expression, and do the assignment at
            % the element level.
            s(2).subs = [obsIndex s(2).subs];
            s = s(2:end);
        end

        % Let a{i,j}'s subsasgn handle the cascaded subscript expressions.
        
        % *** subsasgn allows certain operations that the interpreter
        % *** would not, for example, changing the shape of var_j by
        % *** assignment.
        if isscalar(s) % ~iscell(var_j) && length(s_original)==2
            if isobject(var_j)
                % In-place assignment, without a LHS, may not work with
                % an object, because an overloaded subsasgn is not
                % allowed to work in-place.
                try
                    var_j = subsasgn(var_j,s,b);
                catch ME, throw(ME); end
            else
                % For built-in types, subsasgn can work in-place without a
                % LHS.  Call builtin, to get correct dispatching even if b
                % is an object.
                try
                    builtin('subsasgn',var_j,s,b);
                catch ME, throw(ME); end
            end
        else % ~iscell(var_j) && length(s_original)>2, or iscell(var_j) && length(s_original)>1
            % *** A hack to get the third and higher levels of subscripting in
            % *** things like ds{i,'Var'}(...) etc. to dispatch to the right place
            % *** when ds{i,'Var'}, or something further down the chain, is itself
            % *** a dataset.
            try
                var_j = statslibSubsasgnRecurser(var_j,s,b);
            catch ME, rethrow(ME); end % point to the line in statslibSubsasgnRecurser
        end
        
        % *** this error may not even be possible ***
        if size(var_j,1) ~= a.nobs
            error('stats:dataset:subsasgn:InvalidVarReshape', ...
                  ['You may not change the number of observations in a dataset variable\n' ...
                   'by an assignment to an element.']);
        end
    end

    % If the var is shorter than the dataset, fill it out.  This should never
    % happen; assigning into a var cannot shorten the number of rows.
    varLen = size(var_j,1);
    if varLen < a.nobs
        warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                'Observations with default values added to dataset variable ''%s''.',newVarName);
        var_j = lengthenVar(var_j, a.nobs);

    % If a var was lengthened by assignment, fill out the rest of the dataset,
    % including observation names.
    elseif varLen > a.nobs
        warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                'Observations with default values added to dataset variables.');
        a = fillInDataset(a,varLen,newObsNames);
    end

    a.data{varIndex} = var_j;

case '.'
    % Assignment to or into a variable.  Could be any sort of subscript
    % following that, but row labels are inherited from the dataset.

    % Translate variable (column) name into an index.
    varName = s(1).subs;
    if ischar(varName) && size(varName,1) == 1
        varIndex = find(strcmp(varName,a.varnames));
        isNewVar = isempty(varIndex);
        if isNewVar
            % Handle assignment to a property under the 'Properties' (virtual)
            % property, but disallow assignment to properties directly, or to
            % the 'Properties' property.
            if checkreservednames(varName)
                if strcmp(varName,'Properties')
                    if ~isscalar(s)
                        try
                            a = setproperty(a,s(2:end),b);
                        catch ME, throw(ME); end
                        return
                    else
                        error('stats:dataset:subsasgn:InvalidPropertyAssignment', ...
                              'Cannot assign to the ''.%s'' property of a dataset array.',varName);
                    end
                else % a.ObsNames, a.VarNames
                    error('stats:dataset:subsasgn:InvalidPropertyAssignment', ...
                          'Cannot assign directly to the ''%s'' property.  Use the SET method, or assign\nto it via dataset.Properties.%s',varName,varName);
                end
            end
            genvalidnames({varName},false); % error if invalid

            % If this is a new variable, it will go at the end.
            varIndex = a.nvars + 1;
        end
    else
        error('stats:dataset:subsasgn:IllegalVarSubscript', ...
              'Dataset variable names must be strings.');
    end

    % Handle empty assignment intended as deletion of an entire variable or of
    % columns/pages/etc. of a variable.  Deletion of rows in a (single)
    % variable is caught here and not allowed.  Other empty assignment
    % syntaxes may be assignment to cells or may be deletion of things deeper
    % in a non-atomic variable, neither is handled here.
    if issqrbrktliteral(b) && (isscalar(s) || isequal(s(2).type,'()'))
                               % s(2).type=='()' guarantees that length(s)==2
        if isNewVar
            error('stats:dataset:subsasgn:UnrecognizedVarName', ...
                  'Unrecognized variable name ''%s''.',varName);
        end

        % Syntax:  a.var = []
        %
        % Delete an entire variable.
        if isscalar(s)
            a.data(varIndex) = [];
            a.varnames(varIndex) = [];
            a.nvars = a.nvars - 1;
            % Var-based or properties need to be shrunk.
            if ~isempty(a.props.VarDescription), a.props.VarDescription(varIndex) = []; end
            if ~isempty(a.props.Units), a.props.Units(varIndex) = []; end

        % Syntax:  a.var(:,...) = []
        %          a.var(obsIndices,...) = [] is illegal
        %
        % Delete columns/pages/etc. of a variable, with ':' as the first index
        % in subscript.  This may change the dimensionality of the variable,
        % but won't change the number of rows because we require ':' as the
        % first index.
        else
            if ~iscolon(s(2).subs{1})
                error('stats:dataset:subsasgn:InvalidEmptyAssignment', ...
                      'You can not delete a subset of observations from a single dataset variable.');
            end

            var_j = a.data{varIndex};
            try
                var_j(s(2).subs{:}) = [];
            catch ME, throw(ME); end
            a.data{varIndex} = var_j;
        end

    else
        % Syntax:  a.var = b
        %
        % Replace an entire variable.  It may be shorter than the dataset; it
        % is filled out with default values.  It may be longer than the
        % dataset; existing vars are filled in with default values.  So this
        % is not equivalent to using a colon as the observation index, which
        % cannot change the length of a variable.
        if isscalar(s)
            if isa(b,'dataset')
                error('stats:dataset:subsasgn:DatasetVariable', ...
                      'Cannot include a dataset array as a dataset variable.  Use concatenation instead.');
            end
            var_j = b;
            newObsNames = {};

        % Syntax:  a.var(obsIndices,...) = b
        %          a.var{obsIndices,...} = b
        %          a.var{obsIndices,...} = [] (this is assignment, not deletion)
        %          a.var.field = b
        %
        % Assign to elements in a variable.  Assignment can also be used to
        % expand the variable along a not-first dimension, but expansion
        % operations are not allowed to change the number of rows.
        %
        % Cell indexing, e.g. a.var{obsIndices,...}, or a reference to a
        % field, e.g. a.var.field, may also be followed by deeper levels of
        % subscripting.
        else % ~isscalar(s)
            if isNewVar && (length(s) > 2)
                % Cannot create a new var implicitly by deeper indexing.
                error('stats:dataset:subsasgn:UnrecognizedVarName', ...
                      'Unrecognized variable name ''%s''.',varName);
            end
            if isequal(s(2).type,'.') % dot indexing into variable
                % No obs labels, but the variable must exist.
                if isNewVar
                    error('stats:dataset:subsasgn:UnrecognizedVarName', ...
                          'Unrecognized variable name ''%s''.',varName);
                end
                var_j = a.data{varIndex};
            else % () or {} subscripting into variable
                % Initialize a new var, or extract an existing var.
                if isNewVar
                    % Start the new var out as an empty of the b's class with
                    % the same number of rows as the dataset.
                    var_j = b(zeros(a.nobs,0));
                else
                    var_j = a.data{varIndex};
                end

                % The variable inherits observation labels from the dataset.
                % Translate labels to row numbers if necessary.
                obsIndices = s(2).subs{1};
                if iscolon(obsIndices) || islogical(obsIndices) || isnumeric(obsIndices)
                    % leave these alone
                    newObsNames = {};
                else
                    if (size(var_j,2)>1) && isscalar(s(2).subs)
                        error('stats:dataset:subsasgn:InvalidLinearIndexing', ...
                              'Linear indexing using observation labels is not allowed.');
                    end
                    [obsIndices,numObsIndices,maxObsIndex,newObsNames] = ...
                                              getobsindices(a, obsIndices, true);
                    s(2).subs{1} = obsIndices;
                end
            end

            % Now let the variable's subsasgn handle the subscripting in
            % things like a.name(...) or  a.name{...} or a.name.attribute
            
            % *** subsasgn allows certain operations that the interpreter
            % *** would not, for example, changing the shape of var_j by
            % *** assignment.
            if length(s) == 2
                if isobject(var_j)
                    % In-place assignment, without a LHS, may not work with
                    % an object, because an overloaded subsasgn is not
                    % allowed to work in-place.
                    try
                        var_j = subsasgn(var_j,s(2),b);
                    catch ME, throw(ME); end
                else
                    % For built-in types, subsasgn can work in-place without a
                    % LHS.  Call builtin, to get correct dispatching even if b
                    % is an object.
                    try
                        builtin('subsasgn',var_j,s(2),b);
                    catch ME, throw(ME); end
                end
            else % length(s) > 2
                % *** A hack to get the third and higher levels of subscripting in
                % *** things like ds.Var{i}(...) etc. to dispatch to the right place
                % *** when ds.Var{i}, or something further down the chain, is itself
                % *** a dataset.
                try
                    var_j = statslibSubsasgnRecurser(var_j,s(2:end),b);
                catch ME, rethrow(ME); end % point to the line in statslibSubsasgnRecurser
            end
        end

        % If this is a new variable, make it official.
        if isNewVar
            a.varnames = [a.varnames varName];
            a.nvars = varIndex;
            % Var-based properties need to be extended.
            if ~isempty(a.props.VarDescription), a.props.VarDescription = [a.props.VarDescription {''}]; end
            if ~isempty(a.props.Units), a.props.Units = [a.props.Units {''}]; end
        end

        % If a var was replaced, or a new var was created, and it is
        % shorter than the dataset, fill it out.  It's never the case that
        % assigning into a var can shorten it.
        varLen = size(var_j,1);
        if varLen < a.nobs
            warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                    'Observations with default values added to dataset variable ''%s''.',varName);
            var_j = lengthenVar(var_j,a.nobs);
        end
        a.data{varIndex} = var_j;

        % If a var was expanded by assignment, or if a var was replaced or
        % created, and it is longer than the dataset, fill out the rest of
        % the dataset, including observation names.
        if varLen > a.nobs
            % Don't warn if a had no variables originally
            if a.nvars > 1
                warning('stats:dataset:subsasgn:DefaultValuesAdded', ...
                        'Observations with default values added to dataset variables.');
            end
            a = fillInDataset(a,varLen,newObsNames);
        end
    end
end


%-----------------------------------------------------------------------------
function b = createVar(a,n)
% Create an empty with a specified type and number of rows.
b = a(zeros(n,0));


%-----------------------------------------------------------------------------
function b = lengthenVar(a,n)
% Lengthen an existing variable out to n rows.
m = size(a,1);
b = a;
if isnumeric(a)
    b(m+1:n,:) = 0;
elseif islogical(a)
    b(m+1:n,:) = false;
elseif isa(a,'categorical')
    b(m+1:n,:) = char(''); % objects bug work-around.
elseif iscell(a)
    b(m+1:n,:) = {[]};
else % including struct and objects
    if ndims(a) == 2
        b(n+1,:) = b(1,:); b = b(1:n,:); % without using reshape, may not be one
    else
        sizeOut = size(a); sizeOut(1) = n;
        b(n+1,:) = b(1,:); b = reshape(b(1:n,:),sizeOut);
    end
end


%-----------------------------------------------------------------------------
function a = fillInDataset(a,newLen,newObsNames)
% Fill in variables that are too short in a dataset
for j = 1:a.nvars
    if size(a.data{j},1) < newLen
        a.data{j} = lengthenVar(a.data{j}, newLen);
    end
end

% If the original dataset had observation names, append the names for the new
% observations, or append default names
if ~isempty(a.obsnames)
    if ~isempty(newObsNames)
        a.obsnames = [a.obsnames; newObsNames];
    elseif newLen > a.nobs
        a.obsnames = ...
            [a.obsnames; strcat({'Obs'},num2str(((a.nobs+1):newLen)','%d'))];
    end
% If the new observations have observation names and the original dataset
% doesn't, create default names for the dataset
elseif ~isempty(newObsNames) % && isempty(a.obsnames)
    if a.nobs > 0
        a.obsnames = ...
            [strcat({'Obs'},num2str((1:a.nobs)','%d')); newObsNames];
    else
        a.obsnames = newObsNames;
    end
end
% Otherwise, do not create observation names if there were none.

a.nobs = newLen;
