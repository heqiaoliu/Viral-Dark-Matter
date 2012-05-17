function strvec = strseq(str,idx)
%STRSEQ  Builds a sequence of indexed strings.
%
%   STRVEC = STRSEQ(STR,INDICES) returns the string vector STRVEC obtained
%   by appending the integer values INDICES to the string STR. For example,
%    	strseq('e',[1 2 4])
%   returns
%   	{'e1';'e2';'e4'}
%
%   See also STRCAT.

% Author(s): Murad Abu-Khalaf 2-26-2008
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2008/03/13 17:21:12 $

n = numel(idx);
strvec = cell(n,1); % preallocate
for i=1:n
    strvec{i,1} = sprintf('%s%d',str,idx(i));
end