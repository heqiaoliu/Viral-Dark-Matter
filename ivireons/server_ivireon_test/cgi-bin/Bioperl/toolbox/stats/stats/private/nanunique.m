function [b,ndx,pos] = nanunique(a,varargin)
%NANUNIQUE Set unique.
%   B = NANUNIQUE(A) for the array A returns the same values as in A but
%   with no repetitions. B will also be sorted. A can be a cell array of 
%   strings.
%
%   NANUNIQUE(...,'rows') for the matrix A returns the unique rows of A.
%
%   NANUNIQUE(...,'equalnans') treats NaN's as equal to each other.  
%   By default, each NaN is treated as unique.
%
%   [B,I,J] = NANUNIQUE(...) also returns index vectors I and J such
%   that B = A(I) and A = B(J) (or B = A(I,:) and A = B(J,:)).
%   
%   [B,I,J] = NANUNIQUE(...,'first') returns the vector I to index the
%   first occurrence of each unique value in A.  NANUNIQUE(...,'last'),
%   the default, returns the vector I to index the last occurrence.
%
%   See also UNIQUE, UNION, INTERSECT, SETDIFF, SETXOR, ISMEMBER, SORT, ISSORTED.

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:29:51 $

flagvals = {'rows' 'first' 'last' 'equalnans'};
if nargin > 1
    options = zeros(1,4);
    for i=1:length(varargin)
        options = options + strcmpi(varargin{i},flagvals);
    end
    if nargin > 2
        if any(options > 1) || (options(2)+options(3) > 1)
            error('stats:nanunique:RepeatedFlag', ...
                'You may not specify more than one value for the same option.');
        end
    end
    if sum(options) < nargin-1
        error('stats:nanunique:UnknownFlag', 'Unrecognized option.');
    end
    byrow = (options(1) > 0);
    if options(2) > 0
        order = 'first';
    else % if options(3) > 0 || sum(options(2:3) == 0)
        order = 'last';
    end
    if options(4) > 0
        nancompare = 'same';
    else
        nancompare = 'different';
    end
elseif nargin == 1
    byrow = false;
    order = 'last';
    nancompare = 'different';
else
    error('stats:nanunique:NotEnoughInputs', 'Not enough input arguments.');
end

rows = size(a,1);
cols = size(a,2);

rowvec = (rows == 1) && (cols > 1);

numelA = numel(a);
nOut = nargout;

if ~byrow

    % Handle empty: no elements.

    if (numelA == 0)
        % Predefine b to be of the correct type.
        b = a([]);
        if max(size(a)) > 0
            b = reshape(b,0,1);
            ndx = zeros(0,1);
            pos = zeros(0,1);
        else
            ndx = [];
            pos = [];
        end
        return

    elseif (numelA == 1)
        % Scalar A: return the existing value of A.
        b = a; ndx = 1; pos = 1;
        return

        % General handling.
    else

        % Convert to columns
        a = a(:);

        % Convert to double array for purposes of faster sorting.
        % Additionally, UNIQUE calls DIFF, which requires double input.

        whichclass = class(a);
        isdouble = strcmp(whichclass,'double');

        if ~isdouble
            a = double(a);
        end

        % Sort if unsorted.  Only check this for long lists.

        checksortcut = 1000;

        if numelA <= checksortcut || ~(issorted(a))
            if nOut <= 1
                b = sort(a);
            else
                [b,ndx] = sort(a);
            end
        else
            b = a;
            if nOut > 1
                ndx = (1:numelA)';  % If presorted, indices are 1,2,3,...
            end
        end

        % d indicates the location of non-matching entries.

        db = diff(b);

        % Since DIFF returns NaN in both Inf and NaN cases,
        % use slower method of detection if NaN's detected in DIFF(b).
        % After sort, Infs or NaNs will be at ends of list only.

        if (isnan(db(1)) || isnan(db(numelA-1)))
            if strcmp(nancompare,'same')
                % Treat NaN's as equal to each other.
                bnans = isnan(b);
                d = b(1:numelA-1) ~= b(2:numelA) & ...
                    ~(bnans(1:numelA-1) & bnans(2:numelA));
            else % nancompare is 'different'
                d = b(1:numelA-1) ~= b(2:numelA);
            end
        else
            d = db ~= 0;
        end

        if order(1) == 'l' % 'last'
            d(numelA,1) = true; % Final element is always a member of unique list.
        else % order == 'first'
            d = [true; d];      % First element is always a member of unique list.
        end

        b = b(d);         % Create unique list by indexing into sorted list.

        if nOut == 3
            if order(1) == 'l' % 'last'
                pos = cumsum([1;full(d)]);  % Lists position, starting at 1.
                pos(numelA+1) = [];         % Remove extra element introduced by d.
            else % order == 'first'
                pos = cumsum(full(d));      % Lists position, starting at 1.
            end
            pos(ndx) = pos;             % Re-reference POS to indexing of SORT.
        end

        % Create indices if needed.
        if nOut > 1
            ndx = ndx(d);
        end

        % Re-convert to correct output data type using FEVAL.
        if ~isdouble
            b = feval(whichclass,b);
        end
    end

    % If row vector, return as row vector.
    if rowvec
        b = b.';
        if nOut > 1
            ndx = ndx.';
            if nOut > 2
                pos = pos.';
            end
        end
    end

else    % 'rows' case

    % Handle empty: no rows.

    if (rows == 0)
        % Predefine b to be of the correct type.
        b = a([]);
        ndx = [];
        pos = [];
        b = reshape(b,0,cols);
        if cols > 0
            ndx = reshape(ndx,0,1);
        end
        return

        % Handle scalar: one row.

    elseif (rows == 1)
        b = a; ndx = 1; pos = 1;
        return
    end

    % General handling.
    % Conversion to double not done: SORTROWS is slower for doubles
    % than other types.

    if nOut > 1
        [b,ndx] = sortrows(a);
    else
        b = sortrows(a);
    end

    % d indicates the location of non-matching entries.

    if strcmp(nancompare,'same')
        % Treat NaN's as equal to each other.
        bnans = isnan(b);
        d = b(1:rows-1,:)~=b(2:rows,:) & ...
            ~(bnans(1:rows-1,:) & bnans(2:rows,:));
    else % nancompare is 'different'
        d = b(1:rows-1,:)~=b(2:rows,:);
    end
  
    % d = 1 if differences between rows.  d = 0 if the rows are equal.

    d = any(d,2);
    if order(1) == 'l' % 'last'
        d(rows,1) = true; % Final row is always member of unique list.
    else % order = 'first'
        d = [true; d];    % First row is always a member of unique list.
    end

    b = b(d,:);         % Create unique list by indexing into sorted list.

    % Create position mapping vector using CUMSUM.

    if nOut == 3
        if order(1) == 'l' % 'last'
            pos = cumsum([1;full(d)]);  % Lists position, starting at 1.
            pos(rows+1) = [];           % Remove extra element introduced by d.
        else % order == 'first'
            pos = cumsum(full(d));      % Lists position, starting at 1.
        end
        pos(ndx) = pos;             % Re-reference POS to indexing of SORT.
    end

    % Create indices if needed.
    if nOut > 1
        ndx = ndx(d);
    end
end
end