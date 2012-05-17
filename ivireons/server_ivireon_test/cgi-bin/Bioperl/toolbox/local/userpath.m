function p = userpath(inArg)
%USERPATH User environment path.
%   USERPATH returns a path string containing the user specific portion of
%   the path (if it exists). The userpath is the first folder or folders in
%   the list of folders returned by PATHDEF and thus affects the search path. 
%
%   The userpath consists of a primary path, and on certain platforms, 
%   also contains a secondary path. The primary path is only one folder, but
%   the secondary path can contain multiple folders.
%
%   The default primary userpath is platform specific: on Windows,
%   it is the user's "Documents" (or "My Documents" on WinXP) folder
%   appended with "MATLAB".  On the Mac, it is the user's
%   "Documents" folder ($home/Documents) appended with "MATLAB".
%   On Unix, it is the user's $home appended by Documents and
%   MATLAB; if there is no $home/Documents directory, the default
%   primary userpath will not be used.
%
%   The secondary userpath is available only on UNIX and Mac and is taken 
%   from the MATLABPATH environment variable.
%
%   USERPATH(path) changes the current value of the primary userpath to the 
%   folder passed in. It updates the current MATLAB path, and this
%   new primary userpath will persist across MATLAB sessions. This will not
%   work with the -nojvm startup option.
%
%   USERPATH('reset') resets the primary userpath to the default.  It updates
%   the current MATLAB path, and this new primary userpath will persist across
%   MATLAB sessions. This will not work with the -nojvm startup option.
%
%   USERPATH('clear') removes the primary userpath.  It updates the current
%   MATLAB path, and this new primary userpath will persist across MATLAB sessions.  
%   This will not work with the -nojvm startup option.
%
%   See also PATHDEF.

%   Copyright 1984-2008 The MathWorks, Inc. 
%   $Revision: 1.9.2.6 $ $Date: 2008/03/17 22:12:17 $

cname = computer;
cnameisunix = ~(strncmp(cname,'PC',2));

% Validate number of arguments
error(nargchk(0, 1, nargin, 'struct'));

% If found, process argument and return.  
if nargin == 1 
    javamsg = javachk('swing', mfilename);
    if isempty(javamsg)
        if strcmp(inArg, 'reset') == 1
            resetUserPath;
        elseif strcmp(inArg, 'clear') == 1
            clearUserPath;
        else
            setUserPath(inArg);
        end
        return
    else
        % Can't access userpath without java
        error('MATLAB:userpath:needJava', javamsg.message);
    end
end

% append the user work directory to the path
p = system_dependent('getuserworkfolder');
if exist(p,'dir')
     if isAbsolute(p)
         if cnameisunix
             p(end+1) = ':';
         else
             p(end+1) = ';';
         end
     else
         if ~cnameisunix
             warning('MATLAB:userpath:invalidUserpath', 'Userpath must be an absolute path and must exist on disk.');
         end
         p = '';
     end
else 
     if ~isempty(p)
        if ~cnameisunix
            warning('MATLAB:userpath:invalidUserpath', 'Userpath must be an absolute path and must exist on disk.');
        end
        p = '';
     end
end
if cnameisunix
  p = [p, getenv('MATLABPATH') ':'];
  % Remove any redundant toolbox/local
  p = strrep(p,[matlabroot '/toolbox/local'],'');
  p = strrep(p,'::',':');
end

function resetUserPath
oldUserPath = system_dependent('getuserworkfolder');
rmpathWithoutWarning(oldUserPath);
defaultUserPath = system_dependent('getuserworkfolder', 'default');
addpath(defaultUserPath);
com.mathworks.services.Prefs.remove('UserWorkFolder');
 
function setUserPath(newPath)
if exist(newPath, 'dir')
    % Insure that p is an absolute path
    if isAbsolute(newPath)
        oldUserPath = system_dependent('getuserworkfolder');
        rmpathWithoutWarning(oldUserPath);
        addpath(newPath);
        com.mathworks.services.Prefs.setStringPref('UserWorkFolder', newPath);
    else
        error('MATLAB:userpath:invalidInput', 'Invalid directory or directory does not exist');
    end
else
    error('MATLAB:userpath:invalidInput', 'Invalid directory or directory does not exist');
end

function clearUserPath
oldUserPath = system_dependent('getuserworkfolder');
rmpathWithoutWarning(oldUserPath);
com.mathworks.services.Prefs.setStringPref('UserWorkFolder', '');

function rmpathWithoutWarning(pathToDelete)
if ~isempty(pathToDelete)
    [lastWarnMsg, lastWarnId] = lastwarn;
    oldWarningState = warning('off','MATLAB:rmpath:DirNotFound');
    rmpath(pathToDelete);
    warning(oldWarningState.state,'MATLAB:rmpath:DirNotFound')
    lastwarn(lastWarnMsg, lastWarnId);
end

function status = isAbsolute(file)
cname = computer;
if strncmp(cname,'PC',2)
   status = ~isempty(regexp(file,'^[a-zA-Z]*:\/','once')) ...
            || ~isempty(regexp(file,'^[a-zA-Z]*:\\','once')) ...
            || strncmp(file,'\\',2) ...
            || strncmp(file,'//',2);
else
   status = strncmp(file,'/',1);
end