function t = isvarname(s)
%ISVARNAME True for valid variable name.
%   ISVARNAME(S) is true if S is a valid MATLAB variable name.
%   A valid variable name is a character string of letters, digits and
%   underscores, with length <= namelengthmax, the first character a letter,
%   and the name is not a keyword.
%
%   See also ISKEYWORD, NAMELENGTHMAX, GENVARNAME.

%   Copyright 1984-2006 The MathWorks, Inc.
%   $Revision: 1.7.4.5 $  $Date: 2006/10/14 12:24:41 $

