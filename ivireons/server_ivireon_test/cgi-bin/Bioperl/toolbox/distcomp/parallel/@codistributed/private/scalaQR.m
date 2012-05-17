function [Q, A] = scalaQR(A, ~)
%SCALAQR   ScaLAPACK QR factorization

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.10.1 $  $Date: 2010/02/25 08:02:27 $

use1DForResult = isa(getCodistributor(A), 'codistributor1d');

% Redistribute input according to the default 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, codistributor2dbc());
end

distA = getCodistributor(A);
lbgrid = distA.LabGrid;
localA = getLocalPart(A);

% Set up the array descriptor required by ScaLAPACK
descA = arraydescriptor(A);

[mA, nA] = size(A);

% Set flag for "economy" factorization
if mA > nA
    wantEconQR = nargin > 1;
else
    wantEconQR = false;
end

[localQ, localA] = scalaQRmex(localA, descA, lbgrid(1), lbgrid(2), ...
    distA.Orientation, wantEconQR, isreal(A));

if wantEconQR  % economy factorization
    [Q, A] = iConstructFactorsFromLPs(localQ, distA, localA, nA);
else
    [A, Q] = iConstructFactorsFromLPs(localA, distA, localQ, mA);
end

A = triu(A);  % Get the upper triangular factor

if use1DForResult
    Q = redistribute(Q, codistributor1d());
    A = redistribute(A, codistributor1d());
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%
function [A, B] = iConstructFactorsFromLPs(localA, codistrA, localB, szB)
% First array reuses codistrA because it is the same size as the original
% input.  The second array will be a square array that has a codistributor
% with the properties of codistrA but global size szB x szB

A = codistributed.pDoBuildFromLocalPart(localA, codistrA); %#ok<DCUNK>

% New codistributor for square factor
codistr = codistributor2dbc(codistrA.LabGrid, codistrA.BlockSize, ...
    codistrA.Orientation, [szB szB]);

% Dispose of any workspace remaining in the upper rows and columns
localSz = codistr.hLocalSize();
localB = localB(1:localSz(1), 1:localSz(2));
B = codistributed.pDoBuildFromLocalPart(localB, codistr); %#ok<DCUNK>
end
