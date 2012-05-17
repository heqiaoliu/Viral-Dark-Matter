function edit(varargin)
%EDIT Edit or create a file
%   EDIT FUN opens the file FUN.M in a text editor.  FUN must be the
%   name of a file with a .m extension or a MATLABPATH relative 
%   partial pathname (see PARTIALPATH).
%
%   EDIT FILE.EXT opens the specified file.  MAT and MDL files will
%   only be opened if the extension is specified.  P and MEX files
%   are binary and cannot be directly edited.
%
%   EDIT X Y Z ... will attempt to open all specified files in an
%   editor.  Each argument is treated independently.
%
%   EDIT, by itself, opens up a new editor window.
%
%   By default, the MATLAB built-in editor is used.  The user may
%   specify a different editor by modifying the Editor/Debugger
%   Preferences.
%
%   If the specified file does not exist and the user is using the
%   MATLAB built-in editor, an empty file may be opened depending on
%   the Editor/Debugger Preferences.  If the user has specified a
%   different editor, the name of the non-existent file will always
%   be passed to the other editor.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.34 $  $Date: 2010/03/31 18:23:22 $

if ~iscellstr(varargin)
    error(makeErrID('NotString'), 'The input must be a string.');
end

try
    if (nargin == 0)
        openEditor;
    else
        for i = 1:nargin
            argName = translateUserHomeDirectory(strtrim(varargin{i}));
            if isempty(argName)
                openEditor;
            else
                checkEndsWithBadExtension(argName);

                if ~openInPrivateOfCallingFile(argName)
                    if ~openOperator(argName)
                        if ~openWithFileSystem(argName, ~isSimpleFile(argName))
                            if ~openPath(argName)
                                showEmptyFile(argName);
                            end
                        end
                    end
                end
            end
        end
    end
catch exception
    throw(exception); % throw so that we don't display stack trace
end

%--------------------------------------------------------------------------
% Special case for opening invoking 'edit' from inside of a function:
%   function foo
%   edit bar
% In the case above, we should be able to pick up private/bar.m from
% inside foo.
function opened = openInPrivateOfCallingFile(argName)
opened = false;
st = dbstack('-completenames');
% if there are more than two frames on the stack, then edit was called from
% a function
if length(st) > 2
    dirName = fileparts(st(3).file);
    privateName = fullfile(dirName, 'private', argName);
    opened = openWithFileSystem(privateName, false);
end

%--------------------------------------------------------------------------
% Helper function that displays an empty file -- taken from the previous edit.m
% Now passes error message to main function for display through error.
function showEmptyFile(file)
errMessage = '';
errID = '';

% If nothing is found in the MATLAB workspace or directories,
% open a blank buffer only if:
%   1) the given file is a simple filename (contains no qualifying 
%      directories, i.e. foo.m) 
%   OR 
%   2) the given file's directory portion exists (note that to get into 
%      this method it is implied that the file portion does not exist)
%      (i.e. myDir/foo.m, where myDir exists and foo.m does not).
[path fileNameWithoutExtension extension] = fileparts(file);

if isSimpleFile(file) || (exist(path, 'dir') == 7)
    
    % build the file name with extension.
    if isempty(extension) 
        extension = '.m';
    end
    fileName = [fileNameWithoutExtension extension];

    % make sure the given file name is valid.
    checkValidName(fileName);
    
    % if the path is empty then use the current working directory.
    % else use the fully resolved version of the given path.
    if (strcmp(path, ''))
       path = pwd;
    else
        whatStruct = what(path);
        path = whatStruct.path;
    end
    
    if (isempty(checkJavaAvailable) ...
            && com.mathworks.mde.editor.EditorOptions.getShowNewFilePrompt == false ...
            && com.mathworks.mde.editor.EditorOptions.getNamedBufferOption == ...
                com.mathworks.mde.editor.EditorOptions.NAMEDBUFFER_DONTCREATE ...
            && com.mathworks.mde.editor.EditorOptions.getBuiltinEditor ~= 0)
        [errMessage, errID] = showFileNotFound(file, false);
    else
        openEditor(fullfile(path,fileName));
    end
else
    [errMessage, errID] = showFileNotFound(file, false);
end
handleError(errMessage, errID);

%--------------------------------------------------------------------------
% System dependent call so we can get the preference without Java.
% Don't use these methods if Java is available to avoid race conditions
% with Prefs writing out the file.
function result = isUsingBuiltinEditor
result = getBooleanPref('EditorBuiltinEditor', true);

