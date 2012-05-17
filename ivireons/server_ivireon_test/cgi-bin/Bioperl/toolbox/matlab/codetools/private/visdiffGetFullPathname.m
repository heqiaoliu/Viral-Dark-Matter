function fullpath=visdiffGetFullPathname(fname)
%VISDIFFGETFULLPATHNAME Helper function for visdiff that changes a relative
%   pathname into a full pathname.  If the full path cannot be found, the
%   input argument is returned.
%
%   This file is for internal use only and is subject to change without
%   notice.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $

% If we fail to find something better then we return what we were given:
fullpath = fname;

fp = which(fname);
if ~isempty(fp),
    % This file exists on the MATLAB path. Done:
    fullpath = fp;
    return
else
    % Can we find this file using exist? 
    if exist(fname, 'file'),
        % It exists. Use fileattrib to get the full-path to this file, in
        % case we were given a relative path:
        [ok, info] = fileattrib(fname);
        if ok,
            fullpath = info.Name;
        end
    end  
end

