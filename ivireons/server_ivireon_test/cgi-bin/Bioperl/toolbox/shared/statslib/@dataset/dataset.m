classdef dataset
%DATASET Dataset array.
%   Dataset arrays are used to collect heterogeneous data and metadata,
%   including variable and observation names, into a single container.  They
%   can be thought of as tables of values, with rows representing different
%   observations and columns representing different measured variables.
%   Dataset arrays are suitable for storing column-oriented or tabular data
%   that are often stored as columns in a text file or in a spreadsheet,
%   and can accommodate variables of different types, sizes, units, etc.
%
%   Use the DATASET constructor to create a dataset array from variables in
%   the MATLAB workspace.  You can also create a dataset array by reading data
%   from a text or spreadsheet file.  Dataset arrays can be subscripted using
%   parentheses much like ordinary numeric arrays, but in addition to numeric
%   and logical indices, you can use variable and observation names as
%   indices.  You can access each variable in a dataset array much like fields
%   in a structure, using dot subscripting.  Type "methods dataset" for a list
%   of operations available for dataset arrays.
%
%   Dataset arrays can contain different kinds of variables, including
%   numeric, logical, character, categorical, and cell.  However, a dataset
%   array is a different class than the variables that it contains.  For
%   example, even a dataset array that contains only variables that are double
%   arrays cannot be operated on as if it were itself a double array.
%   However, using dot subscripting, you can operate on variable in a dataset
%   array as if it were a workspace variable.
%
%   A dataset array D has properties that store metadata.  Access or assign to
%   a property using P = D.Properties.PropName or D.Properties.PropName = P,
%   where PropName is one of the following:
%
%       Description    - A string describing the data set
%       DimNames       - A two-element cell array of strings containing names of
%                        the dimensions of the data set
%       VarNames       - A cell array containing names of the variables in the data set
%       VarDescription - A cell array of strings containing descriptions of the variables
%                        in the data set
%       Units          - Units of variables in data set
%       ObsNames       - A cell array of nonempty, distinct strings containing names
%                        of the observations in the data set
%       UserData       - A variable containing additional information associated
%                        with the data set
%
%   Examples:
%      % Load a dataset array from a mat file and create some simple subsets
%      load hospital
%      h1 = hospital(1:10,:)
%      h2 = hospital(:,{'LastName' 'Age' 'Sex' 'Smoker'})
%
%      % Access and modify metadata
%      hospital.Properties.Description
%      hospital.Properties.VarNames{4} = 'Wgt'
%
%      % Create a new dataset variable from an existing one
%      hospital.AtRisk = hospital.Smoker | (hospital.Age > 40)
%
%      % Use individual variables to explore the data
%      boxplot(hospital.Age,hospital.Sex)
%      h3 = hospital(hospital.Age<30,{'LastName' 'Age' 'Sex' 'Smoker'})
%
%      % Sort the observations based on two variables
%      h4 = sortrows(hospital,{'Sex','Age'})
%
%   See also DATASET/DATASET, NOMINAL, ORDINAL

%   Copyright 2006-2010 The MathWorks, Inc. 
%   $Revision: 1.1.6.15 $  $Date: 2010/03/31 18:44:34 $

    properties(Constant, GetAccess='private')
        propsFieldNames = ...
            {'Description'; 'VarDescription'; 'Units';                   'DimNames'; 'UserData'};
        propsFieldDflts = ...
            {           '';               {};      {}; {'Observations' 'Variables'};         []}
    end
    properties(GetAccess='private', SetAccess='private')
        ndims = 2;
        nobs = 0;
        obsnames = {};
        nvars = 0;
        varnames = cell(1,0); % these can never be "truly" empty
        data = {};
        
        % 'Properties' will also appear to contain 'VarNames' and 'ObsNames'.
        props = cell2struct(dataset.propsFieldDflts, dataset.propsFieldNames, 1);
    end
    properties(GetAccess='public', SetAccess='private', Dependent=true)
        Properties;
    end
    methods
        function val = get.Properties(a), val = get(a); end
    end

    methods
        function a = dataset(varargin)
