function this = RegisterDb(extFileName, varargin)
%RegisterDb Constructor for Extensions Registry Database.
%  RegisterDb(extFileName) creates an empty database of extensions that all
%  correspond to extFileName.
%
%  Each extension is described by an instance of the Register class. Each
%  description is created and added to the database by invoking
%  RegisterDb::add().  RegisterDb::register() finds all registrations and
%  adds each of them automatically.
%
%  RegisterDb(extFileName) specifies the file name used to register (and
%  thus, to discover) extensions.  This is an MATLAB file function that is on
%  the MATLAB path, or a method of a class whose parent is on the MATLAB
%  path.
%
%  Typically, RegisterDb is created and retained during register(), where
%  the extension registration files are identified and read. Execution of
%  these files causes add() to be called on RegisterDb.
%
%  What gets recorded initially is just name/type/description info, and if
%  the extension is enabled, the object associated with the extension is
%  ultimately instantiated and recorded in each Register item.
%
%  RegisterDb(extFileName, hMessageLog) sets the .hMessageLog property of
%  this RegisterDb instance to the caller's MessageLog instance.  If
%  omitted, the property may be set later, or left empty if no message
%  reporting is desired.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.9 $ $Date: 2010/01/25 22:46:39 $

this = extmgr.RegisterDb;
this.FileName = extFileName;

% Allocate extension registration type database
this.RegisterTypeDb = extmgr.RegisterTypeDb;

[hMessageLog, debugFlag] = parseInputs(varargin{:});

this.MessageLog = hMessageLog;

% Populate the RegisterDb database
register(this, debugFlag);

% Sort registrations according to .Order as found
% in RegisterType and in Register, and cache .SortedTypeNames
sortRegs(this);

%% ------------------------------------------------------------------------
function register(this, debugflag)
%REGISTER Find and register scope extensions.
%   REGISTER finds and register scope extensions without invoking
%   any license checkout on the scopext.m description files.
%   Errors are logged to MessageLog, if available.
%
%   Scopes may be enhanced by user-provided "plug-in" files
%   for the purpose of providing new data sources and formats,
%   adding new tools and measurements, or adding new renderers.
%   These are collectively known as "scope extensions."
%
%   Scope extensions are registered by adding MATLAB files named
%   "scopext.m" to the MATLAB path.  These files define the
%   package and class name implementing each scope extension.
%   Typically, scopext.m is a package function, placed in the
%   same package that implements the scope extension itself.
%
%   All scope extensions implement their functionality by extending
%   (or subclassing) specified base classes, and implementing a
%   set of required methods for the appropriate interface.  Different
%   base classes are subclassed depending on the type of extension
%   to be implemented.  See SCOPEXT_INTF for help on the process of
%   implementing new scope functionality.  SCOPEXT_REG only
%   addresses the registration of those extensions to make them
%   known to the scope environment.
%
%   The registration function "scopext.m" invokes one or more extension
%   registration methods on an object passed into the function for this
%   purpose.  The function prototype of scopext.m must be:
%
%      function scopext(ext)
%
%   Note that the argument name "ext" must not be changed.  Within this
%   function, methods are optionally invoked on the object to register
%   scope extensions.  The method names are specific to each extension
%   type, and include data source, tool, and visual extension methods
%   as defined below.
%
%   ext.add('sources', ClassName,Name,Description)
%      registers a new data source extension.
%
%   ext.add('tools', ClassName,Name,Description)
%      registers a new tool extension.
%
%   ext.add('visual',ClassName,Name,Description)
%      registers a new visualization extension.
%
%   ext.add('custom',ClassName,Name,Description)
%      registers a new custom extension, which is optionally
%      used by other extension types and are not defined here.
%
%   All arguments to the methods above are strings.
%   Note that 'ClassName' may include the package name as well as
%   the class, as in 'Package.Class'.
%
%   Example: Define a scope extension file that registers
%      one new data source and two new measurement tools.
%      To do this, create a file named scopext.m on the MATLAB
%      path with the following content:
%
%      function scopext(ext)
%      ext.add('source', 'CustomFmt','MyPkg.SrcClass','Read custom format');
%      ext.add('tool','Peaks','MyPkg.PeakFindClass', 'Find data peaks');
%      ext.add('tool','Variance','MyPkg.VarClass',  'Compute sample variance');
%
%      Presumably, MyPkg.PeakFindClass is a class that subclasses
%      the appropriate base class defined in SCOPEXT_INTF and
%      implements a new peak finder tool.
%
%  See also SCOPEXT, SCOPEXT_INTF.

