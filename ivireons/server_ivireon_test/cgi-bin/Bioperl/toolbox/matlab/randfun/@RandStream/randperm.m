function p = randperm(s,n)
%RANDPERM Random permutation.
%   RANDPERM(S,N) is a random permutation of the integers from 1 to N.
%   For example, RANDPERM(S,6) might be [2 4 5 6 1 3].
%   
%   RANDPERM draws random values from the random stream S.
%
%   See also RANDPERM, PERMUTE.

%   Copyright 2008-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/21 03:25:50 $

[~,p] = sort(rand(s,1,n));
