function tline = fgetl(fid)
%FGETL Read line from file, discard newline character.
%   TLINE = FGETL(FID) returns the next line of a file associated with file
%   identifier FID as a MATLAB string. The line terminator is NOT
%   included. Use FGETS to get the next line with the line terminator
%   INCLUDED. If just an end-of-file is encountered, -1 is returned.  
%
%   If an error occurs while reading from the file, FGETL returns an empty
%   string. Use FERROR to determine the nature of the error.
%
%   MATLAB reads characters using the encoding scheme associated with the
%   file. See FOPEN for more information.
%
%   FGETL is intended for use with files that contain newline characters.
%   Given a file with no newline characters, FGETL may take a long time to 
%   execute.
%
%   Example
%       fid=fopen('fgetl.m');
%       while 1
%           tline = fgetl(fid);
%           if ~ischar(tline), break, end
%           disp(tline)
%       end
%       fclose(fid);
%
%   See also FGETS, FOPEN, FERROR.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 5.15.4.7 $  $Date: 2007/12/06 13:29:57 $
%

try
    [tline,lt] = fgets(fid);
    tline = tline(1:end-length(lt));
    if isempty(tline)
        tline = '';
    end

catch exception
    if nargin ~= 1
        error (nargchk(1,1,nargin,'struct'))
    end
    throw(exception);
end
