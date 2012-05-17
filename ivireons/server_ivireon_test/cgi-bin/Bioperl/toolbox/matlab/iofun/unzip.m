function varargout = unzip(zipFilename,varargin)
%UNZIP Extract contents of zip file.
%
%   UNZIP(ZIPFILENAME) extracts the archived contents of ZIPFILENAME into
%   the current folder, preserving the files' attributes and timestamps.
%   ZIPFILENAME is a string specifying the name of the zip file. If
%   ZIPFILENAME does not include the full path, UNZIP searches for the file
%   in the current folder and along the MATLAB path. If you do not specify
%   the file extension, UNZIP appends .zip.
%
%   If any files in the target folder have the same name as files in the
%   zip file, and you have write permission to the files, UNZIP overwrites
%   the existing files with the archived versions. If you do not have write
%   permission, UNZIP issues a warning.
%
%   UNZIP(ZIPFILENAME, OUTPUTDIR) extracts the contents of ZIPFILENAME into
%   the folder OUTPUTDIR.
%
%   UNZIP(URL, ...) extracts the zip contents from an Internet URL. The URL
%   must include the protocol type (e.g., "http://"). The UNZIP function
%   downloads the URL to the temporary folder on your system, and deletes
%   the URL on cleanup.
%
%   FILENAMES = UNZIP(...) returns the names of the extracted files in the
%   string cell array FILENAMES. If OUTPUTDIR specifies a relative path,
%   FILENAMES contains the relative path. If OUTPUTDIR specifies an
%   absolute path, FILENAMES contains the absolute path.
%
%   Unsupported zip files
%   ---------------------
%   UNZIP does not support password-protected or encrypted zip archives.
%
%   Examples
%   --------
%   % Copy the demo MAT-files to the folder 'archive'.
%   % Zip the demo MAT-files to demos.zip
%   rootDir = fullfile(matlabroot, 'toolbox', 'matlab', 'demos');
%   zip('demos.zip', '*.mat', rootDir)
%
%   % Unzip demos.zip to the folder 'archive'
%   unzip('demos.zip', 'archive')
%
%   % Download Cleve Moler's "Numerical Computing with MATLAB" examples
%   % to the output folder 'ncm'.
%   url ='http://www.mathworks.com/moler/ncm.zip';
%   ncmFiles = unzip(url, 'ncm')
%
%   See also FILEATTRIB, GZIP, GUNZIP, TAR, UNTAR, ZIP.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.2.10 $ $Date: 2009/11/16 22:26:48 $

error(nargchk(1,2,nargin,'struct'));
error(nargoutchk(0,1,nargout,'struct'));

cleanUpUrl = [];
% Argument parsing.
[zipFilename, outputDir, url, urlFilename] = parseUnArchiveInputs( ...
   mfilename, zipFilename, {'zip'}, 'ZIPFILENAME', varargin{:});
    
if url && ~isempty(urlFilename) && exist(urlFilename,'file')
    cleanUpUrl = urlFilename;
end

zipFile = [];
entries = [];

% Create a Java ZipFile object and obtain the entries.
try

   % Create a Java file of the ZIP filename.
   zipJavaFile  = java.io.File(zipFilename);

   % Create a Java ZipFile and validate it.
   zipFile = org.apache.tools.zip.ZipFile(zipJavaFile);

   % Extract the entries from the ZipFile.
   entries = zipFile.getEntries;

catch exception
   if ~isempty(zipFile)
       zipFile.close;
   end    
   delete(cleanUpUrl);
   error('MATLAB:unzip:invalidZipFile','Invalid zip file "%s".',zipFilename);
end

cleanUpObject = onCleanup(@()cellfun(@(x)x(), {@()zipFile.close,@()delete(cleanUpUrl)}));

% Setup the ZIP API to process the entries.
api.getNextEntry    = @getNextEntry;
api.getEntryName    = @getEntryName;
api.getInputStream  = @getInputStream;
api.getFileMode     = @getFileMode;
api.getModifiedTime = @getModifiedTime;

% Extract ZIP contents.
files = extractArchive(outputDir, api, mfilename);

if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
   function entry = getNextEntry
      try
         if entries.hasMoreElements
            entry = entries.nextElement;
         else
            entry = [];
         end
      catch exception  %#ok<SETNU>
         fcnName = mfilename;
         format = [upper(fcnName(3)) fcnName(4:end)];
         eid = sprintf('MATLAB:%s:invalid%sFileEntry', mfilename, format);
         error(eid,'Invalid %s file %s.', upper(format), zipFilename);
      end
   end

%--------------------------------------------------------------------------
   function entryName = getEntryName(entry)
      entryName = char(entry.getName);
   end

%--------------------------------------------------------------------------
   function inputStream = getInputStream(entry)
      inputStream  = zipFile.getInputStream(entry);
   end

%--------------------------------------------------------------------------
   function fileMode = getFileMode(entry)
      if ispc
         % Return the external attribute for Windows.
         % The external attribute is the Unix file mode shifted
         % left by 16 bits with the system, hidden, and archive
         % attributes in the lower 2-bytes.
         fileMode = entry.getExternalAttributes;
      else
         % Return the Unix file mode
         fileMode = entry.getUnixMode;
      end
   end

%--------------------------------------------------------------------------
   function modifiedTime = getModifiedTime(entry)
      modifiedTime = entry.getTime;
   end

%--------------------------------------------------------------------------
end
