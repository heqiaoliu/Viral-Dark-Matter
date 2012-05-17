function t = strjust(s,justify)
%STRJUST Justify cell array of strings.
%   Implementation of STRJUST for cell arrays of strings. 

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $

if (~iscellstr(s))
    error('MATLAB:strjust:NotCellstr',...
        'The first argument does not contain a cell array of strings.');
end
if nargin<2
    justify = 'right'; 
end
t = cell(size(s));
num = numel(s);
for i = 1:num
    t{i} = strjust(s{i}, justify);
end


