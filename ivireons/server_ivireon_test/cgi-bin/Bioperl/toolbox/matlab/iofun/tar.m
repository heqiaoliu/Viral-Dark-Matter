function varargout = tar(tarFilename,files,varargin)
%TAR Compress files into tar file.
%
%   TAR(TARFILENAME,FILES) creates a tar file with the name TARFILENAME
%   from the list of files and directories specified in FILES. Relative
%   paths are stored in the tar file, but absolute paths are not.
%   Directories recursively include all of their content.
%   
%   TARFILENAME is a string specifying the name of the tar file. The '.tar'
%   extension is appended to TARFILENAME if omitted. TARFILENAME's
%   extension may end in '.tgz' or '.gz'. In this case, TARFILENAME is
%   gzipped. 
%
%   FILES is a string or cell array of strings that specify the files or
%   directories to be included in TARFILENAME.  Individual files that are
%   on the MATLABPATH can be specified as partial pathnames. Otherwise an
%   individual file can be specified relative to the current directory or
%   with an absolute path. Directories must be specified relative to the
%   current directory or with absolute paths.  On UNIX systems, directories
%   may also start with a "~/" or a "~username/", which expands to the
%   current user's home directory or the specified user's home directory,
%   respectively.  The wildcard character '*' may be used when specifying
%   files or directories, except when relying on the MATLABPATH to resolve
%   a filename or partial pathname.
%
%   TAR(TARFILENAME,FILES,ROOTDIR) allows the path for FILES to be
%   specified relative to ROOTDIR rather than the current directory.
%
%   ENTRYNAMES = TAR(...) returns a string cell array of the relative path
%   entry names contained in TARFILENAME.
%
%   Example
%   -------
%   % Tar all files in the current directory to the file backup.tgz
%   tar('backup.tgz','.');
% 
%   See also GZIP, GUNZIP, UNTAR, UNZIP, ZIP.

% Copyright 2004-2007 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2007/10/15 22:54:31 $

% Check number of arguments
error(nargchk(2,3,nargin,'struct'))
error(nargoutchk(0,1,nargout,'struct'));

% Parse arguments
[files, rootDir, tarFilename, compressFcn] =  ...
   parseArchiveInputs(mfilename, tarFilename, files, varargin{:});

% Open output stream.
try
   if isempty(compressFcn)
     tarFile = java.io.File(tarFilename);
     fileOutputStream = java.io.FileOutputStream(tarFile);
     tarOutputStream  = org.apache.tools.tar.TarOutputStream(fileOutputStream);
   else
     tarFile = java.io.File(tarFilename);
     fileOutputStream = java.io.FileOutputStream(tarFile);
     gzOutputStream = java.util.zip.GZIPOutputStream(fileOutputStream);
     tarOutputStream  = org.apache.tools.tar.TarOutputStream(gzOutputStream);
   end
catch exception %#ok
   eid = sprintf('MATLAB:%s:openError',mfilename);
   error(eid,'Could not open "%s" for writing.',tarFilename);
end

% Create the archive
try
   files = createArchive(tarFilename, files, rootDir, ...
      @createArchiveEntry, tarOutputStream, mfilename);
catch exception
   fileOutputStream.close;
   tarFile.delete;
   throw(exception);
end

% Close stream.
fileOutputStream.close;

if nargout == 1
   varargout{1} = files;
end

%--------------------------------------------------------------------------
function tarEntry = createArchiveEntry(entry, fileAttrib, unixFileMode) %#ok<INUSL>
% Create the TAR archive entry. 
%
% Inputs:
%   ENTRY is a structure with fieldnames entry and file. 
%   FILEATTRIB is a struct representing the file's attributes, 
%   which TAR ignores. 
%   There is no representation in the TarEntry class for PC attributes.
%   UNIXFILEMODE is a double (octal) representation of the file's mode.
%
% Outputs:
%   TARENTRY is a Java TarEntry object.

% Create a Tar entry
file = java.io.File(entry.file);
tarEntry = org.apache.tools.tar.TarEntry(file);

% Set the entry's name.
% Convert to native bytes then to char to preserve encoding.
entryName = char(unicode2native(entry.entry));
tarEntry.setName(entryName);

% Set the Unix file mode.
tarEntry.setMode(unixFileMode);

% Set timestamp.
lastModified = file.lastModified;
tarEntry.setModTime(lastModified)
