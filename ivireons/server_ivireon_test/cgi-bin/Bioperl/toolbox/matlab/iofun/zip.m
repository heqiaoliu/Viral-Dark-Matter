function varargout = zip(zipFilename,files,varargin)
%ZIP Compress files into zip file.
%
%   ZIP(ZIPFILENAME, FILES) creates a zip file with the name ZIPFILENAME
%   from the list of files and directories specified in FILES.  Relative
%   paths are stored in the zip file, but absolute paths are not.
%   Directories recursively include all of their content.
%
%   ZIPFILENAME is a string specifying the name of the zip file. The '.zip'
%   extension is appended to ZIPFILENAME if omitted.
%
%   FILES is a string or cell array of strings that specify the files or
%   directories to be included in ZIPFILENAME.  Individual files that are
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
%   ZIP(ZIPFILENAME, FILES, ROOTDIR) allows the path for FILES to be
%   specified relative to ROOTDIR rather than the current directory.
%
%   ENTRYNAMES = ZIP(...) returns a string cell array of the relative path
%   entry names contained in ZIPFILENAME.
%
%   Example
%   -------
%   % Zip all *.m and *.mat files in the current directory
%   % to the file backup.zip
%   zip('backup',{'*.m','*.mat'});
%
%   See also GZIP, GUNZIP, TAR, UNTAR, UNZIP.

% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.4.2.10 $ $Date: 2007/12/06 13:30:20 $

% Check number of arguments
error(nargchk(2,3,nargin,'struct'))
error(nargoutchk(0,1,nargout,'struct'));

% Parse arguments.
[files, rootDir, zipFilename] =  ...
   parseArchiveInputs(mfilename, zipFilename,  files, varargin{:});

% Open output stream.
try
   zipFile = java.io.File(zipFilename);
   fileOutputStream = java.io.FileOutputStream(zipFile);
   zipOutputStream = org.apache.tools.zip.ZipOutputStream(fileOutputStream);
catch
   eid = sprintf('MATLAB:%s:openError',mfilename);
   error(eid,'Could not open "%s" for writing.',zipFilename);
end

% Create the archive
try
   archive = createArchive(zipFilename, files, rootDir, ...
      @createArchiveEntry, zipOutputStream, mfilename);
catch exception
   fileOutputStream.close;
   zipFile.delete;
   throw(exception);
end

% Close stream.
fileOutputStream.close;

if nargout == 1
   varargout{1} = archive;
end

%--------------------------------------------------------------------------
function zipEntry = createArchiveEntry(entry, fileAttrib, unixFileMode)
% Create the ZIP archive entry. 
%
% Inputs:
%   ENTRY is a structure with fieldnames entry and file. 
%   FILEATTRIB is a structure from the function FILEATTRIB.
%   UNIXFILEMODE is a double (octal) representation of the file's mode.
%
% Outputs:
%   ZIPENTRY is a Java ZipEntry object.

% Create a zip entry object.
zipEntry = org.apache.tools.zip.ZipEntry(entry.entry);

if ispc
   % Set the external attributes for the PC
   externalAttrib = convertAttribToExternal(fileAttrib);
   zipEntry.setExternalAttributes(externalAttrib);
else
   % Set the Unix file mode.
   zipEntry.setUnixMode(unixFileMode);
end

% Set timestamp.
file = java.io.File(entry.file);
lastModified = file.lastModified;
zipEntry.setTime(lastModified);

%--------------------------------------------------------------------------
function externalAttrib = convertAttribToExternal(attrib)
% Convert the file's attribute structure to an external attribute number.

% Attribute  Bit Pattern
% ---------  -----------
%       r    10000001001001000000000000000001
%       w    10000001101101100000000000000000
%       s    10000001101101100000000000000100
%
%       w    10000001101101100000000000000000
%       wa   10000001101101100000000000100000
%
%       w    10000001101101100000000000000000
%       wh   10000001101101100000000000000010
%
%       wh   10000001101101100000000000000010
%       wha  10000001101101100000000000100010
%
%       r    10000001001001000000000000000001
%       ra   10000001001001000000000000100001
%
%       r    10000001001001000000000000000001
%       rh   10000001001001000000000000000011
%
%       rh   10000001001001000000000000000011
%       rha  10000001001001000000000000100011
%
% Common bits turned on between read and write
%            19, 22, 25, 32
%
% File attribute bits
%
%       r    1
%       w    1 (0)
%       h    2
%       s    3
%       a    6
%

% Create the common mask
externalAttrib = uint32(0);

% Set the common bits between read and write
commonBits = {19, 22, 25, 32};
for k=1:numel(commonBits)
    externalAttrib = bitset(externalAttrib, commonBits{k});
end

% Assign the read bit
readBit = 1;

% Assign the writeBits
writeBits = {24, 21, 18};

% Assign the hidden bit
hiddenBit  = 2;

% Assign the system bit
systemBit  = 3;

% Assign the archive bit
archiveBit = 6;

% Set the bits corresponding to the modes 
% from the logical defined in the file's attribute 
if attrib.UserWrite
   for k=1:numel(writeBits)
       externalAttrib = bitset(externalAttrib, writeBits{k});
   end
else
  externalAttrib = bitset(externalAttrib, readBit,  attrib.UserRead);
end

externalAttrib = bitset(externalAttrib, archiveBit, attrib.archive);
externalAttrib = bitset(externalAttrib, hiddenBit,  attrib.hidden);
externalAttrib = bitset(externalAttrib, systemBit,  attrib.system);

externalAttrib = double(externalAttrib);
