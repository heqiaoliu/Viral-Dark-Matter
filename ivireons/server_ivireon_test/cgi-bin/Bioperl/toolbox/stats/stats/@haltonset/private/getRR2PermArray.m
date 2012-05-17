function P = getRR2PermArray(Bases)
%GETRR2PERMARRAY Get HaltonRR2 scrambling permutation vectors.
%   GETRR2PERMARRAY(BASES) returns a cell array of permutation vectors for
%   the bases specified.  The first 100 prime base permutations are cached
%   to reduce memory used my multiple objects.
%
%   This function is used to generate the coefficient permutations when
%   they are being explicitly held in the object.

%   Copyright 2007 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:20:52 $

persistent CachedPerms CachedBases 

if isempty(CachedPerms)
    % Cache the first 100 prime base permutations
    CachedBases = primes(541);
    CachedPerms = computeRR2Perm(CachedBases);
end

[iscached, loc] = ismember(Bases, CachedBases);
if all(iscached)
    P = CachedPerms(loc);
else
    % Calculate the permutations requested
    P = calculateRR2Perm(Bases);
end
