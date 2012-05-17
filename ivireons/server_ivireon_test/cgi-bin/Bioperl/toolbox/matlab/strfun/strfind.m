%STRFIND Find one string within another.
%   K = STRFIND(TEXT,PATTERN) returns the starting indices of any 
%   occurrences of the string PATTERN in the string TEXT.
%
%   STRFIND will always return [] if PATTERN is longer than TEXT.
%
%   Examples
%       s = 'How much wood would a woodchuck chuck?';
%       strfind(s,'a')    returns  21
%       strfind('a',s)    returns  []
%       strfind(s,'wood') returns  [10 23]
%       strfind(s,'Wood') returns  []
%       strfind(s,' ')    returns  [4 9 14 20 22 32]
%
%   See also STRCMP, STRNCMP, REGEXP.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $  $Date: 2009/11/16 22:27:32 $
%   Built-in function.

