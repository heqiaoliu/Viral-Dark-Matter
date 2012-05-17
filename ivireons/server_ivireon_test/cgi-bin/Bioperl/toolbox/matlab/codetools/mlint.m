function [s,filePaths] = mlint(varargin)
%MLINT Check MATLAB code files for possible problems
%   MLINT(FILENAME) displays M-Lint information about FILENAME. If FILENAME
%   is a cell array, information is displayed for each file.
%   MLINT(F1,F2,F3,...) where each input is a character array, displays
%   information about each input file name. You cannot combine cell arrays
%   and character arrays of file names.
%
%   INFO = MLINT(...,'-struct') returns the M-Lint information in a
%   structure array whose length is the number of suspicious constructs
%   found. The structure has the following fields:
%       line    : vector of line numbers to which the message refers
%       column  : two-column array of column extents for each line
%       message : message describing the suspect that M-Lint caught
%   If multiple file names are input, or if a cell array is input, INFO 
%   contains a cell array of structures. 
%
%   MSG = MLINT(...,'-string') returns the M-Lint information as a string
%   to the variable MSG. If multiple file names are input, or if a cell
%   array is input, MSG contains a string where each file's information is
%   separated by ten "=" characters, a space, the file name, a space, and
%   ten "=" characters.
%
%   If the -struct or -string argument is omitted and an output argument is
%   specified, the default behavior is '-struct'. If the argument is
%   omitted and there are no output arguments, the default behavior is to
%   display the information to the command line.
%
%   [INFO,FILEPATHS] = MLINT(...) additionally returns FILEPATHS, the
%   absolute paths to the file names in the same order as they were input.
%
%   [...] = MLINT(...,'-id') requests the message ID from M-Lint as well.
%   When returned to a structure, the output has the following
%   additional field:
%       id       : ID associated with the message
%
%   [...] = MLINT(...,'-fullpath') assumes that the input file names are
%   absolute paths, rather than requiring MLINT to locate them.
%
%   To force M-Lint to ignore a line of code, use %#ok at the end of the
%   line. This tag can be followed by comments.  For example:
%       unsuppressed1 = 10   % This line will get caught
%       suppressed2 = 20     %#ok  These next two lines will not get caught
%       suppressed3 = 30     %#ok
%   [...] = MLINT(...,'-notok') disables the %#ok tag.
%
%   [...] = MLINT(...,'-cyc') displays the McCabe complexity (also referred
%   to as cyclomatic complexity) of each function in the file.
%
%   [...] = MLINT(...,'-config=<file>') overrides the default configuration
%   file and instead uses the one specified by "<file>".  If the file is
%   invalid, M-Lint returns a message indicating that it cannot be opened
%   or read.  In that case, M-Lint uses the factory configuration.
%
%   [...] = MLINT(...,'-config=factory') ignores all configuration files
%   and uses the factory configuration.
%
%   Examples:
%       % "lengthofline.m" is an example file with suspicious M-Lint
%       % constructs. It is found in the MATLAB demos as a read-only file.
%       cd(fullfile(docroot, 'techdoc', 'matlab_env', 'examples'));
%       mlint lengthofline                    % Display to command line
%       info = mlint('lengthofline','-id')    % Store to struct with ID
%
%   See also MLINTRPT.

%   MLINT also takes additional input arguments that are not documented.
%   These arguments are passed directly into the M-Lint executable such
%   that the behavior is consistent with the executable.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.31 $ $Date: 2010/05/13 17:37:41 $

nargs = varargin;

% Extract a cell array of filenames if one was specified,
cellArgInd = cellfun('isclass',nargs,'cell');
usingCell = any(cellArgInd);
if usingCell
    if sum(cellArgInd)>1
        error('MATLAB:mlint:TooManyCellArgs', ...
            'Only one cell array input of filenames is permitted.');
    else
        cellOfFilenames = nargs{cellArgInd};
        nargs(cellArgInd) = [];
    end
end

% Extract the options
% This will also error if there were any non-cell array or non-char inputs
optionsInd = strncmp('-',nargs,1);
options = nargs(optionsInd);
nargs(optionsInd) = [];