%--------------------------------------------------------------------------
function result = getBooleanPref(prefname, defaultValue)
prefValue = system_dependent('getpref', prefname);
if (~isempty(strfind(prefValue, 'Bfalse')))
    result = false;
elseif (~isempty(strfind(prefValue, 'Btrue')))
    result = true;
else
    result = defaultValue;
end

%--------------------------------------------------------------------------
function result = getStringPref(prefname, defaultValue)
% If Java is available, use the Java Prefs API so that we ensure proper
% translation of \u0000-encoded characters. Otherwise, just accept the
% string as-is, knowing that encoding characters in the path might not
% work.
if isempty(checkJavaAvailable)
    result = char(com.mathworks.services.Prefs.getStringPref(...
        prefname, defaultValue));
else
    prefValue = system_dependent('getpref', prefname);
    if (length(prefValue) > 1)
        result = prefValue(2:end);
    else
        result = defaultValue;
    end
end


%--------------------------------------------------------------------------
% Returns the non-MATLAB external editor.
function result = getOtherEditor
result = getStringPref('EditorOtherEditor', '');

%--------------------------------------------------------------------------
% Returns if Java is available (for -nojvm option).
function result = checkJavaAvailable
result = javachk('swing', 'The MATLAB Editor');
 
%--------------------------------------------------------------------------
% Helper function that calls the java editor.  Taken from the original edit.m.
% Did modify to pass non-existent files to outside editors if
% user has chosen not to use the built-in editor.
% Also now passing out all error messages for proper display through error.
% It is possible that this is incorrect (for example, if the toolbox
% cache is out-of-date and the file actually no longer is on disc).
function openEditor(file)
% OPENEDITOR  Open file in user specified editor

errMessage = '';
errID = '';

% Make sure our environment supports the editor. Need java.
err = checkJavaAvailable;
if ~isempty(err)
    if isunix % unix includes Mac
        if nargin==0 % nargin = 0 means no file specified at all.  This case is ok.
            if isMac
                openFileOnMac(getenv('EDITOR'));
            else
                system_dependent('miedit', '');
            end
        else
            if isMac
                openFileOnMac(getenv('EDITOR'), file);
            else
                system_dependent('miedit', file);
            end
        end
        return
    end
end

if isUsingBuiltinEditor
    % Swing isn't available, so return with error
    if ~isempty(err)
        errMessage = err.message;
        errID = err.identifier;
    else
        % Try to open the Editor
        try
            if nargin==0
                editorservices.new;
            else
                editorservices.open(file);
            end % if nargin
        catch exception %#ok
            % Failed. Bail
            errMessage = 'Failed to open editor. Load of Java classes failed.';
            errID = 'JavaErr';
        end
    end
else
    % User-specified editor
    if nargin == 0
        openExternalEditor;
    else
        openExternalEditor(file);
    end
end
handleError(errMessage, errID);

%--------------------------------------------------------------------------
% Open the user's external editor
function openExternalEditor(file)
editor = getOtherEditor;

if ispc
    % On Windows, we need to wrap the editor command in double quotes
    % in case it contains spaces
    if nargin == 0
        system(['"' editor '" &']);
    else
        system(['"' editor '" "' file '" &']);
    end
elseif isunix && ~isMac
    % Special case for vi and vim
    if strcmp(editor,'vi') == 1 || strcmp(editor,'vim') == 1
        editor = ['xterm -e ' editor];
    end

    % On UNIX, we don't want to use quotes in case the user's editor
    % command contains arguments (like "xterm -e vi")
    if nargin == 0
        system([editor ' &']);
    else
        system([editor ' "' file '" &']);
    end
else
    % Run on Macintosh
    if nargin == 0
        openFileOnMac(editor)
    else
        openFileOnMac(editor, file);
    end
end

%--------------------------------------------------------------------------
% Helper function to see if something is Mac.
function mac = isMac
mac = strncmp(computer,'MAC',3);

%--------------------------------------------------------------------------
% Helper method to run an external editor from the Mac
function openFileOnMac(applicationName, absPath)

% Put app name in quotes
appInQuotes = ['"' applicationName '"'];

% Is this a .app -style application, or a BSD exectuable?
% If the former, use it to open the file (if any) via the
% BSD OPEN command.
if length(applicationName) > 4 && strcmp(applicationName(end-3:end), '.app')
    % Make sure that the .app actually exists.
    if exist(applicationName, 'dir') ~= 7
        error(makeErrID('ExternalEditorNotFound'), ...
            'Could not find external editor %s',applicationName);
    end
    if nargin == 1 || isempty(absPath)
        unix(['open -a ' appInQuotes]);
    else
        unix(['open -a ' appInQuotes ' "' absPath '"']);
    end
    return;
