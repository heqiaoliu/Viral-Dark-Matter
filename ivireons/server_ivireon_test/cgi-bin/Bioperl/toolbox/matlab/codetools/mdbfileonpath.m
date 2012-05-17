function varargout = mdbfileonpath(inFilename)
    %MDBFILEONPATH Helper function for the Editor/Debugger
    %   MDBFILEONPATH is passed a string containing an absolute filename of an
    %   file.
    %   It returns:
    %      a filename:
    %         the filename that will be run (may be a shadower)
    %         if file not found on the path and isn't shadowed, returns the
    %         filename passed in
    %      an integer defined in com.mathworks.mlwidgets.dialog.PathUpdateDialog
    %      describing the status:
    %         FILE_NOT_ON_PATH - file not on the path or error occurred
    %         FILE_WILL_RUN - file is the one MATLAB will run (or is shadowed by a newer
    %         p-file)
    %         FILE_SHADOWED_BY_PWD - file is shadowed by another file in the current directory
    %         FILE_SHADOWED_BY_TBX - file is shadowed by another file somewhere in the MATLAB path
    %         FILE_SHADOWED_BY_PFILE - file is shadowed by a p-file in the same directory
    %         FILE_SHADOWED_BY_MEXFILE - file is shadowed by a mex or mdl file in the same directory
    %
    %   inFilename should be an absolute filename with extension ".m" (no
    %   checking is done).
    %   This file is for internal use only and is subject to change without
    %   notice.
    
    %   Copyright 1984-2010 The MathWorks, Inc.
    %   $Revision: 1.1.6.22 $
    
    if nargin > 0
        try
            % Keep these in the try clause in case java throws an error
            statusNotOnPath = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_NOT_ON_PATH;
            statusOK = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_WILL_RUN;
            statusShadowedByCWD = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_PWD;
            statusShadowedByTbx = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_TBX;
            statusShadowedByPfile = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_PFILE;
            statusShadowedByMex = com.mathworks.mlwidgets.dialog.PathUpdateDialog.FILE_SHADOWED_BY_MEXFILE;
            
            [path fn] = fileparts(inFilename);
            
            mexfilename = fullfile(path, [fn '.' mexext]);
            mdlfilename = fullfile(path, [fn '.mdl']);
            pfilename = fullfile(path, [fn '.p']);
            
            isMexFile = com.mathworks.jmi.MLFileUtils.isNativeMexFile(inFilename);
            isPFile = com.mathworks.jmi.MLFileUtils.isPFile(inFilename);
            isMdlFile = com.mathworks.jmi.MLFileUtils.isMdlFile(inFilename);
            
            if ~isMexFile && doesFileExist(mexfilename)
                % Check for mex file shadowing this file in the same directory.
                fullpath = mexfilename;
                shadowStatus = statusShadowedByMex;
            elseif ~isMexFile && ~isMdlFile && doesFileExist(mdlfilename)
                % Check for mdl file shadowing this file in the same directory.
                fullpath = mdlfilename;
                shadowStatus = statusShadowedByMex;
            elseif ~isMexFile && ~isMdlFile && ~isPFile && doesFileExist(pfilename)
                % Check if there is a p-file shadowing this file in the same
                % directory.  If there is (and if the ".m" file is newer), then
                % report that the p-file is shadowing it.
                mdirInfo = dir(inFilename);
                pdirInfo = dir(pfilename);
                % If the p-file is newer than the ".m" file, assume that it's OK
                if (pdirInfo.datenum >= mdirInfo.datenum)
                    [shadowStatus, fullpath] = checkIfShadowed(pfilename);
                else
                    fullpath=pfilename;
                    shadowStatus = statusShadowedByPfile;
                end
            else
                [shadowStatus, fullpath] = checkIfShadowed(inFilename);
            end
            
            varargout{1} = fullpath;
            varargout{2} = shadowStatus;
            
        catch
            varargout{1} = inFilename;
            varargout{2} = 0;
        end
    else
        varargout{1} = '';
        varargout{2} = 0;
    end
    
    %---------------------------------------------------------------------
    % Make this nested to share the status codes
    function [shadowStatus, fullpath] = checkIfShadowed(inFilename)
        
        [path fn ext] = filepartsWithoutPackages(inFilename);
        xfiletorun = getFileToRun(inFilename);
        if ~isempty(xfiletorun)
            [xpath xfn xext] = filepartsWithoutPackages(xfiletorun);
            % The executable fileparts are identical to the file passed in
            if areDirectoriesEqual(xpath, path) && areFilenamesEqual(xfn, fn) && areFilenamesEqual(xext, ext)
                fullpath = xfiletorun;
                shadowStatus = statusOK; % MATLAB will run the file
            end
            
            % Can only happen on unix: eg foo.m and FOO.m
            if areDirectoriesEqual(xpath, path) && ~areFilenamesEqual(xfn, fn) && areFilenamesEqual(xext, ext)
                fullpath = xfiletorun;
                if areDirectoriesEqual(xpath, pwd)
                    shadowStatus = statusShadowedByCWD;
                else
                    shadowStatus = statusShadowedByTbx; % shadower on path
                end
            end
            
            % Paths are different, so the file is shadowed
            if ~areDirectoriesEqual(xpath, path)
                if areDirectoriesEqual(xpath, pwd)
                    shadowStatus = statusShadowedByCWD; % shadower in cwd
                else
                    shadowStatus = statusShadowedByTbx; % shadower on path
                end
                fullpath = xfiletorun;
            end
            
        else
            fullpath = inFilename;
            shadowStatus = statusNotOnPath;
        end
    end
