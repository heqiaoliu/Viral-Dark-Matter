function y = isCodistributedMatrix(A)
%ISCODISTRIBUTEDMATRIX                       Private utility function for parallel

%ISCODISTRIBUTEDMATRIX True for a 2-d codistributed array distributed by columns.
%   isCodistributedMatrix(A)

%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/03/25 21:56:55 $

y = false;
if ~isa(A, 'codistributed') || ndims(A) ~= 2 
    return
end
aDist = getCodistributor(A);
if ~isa(aDist, 'codistributor1d') 
    return;
end

y = aDist.Dimension == 2;
