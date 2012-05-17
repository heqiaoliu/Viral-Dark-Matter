function varargout = workspacefunc(whichcall, varargin)
%WORKSPACEFUNC  Support function for Workspace browser component.

% Copyright 1984-2008 The MathWorks, Inc.
% $Revision: 1.1.6.29 $  $Date: 2010/04/05 22:22:05 $

switch whichcall
    case 'getcopyname',
        varargout = {getCopyName(varargin{1}, varargin{2})};
    case 'getnewname',
        varargout = {getNewName(varargin{1})};
    case 'getshortvalue',
        varargout = {getShortValue(varargin{1})};
    case 'getshortvalues',
        getShortValues(varargin{1});
    case 'getshortvalueserror',
        getShortValuesError(varargin{1});
    case 'getshortvalueobjectj',
        varargout = {getShortValueObjectJ(varargin{1}, varargin{2:end})};
    case 'num2complex',
        varargout = {num2complex(varargin{1}, varargin{2:end})};
    case 'getshortvalueobjectsj',
        varargout = {getShortValueObjectsJ(varargin{1})};
    case 'getabstractvaluesummariesj',
        varargout = {getAbstractValueSummariesJ(varargin{1})};
    case 'getstatobjectm',
        varargout = {getStatObjectM(varargin{1}, varargin{2}, varargin{3})};
    case 'getstatobjectsj',
        varargout = {getStatObjectsJ(varargin{1}, varargin{2}, varargin{3}, varargin{4})};
    case 'getshortvalueerrorobjects',
        varargout = {getShortValueErrorObjects(varargin{1})};
    case 'getwhosinformation',
        varargout = {getWhosInformation(varargin{1})};
    case 'areAnyVariablesReadOnly',
        varargout = {areAnyVariablesReadOnly(varargin{1}, varargin{2})};
    otherwise
        error('MATLAB:workspacefunc:unknownOption', ...
            'Unknown command option.');
end

%********************************************************************
function new = getCopyName(orig, who_output)

counter = 0;
new_base = [orig 'Copy'];
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function new = getNewName(who_output)

counter = 0;
new_base = 'unnamed';
new = new_base;
while localAlreadyExists(new , who_output)
    counter = counter + 1;
    proposed_number_string = num2str(counter);
    new = [new_base proposed_number_string];
end

%********************************************************************
function getShortValues(vars)