end

%---------------------------------------------------------------------
% Like fileparts, but removes package ("\+foo") directories
function [outpath outfile outext] = filepartsWithoutPackages(inpath)
    [outpath outfile outext] = fileparts(inpath);
    outpath = removePackageDirs(outpath);
end

%---------------------------------------------------------------------
% Strip away the package directories from the given directory.
function result = removePackageDirs(inDir)
    result = inDir;
    % Make sure that result ends in a file separator so that the last item
    % is treated as a directory rather than a file. However, we don't wish
    % to return a value ending in a file separator from the method.
    while (~isempty(result) && isPackageDirectory(strcat(result, filesep)))
        result = fileparts(result);
    end
end

%---------------------------------------------------------------------
% Test if two strings containing directories are equal.  This takes
% platform considerations into account.
function pathsAreEqual = areDirectoriesEqual(path1, path2)
    pathsAreEqual = isequal(com.mathworks.util.FileUtils.normalizePathname(path1), ...
        com.mathworks.util.FileUtils.normalizePathname(path2));
    
    if ~pathsAreEqual
    	rfs = com.mathworks.mlwidgets.explorer.model.realfs.RealFileSystem.getInstance();
        resolved1 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path1))).getLocation();
        resolved2 = rfs.resolve(rfs.getEntry(com.mathworks.matlab.api.explorer.FileLocation(path2))).getLocation();
        pathsAreEqual = resolved1.equals(resolved2);
    end
end

%---------------------------------------------------------------------
% Test if two strings containing filenames are equal.  This only
% needs to handle case on the PC
function namesAreEqual = areFilenamesEqual(name1, name2)
    try
        if ispc
            namesAreEqual = isequal(lower(name1), lower(name2));
        else
            namesAreEqual = isequal(name1, name2);
        end
    catch
        namesAreEqual = false;
    end
end

