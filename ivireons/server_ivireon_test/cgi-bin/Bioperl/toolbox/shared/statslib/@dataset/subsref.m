function [varargout] = subsref(a,s)
%SUBSREF Subscripted reference for a dataset array.
%   B = SUBSREF(A,S) is called for the syntax A(I,J), A{I,J}, or A.VAR
%   when A is a dataset array.  S is a structure array with the fields:
%       type -- string containing '()', '{}', or '.' specifying the
%               subscript type.
%       subs -- Cell array or string containing the actual subscripts.
%
%   B = A(I,J) returns a dataset array that contains a subset of the
%   observations and variables in the dataset array A.  I and J are positive
%   integers, vectors of positive integers, observation/variable names, cell
%   arrays containing one or more observation/variable names, or logical
%   vectors.  B contains the same property values as A, subsetted for
%   observations or variables where appropriate.
%
%   B = A{I,J} returns an element of a dataset variable.  I and J are positive
%   integers, or logical vectors.  Cell indexing cannot return multiple
%   dataset elements, that is, the subscripts I and J must each refer to only
%   a single observation or variable.  A{I,J} may also be followed by further
%   subscripting as supported by the variable.
%
%   For dataset variables that are cell arrays, expressions such as A{1,'CellVar'}
%   return the contents of the referenced dataset element in the same way that
%   {}-indexing on an ordinary cell array does.  If the dataset variable is a
%   single column of cells, the contents of a single cell is returned.  If the
%   dataset variable has multiple columns or is N-D, multiple outputs containing
%   the contents of multiple cells are returned.
%
%   For dataset variables that are N-D arrays, i.e., each observation is a
%   matrix or an array, expressions such as A{1,'ArrayVar'} return
%   A.ArrayVar(1,:,...) with the leading singleton dimension squeezed out.
%
%   B = A.VAR or A.(VARNAME) returns a dataset variable.  VAR is a variable
%   name literal, or VARNAME is a character variable containing a variable
%   name.  A.VAR or A.(VARNAME) may also be followed by further subscripting as
%   supported by the variable.  In particular, A.VAR(OBSNAMES,...) and
%   A.VAR{OBSNAMES,...} (when supported by VAR) provide subscripting into a
%   dataset variable using observation names.
%
%   P = A.PROPERTIES.PROPERTYNAME returns a dataset property.  PROPERTYNAME is
%   'ObsNames', 'VarNames', 'Description', 'VarDescription', 'Units', 'DimNames',
%   or 'UserData'.  A.PROPERTIES.PROPERTYNAME may also be followed by further
%   subscripting as supported by the property.
%
%   LIMITATIONS:
%
%      Subscripting expressions such as A.CellVar{1:2}, A.StructVar(1:2).field,
%      or A.Properties.ObsNames{1:2} are valid, but result in SUBSREF
%      returning multiple outputs in the form of a comma-separated list.  If
%      you explicitly assign to output arguments on the LHS of an assignment,
%      for example, [cellval1,cellval2] = A.CellVar{1:2}, those variables will
%      receive the corresponding values. However, if there are no output
%      arguments, only the first output in the comma-separated list is
%      returned.
%
%      Similarly, if a dataset variable is a cell array with multiple columns
%      or is an N-D cell array, then subscripting expressions such as
%      A{1,'CellVar'} result in SUBSREF returning the contents of multiple
%      cells.  You should explicitly assign to output arguments on the LHS of
%      an assignment, for example, [cellval1,cellval2] = A{1,'CellVar'}.
%
%   See also DATASET, DATASET/SUBSASGN, DATASET/GET.

%   Copyright 2006-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.5 $  $Date: 2010/02/08 22:53:55 $

