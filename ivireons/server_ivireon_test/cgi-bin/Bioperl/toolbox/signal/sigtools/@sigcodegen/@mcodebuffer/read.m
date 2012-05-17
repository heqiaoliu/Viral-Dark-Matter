function h = read(fname)
%READ     Read the file and return an MCodeBuffer object.
%   SIGCODEGEN.MCODEBUFFER.READ(FNAME) Read in the file specified by FNAME
%   and return the strings in an MCodeBuffer object.  This is a static
%   method and must be called with its full name.

%   Author(s): J. Schickler
%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:40 $

% Try to open the file.
[fid,errmsg] = fopen(fname,'rt');
if ~isempty(errmsg)
    
    % If it fails, rethrow the error.
    error(generatemsgid('SigErr'),errmsg);
end

% Create a new MCode Buffer object.
h = sigcodegen.mcodebuffer;

% If the file is empty, close and return immediately.
if feof(fid)
    fclose(fid);
    return;
end

firstChar = fread(fid, 1, 'uint8=>char');

% If the very first character is a newline, add an extra newline so that
% when we start to add characters they are added correctly.
if isequal(firstChar, char(10));
    h.cr;
end
h.add(firstChar);

% Add each line to the buffer.
while ~feof(fid)
    h.add(fgets(fid));
end

% Close the opened file.
fclose(fid);

% [EOF]