%DATASET Create a dataset array.
%   DS = DATASET(VAR1, VAR2, ...) creates a dataset array DS from the
%   workspace variables VAR1, VAR2, ... .  All variables must have the same
%   number of rows.
%
%   DS = DATASET(..., {VAR,'name'}, ...) creates a dataset variable named
%   'name' in DS.  Dataset variable names must be valid MATLAB identifiers,
%   and unique.
%
%   DS = DATASET(..., {VAR,'name1',...,'name_M'}, ...), where VAR is an
%   N-by-M-by-P-by-... array, creates M dataset variables in DS, each of size
%   N-by-P-by-..., with names 'name1', ..., 'name_M'.
%
%   DS = DATASET(..., 'VarNames', {'name1', ..., 'name_M'}) creates dataset
%   variables that have the specified variable names.  The names must be valid
%   MATLAB identifiers, and unique.  You may not provide both the 'VarNames'
%   parameter and names for individual variables.
%
%   DS = DATASET(..., 'ObsNames', {'name1', ..., 'name_N'}) creates a dataset
%   array that has the specified observation names.  The names need not be
%   valid MATLAB identifiers, but must be unique.
%
%   Dataset arrays can contain variables that are built-in types, or objects that
%   are arrays and support standard MATLAB parenthesis indexing of the form
%   var(i,...), where i is a numeric or logical vector that corresponds to
%   rows of the variable.  In addition, the array must implement a SIZE method
%   with a DIM argument, and a VERTCAT method.
%
%   You can also create a dataset array by reading from a text or spreadsheet
%   file, as described below.  This creates scalar-valued dataset variables,
%   i.e., one variable corresponding to each column in the file.  Variable
%   names are taken from the first row of the file.
%
%   DS = DATASET('File',FILENAME, ...) creates a dataset array by reading
%   column-oriented data in a tab-delimited text file.  The dataset variables
%   that are created are either double-valued, if the entire column is
%   numeric, or string-valued, i.e. a cell array of strings, if any element in
%   a column is not numeric.  Fields that are empty are converted to either
%   NaN (for a numeric variable) or the empty string (for a string-valued
%   variable).  Insignificant whitespace in the file is ignored.
%
%   Specify a delimiter character using the 'Delimiter' parameter name/value
%   pair.  The delimiter can be any of ' ', '\t', ',', ';', '|' or their
%   corresponding string names 'space', 'tab', 'comma', 'semi', or 'bar'.
%   Specify strings to be treated as the empty string in a numeric column
%   using the 'TreatAsEmpty' parameter name/value pair.  This may be a
%   character string, or a cell array of strings.  'TreatAsEmpty' only applies
%   to numeric columns in the file, and numeric literals such as '-99' are not
%   accepted.
%
%   DS = DATASET('File',FILENAME,'Format',FORMAT, ...)  creates a dataset
%   array using the TEXTSCAN function to read column-oriented data in a text
%   file.  Specifying a format can improve speed significantly for large
%   files.  FORMAT is a format string as accepted by the TEXTSCAN function.
%   You may also specify any of the parameter name/value pairs accepted by the
%   TEXTSCAN function, including the 'Delimiter' parameter.  The default
%   delimiter when you specify the 'Format' parameter is ' '.
%
%   DS = DATASET('XLSFile',XLSFILENAME, ...) creates a dataset array from
%   column-oriented data in an Excel spreadsheet file.  You may also specify
%   the 'Sheet' and 'Range' parameter name/value pairs, with parameter values
%   as accepted by the XLSREAD function.  Variable names are taken from the
%   first row of the spreadsheet.  If the spreadsheet contains figures or
%   other non-tabular information, you should use the 'Range' parameter to
%   read only the tabular data.  By default, the 'XLSFile' option reads data
%   from the spreadsheet contiguously out to the right-most column that
%   contains data, including any empty columns that precede it.  If the
%   spreadsheet contains one or more empty columns between columns of data,
%   use the 'Range' parameter to specify a rectangular range of cells from
%   which to read variable names and data.
%
%   When reading from a text or spreadsheet file, the 'ReadVarNames' parameter
%   name/value pair determines whether or not the first row of the file is
%   treated as variable names.  Specify as a logical value (default true).
%
%   When reading from a text or spreadsheet file, the 'ReadObsNames' parameter
%   name/value pair determines whether or not the first column of the file is
%   treated as observation names.  Specify as a logical value (default false).
%   If the 'ReadVarNames' and 'ReadObsNames' parameter values are both true,
%   the name in the first column of the first row of the file is saved as the
%   first dimension name for the dataset.
%
%   DS = DATASET('XPTFile',XPTFILENAME, ...) creates a dataset array from a
%   SAS XPORT format file. Variable names from the XPORT format file are
%   preserved. Numeric data types in the XPORT format file are preserved
%   but all other data types are converted to cell arrays of strings. The
%   XPORT format allows for 28 missing data types. These are represented in
%   the file by an upper case letter, '.' or '_'. All missing data will be
%   converted to NaN values in DS. However, if you need the specific
%   missing types then you can recover this information using the XPTREAD
%   function. 
%
%   When reading from an XPORT format file, the 'ReadObsNames' parameter
%   name/value pair determines whether or not to try to use the first
%   variable in the file as observation names. Specify as a logical value
%   (default false). If the contents of the first variable are not valid
%   observation names then the variable will be read into a variable of the
%   dataset array and observation names will not be set.
%
%   Examples:
%      % Create a dataset array from workspace variables
%      load cereal
%      cereal = dataset(Calories,Protein,Fat,Sodium,Fiber,Carbo,Sugars, ...
%          'ObsNames',Name)
%      cereal.Properties.VarDescription = Variables(4:10,2);
%
%      % Create a dataset array from a single workspace variable
%      load cities
%      categories = cellstr(categories);
%      cities = dataset({ratings,categories{:}},'ObsNames',cellstr(names))
%
%      % Load data from a text or spreadsheet file
%      patients = dataset('File','hospital.dat','Delimiter',',','ReadObsNames',true)
%      patients2 = dataset('XLSFile','hospital.xls','ReadObsNames',true)
%
%   See also DATASET/SET, DATASET/GET, GENVARNAME, TDFREAD, TEXTSCAN,
%   XLSREAD, XPTREAD. 
        
        varnames = repmat({''},1,nargin);
        hadExplicitNames = false;
        argCnt = 0;
                
        if nargin == 0
            % nothing to do
            return
        end
        
        % Set these as a first guess, they may grow if some vars are
        % created by splitting up arrays, or shrink if there are
        % name/value pairs.
        a.nvars = nargin;
        a.data = cell(1,nargin);

        varCnt = 0;
        while argCnt < nargin
            argCnt = argCnt + 1;
            arg = varargin{argCnt};
            if isstring(arg)
                % Put that one back and start processing param name/value pairs
                argCnt = argCnt - 1;
                break
            elseif iscell(arg) && ~isscalar(arg) && isvector(arg) && (size(arg,1)==1)
                if (numel(arg)==2) && isstring(arg{2})
                    % {var,name}
                    if isa(arg{1},'dataset')
                        error('stats:dataset:dataset:DatasetVariable', ...
                              'Cannot include a dataset array as a dataset variable.  Use concatenation instead.');
                    end
                    varCnt = varCnt + 1;
                    a.data{varCnt} = arg{1};
                    varnames{varCnt} = arg{2};
                    hadExplicitNames = true;
                elseif (numel(arg)>2) && all(cellfun(@isstring,arg(2:end)))
                    % {var,name1,name2,...}
                    if isa(arg{1},'dataset')
                        error('stats:dataset:dataset:DatasetVariable', ...
                              'Cannot include a dataset array as a dataset variable.  Use concatenation instead.');
                    end
                    var = arg{1};                    
                    names = arg(2:end);
                    if length(names) ~= size(var,2)
                        error('stats:dataset:dataset:IncorrectNumberVarnames', ...
                              'Must have one variable name for each column when creating multiple variables from an array.');
                    end
                    szOut = size(var);
                    szOut(2) = []; if isscalar(szOut), szOut(2) = 1; end
                    ncols = size(var,2);
                    a.nvars = a.nvars + ncols-1;
                    varnames = [varnames repmat({''},1,ncols-1)];
                    a.data = [a.data cell(1,ncols-1)];
                    for j = 1:ncols
                        varCnt = varCnt + 1;
                        if ndims(var) == 2
                            a.data{varCnt} = var(:,j);
                        else
                            a.data{varCnt} = reshape(var(:,j,:),szOut);
                        end
                        varnames{varCnt} = names{j};
                    end
                    hadExplicitNames = true;
                else
                    % false alarm -- cell-valued var without name
                    varCnt = varCnt + 1;
                    a.data{varCnt} = arg;
                    name = inputname(argCnt);
                    if isempty(name)
                        name = strcat('Var',num2str(varCnt,'%d'));
                    end
                    varnames{varCnt} = name;
                end
            elseif isstruct(arg) && isscalar(arg)
                if any(diff(structfun(@(x)size(x,1),arg)))
                    error('stats:dataset:dataset:UnequalFieldLengths', ...
                          'Fields in a scalar structure must have the same number of rows.');
                end
                names = fieldnames(arg);
                ncols = length(names);
                a.nvars = a.nvars + ncols-1;
                varnames = [varnames repmat({''},1,ncols-1)];
                a.data = [a.data cell(1,ncols-1)];
                for j = 1:ncols
                    varCnt = varCnt + 1;
                    a.data{varCnt} = arg.(names{j});
                    varnames{varCnt} = names{j};
                end
                hadExplicitNames = true;
            elseif isa(arg,'dataset')
                error('stats:dataset:dataset:DatasetVariable', ...
                      'Cannot include a dataset array as a dataset variable.  Use concatenation instead.');
            else
                % var without name
                varCnt = varCnt + 1;
                a.data{varCnt} = arg;
                name = inputname(argCnt);
                if isempty(name)
                    name = strcat('Var',num2str(varCnt,'%d'));
                end
                varnames{varCnt} = name;
            end
            try
                nrows = size(a.data{varCnt},1);
            catch ME
                throw(addCause(MException('stats:dataset:dataset:SizeMethodFailed', ...
                      'Error evaluating SIZE(VAR,1) for variable %d.',varCnt),ME));
            end
            if argCnt == 1
                a.nobs = nrows;
            elseif ~isequal(nrows,a.nobs)
                error('stats:dataset:dataset:UnequalVarLengths', ...
                      'All variables must have the same number of rows.');
            end

        end % while argCnt < nargin, processing individual vars
        
        a.nvars = varCnt;
        a.data = a.data(1:varCnt);
        varnames = varnames(1:varCnt);
            
        if argCnt < nargin
            pnames = {'file' 'xlsfile' 'xptfile' 'varnames'  'obsnames' };
            dflts =  {    []        []         []          []          []};
            [eid,errmsg,fileArg,xlsfileArg,xptfileArg,varnamesArg,obsnamesArg,otherArgs] ...
                      = dataset.getargs(pnames, dflts, varargin{argCnt+1:end});
            if ~isempty(eid)
                error(sprintf('stats:dataset:dataset:%s',eid),errmsg);
            end
            
            if ~isempty(fileArg)
                if argCnt > 0
                    error('stats:dataset:dataset:FileAndData', ...
                          'You cannot specify the ''file'' parameter and individual variables.');
                end
                a = readFile(a,fileArg,otherArgs);
            elseif ~isempty(xlsfileArg)
                if argCnt > 0
                    error('stats:dataset:dataset:XLSFileAndData', ...
                          'You cannot specify the ''xlsfile'' parameter and individual variables.');
                end
                a = readXLSFile(a,xlsfileArg,otherArgs);
           elseif ~isempty(xptfileArg)
                if argCnt > 0
                    error('stats:dataset:dataset:XPORTFileAndData', ...
                          'You cannot specify the ''xptfile'' parameter and individual variables.');
                end
                a = readXPTFile(a,xptfileArg,otherArgs);
            else
                if ~isempty(otherArgs)
                    error('stats:dataset:dataset:UnrecognizedParams', ...
                          'The parameter %s is unrecognized or not legal in this context.',otherArgs{1});
                end
            end
            
            if ~isempty(varnamesArg)
                if hadExplicitNames
                    error('stats:dataset:dataset:VarNamesAndVarNamesParam', ...
                          'You cannot specify the ''VarNames'' parameter and individual variable names.');
                else
                    varnames = varnamesArg;
                end
            end
            if ~isempty(obsnamesArg)
                a = setobsnames(a,obsnamesArg);
            end
        end % if argCnt < nargin, processing name/value pairs
        
        % Varnames may be empty because we had no vars, or because we read
        % from a file.  In either case, no need to set them.
        if ~isempty(varnames)
            a = setvarnames(a,varnames); % names will be modified to make them valid
        end
        
        end % dataset constructor
    end % methods block
    
    methods(Hidden = true, Static = true, Access = 'public')
        function b = loadobj(b)
            % If loading an array from an old version without a VarDescription
            % property, fill in an empty value.
            if ~isfield(b.props,'VarDescription')
                b.props.VarDescription = {};
                % Put VarDescription second in the order
                fn = fieldnames(b.props);
                i = find(strcmp('VarDescription',fn));
                b.props = orderfields(b.props,[1 i 2:(i-1) (i+1):length(fn)]);
                
            % If loading an array that has a VarDescription property, but is
            % out of sync because the array was modified in an old version
            % that didn't know about VarDescription, clear out the property.
            else % isfield(b.props,'VarDescription')
                if numel(b.props.VarDescription) ~= b.nvars
                    b.props.VarDescription = {};
                end
            end
            
            % If loading an array that has a timeseries variable, need to
            % check if it is an "old-style" time series, and deal with it.
            % Regardless of its data length, an "old-style" object will have
            % been constructed as a 1x1 "new-style" array, and that probably
            % won't match the length of the dataset array.  Create a "new-style"
            % timeseries array sized to match the length of the dataset array,
            % leaving the original timeseries as the first element.  Pad out
            % with default elements, 
            isscalarTS = cellfun(@(c)isa(c,'timeseries') && isscalar(c),b.data,'UniformOutput',true);
            if any(isscalarTS)
                for i = find(isscalarTS)
                    ts = b.data{i};
                    if (ts.TimeInfo.Length == b.nobs) && (b.nobs ~= 1)
                        vn = b.varnames{i};
                        warning('stats:dataset:dataset:OldFormatTimeseries', ...
                            ['The dataset variable ''%s'' appears to be a timeseries object that was ' ...
                             'created and saved to a MAT-file prior to MATLAB R2010b.  Array subscripting ' ...
                             'behavior of the timeseries class changed in R2010b, and the size of the ' ...
                             'timeseries object created from the MAT-file is no longer compatible with the ' ...
                             'dataset array that contains it.  See the documentation for timeseries.  The ' ...
                             'timeseries object has been stored in the first element of a new dataset ' ...
                             'variable ''%s''.  You may want to extract the time vector and the data from ' ...
                             'that element and create separate dataset variables from them.'],vn,vn);
                        ts(b.nvars+1,1) = ts; ts = ts(1:end-1);
                        b.data{i} = ts;
                    end
                end
            end
            
            % Prevent fields in the props struct from new versions from getting through.
            toRemove = setdiff(fieldnames(b.props),dataset.propsFieldNames);
            if ~isempty(toRemove)
                b.props = rmfield(toRemove);
            end
        end
    end
    
    methods(Hidden = true)
        function b = fieldnames(a)
            b = properties(a);
        end
        function b = properties(a)
            b = [a.varnames(:); properties('dataset')];
        end
        
        % Methods that we inherit, but do not want
        function a = transpose(varargin),  throwUndefinedError; end
        function a = ctranspose(varargin), throwUndefinedError; end
        function a = permute(varargin),    throwUndefinedError; end
        function a = reshape(varargin),    throwUndefinedError; end
        function a = fields(varargin),     throwUndefinedError; end
    end % hidden methods block
        
    methods(Static = true)
        function a = empty(varargin)
            if nargin == 0
                a = dataset;
            else
                sizeOut = size(zeros(varargin{:}));
                if prod(sizeOut) ~= 0
                    error('stats:dataset:empty:EmptyMustBeZero', ...
                          'At least one dimension must be zero.');
                elseif length(sizeOut) > 2
                    error('stats:dataset:empty:EmptyMustBeTwoDims', ...
                          'A dataset array must be two-dimensional.');
                else
                    % Create a 0x0 dataset, and then resize to the correct number
                    % of observations or variables.
                    a = dataset();
                    a.nobs = sizeOut(1);
                    a.nvars = sizeOut(2);
                    if a.nvars > 0
                        a.varnames = strcat({'Var'},num2str((1:a.nvars)','%-d'))';
                        a.data = cell(1,a.nvars);
                    end
                end
            end
        end
    end % static methods block
    
    methods(Static = true, Access = 'private', Hidden = true)
        function [eid,emsg,varargout] = getargs(pnames,dflts,varargin)            
            % Initialize some variables
            emsg = '';
            eid = '';
            nparams = length(pnames);
            varargout = dflts;
            unrecog = {};
            nargs = length(varargin);
            
            % Must have name/value pairs
            if mod(nargs,2)~=0
                eid = 'WrongNumberArgs';
                emsg = 'Wrong number of arguments.';
            else
                % Process name/value pairs
                for j=1:2:nargs
                    pname = varargin{j};
                    if ~ischar(pname)
                        eid = 'BadParamName';
                        emsg = 'Parameter name must be text.';
                        break;
                    end
                    i = strmatch(lower(pname),pnames);
                    if isempty(i)
                        % if they've asked to get back unrecognized names/values, add this
                        % one to the list
                        if nargout > nparams+2
                            unrecog((end+1):(end+2)) = {varargin{j} varargin{j+1}};
                            
                            % otherwise, it's an error
                        else
                            eid = 'BadParamName';
                            emsg = sprintf('Invalid parameter name:  %s.',pname);
                            break;
                        end
                    elseif length(i)>1
                        eid = 'BadParamName';
                        emsg = sprintf('Ambiguous parameter name:  %s.',pname);
                        break;
                    else
                        varargout{i} = varargin{j+1};
                    end
                end
            end
            varargout{nparams+1} = unrecog;
        end
    end % static private hidden methods block
            
end % classdef


function tf = isstring(s) % require a row of chars, or possibly ''
tf = ischar(s) && ( (isvector(s) && (size(s,1) == 1)) || all(size(s)==0) );
end

function throwUndefinedError
st = dbstack;
name = regexp(st(2).name,'\.','split');
me = MException(['stats:' name{1} ':UndefinedFunction'], ...
      'Undefined function or method ''%s'' for input arguments of type ''%s''.',name{2},name{1});
throwAsCaller(me);
end



%-----------------------------------------------------------------------------
function a = readFile(a,file,args)

pnames = {'readvarnames' 'readobsnames' 'delimiter' 'treatasempty' 'format' 'headerlines'};
dflts =  {          true          false          {}             {}       []            []};
[eid,errmsg,readvarnames,readobsnames,delimiter,treatasempty,format,headerlines,otherArgs] ...
                   = dataset.getargs(pnames, dflts, args{:});
if ~isempty(eid)
    error(sprintf('stats:dataset:dataset:%s',eid),errmsg);
end
readobsnames = onOff2Logical(readobsnames,'ReadObsNames');
readvarnames = onOff2Logical(readvarnames,'ReadVarNames');

% textscan does something a little obscure when treatAsEmpty is char but
% not a row vector, disallow that here.
if ischar(treatasempty) && ~(isvector(treatasempty) && size(treatasempty,1)==1)
    error('stats:dataset:dataset:InvalidTreatAsEmpty', ...
          'TREATASEMPTY must be a character string, or a cell array of strings.');
end

if ~isempty(format)
    if isempty(delimiter), delimiter = ' '; end
    if isempty(headerlines), headerlines = 0; end
    % Empty treatAsEmpty is accepted by textscan.
    
    fid = fopen(file);
    if fid == -1
        error('stats:dataset:dataset:OpenFailed', ...
              'Unable to open the file %s for reading.',file);
    end
    if readvarnames
        % Search for any of the allowable conversions: a '%', followed
        % optionally by '*', followed optionally by 'nnn' or by 'nnn.nnn',
        % followed by one of the type specifiers or a character list or a
        % negative character list.  Keep the '%' and the '*' if it's there,
        % but replace everything else with the 'q' type specifier.
        specifiers = '(n|d8|d16|d32|d64|d|u8|u16|u32|u64|u|f32|f64|f|s|q|c|\[\^?[^\[\%]*\])';
        vnformat = regexprep(format,['\%([*]?)([0-9]+(.[0-9]+)?)?' specifiers],'%$1q');
        varnames = textscan(fid,vnformat,1,'delimiter',delimiter,'headerlines',headerlines,otherArgs{:});
        % If a textscan was unable to read a varname, the corresponding cell
        % contains an empty cell.  Remove those.  This happens when trying to
        % put delimiters in the format string, because they're just read as
        % part of the string.
        varnames = varnames(~cellfun('isempty',varnames));
        % Each cell in varnames contains another 1x1 cell containing a string,
        % get those out.
        varnames = cellfun(@(c) c{1}, varnames,'UniformOutput',false);
        headerlines = 0; % just skipped them
    end
    raw = textscan(fid,format,'delimiter',delimiter, 'treatasempty',treatasempty, ...
                              'headerlines',headerlines, otherArgs{:});
    fclose(fid);
    if readvarnames
        if numel(varnames) ~= numel(raw)
            % An empty file will get caught here too.
            error('stats:dataset:dataset:ReadVarnamesFailed', ...
                  ['The number of variable names read from %s does not match the ' ...
                   'number of data columns.  You may have specified the format string, ' ...
                   'delimiter, or the number of header lines incorrectly.'],file);
        end
        % If any names are empty or contain spaces, be consistent with tdfread
        emptyNames = find(cellfun('isempty',varnames));
        if ~isempty(emptyNames)
            varnames(emptyNames) = strcat({'Var'},num2str(emptyNames(:),'%-d'));
        end
        varnames = strrep(varnames, ' ', '_');
        varnames = genvarname(varnames);
    else
        varnames = strcat({'Var'},num2str((1:numel(raw))','%-d'));
    end
    s = cell2struct(raw(:),varnames,1);
else
    if ~isempty(headerlines) || ~isempty(otherArgs)
        if ~isempty(headerlines), arg = 'HeaderLines'; else arg = otherArgs{1}; end
        error('stats:dataset:dataset:UnrecognizedParams', ...
              'The ''%s'' parameter is unrecognized or not legal in this context.',arg);
    end
    s = tdfread(file,delimiter,false,readvarnames,treatasempty);
    varnames = fieldnames(s);
    for i = 1:length(varnames)
        name = varnames{i};
        if ischar(s.(name))
            s.(varnames{i}) = cellstr(s.(name));
        end
    end
end

if isempty(varnames) % i.e., if the file was empty
    a.nobs = 0;
else
    varlen = unique(structfun(@(x)size(x,1),s));
    if ~isscalar(varlen)
        errMsg = 'Variable lengths must all be the same.';
        if ~isempty(format)
            errMsg = [errMsg '  You may have specified the format string, delimiter, ' ...
                      'or number of header lines incorrectly.'];
        end
        error('stats:dataset:dataset:UnequalVarLengthsFromFile', errMsg);
    end
    a.nobs = varlen;
    if readobsnames
        obsnames = s.(varnames{1});
        if ischar(obsnames)
            obsnames = cellstr(obsnames);
        elseif ~iscellstr(obsnames)
            error('stats:dataset:dataset:ObsnamesVarNotString', ...
                  'Cannot convert ''%s'' to strings for observation names.',class(obsnames));
        end
        s = rmfield(s,varnames{1});
        dimnames = a.props.DimNames;
        dimnames{1} = varnames{1};
        varnames(1) = [];
        a = setobsnames(a,obsnames);
        a = setdimnames(a,dimnames);
    end
end
a.nvars = length(varnames);
a.data = struct2cell(s); a.data = a.data(:)';
a = setvarnames(a,varnames(:)'); % names will be modified to make them valid

end % readFile function


%-----------------------------------------------------------------------------
function a = readXLSFile(a,xlsfile,args)

pnames = {'readvarnames' 'readobsnames' 'sheet' 'range'};
dflts =  {          true          false      ''      ''};
[eid,errmsg,readvarnames,readobsnames,sheet,range] ...
                   = dataset.getargs(pnames, dflts, args{:});
if ~isempty(eid)
    error(sprintf('stats:dataset:dataset:%s',eid),errmsg);
end
readobsnames = onOff2Logical(readobsnames,'ReadObsNames');
readvarnames = onOff2Logical(readvarnames,'ReadVarNames');

[numeric,txt,raw] = xlsread(xlsfile,sheet,range);
if isempty(numeric) && isempty(txt)
    return
end
clear numeric txt

if readvarnames
    varnames = raw(1,:);
    if ~iscellstr(varnames)
        varnames = cellfun(@convert2Str, varnames, 'UniformOutput',false);
    end
    raw(1,:) = [];
else
    varnames = strcat({'Var'},num2str((1:size(raw,2))','%-d'));
end

a.nobs = size(raw,1);
if readobsnames
    obsnames = raw(:,1);
    if ~iscellstr(obsnames)
        obsnames = cellfun(@convert2Str, obsnames, 'UniformOutput',false);
    end
    dimnames = a.props.DimNames;
    dimnames{1} = varnames{1};
    varnames(1) = [];
    raw(:,1) = [];
    a = setobsnames(a,obsnames);
    a = setdimnames(a,dimnames);
end

a.nvars = length(varnames);
a.data = cell(1,a.nvars);
a = setvarnames(a,varnames(:)'); % names will be modified to make them valid

for j = 1:a.nvars
    var_j = raw(:,j);
    num_j = cellfun(@isnumeric,var_j);
    if all(num_j)
        % convert columns that are all double to a double var
        a.data{j} = cell2mat(var_j);
    else
        char_j = cellfun(@ischar,var_j);
        if all(char_j)
            % convert columns that are all char to a string var
            a.data{j} = var_j;
        else
            log_j = cellfun(@islogical,var_j);
            if all(log_j)
                % convert columns that are all logical to a logical var
                a.data{j} = cell2mat(var_j);
            elseif all(num_j | log_j)
                % convert columns that are mixed double/logical to a double var
                a.data{j} = cellfun(@double,var_j);
            else
                % convert columns that are mixed anyhting else to a string var
                a.data{j} = cellfun(@convert2Str, var_j, 'UniformOutput',false);
            end
        end
    end
end

end % readXLSFile function

%-----------------------------------------------------------------------------
function a = readXPTFile(a,xptfile,args)

pnames = {'readvarnames' 'readobsnames'};
dflts =  {          false          false};
[eid,errmsg,readvarnames,readobsnames] ...
    = dataset.getargs(pnames, dflts, args{:});
if ~isempty(eid)
    error(sprintf('stats:dataset:dataset:%s',eid),errmsg);
end
readobsnames = onOff2Logical(readobsnames,'ReadObsNames');
readvarnames = onOff2Logical(readvarnames,'ReadVarNames');

% Var names are always present in the XPT file, and are always read, and are
% always valid (max 8 char alphanumeric).
if(readvarnames)
   warning('stats:dataset:dataset:XPTReadVarNotSupported', ...
        'READVARNAMES is not supported when reading XPORT format files and will be ignored.');
end

a = xptread(xptfile,'ReadObsNames',readobsnames);

end % readXPTFile function

%-----------------------------------------------------------------------------
function s = convert2Str(n)
if isnumeric(n)
    if isnan(n)
        % A numeric NaN means the cell was empty, make that the empty string
        s = '';
    else
        s = num2str(n);
    end
elseif islogical(n)
    if n
        s = 'true';
    else
        s = 'false';
    end
elseif ischar(n)
    s = n;
else
    error('stats:dataset:dataset:UnexpectedClass', ...
          'Unable to convert value of class %s to char.',class(n));
end
end % function
    

%-----------------------------------------------------------------------------
function arg = onOff2Logical(arg,str)

if ischar(arg)
    if strcmpi(arg,'on')
        arg = true;
    elseif strcmpi(arg,'off')
        arg = false;
    else
        error(['stats:dataset:dataset:Invalid' str], ...
              'The ''%s'' parameter must be ''on'', ''off'', or a logical scalar.',str);
    end
elseif islogical(arg)
    % leave it alone
else
    error(['stats:dataset:dataset:Invalid' str], ...
           'The ''%s'' parameter must be ''on'', ''off'', or a logical scalar.',str);
end
end % function