loc = feature( 'locale' );
if strcmp( loc.ctype, 'ja_JP.Shift_JIS' )
    options = [ { '-ja' } options ];
end

% Look for the -config= options, and supply the default when unspecified.
% Process all -config= options since M-Lint source code allows it.
configInd = strncmp('-config=',options,8);
if any(configInd) 
    if any(strcmp(options(configInd),'-config=factory'))
        % Ignore config files, i.e, don't pass along any -config= options
        options(configInd) = [];
    end
elseif usejava('jvm')
    % No -config= option was found, so use the user's default (preference) file.
    options{end+1} = ['-config=' char( com.mathworks.widgets.text.mcode.MLintPrefsUtils.getActiveConfiguration.getFile().getAbsolutePath() )];
    % When java is not enabled, there is no way to access the preferences,
    % and M-Lint uses the factory config.
end

% pass in a directory for mylint
options{end+1} = ['-xdir=' prefdir];

% Create a cell array of specified filenames if a cell array wasn't input
if ~usingCell
    cellOfFilenames = nargs;
    nFiles = length(cellOfFilenames);
    if nFiles<1
        error('MATLAB:mlint:NoFile','No file name provided.');
    end
else
    nFiles = length(cellOfFilenames);
    if ~isempty(nargs)
        ignored = sprintf(' %s',nargs{:});
        warning('MATLAB:mlint:UnusedArgs','The following arguments were ignored:%s.',ignored);
    end
end

% Apply options (-config option handled earlier)
outputType = '';
idFlag = false;
resolvePath = true;
removeInd = [];
text = false;
for opt = 1:length(options)
    option = lower(options{opt});
    switch option
        case '-struct'
            outputType = option;
        case {'-string','-disp'}
            outputType = option;
            removeInd = [removeInd opt]; %#ok<AGROW>
        case '-fullpath'
            resolvePath = false;
            removeInd = [removeInd opt]; %#ok<AGROW>
        case '-id'
            idFlag = true;
        case '-text'
            resolvePath = false;    % The file is a pseudo file and hence need not be resolved
            text = true;
    end
end
options(removeInd) = [];

% If outputType = disp and nargout > 0, then throw an error
if( strcmpi(outputType, '-disp') && nargout > 0 )
    error( 'MATLAB:mlint:TooManyOutputArguments', 'MLINT when called with the -DISP option, cannot assign values to any outputs. \nUse -STRING or -STRUCT to assign the output of MLINT to a variable.' );
end

% Make sure that there are only 2 inputs if -TEXT switch is made
if( text )
    if( nFiles ~= 2 )
        error( 'MATLAB:mlint:InvalidInput', '-TEXT requires one argument with text, and a second one with a .m filename' );
    end
    nFiles = 1;
else
    % ARE FILE NAMES ASCII CHARS.?
    isAscii = true;
    for i = 1:nFiles
        M = max( double( cellOfFilenames{i} ) );
        if( M >= 127 )
            isAscii = false;
            break;
        end
    end
end


if isempty(outputType) && nargout>0
    outputType = '-struct';
    options{end+1} = outputType;
elseif isempty(outputType)
    outputType = '-disp';
end

% Locate the specified files
if resolvePath
    for nfile = 1:nFiles
        cellOfFilenames{nfile} = local_resolvePath(cellOfFilenames{nfile});
    end
end

% If second output was specified, output a column cell array of filenames
if nargout>1
    filePaths = cellOfFilenames';
end

% Call the M-Lint MEX-file
if nFiles > 0
    if( text || isAscii )
        mlintMsg = mlintmex(cellOfFilenames{:},options{:});
    else    % IF NON-ASCII FILE NAMESS ARE SUPPLIED, READ INDIVIDUAL FILES AND GENEREATE OUTPUT USING -TEXT SWITCH
        mlintMsg = '';
        options{end + 1} = '-text';
        for i = 1:nFiles
            fileText = fileread( cellOfFilenames{i} );
            mMsg = mlintmex( fileText, cellOfFilenames{i}, options{:} );
            mlintMsg = RearrangeOutput( mlintMsg, mMsg, outputType, nFiles, i, cellOfFilenames{i} );
        end
        if( ~ischar( mlintMsg ) )
            mlintMsg = mlintMsg';   % If its a CELL ARRAY, transpose output, so that it matches with FILEPATHS
        end
    end