%---------------------------------------------------------------------
function fn = getFileToRun(inPath_arg)
    % Return a string containing the absolute path of the file that
    % MATLAB will run based on the input filename (e.g., foo)
    
    import com.mathworks.jmi.MatlabPath;
    
    if isFileInPackage(inPath_arg) || isObject(inPath_arg)
        % 1) For MCOS files, we need to determine whether the parent 
        %    directory for the package or class is on the path. If the 
        %    parent directory is not on the path, then return the empty 
        %    string.
        parentPath = MatlabPath.getValidPathEntryParent(java.io.File(inPath_arg).getParentFile());
        if ~isDirectoryOnPath(char(parentPath.getPath))
            fn = '';
            return;
        end
        
        % 2) Next, determine what which thinks is the full path to the 
        %    class or method that we're trying to set a breakpoint in. 
        %    Then, look to see if the result of which is on the path (it 
        %    might not be if we're inside the class or package directory).
        whichResult = which(trimToMcosPath(inPath_arg));
        whichParentPath = MatlabPath.getValidPathEntryParent(java.io.File(whichResult).getParentFile());
        if isDirectoryOnPath(char(whichParentPath.getPath))
           fn = whichResult;
           return;
        end
        
        % 3) Finally, if the given file is on the path, and not found by
        %    which, simply return the given file.
        fn = inPath_arg;
    elseif isPrivate(inPath_arg)
        % For files in a private use absolute path
        fn = which(inPath_arg);
    else  % make the variable names somewhat obscure -- geck 281208
        [~, fileparts_Filename_Var] = fileparts(inPath_arg);
        fn = which(fileparts_Filename_Var);
        % correct returned built-ins to point to their matching file for the purposes of command-line help -- geck 376452
        if ( 1 ==strfind( fn, 'built-in (' ) )
            fn = fn(length('built-in (')+1:length(fn)-1); % e.g. matlabroot '/toolbox/matlab/ops/@single/plus'
            fn = [fn '.m'];
        end
    end
end


%---------------------------------------------------------------------
function result = trimToMcosPath(filepath)
    % Trims away the part of the path that is not related to the MCOS name.
    % See the corresponding Java method MatlabPath.trimToMcosPath for more
    % details.
    
    result = char(com.mathworks.jmi.MatlabPath.trimToMcosPath(filepath));
end


%---------------------------------------------------------------------
% Does the given file live in a private directory? Argument must represent
% a file and therefore not end in a file separator.
function result = isPrivate(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = com.mathworks.jmi.MatlabPath.isPrivate(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given file live in an MCOS class directory? Argument must
% represent a file and therefore not end in a file separator.
function result = isObject(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = com.mathworks.jmi.MatlabPath.isObject(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given file live in an MCOS package? Argument must not end in a
% file separator.
function result = isFileInPackage(inFile)
    assert(~isdir(inFile), ['argument must be a file, not a directory: ' inFile]);
    result = isPackageDirectory(fileparts(inFile));
end

%---------------------------------------------------------------------
% Does the given directory represent an MCOS package? See comments in
% MatlabPath.isPackage. Argument must end in a file separator.
function result = isPackageDirectory(inDir)
    assert(isdir(inDir), ['argument must be a directory: ' inDir]);
    result = com.mathworks.jmi.MatlabPath.isPackage(inDir);
end

%---------------------------------------------------------------------
% This returns true only if inFilename's case matches what is on disk.
% This function is used instead of the 'exist' function because we want to
% differentiate files 'FOO.m' and 'foo.m' when on UNIX.  The 'exist'
% function will return 2 regardless of the case of the string that is
% passed in.
function existsOnDisk = doesFileExist(inFilename)
    fileObject = java.io.File(inFilename);
    existsOnDisk = false;
    if isempty(fileObject)
        return;
    else
        try
            if fileObject.exists && fileObject.isFile
                [path fn1] = fileparts(inFilename);
                filename2 = char(fileObject.getCanonicalPath);
                [path fn2] = fileparts(filename2);
                if isequal(fn1, fn2)
                    existsOnDisk = true;
                end
            end
        catch
            existsOnDisk = false;
        end
    end
end

function isOnPath = isDirectoryOnPath(directory)
% returns true if the given directory is on the path (including pwd).
    
    assert(exist(directory, 'dir') == 7);
    
    % determine if the directory is on the path, either implicitly
    % by being on pwd, or explicitly by being on the actual path.
    cellOfPathEntries = regexp(path, pathsep, 'split');
    cellOfPathEntries{end+1} = pwd;
    isOnPath = ~isempty(find(doPlatformBasedPathComparison(cellOfPathEntries, directory), 1));
    
end

function areEqual = doPlatformBasedPathComparison(cellOfPathEntries, directory)
% returns true if the given directory is contained within the given cell
% array of path entries. this function takes into account the fact that the
% path is case-sensitive on Mac and Linux, while case-insensitive on 
% Windows.
    if ispc
        areEqual = strcmpi(cellOfPathEntries, directory);
    else
        areEqual = strcmp(cellOfPathEntries, directory);
    end
end