% NOTE: For plug-in behaviors in other (non-scope) code, see:
%   /toolbox/simulink/simulink/findblib.m
%   /toolbox/simulink/simulink/libbrowse.m
%   /toolbox/matlab/demos/finddemo.m
%
% This function creates and populates an RegisterDb object.

% Get marker file name that plug-in's must provide.
% This is the name of an MATLAB file function, possibly multiple, 
% each of which is either on the MATLAB path, or in a package
% whose parent is on the MATLAB path.

extFileNames = which('-all',this.FileName);

for i = 1:numel(extFileNames)
    if debugflag
        % Run the files instead of evaluating them when in debug mode.  This
        % allows us to place breakpoints in the extension files.
        run_ext_file(this, extFileNames{i});
    else
        % Evaluate files to get registration data Automatically adds to
        % this object.  Execute the content of each registration file
        eval_ext_file(this,extFileNames{i});
    end
end

% Remove any left over cached application data.  We are not going to be
% adding any more registrations so there's no way that this data will be
% used and is just using up memory.
this.CachedApplicationData = [];

%% ------------------------------------------------------------------------
function run_ext_file(this, fname)

[root, path] = strtok(fname, '@');
if isempty(path)
    [file_path, file_name] = fileparts(root);
    % Since the file may be shadowed in multiple directories, the only way
    % to execute a particular version is to cd into the directory and eval
    % the file. We could have read the file and executed its contents as a
    % script, but that defeats the whole purpose of being in debug mode.
    % Capture the current working directory.
    orig_dir = pwd;
    % CD into the directory which contains the file that needs to be evaluated.
    cd(file_path);
    % Evaluate the file.
    try
        feval(file_name, this);
    catch e
        cd(orig_dir);
        error(e.message);
    end
    cd(orig_dir);
else
    path(1) = [];
    [package, file] = fileparts(path);
    file = sprintf('%s.%s', package, file);
    feval(file, this);
end



%% ------------------------------------------------------------------------
function typeNames = getUniqueTypes(this)
%GETUNIQUETYPES Return unique type strings registered by extensions.
%  GETUNIQUETYPES(H) returns a cell-array of unique type strings, collected
%  from all extensions registered in database.  This list does not include
%  type registrations, which are extensions themselves - just a type of
%  extension that could be registered.

% If there are no children added yet, shortcut and return {}.
if numChild(this) == 0
    typeNames = {};
else
    typeNames = get(allChild(this), 'Type');
    
    % Prune list to hold just unique names of extensions.  Wrap in CELLSTR
    % in case of a single string.
    typeNames = unique(cellstr(typeNames));
end

%% ------------------------------------------------------------------------
function eval_ext_file(this,fname)
%EVAL_EXT_FILE Read and execute content from a registration file.
%   Content is read in and evaluated using "eval"
%   This is done to avoid license checkout.

% Read registration content, converting "function" to "script"
%
[fcnStr,err] = read_ext_file(this,fname);
if err, return; end

% We want to detect if any registrations occur after executing
% the plug-in.
%  - no additional plug-in's?  issue warning, since the file
%    did not do what it should do
%  - one or more plug-in's?  we want to know which, so we can
%    associate the name of the plug-in file with each new
%    registered plug-in

