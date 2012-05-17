function t = strcat(varargin)
%STRCAT Concatenate strings.
%   COMBINEDSTR = STRCAT(S1, S2, ..., SN) horizontally concatenates strings
%   in arrays S1, S2, ..., SN. Inputs can be combinations of single
%   strings, strings in scalar cells, character arrays with the same number
%   of rows, and same-sized cell arrays of strings. If any input is a cell 
%   array, COMBINEDSTR is a cell array. Otherwise, COMBINEDSTR is a 
%   character array.
%
%   Notes:
%
%   For character array inputs, STRCAT removes trailing ASCII white-space
%   characters: space, tab, vertical tab, newline, carriage return, and
%   form-feed. To preserve trailing spaces when concatenating character
%   arrays, use horizontal array concatenation, [s1, s2, ..., sN].
%
%   For cell array inputs, STRCAT does not remove trailing white space.
%
%   When combining nonscalar cell arrays and multi-row character arrays, 
%   cell arrays must be column vectors with the same number of rows as the
%   character arrays.
%
%   Example:
%
%       strcat({'Red','Yellow'},{'Green','Blue'})
%
%   returns
%
%       'RedGreen'    'YellowBlue'
%
%   See also CAT, CELLSTR.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.16.4.7 $  $Date: 2009/12/14 22:25:50 $

%   The cell array implementation is in @cell/strcat.m

if nargin<1
    error('MATLAB:strfun:Nargin','Not enough input arguments.'); end

% initialise return arguments
t = '';

% get number of rows of each input
rows = cellfun('size',varargin,1);
% get number of dimensions of each input
twod = (cellfun('ndims',varargin) == 2);

% return empty string when all inputs are empty
if all(rows == 0)
    return;
end
if ~all(twod)
    error('MATLAB:strfun:InputDimension',...
        'All the inputs must be two dimensional.');
end

% Remove empty inputs
k = (rows == 0);
varargin(k) = [];
rows(k) = [];
maxrows = max(rows);
% Scalar expansion

for i=1:length(varargin),
    if rows(i)==1 && rows(i)<maxrows
        varargin{i} = varargin{i}(ones(1,maxrows),:);
        rows(i) = maxrows;
    end
end

if any(rows~=rows(1)),
    error('MATLAB:strcat:NumberOfInputRows',...
        'All the inputs must have the same number of rows or a single row.');
end

n = rows(1);
space = sum(cellfun('prodofsize',varargin));
s0 =  blanks(space);
scell = cell(1,n);
notempty = true(1,n);
s = '';
for i = 1:n
    s = s0;
    str = varargin{1}(i,:);
    if ~isempty(str) && (str(end) == 0 || isspace(str(end)))
        str = char(deblank(str));
    end
    pos = length(str);
    s(1:pos) = str;
    pos = pos + 1;
    for j = 2:length(varargin)
        str = varargin{j}(i,:);
        if ~isempty(str) && (str(end) == 0 || isspace(str(end)))
            str = char(deblank(str));
        end
        len = length(str);
        s(pos:pos+len-1) = str;
        pos = pos + len;
    end
    s = s(1:pos-1);
    notempty(1,i) = ~isempty(s);
    scell{1,i} = s;
end
if n > 1
    t = char(scell{notempty});
else
    t = s;
end