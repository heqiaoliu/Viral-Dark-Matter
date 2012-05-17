function [tf, nitf_version] = isnitf(filename)
%ISNITF   Check if file is NITF.
%    [TF, NITF_VERSION] = ISNITF(FILENAME) checks whether a file contains
%    NITF data, returning TRUE in TF if it does and FALSE otherwise.  If
%    the file does contain NITF data, NITF_VERSION contains the format
%    version.
%
%    See also NITFINFO, NITFREAD.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2007/05/10 13:46:46 $

% Open the file.
[fid, message] = fopen(filename, 'r');
if (fid < 0)
    
       error('Images:isnitf:fileOpen', 'Could not open file "%s": %s.', filename, message);
end

% Get first conditional NITF header fields and inspect the first for the NITF version.
fhdr = fread(fid, 324, 'uint8=>char');
fclose(fid);

%Check the NITF version
if (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF02.10'))

  % It's an NITF2.1 file.
  nitf_version = '2.1';
  tf = true;
  
elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF02.00')) 
   
  % It's an NITF2.0 file.
  nitf_version = '2.0';
  tf = true;

elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NITF01.10')) 
   
  % It's an NITF1.1 file.
  nitf_version = '1.1';
  tf = true;
  
elseif (numel(fhdr) == 324 && isequal(char(fhdr(1:9))', 'NSIF01.00'))
    
    % It's an NSIF 1.0 file which translates to an NITF2.1 file;
    nitf_version = '2.1';
    tf = true;
        
else
  
  % If we can't determine the NITF version the file is invalid
    nitf_version = 'UNK';
    tf = false;
end

end
