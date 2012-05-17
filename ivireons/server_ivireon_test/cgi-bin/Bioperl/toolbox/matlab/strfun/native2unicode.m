%NATIVE2UNICODE	Convert bytes to Unicode characters.
%   UNICODESTR = NATIVE2UNICODE(BYTES) takes a vector containing
%   numeric values in the range [0,255] and converts these values
%   as a stream of 8-bit bytes to Unicode characters. The stream
%   of bytes is assumed to be in MATLAB's default character
%   encoding scheme. The Unicode characters are returned in the
%   char vector UNICODESTR with the same general array shape as
%   BYTES. You can use the function FREAD to generate input to 
%   this function.
%
%   UNICODESTR = NATIVE2UNICODE(BYTES,ENCODING) does the conversion
%   with the assumption that the byte stream is in the character
%   encoding scheme specified by the string ENCODING. ENCODING must
%   be the empty string ('') or a name or alias for an encoding
%   scheme. Some examples are 'UTF-8', 'latin1', 'US-ASCII', and
%   'Shift_JIS'. For common names and aliases, see the Web site 
%   http://www.iana.org/assignments/character-sets. If ENCODING is 
%   unspecified or is the empty string (''), MATLAB's default
%   encoding scheme is used.
%
%   If BYTES is a CHAR vector, it is returned unchanged.
%
%   For example,
%
%       fid = fopen('japanese.txt');
%       b = fread(fid,'*uint8')';
%       fclose(fid);
%       str = native2unicode(b,'Shift_JIS');
%       disp(str);
%  
%   reads and displays some Japanese text. For the final command,
%   disp(str), to display this text correctly, the contents of str
%   must consist entirely of Unicode characters. The call to
%   NATIVE2UNICODE converts text read from the file to Unicode and
%   returns it in str. The Shift_JIS argument ensures that str
%   contains the same string on any computer, regardless of how it
%   is configured for language. Note that the computer must be
%   configured to display Japanese (e.g. a Japanese Windows machine)
%   for the output of disp(str) to be correct.
%
%   Here is an equivalent way to read and display Japanese text, again 
%   assuming that the computer is configured to display Japanese: 
%
%       fid = fopen('japanese.txt', 'r', 'n', 'Shift_JIS');
%       str = fread(fid, '*char')';
%       fclose(fid);
%       disp(str);
%
%   See also UNICODE2NATIVE.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.4 $  $Date: 2005/12/12 23:26:48 $
%   Built-in function.