end

% At this point, it must be BSD a executable (or possibly nonexistent)
% Can we find it?
[status, result] = unix(['which ' appInQuotes ]);

% UNIX found the application
if status == 0
    % Special case for vi, vim and emacs since they need a shell
    if checkMacApp(applicationName, 'vi') || ...
            checkMacApp(applicationName, 'vim') || ...
            checkMacApp(applicationName, 'emacs')
        appInQuotes = ['xterm -e ' appInQuotes];
    end
    
    if nargin == 1 || isempty(absPath)
        command = [appInQuotes ' &'];
    else
        command = [appInQuotes ' "' absPath '" &'];
    end

    % We think that we have constructed a viable command.  Execute it,
    % and error if it fails.
    [status, result] = unix(command);
    if status ~= 0
        error(makeErrID('ExternalEditorFailure'), ...
            'Could not open external editor %s',result);
    end
    return;
else
    % We could not find a BSD executable.  Error.
    error(makeErrID('ExternalEditorNotFound'), ...
        'Could not find external editor %s',result);
end

% Helper function for openFileOnMac
function found = checkMacApp(applicationName, lookFor)
found = ~isempty(strfind(applicationName,['/' lookFor])) || ...
    strcmp(applicationName, lookFor) == 1;
        
%--------------------------------------------------------------------------
% Helper function that trims spaces from a string.  Taken from the original
% edit.m
function s1 = strtrim(s)
%STRTRIM Trim spaces from string.

if isempty(s)
    s1 = s;
else
    % remove leading and trailing blanks (including nulls)
    c = find(s ~= ' ' & s ~= 0);
    s1 = s(min(c):max(c));
end

%----------------------------------------------------------------------------
% Checks if filename is valid by platform.
function checkValidName(file)
% Is this a valid filename?
if ~isunix
    invalid = '/\:*"?<>|';
    a = strtok(file,invalid);

    if ~strcmp(a, file)
        errMessage = sprintf('File ''%s'' contains invalid characters.', file);
        errID = 'BadChars';
        handleError(errMessage, errID);
    end
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName with the path.
% If it does, it opens the file.
function fExists = openPath(argName)

[fExists, pathName] = resolvePath(argName);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that resolves using the path
function [result, absPathname] = resolvePath(argName)

result = 0;
absPathname = argName;

[unused, relativePath] = helpUtils.separateImplicitDirs(pwd);

[classInfo, whichTopic] = helpUtils.splitClassInformation(argName, relativePath, true, false);
if ~isempty(whichTopic)
    % whichTopic is the full path to the resolved output either by class 
    % inference or by which
    
    switch exist(whichTopic, 'file')
    case 4 % Mdl File
        if ~hasExtension(argName)
            error(makeErrID('MdlErr'), 'Can''t edit the MDL-file ''%s'' unless you include the ''.mdl'' file extension.', argName);            
        end
    case 7 % Directory, therefore package
        error(makeErrID('PkgErr'), 'Can''t edit the package directory ''%s''.', classInfo.fullTopic);            
    end
    
    result = 1;
    absPathname = whichTopic;
elseif ~ischar(whichTopic)
    % there is a trick in splitClassInformation in which whichTopic will be
    % char empty for things that which has found nothing, and double empty for
    % things that which has not been called on... I apologize for this hack. -=>JBreslau
    fullTopic = helpUtils.safeWhich(argName);
    if ~isempty(fullTopic)
        result = 1;
        absPathname = fullTopic;
    end
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName as a builtin operator.
% If it does, it opens the file.
function fExists = openOperator(argName)

[fExists, pathName] = resolveOperator(argName);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that resolves builtin operators
function [result, absPathname] = resolveOperator(argName)
if helpUtils.isOperator(argName) && exist(argName, 'builtin')
    argName = regexp(which(argName), '\w+(?=\.[mp]$|\)$|$)', 'match', 'once');
    absPathname = which([argName '.m']);
    result = 1;
else
    result = 0;
    absPathname = argName;
end

%--------------------------------------------------------------------------
% Helper method that tries to resolve argName as a file.
% If it does, it opens the file.
function fExists = openWithFileSystem(argName, errorDir)

[fExists, pathName] = resolveWithFileSystem(argName, errorDir);

if (fExists)
    openEditor(pathName);
end