w = warning('off', 'all');
fprintf(char(10));
for i=1:length(vars)
    % Escape any backslashes.
    % Do it here rather than in the getShortValue code, since the
    % fact that Java is picking them up for interpretation is a
    % function of how they're being displayed.
    val = getShortValue(vars{i});
    val = strrep(val, '\', '\\');
    val = strrep(val, '%', '%%');
    fprintf([val 13 10]);
end
warning(w);

%********************************************************************
function retstr = getShortValue(var)

retstr = '';
if isempty(var)
    if builtin('isnumeric', var)
        % Insert a space for enhanced readability.
        retstr = '[ ]';
    end
    if ischar(var)
        retstr = '''''';
    end
end

if isempty(retstr)
    try
        if ~isempty(var)
            if builtin('isnumeric',var) && (numel(var) < 11) && (ndims(var) < 3)
                % Show small numeric arrays.
                if isempty(strfind(get(0, 'format'), 'long'))
                    retstr = mat2str(var, 5);
                else
                    retstr = mat2str(var);
                end
            elseif islogical(var) && (numel(var) == 1)
                if var
                    retstr = 'true';
                else
                    retstr = 'false';
                end
            elseif (ischar(var) && (size(var, 1) == 1))
                % Show "single-line" char arrays, while establishing a reasonable
                % truncation point.
                if isempty(strfind(var, char(10))) && ...
                        isempty(strfind(var, char(13))) && ...
                        isempty(strfind(var, char(0)))
                    limit = 128;
                    if numel(var) <= limit
                        retstr = ['''' var ''''];
                    else
                        retstr = ['''' var(1:limit) '...'' ' ...
                            '<Preview truncated at ' num2str(limit) ' characters>'];
                    end
                end
            elseif isa(var, 'function_handle') && numel(var) == 1
                retstr = strtrim(evalc('disp(var)'));
            end
        end
        
        % Don't call mat2str on an empty array, since that winds up being the
        % char array "''".  That looks wrong.
        if isempty(retstr)
            s = size(var);
            D = numel(s);
            if D == 1
                % This can happen when objects that have overridden SIZE (such as
                % a javax.swing.JFrame) return another object as their "size."
                % In that case, it's a scalar.
                theSize = '1x1';
            elseif D == 2
                theSize = [num2str(s(1)), 'x', num2str(s(2))];
            elseif D == 3
                theSize = [num2str(s(1)), 'x', num2str(s(2)), 'x', ...
                    num2str(s(3))];
            else
                theSize = [num2str(D) '-D'];
            end
            classinfo = [' ' class(var)];
            retstr = ['<', theSize, classinfo, '>'];
        end
    catch err %#ok<NASGU>
        retstr = sprintf('<Error displaying value>');
    end
end

%********************************************************************
function result = localAlreadyExists(name, who_output)
result = false;
counter = 1;
while ~result && counter <= length(who_output)
    result = strcmp(name, who_output{counter});
    counter = counter + 1;
end

%********************************************************************
function getShortValuesError(numberOfVars)

fprintf(char(10));
for i=1:numberOfVars
    fprintf([sprintf('<Error retrieving value>') 13 10]);
end

%********************************************************************
function retval = getShortValueObjectJ(var, varargin)
if isempty(var)
    if builtin('isnumeric', var)
        retval = num2complex(var);
        return;
    end
    if ischar(var)
        retval = num2complex(var);
        return;
    end
end

try
    % Start by assuming that we won't get anything back.
    retval = '';
    if ~isempty(var)
        if islogical(var)
            retval = num2complex(var);
        end
    end

    if (ischar(var) && (size(var, 1) == 1))
        % Show "single-line" char arrays, while establishing a reasonable
        % truncation point.
        if isempty(strfind(var, char(10))) && ...
                isempty(strfind(var, char(13))) && ...
                isempty(strfind(var, char(0)))
            quoteStrings = true;
            limit = 128;
            optargin = size(varargin,2);
            if (optargin > 0) 
                quoteStrings = varargin{1};
            end
            if (optargin > 1) 
                limit = varargin{2};
            end
            if numel(var) <= limit
                if (quoteStrings)
                    retval = java.lang.String(['''' var '''']);
                else
                    retval = java.lang.String(['' var '']);
                end
            else
                retval = java.lang.String(...
                    sprintf('''%s...'' <Preview truncated at %s characters>', ...
                    var(1:limit), num2str(limit)));
            end
        end
    end

    if isa(var, 'function_handle') && numel(var) == 1
        retval = java.lang.String(strtrim(evalc('disp(var)')));
    end

    % Don't call mat2str on an empty array, since that winds up being the
    % char array "''".  That looks wrong.
    if isempty(retval)
        retval = num2complex(var);
    end
catch err %#ok<NASGU>
    retval = java.lang.String(sprintf('<Error displaying value>'));
end

%********************************************************************
function outVal = num2complex(in)
import com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory;
if builtin('isnumeric', in)
    if isscalar(in)
        outVal = createComplexScalar(in);
    else
        if isempty(in) || numel(size(in)) > 2 || numel(in) > 10
            clazz = class(in);
            outVal = ValueSummaryFactory.getInstance(cast(0, clazz), size(in), ...
                ~dataviewerhelper('isUnsignedIntegralType', in), isreal(in));
        else
            outVal = createComplexVector(in);
        end
    end
else
    if islogical(in)
        if isscalar(in)
            if (in)
                outVal = java.lang.Boolean.TRUE;
            else
                outVal = java.lang.Boolean.FALSE;
            end
        else
            % Let it drop to the class-handling code.
            outVal = getAbstractValueSummaryJ(in);
        end
    else
        outVal = getAbstractValueSummaryJ(in);
    end
end

%********************************************************************
function outVal = createComplexScalar(in)
import com.mathworks.widgets.spreadsheet.data.ComplexScalarFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(toReport, signed);
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if isreal(in)
        outVal = ComplexScalarFactory.valueOf(toReport);
    else
        outVal = ComplexScalarFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function outVal = createComplexVector(in)
import com.mathworks.widgets.spreadsheet.data.ComplexArrayFactory;
toReport = dataviewerhelper('upconvertIntegralType', in);
if isinteger(in)
    signed   = ~dataviewerhelper('isUnsignedIntegralType', in);
    % Integer values need their signed-ness explicitly stated.
    if isreal(in)
        outVal = ComplexArrayFactory.valueOf(toReport, signed);
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport), signed);
    end
