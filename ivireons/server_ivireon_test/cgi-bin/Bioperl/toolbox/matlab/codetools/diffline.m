function [newline1,newline2] = diffline(line1,line2,padlength)
% DIFFLINE - Highlights differences within a line of text
%
%   [newline1, newline2] = DIFFLINE(line1,line2,padlength)
%
% The returned strings are HTML fragments in which any non-matching
% portions of the string are wrapped in "span" tags with the
% class "diffchars".

if nargin<3
    padlength = inf;
end
lines = comparisons_private('linediff',line1,line2,padlength);
newline1 = lines{1};
newline2 = lines{2};
end
