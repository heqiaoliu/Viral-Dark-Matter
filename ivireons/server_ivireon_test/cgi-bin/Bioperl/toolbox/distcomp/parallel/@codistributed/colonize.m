function B = colonize(A)
%COLONIZE Implement A(:) for codistributed A
%   B = COLONIZE(A) implements B = A(:)
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.ones(N);
%       B = colonize(A) % B is now a 1000000-by-1 vector of ones
%   end
%   
%   See also COLONIZE, CODISTRIBUTED, CODISTRIBUTED/ONES.
%   


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:58:25 $

aDist = getCodistributor(A);
da = aDist.Dimension;
pa = aDist.Partition;
na = ndims(A);
k = da;
s = size(A);
if k > ndims(A)
    ppb = prod(s)*pa;
else    
    ppb = prod(s([1:k-1 k+1:end]))*pa;
end

s = size(A);
if isvector(A) && s(2)==1 && da == 1 %column vector
    B = A;
elseif da < na
    da = ndims(A);
    pa = codistributor1d.defaultPartition(s(na));
    A = redistribute(A, codistributor1d(da, pa));
    pb = prod(s(1:na-1))*pa;
    a = getLocalPart(A);
    B = codistributed.pDoBuildFromLocalPart(a(:), codistributor1d(1, pb, [sum(pb), 1]));
    B = redistribute(B, codistributor1d(1, ppb));
else
    a = getLocalPart(A);
    B = codistributed.pDoBuildFromLocalPart(a(:), codistributor1d(1, ppb, [sum(ppb), 1]));
end
