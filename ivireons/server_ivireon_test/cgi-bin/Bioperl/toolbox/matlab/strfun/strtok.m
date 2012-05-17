function [token, remainder] = strtok(string, delimiters)
%STRTOK Find token in string.
%   TOKEN = STRTOK(STR) returns the first token in the string STR delimited
%   by white-space characters. STRTOK ignores any leading white space. 
%   If STR is a cell array of strings, TOKEN is a cell array of tokens.
%
%   TOKEN = STRTOK(STR,DELIM) returns the first token delimited by one of  
%   the characters in DELIM. STRTOK ignores any leading delimiters.
%   Do not use escape sequences as delimiters.  For example, use char(9)
%   rather than '\t' for tab.
%
%   [TOKEN,REMAIN] = STRTOK(...) returns the remainder of the original
%   string.
%
%   If the body of the input string does not contain any delimiter 
%   characters, STRTOK returns the entire string in TOKEN (excluding any
%   leading delimiter characters), and REMAIN contains an empty string.
%
%   Example:
%
%      s = '  This is a simple example.';
%      [token, remain] = strtok(s)
%
%   returns
%
%      token = 
%      This
%      remain = 
%       is a simple example.
%
%   See also ISSPACE, STRFIND, STRNCMP, STRCMP, TEXTSCAN.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.14.4.7 $  $Date: 2009/12/14 22:25:51 $

if nargin<1 
   error('MATLAB:strtok:NrInputArguments','Not enough input arguments.');
end

token = ''; remainder = '';

len = length(string);
if len == 0
    return
end

if (nargin == 1)
    delimiters = [9:13 32]; % White space characters
end

i = 1;
while (any(string(i) == delimiters))
    i = i + 1;
    if (i > len), 
       return, 
    end
end

start = i;
while (~any(string(i) == delimiters))
    i = i + 1;
    if (i > len), 
       break, 
    end
end
finish = i - 1;

token = string(start:finish);

if (nargout == 2)
    remainder = string(finish + 1:length(string));
end
