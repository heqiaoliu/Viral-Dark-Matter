function wt = gfweight(g, gh_flag)
%GFWEIGHT Calculate the minimum distance of a linear block code.
%   WT = GFWEIGHT(G) outputs the minimum distance of the given generator
%   matrix G.
%   WT = GFWEIGHT(G, GH_FLAG) outputs the minimum distance, where GH_FLAG is
%   used to specify the feature of the first input parameter.
%   When GH_FLAG == 'gen', G is a generator matrix.
%   When GH_FLAG == 'par', G is a parity-check matrix.
%   When GH_FLAG == n, which represents the code word length, G is a
%   generator polynomial for a cyclic or BCH code.
%
%   See also HAMMGEN, CYCLPOLY.

% Algorithm: The minimum weight (distance) of a linear block code equals
% the minimum number of columns in the parity check matrix that sum to 0.
%
%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $ $ Date: $

if nargin < 1
    error('comm:gfweight:NotEnoughInput','Not enough input parameters.');
elseif nargin < 2
    gh_flag = 'gen';        % default as generator matrix
end

% Convert g into parity check matrix h
if ~ischar(gh_flag)
    [h, g] = cyclgen(gh_flag, g);
elseif strncmpi(gh_flag, 'gen', 3)
    h = gen2par(g);
else
    h = g;
end
n = size(h, 2);

for wt = 2:n
    for i = 1:(n-wt+1)
        isSum0 = test(h(:,i), i, 1);
        if isSum0
            break;
        end
    end
    if isSum0
        break;
    end
end

function isSum0 = test(psum, i, numCols)
% Returns true if the GF sum of column i and any remaining wt-1 columns is 0.
% This is a recursive function that add wt columns in matrix h.
% psum    -- GF sum of the previous numCols columns
% i       -- index of the previous column
% numCols -- recursion depth (number of columns already added)

if numCols >= wt
    isSum0 = (sum(psum)==0);
else
    numCols = numCols + 1;
    for j = (i+1):(n-wt+numCols)
        isSum0 = test(gfadd(psum, h(:,j)), j, numCols);
        if isSum0
            break;
        end
    end
end

end     % test
end     % gfweight
