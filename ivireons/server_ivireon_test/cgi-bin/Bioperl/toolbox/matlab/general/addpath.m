function oldpath = addpath(varargin)
%ADDPATH Add directory to search path.
%   ADDPATH DIRNAME prepends the specified directory to the current
%   matlabpath.  Surround the DIRNAME in quotes if the name contains a
%   space.  If DIRNAME is a set of multiple directories separated by path
%   separators, then each of the specified directories will be added.
%
%   ADDPATH DIR1 DIR2 DIR3 ...  prepends all the specified directories to
%   the path.
%
%   ADDPATH ... -END    appends the specified directories.
%   ADDPATH ... -BEGIN  prepends the specified directories.
%   ADDPATH ... -FROZEN disables directory change detection for directories
%                       being added and thereby conserves Windows change
%                       notification resources (Windows only).
%
%   Use the functional form of ADDPATH, such as ADDPATH('dir1','dir2',...),
%   when the directory specification is stored in a string.
%
%   P = ADDPATH(...) returns the path prior to adding the specified paths.
%
%   Examples
%       addpath c:\matlab\work
%       addpath /home/user/matlab
%       addpath /home/user/matlab:/home/user/matlab/test:
%       addpath /home/user/matlab /home/user/matlab/test
%
%   See also RMPATH, PATHTOOL, PATH, SAVEPATH, USERPATH, GENPATH, REHASH.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.29.4.11 $  $Date: 2007/12/06 13:29:45 $

% Number of  input arguments
n = nargin;
error(nargchk(1,Inf,n,'struct'));

if nargout>0
    oldpath = path;
end

append = -1;
freeze = 0;
args = varargin;

while (n > 1)   
    last = args{n};
    % Append or prepend to the existing path
    if isequal(last,1) || strcmpi(last,'-end')
        if (append < 0), append = 1; end; 
        n = n - 1;
    elseif isequal(last,0) || strcmpi(last,'-begin')
        if (append < 0), append = 0; end;
        n = n - 1;
    elseif strcmpi(last,'-frozen') 
        if ispc, freeze = 1; end
        n = n - 1;
    else
        break;
    end
end
if (append < 0), append = 0; end

% Check, trim, and concatenate the input strings
p = catdirs(varargin{1:n});

% If p is empty then return
if isempty(p)
    return;
end

% See whether frozen is desired, where the state is not already set frozen
if freeze
    oldfreeze = system_dependent('DirsAddedFreeze');
    % Check whether old unfrozen state needs to be restored
    if ~isempty(strfind(oldfreeze,'unfrozen'))
        %Use the onCleanup object to automatically restore old state at
        %exit or error.
        cleanUp = onCleanup(@()system_dependent('DirsAddedUnfreeze')); %#ok<NASGU>
    end
end

% Append or prepend the new path
mp = matlabpath;
if append
    path(mp, p);
else
    path(p, mp);
end    

