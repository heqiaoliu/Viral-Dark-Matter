function d = chars(this)
%CHARS Returns the number of characters of text in the string buffer.
%   H.CHARS Returns the number of characters of text in the string buffer,
%   including carriage returns.
%
%   See also STRINGBUFFER/LINE, STRINGBUFFER/STRING

%   Author(s): D. Orofino, J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/03/02 10:26:30 $

d = length(this.string);

% [EOF]