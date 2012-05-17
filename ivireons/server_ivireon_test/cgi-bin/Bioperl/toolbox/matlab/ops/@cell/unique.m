function [b,ndx,pos] = unique(a,flag1,flag2)
%UNIQUE Return unique set for a cell array of strings.
%   UNIQUE(A) for the cell vector A returns the same strings as in A but
%   with no repetitions.  The output is also sorted.
%
%   [B,I,J] = UNIQUE(A) also returns index vectors I and J such
%   that B = A(I) and A = B(J) (or B = A(I,:) and A = B(J,:)).
%   
%   [B,I,J] = UNIQUE(A,'first') returns the vector I to index the
%   first occurrence of each unique value in A.  UNIQUE(A,'last'),
%   the default, returns the vector I to index the last occurrence.
%   
%   See also UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER.

%   Copyright 1984-2007 The MathWorks, Inc.
%   $Revision: 1.12.4.7 $  $Date: 2008/12/01 07:18:26 $
% ----------------------------------------------------------------------------------------------------
flagvals = {'rows' 'first' 'last'};
if nargin > 1
    options = strcmpi(flag1,flagvals);
    if nargin > 2
        options = options + strcmpi(flag2,flagvals);
        if any(options > 1) || (options(2)+options(3) > 1)
           error('MATLAB:CELL:UNIQUE:RepeatedFlag', ...
                 'You may not specify more than one value for the same option.');
        end
    end
    if sum(options) < nargin-1
        error('MATLAB:CELL:UNIQUE:UnknownFlag', 'Unrecognized option.');
    end
    if options(1) > 0
        warning('MATLAB:CELL:UNIQUE:RowsFlagIgnored', ...
                '''rows'' flag is ignored for cell arrays.');
    end
    if options(2) > 0
        order = 'first';
    else % if options(3) > 0 || sum(options(2:3) == 0)
        order = 'last';
    end
elseif nargin == 1
    order = 'last';
else
    error('MATLAB:UNIQUE:NotEnoughInputs', 'Not enough input arguments.');
end

if ~iscellstr(a)
   error('MATLAB:CELL:UNIQUE:InputClass','Input must be a cell array of strings.')
end

% check is input is a column vector with each element a single row text array.
if any(cellfun('size',a,1)>1)
   error('MATLAB:CELL:UNIQUE:NotARowVector','Each element in A must be a single-row text array.')
end

% initialise output variables
if isempty(a)
    if ~any(size(a))
        b = {};
        ndx = [];
        pos = [];
    else
        b = cell(0, 1);
        ndx = zeros(0,1);
        pos = ndx;
    end
    return
end

isrow = ndims(a)==2 && size(a,1)==1 && size(a,2) ~= 1;

% first sort the rows of the cell array.
[b,ndx] = sort(a);

d = ~strcmp(b(1:end-1),b(2:end));

if order(1) == 'l' % 'last'
    d = localcat(d, true, isrow);
else % order == 'first'
    d = localcat(true, d, isrow);      % First element is always a member of unique list.
end

% extract unique elements
b = b(d);

if order(1) == 'l' % 'last'
   % create position index vector
   pos = cumsum(localcat(1,d(1:end-1), isrow));
else % order == 'first'
   % create position index vector
   pos = cumsum(d);
end
% Re-reference POS to indexing of SORT.
pos(ndx) = pos;

% create index vector
ndx = ndx(d);

function value = localcat(a,b,isrow)

if (isrow)
    value = [a,b];
else
    value = [a;b];
end