% Cache the right-most (last) current child
%
% Note: Could be no children in list, in which case hLastChild is empty
hLastChild = this.down('last');

% Execute the plug-in function
%
% Protect against empty strings, which eval does not like
if ~isempty(fcnStr)
    % Run registration on a newly instantiated
    % Extensions registry database object (RegisterDb).
    %
    % All data is manipulated "in-place" via the ext object
    
    % Set the name of the extension registration file we are reading
    % into this.  This is done purely for error-reporting purposes.
    % this is the only variable passed in to the evaluation,
    % and if errors occur during the underlying "add" operation only
    % this is available to deduce the context of the error.
    % We want to associate the plug-in file name with the error message,
    % so a temporary "scratch" string has been added to this just
    % for this purpose.  We clear it when done, just to make sure
    % it's not being used for any other "persistent" purposes.
    %
    this.FileBeingProcessed = fname;
    
    % Evaluate registration function content as a script
    % Pass extension registration database as an additional argument
    % This gets passed as "ext" in the eval_ext_script() function,
    % which is what the script expects to have as a formal arg.
    try
        % Errors could occur during "add" operation
        % That's where the "FileBeingProcessed" property is used
        %
        eval_ext_script(fcnStr,this);
    catch e
        % Hard errors detected (syntax error during eval, etc)
        % Copy error to report:
        local_adderror(this, fname, uiservices.cleanErrorMessage(e));
 
        % Remove ALL plug-in's coming from this extension file.
        %
        % We have a pointer to the last valid extension prior to attempting
        % to add new ones from this file, so we can remove the recent
        % extensions unambiguously.
        %
        % This means even if 4 of 5 extensions did get added properly,
        % and only the 5th caused an error, all 5 will get removed.
        % All plug-in's in one registration file will be added or
        % removed as a group - no "partial additions."
        %
        % Note:
        % If any extensions were added before error occurred,
        % they do NOT have a .File name associated with them
        % at this point.
        
        disconnectChildren(this,hLastChild);
        this.FileBeingProcessed = '';
        return
    end
    this.FileBeingProcessed = '';
end

addFileName(this,hLastChild,fname);

% NOTE:
%  We register success messages here, and not in RegisterDb:add,
%  That's because the add() method could get called with only
%  a partial amount of information during construction, say,
%  only the extension type and name.  Yet we want the message log
%  to indicate the file, description, dependencies, etc, all of
%  which might have only been added after the constructor line
%  executed, e.g., via property set such as h.Description=blah.
%  So we must wait until the entire extension file executes.
%  Forcing us to do this here, and not add()
%
registerSuccess(this,hLastChild);

%% ------------------------------------------------------------------------
function addFileName(this,hLastChild,fname)
%addFileName Associate file name info with each added extension.

if ~isempty(hLastChild)
    % Children existed previously
    % Point to first "newly added" child in database
    hNewChild = hLastChild.right;
else
    % No children previously, might be one or more now
    % Point to first child in database (if any)
    hNewChild = this.down;
end
while ~isempty(hNewChild)
    hNewChild.File = fname;
    hNewChild = hNewChild.right; % next new child
end

%% ------------------------------------------------------------------------
function disconnectChildren(this,hLastChild)
%disconnectChildren Disconnect all children of this after hLastChild.

if ~isempty(hLastChild)
    % Children existed previously
    % Point to first "newly added" child in database
    hNewChild = hLastChild.right;
else
    % No children previously, might be one or more now
    % Point to first child in database (if any)
    hNewChild = this.down;
end
while ~isempty(hNewChild)
    nextNewChild = hNewChild.right; % cache next child
    disconnect(hNewChild);          % disconnect this child
    hNewChild = nextNewChild;       % next new child
end

