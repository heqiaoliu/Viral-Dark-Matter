function [path, fname, extension,version] = fileparts(name)
%FILEPARTS Filename parts.
%   [PATHSTR,NAME,EXT] = FILEPARTS(FILE) returns the path, file name, and
%   file name extension for the specified FILE. The FILE input is a string
%   containing the name of a file or folder, and can include a path and
%   file name extension. The function interprets all characters following
%   the right-most path delimiter as a file name plus extension.
%
%   If the FILE input consists of a folder name only, be sure that the
%   right-most character is a path delimiter (/ or \). Othewise, FILEPARTS
%   parses the trailing portion of FILE as the name of a file and returns
%   it in NAME instead of in PATHSTR.
%
%   FILEPARTS only parses file names. It does not verify that the file or
%   folder exists. You can reconstruct the file from the parts using
%      fullfile(pathstr,[name ext versn])
%
%   FILEPARTS is platform dependent.
%
%   On Microsoft Windows systems, you can use either forward (/) or back
%   (\) slashes as path delimiters, even within the same string. On Unix
%   and Macintosh systems, use only / as a delimiter.
%
%   See also FULLFILE, PATHSEP, FILESEP.

%   Copyright 1984-2010 The MathWorks, Inc.
%   $Revision: 1.18.4.12 $ $Date: 2010/05/13 17:42:19 $

% Nothing but a row vector should be operated on.
if ~ischar(name) || size(name, 1) > 1
    error('MATLAB:fileparts:MustBeChar', 'Input must be a row vector of characters.');
end

if nargout == 4
    warning('MATLAB:fileparts:VersionToBeRemoved', ...
        'The fourth output, VERSN, of FILEPARTS will be removed in a future release.');
end

path = '';
fname = '';
extension = '';
version = '';

if isempty(name)
    return;
end

builtinStr = xlate('built-in');
if strncmp(name, builtinStr, size(builtinStr,2))
    fname = builtinStr;
    return;
end

if ispc
    ind = find(name == '/'|name == '\', 1, 'last');
    if isempty(ind)
        ind = find(name == ':', 1, 'last');
        if ~isempty(ind)       
            path = name(1:ind);
        end
    else
        if ind == 2 && (name(1) == '\' || name(1) == '/')
            %special case for UNC server
            path =  name;
            ind = length(name);
        else 
            path = name(1:ind-1);
        end
    end
    if isempty(ind)       
        fname = name;
    else
        if ~isempty(path) && path(end)==':' && ...
                (length(path)>2 || (length(name) >=3 && name(3) == '\'))
                %don't append to D: like which is volume path on windows
            path = [path '\'];
        elseif isempty(deblank(path))
            path = '\';
        end
        fname = name(ind+1:end);
    end
else    % UNIX
    ind = find(name == '/', 1, 'last');
    if isempty(ind)
        fname = name;
    else
        path = name(1:ind-1); 

        % Do not forget to add filesep when in the root filesystem
        if isempty(deblank(path))
            path = '/';
        end
        fname = name(ind+1:end);
    end
end

if isempty(fname)
    return;
end

% Look for EXTENSION part
ind = find(fname == '.', 1, 'last');

if isempty(ind)
    return;
else
    extension = fname(ind:end);
    fname(ind:end) = [];
end
