function [files, rootDir, outputDir, dirCreated] = checkFilesDirInputs( ...
                                         fcnName, files, varargin)
%CHECKFILESDIRINPUTS Check FILES, ROOTDIR, OUTPUTDIR arguments
%
%   CHECKFILESDIRINPUTS checks and validates FILES, ROOTDIR and OUTPUT
%   input arguments.  FCNAME is the name of the calling function.  FILES is
%   a character string or char cell array. VARARGIN is a two-element cell
%   array. The first argument of VARARGIN is ROOTDIR, the name of the root
%   directory for FILES. The second argument of VARARGIN is OUTPUTDIR, the
%   name of the output directory.
%
%   The output FILES is a char cell array. ROOTDIR is a string directory
%   name. OUTPUTDIR is a string directory name which will be created if it
%   does not exist. ROOTDIR and OUTPUTDIR will be returned empty if not 
%   supplied.

%   Copyright 2004-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $   $Date: 2009/11/16 22:26:59 $

% This function requires Java.
dirCreated = '';
if ~usejava('jvm')
   eid=sprintf('MATLAB:%s:NoJvm', fcnName);
   error(eid,'Function %s requires Java.', upper(fcnName));
end

% Check FILES
if ischar(files)
   files = {files};
elseif isnumeric(files) || ~iscell(files) || ...
      ~all(cellfun('isclass',files,'char'))
   eid = sprintf('MATLAB:%s:isNumeric', fcnName);
   error(eid,'FILES is not type char or char cell array.');
end

% Check ROOTDIR
if numel(varargin) >= 1 && ~isempty(varargin{1})
   rootDir = varargin{1};
   if ~ischar(rootDir) || ~exist(rootDir,'dir')
      eid = sprintf('MATLAB:%s:nonExistDir', fcnName);
      error(eid,'ROOTDIR directory "%s" does not exist.',num2str(rootDir))
   end
else
   rootDir = '';
end

% Check OUTPUTDIR
if numel(varargin) == 2 && ~isempty(varargin{2})
   outputDir = varargin{2};
   if ~ischar(outputDir)
      eid=sprintf('MATLAB:%s:invalidDir', fcnName);
      error(eid,'OUTPUTDIR directory argument "%d" is not type char.', outputDir)
   elseif ~exist(outputDir,'dir') 
      if exist(outputDir,'file') 
          error(sprintf('MATLAB:%s:invalidDir', fcnName), ...
              'OUTPUTDIR directory argument "%s" is the name of a file.  OUTPUTDIR must refer to a directory.',...
              outputDir);
      end
      dirCreated = determineDirectoryCreated(outputDir);
      mkdir(outputDir);
   end
else
   outputDir = '';
end

function result = determineDirectoryCreated(outputDir)

result = outputDir;
proposedDir = fileparts(outputDir);
while ~isempty(proposedDir) && ~exist(proposedDir, 'dir')
    result = proposedDir;
    proposedDir = fileparts(proposedDir);
end