else
    % Floating-point values don't have a "signed" vs. "unsigned" concept.
    if isreal(in)
        outVal = ComplexArrayFactory.valueOf(toReport);
    else
        outVal = ComplexArrayFactory.valueOf(real(toReport), imag(toReport));
    end
end

%********************************************************************
function ret = getAbstractValueSummariesJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getAbstractValueSummaryJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(sprintf('<Error displaying value>'));
    end
end
warning(w);

%********************************************************************
function out = getAbstractValueSummaryJ(in)
try
    s = size(in);
    if ~isnumeric(s) || isscalar(s)
        s = builtin('size', in);
    end
catch err %#ok<NASGU>
    s = builtin('size', in);
end
if ~isa(in, 'timeseries') || numel(in)~=1
    clazz = class(in);
else
    clazz = [class(in.Data) ' ' class(in)];
end

out = com.mathworks.widgets.spreadsheet.data.ValueSummaryFactory.getInstance(clazz, s);

%********************************************************************
function ret = getShortValueObjectsJ(vars)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    try
        ret(i) = getShortValueObjectJ(vars{i});
    catch err %#ok<NASGU>
        ret(i) = java.lang.String(sprintf('<Error displaying value>'));
    end
end
warning(w);

%********************************************************************
function retval = getStatObjectM(var, baseFunction, showNaNs)

underlyingVar = var;
% First handle timeseries, since they aren't numeric.
isTimeseries = false;
if isa(var, 'timeseries')
    underlyingVar = get(var, 'Data');
    isTimeseries = true;
end
    
if ~builtin('isnumeric', underlyingVar) || isempty(underlyingVar) || issparse(underlyingVar)
    retval = '';
    return;
end

if isinteger(underlyingVar) && ~strcmp(baseFunction, 'max') && ...
        ~strcmp(baseFunction, 'min') && ~strcmp(baseFunction, 'range')
    retval = '';
    return;
end

if isTimeseries
    if strcmp(baseFunction, 'range')
        retval = local_ts_range(var);
    else
        retval = fevalPossibleMethod(baseFunction, var);
    end
else
    retval = feval(lookupStatFunction(baseFunction, showNaNs), var(:));
end

%********************************************************************
function retval = getStatObjectJ(var, baseFunction, showNaNs)
retval = num2complex(getStatObjectM(var, baseFunction, showNaNs));

%********************************************************************
function ret = getStatObjectsJ(vars, baseFunction, showNaNs, numelLimit)

w = warning('off', 'all');
ret = javaArray('java.lang.Object', length(vars));
for i = 1:length(vars)
    var = vars{i};
    if numel(var) > numelLimit
        ret(i) = java.lang.String(sprintf('<Too many elements>'));
    else
        try
            ret(i) = getStatObjectJ(var, baseFunction, showNaNs);
        catch err %#ok<NASGU>
            clazz = builtin('class', var);
            if strcmp(clazz, 'int64') || strcmp(clazz, 'uint64')
                ret(i) = num2complex('');
            else
                ret(i) = java.lang.String(sprintf('<Error displaying value>'));
            end
        end
    end
end
warning(w);

%********************************************************************
function fun = lookupStatFunction(fun, showNaNs)
if (showNaNs)
    switch(fun)
        case 'min'
            fun = 'local_min';
        case 'max'
            fun = 'local_max';
        case 'range'
            fun = 'local_range';
        case 'mode'
            fun = 'local_mode';
    end
else
    switch(fun)
        case 'range'
            fun = 'local_nanrange';
        case 'mean'
            fun = 'local_nanmean';
        case 'median'
            fun = 'local_nanmedian';
        case 'mode'
            fun = 'local_mode';
        case 'std'
            fun = 'local_nanstd';
        otherwise
            % return the input.
    end
end

%********************************************************************
function out = fevalPossibleMethod(baseFunction, var)
if ismethod(var, baseFunction)
    out = feval(baseFunction, var);
else
    out = '';
end

%********************************************************************
function out = getShortValueErrorObjects(numberOfVars)

out = javaArray('java.lang.String', length(numberOfVars));
for i=1:numberOfVars
    out(i) = java.lang.String(sprintf('<Error retrieving value>'));
end

%********************************************************************
function m = local_min(x)
if isfloat(x)
    if any(isnan(x))
        m = cast(NaN, class(x));
    else
        m = min(x);
    end
else
    m = min(x);
