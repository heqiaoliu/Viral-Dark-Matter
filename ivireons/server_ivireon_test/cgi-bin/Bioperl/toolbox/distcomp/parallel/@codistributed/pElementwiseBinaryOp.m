function C = pElementwiseBinaryOp(fcn, A, B)
%pElementWiseBinaryOp Perform elementwise binary operations
%   D3 = codistributed.pElementWiseBinaryOp(F, D1, D2) performs the elementwise 
%   binary operation F on all elements of D1 and D2.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/04/15 23:01:12 $

% Arrays must be of equal size or one is a scalar.
if ~(isequal(size(A),size(B)) || isscalar(A) || isscalar(B))
    E = MException('distcomp:codistributed:ElementwiseBinaryOp:dimagree', ...
                    'Matrix dimensions must agree.');
    throwAsCaller(E);
end

try
    [A, B] = iRedistributeInputs(A, B);
catch E
    throwAsCaller(E); % Hide the implementation stack.
end

% Deconstruct into local part (or replicated) and codistributors (or empty).
[LPA, codistrA] = iSplit(A);
[LPB, codistrB] = iSplit(B);

% Since the codistributors are identical if they are non-empty, it doesn't
% matter which one we pick.
if ~isempty(codistrA)
    codistr = codistrA;
else
    codistr = codistrB;
end

try
    [LP, codistr] = codistr.hElementwiseBinaryOpImpl(fcn, codistrA, LPA, codistrB, LPB);
catch E
    throwAsCaller(E); % Hide the implementation stack.
end
C = codistributed.pDoBuildFromLocalPart(LP, codistr); %#ok<DCUNK> Calling a private static method.
end


function [A, B] = iRedistributeInputs(A, B)
% Redistribute, scatter or gather A and B so that:
% - If A and B have the same size, they are both codistributed and the same
%   distribution scheme.
% - The only replicated data we have are scalars.
% In particular:
% - At least one of A and B is codistributed.

if isa(A, 'codistributed') ... 
        && isa(B, 'codistributed') 
    if isequal(size(A),size(B))
        % codistributed A, codistributed B and sizes are the same.
        % Ensure they are identically distributed.
        B = redistribute(B, getCodistributor(A));
    else
        % Either A or B are a scalar, but not both.  
        % Convert the scalar to replicated.
        A = iGatherIfCodistributedScalar(A);
        B = iGatherIfCodistributedScalar(B);
    end
elseif isa(A, 'codistributed')
    % A is codistributed, B is replicated.  
    [A, B] = iScatterGather(A, B);
else
    % A is not codistributed, B is codistributed.
    [B, A] = iScatterGather(B, A);
end

end % End of iRedistributeInputs.


function D = iGatherIfCodistributedScalar(D)
if isscalar(D) && isa(D, 'codistributed')
    D = gather(D);
end

end % End of iGatherIfCodistributedScalar.
    

function [X, Y] = iScatterGather(D, R)
% The input D must be codistributed, R must be replicated.  Transform them to
% meet the criteria for the return arguments of iRedistributeInputs.  D is
% transformed into X, R into Y.
if isequal(size(R), size(D))
    % Same size, so make both codistributed.  
    Y = codistributed.pConstructFromReplicated(R, getCodistributor(D)); %#ok<DCUNK> Calling a private static method.
    X = D;
else
    % Not the same size, so make the non-scalar codistributed, the scalar into a
    % replicated.
    if isscalar(D)
        % D is a scalar, but R is not.
        Y = codistributed.pConstructFromReplicated(R); %#ok<DCUNK> Calling a private static method.
        X = gather(D);
    else
        % R is a scalar, D is not.
        % Since the non-scalar D is already codistributed and the scalar R is already
        % replicated, nothing needs to be done.
        X = D;
        Y = R;
    end
end

end % End of iScatterGather.

function [LP, codistr] = iSplit(D)
if isa(D, 'codistributed')
    % Get codistributor and local part from codistributed array.  
    LP = getLocalPart(D);
    codistr = getCodistributor(D);
else
    % Let empty codistributor indicate that local part represents a
    % replicated array.
    LP = D;
    codistr = [];
end

end % End of iSplit.

