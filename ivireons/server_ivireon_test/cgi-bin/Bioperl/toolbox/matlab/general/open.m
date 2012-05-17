function out = open(name)
%OPEN	 Open files by extension.
%   OPEN NAME where NAME is a string, does different things
%   depending on the type of the object named by that string:
%
%   Type         Action
%   ----         ------
%   variable      open named array in Variable Editor
%   .m    file    open M-file in M-file Editor
%   .p    file    if NAME resolves to a P-file and NAME did not end with a
%                 .p extension, attempts to open matching M-file; if NAME 
%                 did end with a .p extension, displays an error 
%   .mat  file    open MAT file; store variables in a structure
%   .mdl  file    open model in SIMULINK
%   .fig  file    open figure in Handle Graphics
%   .prj  file    open project in Compiler Development Tool
%   .html file    open HTML document in MATLAB browser
%   .url  file    open an Internet location in your default Web browser
%   .doc* file    open document in Microsoft Word
%   .pdf  file    open PDF document in Adobe Acrobat
%   .ppt* file    open document in Microsoft PowerPoint
%   .xls* file    start MATLAB Import Wizard
%   .exe  file    run Microsoft Windows executable file
%
%                   
%   OPEN works similar to LOAD in the way it searches for files.
%
%     If NAME exists on MATLAB path, open file returned by WHICH.
%
%     If NAME exists on file system, open file named NAME.
%
%   Examples:
%
%     open('f2')                First looks for a variable named f2, then 
%                               looks on the path for a file named f2.mdl 
%                               or f2.m.  Error if can't find any of these.
%
%     open('f2.mat')            Error if f2.mat is not on path.
%
%     open('d:\temp\data.mat')  Error if data.mat is not in d:\temp.
%
%
%   OPEN is user-extensible.  To open a file with the extension ".XXX",
%   OPEN calls the helper function OPENXXX, that is, a function
%   named 'OPEN', with the file extension appended.
%
%   For example,
%      open('foo.log')       calls openlog('foo.log')
%      open foo.log          calls openlog('foo.log')
%
%   You can create your own OPENXXX functions to set up handlers 
%   for new file types.  OPEN will call whatever OPENXXX function 
%   it finds on the path.
%
%   See also SAVEAS, WHICH, LOAD, UIOPEN, FILEFORMATS, PATH.
%

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.35.4.21 $  $Date: 2009/07/27 20:17:26 $

if nargin < 1
    error(nargchk(1,1,nargin,'struct'));
end

[m n]=size(name); %#ok<NASGU>

if iscell(name) || ~ischar(name) || m~=1,
    error('MATLAB:open:invalidInput', 'NAME must contain a single string.');
end

% In WHICH, files take precedence over variables, but we want
% variables to take precedence in OPEN.  This forces an EXIST
% check on the variable name before we do anything else.
exist_var = evalin('caller', ...
                        ['exist(''' strrep(name, '''','''''') ''', ''var'')']);

% If we found a variable that matches, use that.  Open the variable, and
% get out.
if exist_var == 1
    evalin('caller', ['openvar(''' name ''', ' name ');']);
    return;
end

% We did not find a variable match.  Use files.
fullpath = whichWrapper(name);

% Check to see if it is a help file
if ~exist(fullpath, 'file') && ~hasExtension(name)
    fullpath = whichWrapper([name '.m']);
end

% Find fully qualified paths or files without extensions.
if isempty(fullpath) && exist(name,'file') == 2
  fullpath = name;
end

if isempty(fullpath)
    % which did not find it and exist didn't find it either
    error('MATLAB:open:fileNotFound', 'File ''%s'' not found.',name)
end


%check if user specified extension
%If it is not on the path, then exist only returns a name if the match is
%exact.  If it is on the path, then exist may return a match which has an
%extension, when none was specified.  In that case, call which with a '.'
%appended, so that we can see if the exact match is available.
[~, ~, tmpExt] = fileparts(name);
if isempty(tmpExt)
    %Get all files/dirs which have just the name
    tmpPath = whichWrapper([name '.'], '-all');
    if ~isempty(tmpPath)
        for i = 1:length(tmpPath)
            %If we find a file, set the path to it, and stop.  This means
            %we find files in the same order as which -all returns them.
            if exist(tmpPath{i},'file') == 2
                fullpath = tmpPath{i};
                break;
            end
        end
    end;
end;

% get the path and ext
path = fileparts(fullpath);

if isempty(path)
    error('MATLAB:open:fileNotFound', 'File ''%s'' not found.',fullpath);
else
    % let finfo decide the filetype
    [~, openAction] = finfo(fullpath);
    if isempty(openAction)
        openAction = 'defaultopen';
     % edit.m does not opens p files
     % check here if the .p extension was supplied by the user
     % If the user did not specify .p then which command appended the .p and 
     % we need to strip it off before calling openp.
     elseif strcmp(openAction, 'openp')
        [~,~,ext] = fileparts(name);
        % g560308/g479211 is there wasn't an extension specified and a .p file
        % was found, then search for an associated .m file.
        if isempty(ext)
           fullpath = fullpath(1:end-2);
           % if the .m file associated with the .p file does not exist, error out.
           if exist([fullpath, '.m'],'file') == 0
              error('MATLAB:open:openFailure', 'M-File associated with ''%s'' not found.', [fullpath,'.p']);
           end

        end
        
    end
    
    try
        % if opening a mat file be sure to fetch output args
        if isequal(openAction, 'openmat') || nargout
            out = feval(openAction,fullpath);
        else
            feval(openAction,fullpath);
        end
    catch exception
        % we only want the message from the exception, not the stack trace
        error('MATLAB:open:openFailure', '%s', exception.message);
    end
end 

%------------------------------------------
% Helper method that determines if filename specified has an extension.
% Returns 1 if filename does have an extension, 0 otherwise
function result = hasExtension(s)

[~,~,ext] = fileparts(s);
result = ~isempty(ext);

%------------------------------------------
% WHICH may error out with some input string like '.', '.m', etc,
% Simply ignore the errors and return an empty cell.
function result = whichWrapper(varargin)
try
    result = which(varargin{:});
catch exception  %#ok<NASGU>
    result = '';
end

%------------------------------------------
function out = defaultopen(name)
% Default action to open unrecognized file types.

% To import files by default, uncomment the following line.
%out = uiimport(name);

% To edit files by default, uncomment the following line.
out = []; edit(name);