%% ------------------------------------------------------------------------
function [fcnStr,err] = read_ext_file(this,fname)
%read_plugin_content Read and return contents of plug-in file.
%  Returns string fcnStr, processed such that "eval" can be executed on it.
%  This means turning the "function" into a "script."  This is generally
%  dangerous, since there is no guarantee that this conversion is
% unambiguous.  There are several steps we take:
%
%  - The "function" declaration line is removed
%  - Line-continuations (...) are removed, as is the remainder of
%     text on that line to conform with MATLAB syntax

fcnStr = '';  % Initialize string containing script contents

% Open file, read-only, text mode
% (text mode: only on a PC, CR is removed preceding LF)
[fid,errmsg] = fopen(fname,'rt');
err = ~isempty(errmsg);  % || (fid == -1)
if err
    local_adderror(this,fname,errmsg);
    return
end

% Find function definition line
fcnFound = false;
while ~feof(fid)
    fcnLine = fgetl(fid);
    if ~ischar(fcnLine)
        break % EOF or read error
    end
    fcnFound = ~isempty(findstr(lower(fcnLine),'function'));
    if fcnFound, break; end
end

% Were we successful in finding "function" line?
err = ~fcnFound;
if err
    if ~feof(fid)
        errmsg = ferror(fid);
    else
        errmsg = 'Function declaration not found.';
    end
    local_adderror(this,fname,errmsg);
    fclose(fid);
    return
end

% Must have found "function" line
%
% NOTE: Here we could parse fcnLine string to extract
%       the input argument name, but we don't.
%
%    Benefit: user could change name of formal arg in plug-in function,
%             and we would not know this unless the parse
%   Drawback: more work to parse file, and to set up evaluation

% Start reading the registration file
cr = sprintf('\n');
while ~feof(fid)
    fcnLine = fgetl(fid);  % Read next line in file
    if ~ischar(fcnLine)
        break  % EOF or read error
    end
    % Must remove any line-continuations (...), since eval()
    % does not allow these.
    %
    dotsIdx = findstr(fcnLine,'...');
    if isempty(dotsIdx)
        % No line continuation
        % Must reintroduce carriage-return, in case a comment was at
        % the end of the line of text.  Concatenation without CR would
        % cause all new chars to be part of the comment, resulting in
        % incorrect evaluation of the plug-in.
        fcnStr = [fcnStr fcnLine cr]; %#ok
    else
        % Remove "..." and concatenate with the next line in file
        % with no carriage return.
        %
        % Note: this will remove '...' inside any quoted strings.
        % To fix this, we would need to contextually parse each line,
        % requiring more time to execute.
        %
        % We must remove not only the "...", but also the rest of the line
        % after the "...".  This is because MATLAB treats all characters
        % after the ellipsis as a comment.  If a user adds additional chars,
        % these would accidentally be "executed" and possibly cause bugs.
        %
        % So instead of removing from dotsIdx:dotsIdx+2,
        % we remove ALL chars to the end of the line:
        %
        fcnStr = [fcnStr fcnLine(1:dotsIdx-1) ' ']; %#ok
    end
end
err = ~feof(fid);
if err
    local_adderror(this,fname,ferror(fid));
    fclose(fid);  % get error msg before closing fid
    return
end
fclose(fid);

%% ------------------------------------------------------------------------
function eval_ext_script(script__content__,ext) %#ok
% This is done in a local function to reduce the accidents
% possible when evaluating user code.  The user code could
% create any number of variables that could conflict with
% local variables in the caller's context.  So we reduce the
% variables in scope of this eval as much as possible
%
% script__content__ could be named just about anything, but
% we choose to make it a variable that is unlikely
% to be utilized by user code ... if it is overwritten,
% it won't make a difference to this code.  However,
% the user will find it to be declared if they accidentally
% utilize it.
%
% On the other hand, 'ext' (which is really this) must be
% utilized exactly as spelled in the user code - no change in name
% can be made to this variable!  That's because we're evaluating
% the function as a script, and all variables must be defined.
%
% NOTE:
% It is expected that the user code invokes RegisterDB::add()
% to add entries to the extension database.
%
eval(script__content__);

