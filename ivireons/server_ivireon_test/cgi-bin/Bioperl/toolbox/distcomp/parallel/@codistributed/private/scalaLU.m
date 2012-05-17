function varargout = scalaLU(A)
%SCALALU   ScaLAPACK LU factorization

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/12/03 19:00:39 $

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end

aDist = getCodistributor(A);
lbgrid = aDist.LabGrid;
localA = getLocalPart(A);

% Set up the array descriptor required by ScaLAPACK
descA = arraydescriptor(A);

[localA, localP] = scalaLUmex(localA, descA, lbgrid(1), lbgrid(2), aDist.Orientation, isreal(A));
A = codistributed.pDoBuildFromLocalPart(localA, aDist); %#ok<DCUNK> 

% Postprocess the permutation vector
processCol = aDist.hLabindexToProcessorCol(labindex);
localP = localP(1:size(localA, 1), processCol == 1);
codistr = codistributor2dbc(lbgrid, aDist.BlockSize,  ...
                            aDist.Orientation, [size(A,1) 1]);
P = codistributed.pDoBuildFromLocalPart(localP, codistr); %#ok<DCUNK>
P = gather(P);
varargout{3} = permVector(P(1:min(size(A))), size(A, 1));

% subsref is currently only supported on 1D, so we have no choice but to 
% convert into 1D at this point to set up the L and U factors.
LU = redistribute(A, codistributor1d(2));
L = tril(LU, -1) + eye(size(LU), getCodistributor(LU));
if size(L,1) < size(L,2)
       indx.type = '()';
       indx.subs = {':',1:size(L,1)};
       L = subsref(L,indx);
end
U = triu(LU);
if size(U,1) > size(U,2)
       indx.type = '()';
       indx.subs = {1:size(U,2),':'};
       U = subsref(U,indx);
end
varargout{1} = L;
varargout{2} = U;


function perm = permVector(P,n)
% Convert ScaLAPACK output to MATLAB permutation vector
perm = 1:n;
for i = 1:length(P)
    swap = perm(P(i));
    perm(P(i)) = perm(i);
    perm(i) = swap;
end