switch s(1).type
case '()'
    % '()' is a reference to a subset of obs/vars that returns a dataset.
    
    % Parenthesis indexing can only return a single thing.
    if nargout > 1
        error('stats:dataset:subsref:TooManyOutputs', ...
              'Too many outputs.');

    % No cascaded subscripts are allowed to follow parenthesis indexing.
    elseif ~isscalar(s)
        error('stats:dataset:subsref:InvalidSubscriptExpr', ...
              '() indexing must appear last in a dataset array index expression.');
    
    elseif numel(s(1).subs) ~= a.ndims
        error('stats:dataset:subsref:NDSubscript', ...
              'Dataset array subscripts must be two-dimensional.');
    end
       
    % Translate observation (row) names into indices (leaves ':' alone)
    [obsIndices, numObsIndices] = getobsindices(a, s(1).subs{1});
    
    % Translate variable (column) names into indices (translates ':')
    varIndices = getvarindices(a, s(1).subs{2});

    % Create the output dataset and move everything over, including the
    % properties. The RHS subscripts may have picked out the same observation
    % or variable more than once, have to make sure names are uniqued.
    b = dataset;
    b.ndims = 2;
    b.nobs = numObsIndices;
    if ~isempty(a.obsnames), b.obsnames = genuniquenames(a.obsnames(obsIndices)); end
    b.nvars = numel(varIndices);
    b.varnames = genuniquenames(a.varnames(varIndices));
    b.data = cell(1,b.nvars);
    for j = 1:b.nvars
        var_j = a.data{varIndices(j)};
        if ndims(var_j) == 2
            b.data{j} = var_j(obsIndices,:); % without using reshape, may not have one
        else
            % Each var could have any number of dims, no way of knowing,
            % except how many rows they have.  So just treat them as 2D to get
            % the necessary rows, and then reshape to their original dims.
            sizeOut = size(var_j); sizeOut(1) = b.nobs;
            b.data{j} = reshape(var_j(obsIndices,:), sizeOut);
        end
    end
    b.props = a.props;
    % Var-based or obs-based properties need to be subscripted.
    if ~isempty(a.props.VarDescription), b.props.VarDescription = a.props.VarDescription(varIndices); end
    if ~isempty(a.props.Units), b.props.Units = a.props.Units(varIndices); end
    varargout{1} = b;

case '{}'
    % '{}' is a reference to an element in a dataset.  Could be any sort
    % of subscript following that.  The shape of the element differs,
    % depending on the dimensionality of the var: if the var is nxp, the
    % element is 1xp, while if the var is nxpxqx..., the element is
    % pxqx... .  This is much like time series behavior.  Also, if the var
    % is a column of cells, then the element is technically a scalar cell,
    % but it seems sensible to do one extra "contents of", and not force
    % callers to say a{i,j}{1}.

    if numel(s(1).subs) ~= a.ndims
        error('stats:dataset:subsref:NDSubscript', ...
              'Dataset array subscripts must be two-dimensional.');
    end

    % Translate observation (row) names into indices (leaves ':' alone)
    [obsIndices, numObsIndices] = getobsindices(a, s(1).subs{1});
    
    % Translate variable (column) names into indices (translates ':')
    varIndices = getvarindices(a, s(1).subs{2});

    % Curly brace indexing at the dataset level with multiple subscripts might
    % be expected to be able to return a comma-separated list of dataset
    % elements, but we restrict that for simplicity -- we'd have to deal with
    % multiple variables, and allowing deeper levels of subscripting also
    % becomes less straightforward.  Catch multi-element cell references here
    % as errors. ':' is ok as either a obs or var index as long as it resolves
    % to a singleton.
    if (numObsIndices > 1) || ~isscalar(varIndices)
        error('stats:dataset:subsref:MultipleSubscriptCellIndexing', ...
              'Cannot reference multiple elements using cell indexing.');
    end
    % However, we do return multiple outputs when cascaded subscripts resolve
    % to multiple things and result in comma-separated lists.
    
    var_j = a.data{varIndices};
    if ndims(var_j) == 2
        b = var_j(obsIndices,:); % without using reshape, may not have one
    else
        % The var could have any number of dims.  Treat it as 2D to get the
        % necessary row, and then reshape to its original dims, then strip
        % off the leading singleton dim.
        sizeOut = size(var_j);
        b = reshape(var_j(obsIndices,:), sizeOut(2:end));
    end

    % If the var is cell-valued, pull out the contents.  This may result in a
    % comma-separated list, so ask for and assign to as many outputs as we're
    % given.  nargout will be equal to the number of LHS outputs, or one when
    % there's zero LHS outputs (because the overloaded numel gets called on
    % the top-level subscripting, and that's one dataset element).  So again
    % nargout will work for CSLs, although for no LHS, this only assigns one
    % output and drops everything else in the CSL.
    if iscell(b)
        if isscalar(s)
            try
                [varargout{1:nargout}] = b{:};
            catch ME, throw(ME); end
        else
            if isscalar(b)
                % *** A hack to get the second (third, really) level of subscripting
                % *** in things like ds{i,'Var'}(...) etc. to dispatch to the right
                % *** place when ds{i,'Var'} is itself a dataset.
                try
                    [varargout{1:nargout}] = statslibSubsrefRecurser(b{:},s(2:end));
                catch ME, rethrow(ME); end % point to the line in statslibSubsrefRecurser
            else
                error('stats:dataset:subsref:BadCellRef', ...
                      'Bad cell reference operation.');
            end
        end
        
    elseif isscalar(s)
        % If there's no cascaded subscripting, return the dataset element.
        varargout{1} = b;
        
    else % ~isscalar(s)
        % b = a{i,j} is a single dataset element, let its subsref handle any
        % remaining cascaded subscripts.  This may return a comma-separated list
        % when the cascaded subscripts resolves to multiple things, so ask for and
        % assign to as many outputs as we're given.  nargout will be equal to the
        % number of LHS outputs, or one when there's zero LHS outputs (because the
        % overloaded numel gets called on the top-level subscripting, and that's
        % one dataset element).  So, fortuitously, nargout will work for CSLs,
        % although for no LHS, this only assigns one output and drops everything
        % else in the CSL.
        if length(s) == 2
            try
                [varargout{1:nargout}] = subsref(b,s(2));
            catch ME, throw(ME); end
        else % length(s) > 2
            % *** A hack to get the third and higher levels of subscripting in
            % *** things like ds.Var{i}(...) etc. to dispatch to the right place
            % *** when ds.Var{i}, or something further down the chain, is itself
            % *** a dataset.
            try
                [varargout{1:nargout}] = statslibSubsrefRecurser(b,s(2:end));
            catch ME, rethrow(ME); end % point to the line in statslibSubsrefRecurser
        end
    end
        
