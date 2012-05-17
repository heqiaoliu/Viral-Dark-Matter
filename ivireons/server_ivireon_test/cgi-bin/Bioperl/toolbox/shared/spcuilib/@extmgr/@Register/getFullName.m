function id = getFullName(this)
%GETFULLNAME Get full name including extension type and name.
%   NAME=GETFULLNAME(H) returns a string containing both the extension
%   type and name concatenated into a unique identifier string.
%
%   Assume h is a RegExt object with
%        h.Type = 'source'
%        h.Name = 'File'
%   GETFULLNAME(h) returns the string 'source:File'.

% Copyright 2004-2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2009/07/23 18:44:09 $

id = [this.Type ':' this.Name];

% [EOF]
