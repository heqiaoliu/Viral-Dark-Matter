function write(this, fname)
%WRITE Write buffer string to text file.
%   H.WRITE(FNAME) Write the buffer string to the text file FNAME.
%
%   H.WRITE(FID) Write the buffer string to a text file pointed to by FID.
%   The file will not be closed.
%
%   See also FOPEN, FCLOSE, FPRINTF.

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2007/12/14 15:17:47 $

error(nargchk(2,2,nargin,'struct'));

% If fname is not a character, we assume that it is the FID to write to.
if ischar(fname),
    
    % open in "write text" mode, no append.  If the user wishes to append,
    % he can supply an FID instead of a filename.
    [fid, msg] = fopen(fname,'wt');
    if fid==-1,
        error(generatemsgid('FileErr'),msg);
    end
else
    fid = fname;
end

fprintf(fid,'%s', this.string);

if ischar(fname)
    fclose(fid);
end

% [EOF]