end
%********************************************************************
function m = local_max(x)
if isfloat(x)
    xc = x(:);
    if any(isnan(xc))
        m = cast(NaN, class(xc));
    else
        m = max(xc);
    end
else
    m = max(x(:));
end

%********************************************************************
function m = local_range(x)
lm = local_max(x);
if isnan(lm)
    m = cast(NaN, class(x));
else
    m = lm-local_min(x);
end

%********************************************************************
function m = local_ts_range(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanrange(x)
m = max(x)-min(x);

%********************************************************************
function m = local_nanmean(x)
% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

% Count up non-NaNs.
n = sum(~nans);
n(n==0) = NaN; % prevent divideByZero warnings
% Sum up non-NaNs, and divide by the number of non-NaNs.
m = sum(x) ./ n;

%********************************************************************
function y = local_nanmedian(x)

% If X is empty, return all NaNs.
if isempty(x)
    y = nan(1, 1, class(x));
else
    x = sort(x,1);
    nonnans = ~isnan(x);

    % If there are no NaNs, do all cols at once.
    if all(nonnans(:))
        n = length(x);
        if rem(n,2) % n is odd
            y = x((n+1)/2,:);
        else        % n is even
            y = (x(n/2,:) + x(n/2+1,:))/2;
        end

    % If there are NaNs, work on each column separately.
    else
        % Get percentiles of the non-NaN values in each column.
        y = nan(1, 1, class(x));
        nj = find(nonnans(:,1),1,'last');
        if nj > 0
            if rem(nj,2) % nj is odd
                y(:,1) = x((nj+1)/2,1);
            else         % nj is even
                y(:,1) = (x(nj/2,1) + x(nj/2+1,1))/2;
            end
        end
    end
end

%********************************************************************
function y = local_nanstd(varargin)
y = sqrt(local_nanvar(varargin{:}));

%********************************************************************
function y = local_nanvar(x)

% The output size for [] is a special case when DIM is not given.
if isequal(x,[]), y = NaN(class(x)); return; end

% Need to tile the mean of X to center it.
tile = ones(size(size(x)));
tile(1) = length(x);

% Count up non-NaNs.
n = sum(~isnan(x),1);

% The unbiased estimator: divide by (n-1).  Can't do this when
% n == 0 or 1, so n==1 => we'll return zeros
denom = max(n-1, 1);
denom(n==0) = NaN; % Make all NaNs return NaN, without a divideByZero warning

x0 = x - repmat(local_nanmean(x), tile);
y = local_nansum(abs(x0).^2) ./ denom; % abs guarantees a real result

%********************************************************************
function y = local_nansum(x)
x(isnan(x)) = 0;
y = sum(x);

%********************************************************************
function y = local_mode(x)

y = mode(x);

%********************************************************************
function out = getWhosInformation(in)

if numel(in) == 0
    out = com.mathworks.mlwidgets.workspace.WhosInformation.getInstance;
else
    s = size(in);
    per = false(s);
    level = zeros(s);
    fcn = cell(s);
    siz = cell(s);
    for i = 1:length(in)
        level(i) = in(i).nesting.level;
        fcn{i} = in(i).nesting.function;
        siz{i} = int64(in(i).size);
    end
    out = com.mathworks.mlwidgets.workspace.WhosInformation({in.name}, ...
        siz, [in.bytes], {in.class}, per, [in.global], [in.sparse],...
        [in.complex], com.mathworks.mlwidgets.workspace.NestingInformation.getInstances(level, fcn));
end

%********************************************************************
function isReadOnly = areAnyVariablesReadOnly(values, valueNames)
values = fliplr(values);
valueNames = fliplr(valueNames);
isReadOnly = false;
for i = 1:length(valueNames)-1
    thisFullValue = values{i};
    if ~isstruct(thisFullValue)
        thisFullValueName = valueNames{i};
        nextFullValueName = valueNames{i+1};
        delim = nextFullValueName(length(thisFullValueName)+1);
        if delim == '.'
            nextShortIdentifier = nextFullValueName(length(thisFullValueName)+2:end);
            metaclassInfo = metaclass(values{i});
            properties = metaclassInfo.Properties;
            for j = 1:length(properties)
                thisProp = properties{j};
                if strcmp(thisProp.Name, nextShortIdentifier)
                    if ~strcmp(thisProp.SetAccess, 'public')
                        isReadOnly = true;
                        return;
                    end
                end
            end
        end
    end
end