case '.'
    % A reference to a variable or a property.  Could be any sort of subscript
    % following that.  Row names for () and {} subscripting on variables are
    % inherited from the dataset.
    
    % Translate variable (column) name into an index.
    varName = s(1).subs;
    if ischar(varName) && size(varName,1) == 1
        varIndex = find(strcmp(varName,a.varnames));
        if isempty(varIndex)
            % If there's no such var, it may be a reference to the 'properties'
            % (virtual) property.  Handle those, but disallow references to
            % any property directly.
            if strcmp(varName,'Properties')
                if isscalar(s)
                    varargout{1} = get(a);
                else
                    % If there's cascaded subscripting into the property, let the
                    % property's subsasgn handle the reference. This may result
                    % in a comma-separated list, so ask for and assign to as many
                    % outputs as we're given.  If there's no LHS to the original
                    % expression, then we're given nargout==0, and this only
                    % assigns one output and drops everything else in the CSL.
                    try
                        [varargout{1:nargout}] = getproperty(a,s(2:end));
                    catch ME, throw(ME); end
                end
                return
            elseif checkreservednames(varName)
                error('stats:dataset:subsref:IllegalPropertyReference', ...
                      'Cannot access the ''%s'' property directly.  Use the GET method, or access\nit via dataset.Properties.%s',varName,varName);
            else
                error('stats:dataset:subsref:UnrecognizedVarName', ...
                      'Unrecognized variable name ''%s''.',varName);
            end
        end
    else
        error('stats:dataset:subsref:IllegalVarSubscript', ...
              'Dataset variable names must be strings.');
    end

    b = a.data{varIndex};
    
    if isscalar(s)
        % If there's no cascaded subscripting, only ever assign the var itself.
        varargout{1} = b;
        
    else % ~isscalar(s)
        if ~isequal(s(2).type,'.') % () or {} subscripting after dot
            % The variable inherits observation labels from the dataset.
            % Translate labels to row numbers if necessary.
            obsIndices = s(2).subs{1};
            if iscolon(obsIndices) || islogical(obsIndices) || isnumeric(obsIndices)
                % leave these alone
            else
                obsIndices = getobsindices(a, obsIndices); % (leaves ':' alone)
                if (size(b,2)>1) && isscalar(s(2).subs)
                    error('stats:dataset:subsref:InvalidLinearIndexing', ...
                          'Linear indexing using observation labels is not allowed.');
                end
                s(2).subs{1} = obsIndices;
            end
        else
            % A reference to an attribute field, so no obs labels
        end
        
        % Now let the variable's subsref handle the remaining subscripts in
        % things like a.name(...) or  a.name{...} or a.name.attribute. This
        % may return a comma-separated list, so ask for and assign to as many
        % outputs as we're given.  If there's no LHS to the original expression,
        % then we're given nargout==0, and this only assigns one output and
        % drops everything else in the CSL.
        if length(s) == 2
            try
                [varargout{1:nargout}] = subsref(b,s(2));
            catch ME, throw(ME); end
        else % length(s) > 2
            % *** A hack to get the third and higher levels of subscripting in
            % *** things like ds.Var{i}(...) etc. to dispatch to the right place
            % *** when ds.Var{i}, or something further down the chain, is itself
            % *** a dataset.
            try
                [varargout{1:nargout}] = statslibSubsrefRecurser(b,s(2:end));
            catch ME, rethrow(ME); end % point to the line in statslibSubsrefRecurser
        end
    end
end