%% ------------------------------------------------------------------------
function local_adderror(this,fname,errmsgs)
% Add message to Extensions object error list.
%
hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    summary = 'Extension file failed to register';
    details=sprintf(['Error occurred while registering extension.<br>' ...
        '<ul>' ...
        '<li><b>File:</b> %s<br>' ...
        '<li><b>Message:</b><br>' ...
        '%s<br>' ...
        '</ul>' ...
        '<b>Skipping this extension.</b><br>'], ...
        fname, errmsgs);
    hMessageLog.add('Fail','Extension',summary,details);
end

%% ------------------------------------------------------------------------
function registerSuccess(this,hLastChild)
%registerSuccess Record message indicating successful extension registration.

hMessageLog = this.MessageLog;
if ~isempty(hMessageLog)
    if ~isempty(hLastChild)
        % Children existed previously
        % Point to first "newly added" hRegister child in database
        hNext = hLastChild.right;
    else
        % No children previously, might be one or more now
        % Point to first hRegister child in database (if any)
        hNext = this.down;
    end
    while ~isempty(hNext)
        % Send success message
        summary = sprintf('%s registered',hNext.Name);
        details = coreDetailMsg(hNext, ...
            'Extension successfully registered');
        hMessageLog.add('Info','Extension',summary,details);
        
        hNext = hNext.right; % next new child
    end
end

%% ------------------------------------------------------------------------
function details = coreDetailMsg(hRegister,title)
% Construct common detail message content

details = sprintf([ title ...
    '<ul>' ...
    '<li>Type: %s' ...
    '<li>Name: %s' ...
    '<li>Class: %s' ...
    '<li>Description: %s' ...
    '<li>File: %s' ...
    '<li>Order: %f' ...
    '<li>Depends: %s' ...
    '</ul>'], ...
    hRegister.Type, hRegister.Name, hRegister.Class, ...
    hRegister.Description, hRegister.File, ...
    hRegister.Order, getDependsStr(hRegister));

%% ------------------------------------------------------------------------
function sortRegs(this)
%sortRegs Sort registrations by type and extension order.
%   Sort registrations and registration types according to the optional
%   .Order property as found in Register and in RegisterType.  If Order is not
%   explicitly set on a registration type or name, a default value of zero
%   is obtained.
%
%   We must cache SortedTypeNames for the dialog (ExtDialog), but
%   no there is no real reason to sort the registrations themselves.
%   We must sort the configurations, however, since the order of enabling
%   in ExtDriver::processConfigDbEnableStates must respect the extension
%   ordering.

% Find sorted order of all types used by extensions
%
% Get list of unique type names of all registered extensions
% (*not* just those types registered in hRegisterTypeDb)
typeNames = getUniqueTypes(this);
N = numel(typeNames);
typeOrder = zeros(1,N);
hRegisterTypeDb = this.RegisterTypeDb;
for i=1:N
    typeOrder(i) = getOrder(hRegisterTypeDb,typeNames{i});
end
% Sort types into ascending order
[temp,type_sort_order] = sort(typeOrder);

% Cache ordered list of unique type names as a cell-string
%
% This is useful for dialog tabs, etc, where the as-sorted
% list of unique type names is needed.
sortedTypeNames = typeNames(type_sort_order);
this.SortedTypeNames = sortedTypeNames;

%% ------------------------------------------------------------------------
function [hMessageLog, debugFlag] = parseInputs(varargin)

hMessageLog = [];
debugFlag   = false;

while ~isempty(varargin)
    if islogical(varargin{1})
        debugFlag = varargin{1};
    elseif isa(varargin{1}, 'uiservices.MessageLog')
        hMessageLog = varargin{1};
    else
        error(generatemsgid('InvalidInput'), 'Internal Error: Invalid input.');
    end
    varargin(1) = [];
end

% [EOF]