else
    s = {};
    return;
end

% REMOVE TEXT FROM CELLOFFILENAMES
% Cannot remove this before calling mlintmex as text must be passed to
% mlintmex
if( text )
   for i = 1:length( cellOfFilenames )
       % Remove the TEXT from CELLOFFILENAMES
       [~, ~, ext] = fileparts( cellOfFilenames{i} );
       if( strcmpi( ext, '.m' ) )
           cellOfFilenames = cellOfFilenames(i);    % Throw out the text and retain only the file name
           break;
       end
    end
end

% Return the results, or go on to build the structure
switch outputType
    case '-disp'
        if nFiles>1
            split = reshape(regexp(mlintMsg, '={10}.*?(?=={10}|$)','match'), [2 nFiles]);
            if feature('hotlinks')
                split(1,:) = strcat({'========== <a href="matlab: edit('''}, cellOfFilenames, {''')">'}, cellOfFilenames, {'</a> '});
            else
                split(1,:) = strcat({'========== '}, cellOfFilenames, {' '});
            end
            split(2,:) = local_HTMLize(split(2,:),cellOfFilenames);
            mlintMsg = [split{:}];
        else
            cmsg = local_HTMLize({mlintMsg}, cellOfFilenames);
            mlintMsg = cmsg{1};
        end
        disp(mlintMsg);
    case '-string'
        if nFiles>1
            split = reshape(regexp(mlintMsg, '={10}.*?(?=={10}|$)','match'), [2 nFiles]);
            split(1,:) = strcat({'========== '}, cellOfFilenames, {' '});
            mlintMsg = [split{:}];
        end
        s = mlintMsg;
    case '-struct'
        % Convert mlintMsg to a cell array for local_msgToCellStruct 
        if isstruct(mlintMsg)
            mlintMsg = {mlintMsg};
        end
        % mlintMsg is not quite the right formation, so transform it
        s = local_transformCellStruct(mlintMsg,idFlag);
        if ~usingCell && nFiles==1
            s = s{1};
        end
end

end


% ------------------------------------------------
function cs = local_transformCellStruct(cinfo,idFlag)
% The M-Lint MEX-file returns a structure with a "loc" field that we need
% to convert to a "line" and "column" field.

% Nest arrayfun inside cellfun to manipulate a cell array of struct arrays
cs = cellfun(@nStructReorg,cinfo,'UniformOutput',false);

    function anew = nStructReorg(sa)
        % Reorganize a struct array
        if isempty(sa)
            % resolve the empty array case
            strFlds = {'message',{},'line',{},'column',{},'fix',{}};
            if idFlag
                strFlds = [strFlds {'id',{}}];
            end
            anew = struct(strFlds{:});
        else
            % resolve all the records at once
            anew = arrayfun(@nRecordReorg,sa);
        end

        function snew = nRecordReorg(s)
            % Reorganize a single record of a structure
            snew.message = s.message;
            snew.line    = s.loc(:,1);
            snew.column  = s.loc(:,2:3);
            % Added the fields FIX so messages returned by MLINT atleast
            % all the fields returned by MLINTMEX
            snew.fix     = s.fix;
            if idFlag
                snew.id = s.id;
            end
        end

    end

end


% ------------------------------------------------
function fullFilename = local_resolvePath(filename)
% Locate the specified file using EXIST, WHICH, PWD, and DIR.
% The strategy is as follows:
% 1. First assume filename is relative to the CWD.  Prepend PWD.
% 2. Append .m and try again.
% 3. Try to locate filename by appending .m and using WHICH.
% 4. Try again without appending .m (this may lead to a later warning).
% 5. Now assume filename was a full path to a file.
% 6. Append .m and try again.

% Perform entire search in a try/catch. If there's an error, simply
% indicate that no MATLAB code file could be found.
try
    % First check if filename is a partial path relative to CWD
    fullFilename = fullfile(cd,filename);
    
    % If file doesn't exist, try again with a .m extension
    if ~local_fullNameIsFile(fullFilename)
        mFullFilename = [fullFilename '.m'];
        % If found with a .m extension, use it!
        if local_fullNameIsFile(mFullFilename)
            fullFilename = mFullFilename;
        else
            % Check if filename is on path as a file
            mFilename = filename;
            if isempty(regexp(mFilename,'\.[mM]$','once'))
                mFilename = [filename '.m'];
            end
            fullFilename = which(mFilename);
            % If WHICH doesn't find the file, try without the .m
            if isempty(fullFilename)
                fullFilename = which(filename);
                % If WHICH still doesn't find filename, then it is attempting
                % to be a full path to a file not on the MATLAB search path
                if isempty(fullFilename)
                    fullFilename = filename;
                    % If file doesn't exist, try again with a .m extension
                    if ~local_fullNameIsFile(fullFilename)
                        mFullFilename = [fullFilename '.m'];
                        % If found with a .m extension, use it!
                        if local_fullNameIsFile(mFullFilename)
                            fullFilename = mFullFilename;
                        else
                            % We have no where else to look.
                            me = nested_errFileNotFound(filename);
                            throw(me);
                        end
                    end
                end
            end
        end
    end
catch me
    % If the file was not found and the exception was already thrown,
    % rethrow it. Otherwise, add a cause and throw it.
    if strcmp(me.identifier, 'MATLAB:mlint:FileNotFound')
        rethrow(me)
    else
        nme = nested_errFileNotFound(filename);
        nme = addCause(nme,me);
        throw(nme);
    end
end

    % Generate a common MException when file not found or an error occurs
    function me = nested_errFileNotFound(filename)
        if ischar(filename)
            me = MException('MATLAB:mlint:FileNotFound', ...
                'MATLAB file "%s" not found with or without a ".m" extension.',filename);
        else
            me = MException('MATLAB:mlint:InvalidInput', ...
                'Expected input filename to be a char array, but found value of class "%s".',class(filename));
        end
    end

% If input filename isn't a ".m" (lowercase) extension, warn and suggest.
% Even for ".M", this will warn for PC and UNIX; however, on UNIX, ".M" 
% files cannot be run. Either way, the M-Lint MEX-file checks
% case-insensitively.
if isempty(regexp(fullFilename,'\.m$','once'))
    warning('MATLAB:mlint:ExtensionNotM', ...
        ['The input file that takes precedence, "%s",\n         ' ...
         'is not a MATLAB file. Use a ".m" extension instead.'],fullFilename);
end

end


% ------------------------------------------------
function flag = local_fullNameIsFile(filename)
flag = ~(isempty(dir(filename)) || isdir(filename));

end


% ------------------------------------------------
function cmsgs = local_HTMLize(cmsgs,files)
% Insert file editor hyperlinks into the displayed output
% CMSGS is a cell array of msgs, corresponding to the cell array of FILES

% ...only if the desktop is enabled
if ~feature('hotlinks')
    return
end

% Escape all regexp metacharacters
literalFiles = regexptranslate('escape',files);

% Loop through files and replace messages
for n=1:length(files)
    repExp = sprintf('<a href="matlab: opentoline(''%s'',$1)">L $1</a>', literalFiles{n});
    cmsgs{n} = regexprep(cmsgs{n},'L (\d+)', repExp);
end

end

% ------------------------------------------------

function mlMsg = RearrangeOutput( mlMsg, mMsg, opType, nF, idx, fName )

if( strcmpi( opType, '-struct' ) )
    mlMsg{idx} = mMsg{1};
elseif( nF == 1 )
    mlMsg = mMsg;
else
    mlMsg = sprintf( '%s========== %s ==========\n%s', mlMsg, fName, mMsg );
end

end