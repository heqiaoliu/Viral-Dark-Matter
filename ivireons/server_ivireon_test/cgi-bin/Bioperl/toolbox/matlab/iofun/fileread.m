function out=fileread(filename)
%FILEREAD Return contents of file as string vector.
%   TEXT = FILEREAD('FILENAME') returns the contents of the file FILENAME as a
%   MATLAB string.
%
%   See also FREAD, TEXTSCAN, LOAD, WEB.

% Copyright 1984-2007 The MathWorks, Inc.
% $Revision: 1.5.4.8 $  $Date: 2007/12/06 13:29:59 $

% Validate input args
error(nargchk(1, 1, nargin, 'struct'));

% get filename
if ~ischar(filename), 
    error('MATLAB:fileread:filenameNotString', 'Filename must be a string.'); 
end

% do some validation
if isempty(filename), 
    error('MATLAB:fileread:emptyFilename', 'Filename must not be empty.'); 
end

% open the file
[fid, message] = fopen(filename);
if fid == (-1)
    error('MATLAB:fileread:cannotOpenFile', 'Could not open file %s. %s.', filename, message);
end

try
    % read file
    out = fread(fid,'*char')';
catch exception
    % close file
    fclose(fid);
	throw(exception);
end

% close file
fclose(fid);
