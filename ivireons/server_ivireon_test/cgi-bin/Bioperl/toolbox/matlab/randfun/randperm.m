function p = randperm(n)
%RANDPERM Random permutation.
%   RANDPERM(n) is a random permutation of the integers from 1 to n.
%   For example, RANDPERM(6) might be [2 4 5 6 1 3].
%   
%   Note that RANDPERM calls RAND and therefore changes RAND's state.
%
%   See also PERMUTE.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:25:47 $

[~,p] = sort(rand(1,n));