%--------------------------------------------------------------------------
% Helper method that checks the filesystem for files
function [result, absPathname] = resolveWithFileSystem(argName, errorDir)
[result, absPathname] = resolveWithDir(argName, errorDir);

if ~result && ~hasExtension(argName)
    argM = [argName '.m'];
    [result, absPathname] = resolveWithDir(argM, false);
end


%--------------------------------------------------------------------------
% Helper method that checks the filesystem for files
function [result, absPathname] = resolveWithDir(argName, errorDir)
    
result = 0;
absPathname = argName;

dir_result = dir(argName);

if ~isempty(dir_result)
    if (numel(dir_result) == 1) && ~dir_result.isdir
        result = 1;  % File exists
        % If file exists in the current directory, return absolute path
        if (~isAbsolutePath(argName))
            absPathname = fullfile(pwd, argName);
        end
    elseif errorDir
        errMessage = sprintf('Can''t edit the directory ''%s''.', argName);
        errID = 'BadDir';
        handleError(errMessage, errID);
    end
end

%--------------------------------------------------------------------------
% Translates a path like '~/myfile.m' into '/home/username/myfile.m'.
% Will only translate on Unix.
function pathname = translateUserHomeDirectory(pathname)
if isunix && strncmp(pathname, '~/', 2)
    pathname = [deblank(evalc('!echo $HOME')) pathname(2:end)];
end

%--------------------------------------------------------------------------
% Helper method that determines if filename specified has an extension.
% Returns true if filename does have an extension, false otherwise
function result = hasExtension(s)

[pathname,name,ext] = fileparts(s);
if (isempty(ext))
    result = false;
    return;
end
result = true;


%----------------------------------------------------------------------------
% Helper method that returns error message for file not found
%
function [errMessage, errID] = showFileNotFound(file, rehashToolbox)

if hasExtension(file) % we did not change the original argument
    errMessage = sprintf('File ''%s'' not found.', file);
    errID = 'FileNotFound';
else % we couldn't find original argument, so we also tried modifying the name
    errMessage = sprintf('Neither ''%1$s'' nor ''%1$s.m'' could be found.', file);
    errID = 'FilesNotFound';
end

if (rehashToolbox) % reset errMessage to rehash message
    errMessage = sprintf('File ''%s''\nis on your MATLAB path but cannot be found.\nVerify that your toolbox cache is up-to-date.', file);
end

%--------------------------------------------------------------------------
% Helper method that checks if filename specified ends in .mex, .p, or .mdlp.
% For mex, actually checks if extension BEGINS with .mex to cover different forms.
% If any of those bad cases are true, throws an error message.
function checkEndsWithBadExtension(s)

errMessage = '';
errID = '';

[pathname,name,ext] = fileparts(s);
ext = lower(ext);
if (strcmp(ext, '.p'))
    errMessage = sprintf('Can''t edit the P-file ''%s''.', s);
    errID = 'PFile';
elseif (strcmp(ext, ['.' mexext]))
    errMessage = sprintf('Can''t edit the MEX-file ''%s''.', s);
    errID = 'MexFile';
elseif (strcmp(ext, '.mdlp'))
    errMessage = sprintf('Can''t edit the Simulink Protected Model file ''%s''.', s);
    errID = 'ProtectedModel';
end
handleError(errMessage, errID);

%--------------------------------------------------------------------------
function handleError(errMessage, errID)
if (~isempty(errMessage))
    error(makeErrID(errID), '%s', errMessage);
end

%--------------------------------------------------------------------------
% Helper method that checks for directory seps.
function result = isSimpleFile(file)

result = false;
if isunix
    if isempty(findstr(file, '/'))
        result = true;
    end
else % on windows be more restrictive
    if isempty(findstr(file, '\')) && isempty(findstr(file, '/'))...
            && isempty(findstr(file, ':')) % need to keep : for c: case
        result = true;
    end
end

%--------------------------------------------------------------------------
% Helper method for error messageID display
function realErrID = makeErrID(errIDin)
realErrID = ['MATLABeditor:'  errIDin];

%--------------------------------------------------------------------------
function result = isAbsolutePath(filePath)
% Helper method to determine if the given path to an existing file is
% absolute.
% NOTE: the given filePath is assumed to exist.

    result = false;
    [directoryPart, filePart] = fileparts(filePath); %#ok<NASGU>
    
    if isunix && strncmp(directoryPart, '/', 1)
        result = true;
    elseif ispc && ... % Match C:\, C:/, \\, and // as absolute paths
            (~isempty(regexp(directoryPart, '^([\w]:[\\/]|\\\\|//)', 'once')))
        result = true;
    end
