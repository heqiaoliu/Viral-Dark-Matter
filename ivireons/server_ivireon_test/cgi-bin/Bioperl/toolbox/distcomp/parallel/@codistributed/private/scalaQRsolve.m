function A = scalaQRsolve(A, B)
% SCALAQRSOLVE  SCALAPACK QR or LQ solver

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2010/01/25 21:31:34 $
    
if size(A, 1) ~= size(B, 1)
    error('distcomp:codistributed:dimagree',...
          'Matrix dimensions must agree.');
end

use1DForResult = iUse1DForResult(A, B);

% Redistribute input according to the column-oriented 2dbc distribution scheme.
if ~isa(getCodistributor(A), 'codistributor2dbc')
    A = redistribute(A, ...
                     codistributor2dbc(codistributor2dbc.defaultLabGrid, ...
                                       codistributor2dbc.defaultBlockSize, ...
                                       'col'));
end

distributedB = isa(B, 'codistributed');
distA = getCodistributor(A);
lbgrid = distA.LabGrid;

% new codistributor for B
% if A has more columns than rows, B needs extra rows for scalapack result
numOutputRows = max(size(A));
newDistB = codistributor2dbc(lbgrid, distA.BlockSize, distA.Orientation, ...
                             [numOutputRows size(B, 2)]);
if ~distributedB
    B = [B; zeros(numOutputRows - size(B, 1), size(B, 2), class(B))];
    B = codistributed.pConstructFromReplicated(B, newDistB); %#ok<DCUNK> Calling a private static method.
else
    % Redistribute B into the correct format and pad with zeros
    % with minimal communication
    B = redistribute(B, codistributor2dbc(lbgrid, distA.BlockSize, ...
                     distA.Orientation, size(B)));
    localB = getLocalPart(B);
    localB = [localB; zeros(newDistB.hLocalSize() - [size(localB, 1) 0], class(localB))];
    B = codistributed.pDoBuildFromLocalPart(localB, newDistB); %#ok<DCUNK>
end

% If inputs are of different types, convert the double one to single
if isaUnderlying(A,'single') && isaUnderlying(B,'double')
    B = single(B);
end

if isaUnderlying(A,'double') && isaUnderlying(B,'single')
    A = single(A);
end

isrealA = isreal(A);
isrealB = isreal(B);

descA = arraydescriptor(A);
descB = arraydescriptor(B);

localA = getLocalPart(A);
if ~isrealA && isreal(localA)
    localA = complex(localA);
end

localB = getLocalPart(B);
if ~isrealB && isreal(localB)
    localB = complex(localB);
end

localA = scalaQRsolvemex(localA, descA, localB, descB, lbgrid(1), ...
                         lbgrid(2), distA.Orientation, isrealA, isrealB);
                     
% We keep only as many rows of the result as there were columns in input A
codistr = codistributor2dbc(lbgrid, distA.BlockSize, ...
                            distA.Orientation, [size(A, 2) size(B, 2)]);
szLocalA = codistr.hLocalSize();
localA = localA(1:szLocalA(1), :);
A = codistributed.pDoBuildFromLocalPart(localA, codistr); %#ok<DCUNK>

if use1DForResult
    A = redistribute(A, codistributor1d(1));
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
function use1DForResult = iUse1DForResult(A, B)
    uses1D = @(x) isa(x, 'codistributed') && ...
                  isa(getCodistributor(x), 'codistributor1d');
    if uses1D(A) || uses1D(B)
        use1DForResult = true;
    else
        use1DForResult = false;
    end
end