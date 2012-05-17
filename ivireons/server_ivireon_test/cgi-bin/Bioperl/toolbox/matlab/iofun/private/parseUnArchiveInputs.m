function [archiveFilename, outputDir, url, urlFilename, uncompressFcn] = ...
   parseUnArchiveInputs(archiveFcn, archiveFilename, validExtensions, ...
                        argName, varargin)
%PARSEUNARCHIVEINPUTS Parse arguments for unarchive functions.
%   
%   PARSEUNARCHIVEINPUTS parses and checks an unarchive function's input
%   arguments. 
%
%   Inputs Arguments:
%   -----------------
%   ARCHIVEFCN is the string name of the calling function.
%
%   ARCHIVEFILENAME is the filename of the archive and does not need an
%   extension. 
%
%   VALIDEXTENSIONS is a string cell array containing the valid extensions
%   (excluding '.') of an archive. 
%
%   ARGNAME is a string containing the name of the ARCHIVEFILENAME argument
%   and is used in error messages. 
%
%   VARARGIN contains OUTPUTDIR, the name of the output directory for the
%   entries.
%
%   Output Arguments:
%   ----------------- 
%   The output string, ARCHIVEFILENAME, is the file name of the archive.
%
%   URL is logical and true if the input ARCHIVEFILENAME is an URL.
%
%   OUTPUTDIR is the string name of the output directory and is created if
%   it does not exists. If it is not supplied it defaults to '.'.
%
%   URLFILENAME is the name of the temporary downloaded file if URL is
%   true; otherwise it is empty. 
%
%   UNCOMPRESSFCN is a handle to a function which uncompresses the archive.
%   (Currently only GUNZIP is supported.) UNCOMPRESSFCN is empty if no
%   uncompression is required.

%   Copyright 2004-2007 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2010/05/13 17:42:24 $                     

% This function requires Java.
if ~usejava('jvm')
   eid=sprintf('MATLAB:%s:NoJvm', archiveFcn);
   error(eid,'Function %s requires Java.', upper(archiveFcn));
end

% Verify the output directory and create if it does not exist
if numel(varargin) == 0
    outputDir = '.';
else
    outputDir = varargin{1};
    
    % If empty, set to .
    if isempty(outputDir)
        outputDir = '.';
        
    % Verify outputDir is a char.
    elseif ~ischar(outputDir)
        eid=sprintf('MATLAB:%s:invalidDir', archiveFcn);
        error(eid,'OUTPUTDIR directory argument is not type char.')
    
    % Add ./ or .\ if outputDir is not an absolute path.
    elseif ~isAbsolute(outputDir) && ~isequal('.',outputDir(1))
        outputDir = fullfile('.',outputDir);
    end
end

% archiveFilename must not be a directory 
% If exist is true as a directory, then 
% check the contents from dir since MATLABPATH may 
% contain a directory with the same name as archiveFilename
if exist(archiveFilename,'dir') && ~isempty(dir(archiveFilename))
   eid = sprintf('MATLAB:%s:isDirectory', archiveFcn);
   error(eid, '%s "%s" is a directory.', ...
      upper(argName), archiveFilename);
end

% Check the validity of archiveFilename and if it's a URL
[archiveFilename, url] = checkfilename(archiveFilename, validExtensions, ...
   archiveFcn,argName,true, tempdir);
if url
   % Save the downloaded filename to delete later
   urlFilename = archiveFilename;
else
   urlFilename = '';
end

% Test the extension to see if its compressed
[null, null ,archiveExt] = fileparts(archiveFilename);
if nargout == 5
   uncompressFcn = getArchiveCompressFcn(archiveExt, archiveFcn);
else
   uncompressFcn = [];
end

% Make the directory if it does not exist.
if ~isdir(outputDir)
    mkdir(outputDir);
end