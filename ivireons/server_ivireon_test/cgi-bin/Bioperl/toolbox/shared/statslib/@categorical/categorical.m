classdef categorical
%CATEGORICAL Arrays for categorical data.
%   Categorical arrays are used to store discrete values that are not numeric.
%   A categorical array provides efficient storage and convenient manipulation
%   of such data, while also maintaining meaningful labels for the values.
%   Categorical arrays are often used as grouping variables.
%
%   CATEGORICAL is an abstract class, and you cannot create instances of it
%   directly.  You must create NOMINAL or ORDINAL arrays.
%
%   See also NOMINAL, ORDINAL, GROUPINGVARIABLE

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $  $Date: 2010/03/31 18:44:32 $

    properties(GetAccess='protected', SetAccess='protected')
        labels = {};
        codes = uint16([]);
    end
    
    properties(Constant, GetAccess='public')
        % Text label for categorical levels that are undefined.
        undefLabel = '<undefined>';
    end
        
    properties(Constant, GetAccess='protected')
        % Maximum legal value for an internal code.
        maxCode = intmax('uint16') - 1;
    end
    
    methods(Access = 'protected')
        function b = categorical(a,labels,levels,edges)
%CATEGORICAL Create a categorical array.
%   CATEGORICAL is an abstract class, and you cannot create instances of it
%   directly.  You must create NOMINAL or ORDINAL arrays.
%
%   See also NOMINAL, ORDINAL

        codesClass = class(b.codes);

        if nargin == 0
            % Nothing to do

        elseif (nargin < 4) || isempty(edges)
            % Remove spaces from character data
            if ischar(a)
                if ndims(a) > 2
                    error('stats:categorical:categorical:NDCharArrayData', ...
                          'Cannot create a categorical array from an N-D character array.');
                end
                a = strjust(a,'left'); % leave this as char for memory
            elseif iscellstr(a)
                a = strtrim(a);
            end

            % Levels given explicitly, do not reorder them
            if nargin > 2 && ~isempty(levels)
                explicitLevels = true;
                if ischar(levels)
                    if ndims(levels) > 2
                        error('stats:categorical:categorical:NDCharArrayLevels', ...
                              'LEVELS must be 2D if it is a character array.');
                    end
                    levels = strtrim(cellstr(levels));
                elseif iscellstr(levels)
                    levels = strtrim(levels(:));
                    if isa(a,'categorical') && any(strcmp(categorical.undefLabel,levels))
                        warning('stats:categorical:categorical:UndefinedLabelInLevels', ...
                                ['LEVELS contains the string ''%s''.  This will not match\n' ...
                                 'undefined elements of A.  Use a categorical array for LEVELS ' ...
                                 'instead.'], categorical.undefLabel);
                    end
                    % unique will remove duplicate empty strings
                elseif isa(levels,'categorical')
                    levels.codes = levels.codes(:); % can't use categorical subscripting
                    if  sum(isundefined(levels))>1
                        error('stats:categorical:categorical:MultipleUndefinedLevels', ...
                              'LEVELS contains multiple undefined elements.');
                    end
                else
                    levels = levels(:);
                    if isfloat(levels) && sum(isnan(levels))>1
                        error('stats:categorical:categorical:MultipleNaNLevels', ...
                              'LEVELS contains multiple NaN values.');
                    end
                end
                % Levels is now a column vector
                try
                    ulevels = unique(levels);
                catch ME
                    throw(addCause(MException('stats:categorical:categorical:UniqueMethodFailedLevels', ...
                          'Could not compute unique values in LEVELS using UNIQUE.'),ME));
                end
                if length(ulevels) < length(levels)
                    error('stats:categorical:categorical:DuplicatedLevels', ...
                          'LEVELS contains duplicated values.');
                end

            % Infer levels from the data, they are sorted
            else
                explicitLevels = false;
                if ischar(a)
                    % a has already been left justified, cellstr strips trailing spaces
                    levels = cellstr(unique(a,'rows'));
                    % '' becomes <undefined> by default, remove that from the list
                    levels = levels(cellfun('prodofsize',levels)>0);                        
                else
                    % Numeric, logical, cellstr, categorical, or anything else
                    % that has a unique method.  Cellstr will already have had
                    % leading/trailing spaces removed
                    try
                        levels = unique(a(:));
                    catch ME
                        throw(addCause(MException('stats:categorical:categorical:UniqueMethodFailedData', ...
                              'Could not compute unique values in A using UNIQUE.'),ME));
                    end
                    
                    % '' or NaN or <undefined> all become <undefined> by default, remove
                    % those from the list of levels.
                    if iscellstr(levels)
                        levels = levels(cellfun('prodofsize',levels)>0);                        
                    elseif isfloat(levels)
                        levels = levels(~isnan(levels));
                    elseif isa(levels,'categorical')
                        levels.codes = levels.codes(~isundefined(levels)); % can't use categorical subscripting
                    end
                end
            end
            if length(levels) > categorical.maxCode
                error('stats:categorical:categorical:MaxNumLevelsExceeded', ...
                      'Too many categorical levels.');
            end

            % Labels given explicitly, do not reorder them
            mergingLevels = false;
            if nargin > 1 && ~isempty(labels)
                labels = categorical.checklabels(labels,0); % error if '', or '<undefined>', but allow duplicates
                if length(labels) ~= length(levels)
                    if nargin < 3
                        error('stats:categorical:categorical:IncorrectNumLabels', ...
                              'LABELS must have one element for each unique value in A.');
                    else
                        error('stats:categorical:categorical:LengthMismatchLabelsLevels', ...
                              'LABELS and LEVELS must have the same length.');
                    end
                end
                
                % If the labels contain duplicates, those will be merged into
                % identical levels.  Remove the duplicate labels, put the
                % levels corresponding to those labels at the end so they'll
                % be easier to remove, and create a map from the levels to the
                % ultimate internal codes.
                [ulabels,i,j] = unique(labels,'first');
                mergingLevels = (length(ulabels) < length(labels));
                if mergingLevels
                    [i,iord] = sort(i);
                    iordinv(iord) = 1:length(iord); j = iordinv(j);
                    dups = setdiff(1:length(labels),i);
                    labels = labels(i(:)');
                    ord = [i(:); dups(:)];
                    levels = levels(ord);
                    mergeConvert = j(ord);
                end
                
                b.labels = labels;

            % Infer labels from the levels, which in turn may be inferred from
            % the data.  The levels have already been unique'd and turned into
            % a vector
            elseif ~isempty(levels)
                if isnumeric(levels)
                    b.labels = cellstr(num2str(levels,'%-0.5g'))';
                    if length(unique(b.labels)) < length(b.labels)
                        error('stats:categorical:categorical:CantInferNumericLabels', ...
                              ['Unable to create default labels using only 5 significant ' ...
                               'digits.\nUse the LABELS input argument.']);
                    end
                elseif islogical(levels)
                    labs = {'false' 'true'};
                    b.labels = labs(levels+1);
                % elseif ischar(levels)
                    % Char levels have already been converted to cellstr
                elseif iscellstr(levels)
                    % These may be specifying character values, or they may be
                    % specifying categorical values via their labels.
                    
                    % We will not attempt to create a label for the empty string or
                    % the undefined categorical label.  Labels must given explicitly.
                    if any(strcmp(categorical.undefLabel,levels))
                        error('stats:categorical:categorical:UndefinedLabel', ...
                              ['Cannot create a label from the string ''%s''.\n' ...
                               'Provide a value for the LABELS argument.'],categorical.undefLabel);
                    elseif any(strcmp('',levels))
                        error('stats:categorical:categorical:EmptyLabel', ...
                              ['Cannot create a label from the empty string.\n' ...
                               'Provide a value for the LABELS argument.']);
                    end
                    % Don't try to make labels out of things that aren't strings.
                    if ~all(cellfun('size',levels,1) == 1)
                        error('stats:categorical:categorical:CantInferLabels', ...
                              'Cannot create default labels.');
                    end
                    b.labels = levels(:)';
                elseif isa(levels,'categorical')
                    % We will not attempt to create a label for an undefined
                    % categorical element.  Labels must given explicitly.
                    if any(isundefined(levels))
                        error('stats:categorical:categorical:UndefinedLevel', ...
                              ['LEVELS cannot contain an undefined element unless you\n' ...
                               'provide the LABELS argument.']);
                    end
                    blabels = cellstr(levels); % can't use categorical subscripting to
                    b.labels = blabels(:)';    % get a row, force the cellstr instead
                else
                    % Anything else that has a char method
                    try
                        clevels = char(levels(:));
                    catch ME
                        throw(addCause(MException('stats:categorical:categorical:CharMethodFailedLevels', ...
                              'Could not convert LEVELS to character using CHAR.'),ME));
                    end
                    if ~ischar(clevels) || (size(clevels,1) ~= numel(levels))
                        error('stats:categorical:categorical:CharMethodFailedLevels', ...
                              'The CHAR method for LEVELS must create a character matrix with one row for each element of LEVELS.');
                    end
                    b.labels = strtrim(cellstr(clevels)');
                end
            end

            % Assign level codes to each element of output
            if isnumeric(a)
                if ~isnumeric(levels)
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be numeric when input A is numeric.');
                end
                b.codes = zeros(size(a),codesClass);
                [dum,b.codes(:)] = ismember(a,levels);
                % NaN may have been given explicitly as a level
                if any(isnan(levels))
                    b.codes(isnan(a)) = find(isnan(levels));
                end
            elseif islogical(a)
                if islogical(levels)
                    % OK, nothing to do
                elseif isnumeric(levels)
                    levels = logical(levels);
                else
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be the same class as input A.');
                end
                b.codes = zeros(size(a),codesClass);
                trueCode = find(levels);
                falseCode = find(~levels);
                % Already checked that levels contains unique values, but
                % still need to make sure it has at most one non-zero.
                if length(trueCode) > 1
                    error('stats:categorical:categorical:DuplicatedLevels', ...
                          'LEVELS contains duplicated values when cast to logical.');
                end
                if ~isempty(trueCode),  b.codes(a)  = trueCode;  end
                if ~isempty(falseCode), b.codes(~a) = falseCode; end
            elseif ischar(a)
                if ~iscellstr(levels)
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be the same class as input A.');
                end
                % a has already been left justified, levels has already had
                % leading/trailing spaces removed. strmatch ignores trailing spaces
                b.codes = zeros(size(a,1),1,codesClass);
                for i = 1:length(levels)
                    b.codes(strmatch(levels{i},a,'exact')) = i;
                end
            elseif iscellstr(a)
                if ~iscellstr(levels)
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be the same class as input A.');
                end
                % a and levels have already had leading/trailing spaces removed
                b.codes = zeros(size(a),codesClass);
                [dum,b.codes(:)] = ismember(a,levels);
            elseif isa(a,'categorical')
                % This could be done in the generic case that follows, but this
                % should be faster.
                convert = zeros(1,length(a.labels)+1,codesClass);
                if isa(levels,class(a))
                    undef = find(isundefined(levels));
                    if ~isempty(undef), convert(1) = undef; end
                    levels = cellstr(levels);
                elseif iscellstr(levels)
                    % Leave them alone
                else
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be from the same class as input A.');
                end
                [tf,convert(2:end)] = ismember(a.labels,levels);
                b.codes = reshape(convert(a.codes+1), size(a.codes));
            else % anything else that has an eq method
                if  ~isa(levels,class(a))
                    error('stats:categorical:categorical:TypeMismatchLevels', ...
                          'LEVELS must be from the same class as input A.');
                end
                b.codes = zeros(size(a),codesClass);
                for i = 1:length(levels)
                    try
                        b.codes(a==levels(i)) = i;
                    catch ME
                        throw(addCause(MException('stats:categorical:categorical:EQMethodFailedDataLevels', ...
                              'Could not compare values in A and LEVELS using the equality operator.'),ME));
                    end
                end
            end
            if any(b.codes(:) == 0) && explicitLevels
                warning('stats:categorical:categorical:ExtraLevels', ...
                        'Input A contains values not present in LEVELS.');
            end
            
            % Merge levels that were given identical labels.
            if mergingLevels
                b.codes = reshape(mergeConvert(b.codes),size(b.codes));
            end

        else %if ~isempty(edges)
            if ~isempty(levels)
                error('stats:categorical:categorical:LevelAndEdges', ...
                      'LEVELS and EDGES cannot both be given.');
            elseif ~isnumeric(a) || ~isreal(a)
                error('stats:categorical:categorical:EdgesWithNonnumericData', ...
                      'Input must be real numeric when EDGES is given.');
            elseif ~isnumeric(edges) || ~isreal(edges)
                error('stats:categorical:categorical:NonnumericEdges', ...
                      'EDGES must be real numeric.');
            elseif ~isvector(edges) || length(edges) < 2
                error('stats:categorical:categorical:NonvectorEdges', ...
                      'EDGES must be a numeric vector with at least two elements.');
            elseif length(edges) > categorical.maxCode
                error('stats:categorical:categorical:MaxNumLevelsExceeded', ...
                      'Too many categorical levels.');
            end
            
            nbins = length(edges) - 1;
            if ~isempty(labels)
                labels = categorical.checklabels(labels,2); % error if duplicates
                if length(labels) ~= nbins
                    error('stats:categorical:categorical:SizeMismatchLabelsEdges', ...
                          'LABELS must have one fewer element than EDGES.');
                end
                b.labels = labels;

            % Build up labels from the edges
            else
                b.labels = cell(1,nbins);
                for i = 1:nbins
                    b.labels{i} = sprintf('[%0.5g, %0.5g)',edges(i),edges(i+1));
                end
                b.labels{end}(end) = ']';
                if length(unique(b.labels)) < length(b.labels)
                    error('stats:categorical:categorical:CantInferNumericLabels', ...
                          'Cannot create unique default labels using 5 significant digits from EDGES.');
                end
            end

            % HISTC includes a rightmost "x==edges(end)" bin, remove it
            [dum,bcodes] = histc(a(:),edges);
            bcodes(bcodes==nbins+1) = nbins;
            bcodes = cast(bcodes,codesClass);
            b.codes = reshape(bcodes,size(a));
        end

        end % categorical constructor
    end % methods block

    methods(Static=true, Access='protected')
        labels = checklabels(labels,dupFlag)
    end % static protected methods block
    
    methods(Access = 'public', Abstract = true)
        t = eq(a,b)
        t = ne(a,b)
        a = cat(dim,varargin)
        a = horzcat(varargin)
        a = vertcat(varargin)
        [tf,loc] = ismember(a,s)
        [c,ia,ib] = union(a,b)
        [c,ia,ib] = intersect(a,b)
        [c,ia,ib] = setxor(a,b)
        [c,ia] = setdiff(a,b)
        a = mergelevels(a,oldlevels,newlevel)
    end % abstract methods block
    
    methods(Hidden = true)
        % The default properties and fieldnames methods work as desired
    
        % Methods that we inherit, but do not want
        function a = fields(varargin), throwUndefinedError; end
    end
    
    methods(Static = true)
        % This method is callable, but since categorical is abstract, it
        % simply errors out.
        function a = empty(varargin)
            if nargin == 0
                codes = [];
            else
                codes = zeros(varargin{:});
                if ~isempty(codes)
                        error('stats:categorical:empty:EmptyMustBeZero', ...
                              'At least one dimension must be zero.');
                end
            end
            a = categorical(codes);
        end
    end

end % classdef

function throwUndefinedError
st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException(['stats:' name{1} ':UndefinedFunction'], ...
      'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},name{1});
throwAsCaller(me);
end

