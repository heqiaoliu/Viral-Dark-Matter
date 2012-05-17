function outputNames = createArchive(filename, files, rootDir, ...
                       createArchiveEntryFcn, archiveOutputStream, fcnName)
%CREATEARCHIVE Create an archive of files
%
%   CREATEARCHIVE creates an archive FILENAME from the files specified by
%   FILES and ROOTDIR. OUTPUTNAMES is a string cell array of relative path
%   filenames stored in the archive. For all operating systems, the
%   directory delimiter is '/'.
%
%   FILENAME is a string containing the name of the archive.
%
%   FILES is a string cell array of the filenames to add to the archive.
%
%   ROOTDIR is a string containing the name of the root directory of FILES.
%
%   CREATEARCHIVEENTRYFCN is a function handle to create an archive entry
%
%   ARCHIVEOUTPUTSTREAM is a Java stream object attached to the archive 
%   output file.
%
%   FCNNAME is the string name of the calling function and used in
%   constructing error messages.

% Copyright 2004-2008 The MathWorks, Inc.
% $Revision: 1.1.6.6 $   $Date: 2008/03/17 22:17:54 $

% Create a structure of the inputs.
entries = getArchiveEntries(filename, files, rootDir, fcnName);

% Check for duplicates
checkDuplicateEntries(entries, fcnName)

% Create a stream copier to copy files
streamCopier = ...
   com.mathworks.mlwidgets.io.InterruptibleStreamCopier.getInterruptibleStreamCopier;

% Add each entry to the archive.
for i = 1:length(entries)
   % Create the entry objects.
   addArchiveEntry(filename, createArchiveEntryFcn, entries(i), ...
                   archiveOutputStream, streamCopier, fcnName);
end

% Close stream.
archiveOutputStream.close;

% Return outputNames
outputNames = {entries(:).entry};

%--------------------------------------------------------------------------
function checkDuplicateEntries(entries, fcnName)
% Check for duplicate entry names.
allNames = {entries.entry};
[uniqueNames,i] = unique(allNames);
if length(uniqueNames) < length(entries)
   firstDup = allNames{min(setdiff(1:length(entries),i))};
   eid = sprintf('MATLAB:%s:duplicateEntry',fcnName);
   error(eid, 'Function %s tried to add two files as "%s".', ...
              upper(fcnName), firstDup);
end

%--------------------------------------------------------------------------
function addArchiveEntry(archiveFilename, createArchiveEntryFcn, entry, ...
                         fileOutputStream, streamCopier, archiveFcn)

% Get the file attribute and the Unix file mode.
[fileAttrib unixFileMode] = getFileAttrib(entry.file);

% Create the archive entry
archiveEntry = createArchiveEntryFcn(entry, fileAttrib, unixFileMode);

% Create a Java file input stream from the archive entry
try
   file = java.io.File(entry.file);
   fileInputStream = java.io.FileInputStream(file);
catch exc %#ok<NASGU>
   eid = sprintf('MATLAB:%s:openEntryError',archiveFcn);
   warning(eid,'Cannot open file "%s" for reading.',entry.file);
   return;
end

% Put and copy the entry into the archive
try
   fileOutputStream.putNextEntry(archiveEntry);
   streamCopier.copyStream(fileInputStream,fileOutputStream);

catch exc  %#ok<NASGU>
   eid=sprintf('MATLAB:%s:copyStreamError', archiveFcn);
   error(eid,'Unable to write entry %s to %s file %s', ...
             entry.entry, archiveFcn, archiveFilename);
end

% Close everything up.
fileInputStream.close;
fileOutputStream.closeEntry;

%--------------------------------------------------------------------------
function [attrib, mode] = getFileAttrib(filename)
% Get the file attributes and the Unix file mode
%
% The input FILENAME is a string.
% The output attrib is a struct.
% The output MODE is double (octal).

% Obtain the file attributes (modes)
[status, attrib, id] = fileattrib(filename);
if ~status
   error(id,'Unable to obtain attributes of file "%s".', filename);
end

% Convert each mode to a string.
userMode  = convertMode(attrib.UserRead,  attrib.UserWrite,  attrib.UserExecute);

if isunix
  groupMode = convertMode(attrib.GroupRead, attrib.GroupWrite, attrib.GroupExecute);
  otherMode = convertMode(attrib.OtherRead, attrib.OtherWrite, attrib.OtherExecute);
else
  % The Group and Other mode is not defined for Windows.
  % Set mode to read-execute in case the file is extracted on Unix
  % and for consistency with Windows extraction.
  groupMode = '5';
  otherMode = '5';
end

% Concatonate the UID and modes together.
charMode  = ['100' userMode groupMode otherMode];

% Convert the mode to octal.
mode = base2dec(charMode, 8);

%--------------------------------------------------------------------------
function mode = convertMode(readMode, writeMode, executeMode)
% Convert the read, write, execute mode to a string (0-7).
%
% The inputs, READMODE, WRITEMODE, EXECUTEMODE, are integers (1 or 0)
% denoting if the particular mode is set. The output, MODE, is a
% string denoting the mode's octal attribute represented by
% the value '0' - '7'.

octalReadMode    = 4;
octalWriteMode   = 2;
octalExecuteMode = 1;
mode = octalReadMode*readMode + ...
       octalWriteMode*writeMode + ...
       octalExecuteMode*executeMode;
mode = num2str(mode);

