function H = setParityCheckMatrix(h, H)
%SETPARITYCHECKMATRIX  Set parity check matrix of an LDPC encoder object.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/23 19:24:48 $

if ~issparse(H)
    error('comm:ldpcenc:NonSparseParityCheckMatrix', ...
          'The parity-check matrix must be a sparse matrix.');
end

N = size(H,2);
K = N - size(H,1);

if N <= 0
    error('comm:ldpcenc:InvalidNumColumns', ...
          'The parity-check matrix must have at least one column.');
end

if K <= 0
    error('comm:ldpcenc:TooFewColumns', ...
          'The parity-check matrix must have more columns than rows.');
end

if ~isempty(find(nonzeros(H)~=1, 1))
    error('comm:ldpcenc:NotZeroOneMatrix', ...
          'The parity-check matrix must be a zero-one matrix.');
end

if ~isempty(find(full(sum(H,1)==0), 1))
    error('comm:ldpcenc:EmptyColumn', ...
          'The parity-check matrix must have at least one nonzero element in each column.');
end

H = logical(H);    % Convert the parity-check matrix to a logical matrix to save memory.
PB = H(:,K+1:end); % Extract the last (N-K) columns of the parity-check matrix.

% Check if PB is triangular
switch isfulldiagtriangular(PB)
    case 1,
        Alg = 'Forward Substitution';   % PB is lower triangular and has a full diagonal.
        RowOrder = -1;                  % Don't need to reverse the order of rows in PB
    case -1,
        Alg = 'Backward Substitution';  % PB is upper triangular and has a full diagonal.
        RowOrder = -1;                  % Don't need to reverse the order of rows in PB
    case 0,
        % Reverse the order of rows in PB, but keep PB, since if PB is not
        % triangular, we need to factorize it in GF(2).
        Reversed_PB = PB(end:-1:1,:);
        switch isfulldiagtriangular(Reversed_PB) % Check if Reversed_PB is triangular.
            case 1,
                Alg = 'Forward Substitution';
                RowOrder = (N-K):-1:1;
                PB = Reversed_PB;
            case -1,
                Alg = 'Backward Substitution';
                RowOrder = (N-K):-1:1;
                PB = Reversed_PB;
            case 0,
                Alg = 'Matrix Inverse';
        end
end

% The following properties won't be used for forward/backward substitution.
% But the C-MEX function expects these inputs. So just provide dummy
% values by default.
h.MatrixL_RowIndices  = int32(0);
h.MatrixL_ColumnSum   = int32(0);
h.MatrixL_RowStartLoc = int32(0);

if strcmp(Alg, 'Forward Substitution')
    h.EncodingMethod = int8(1);
    P = tril(PB, -1);  % Remove the diagonal of PB and put it in P.
elseif strcmp(Alg, 'Backward Substitution')
    h.EncodingMethod = int8(-1);
    P = triu(PB, 1);   % Remove the diagonal of PB and put it in P.
else
    % If we reach this line, then Alg = 'Matrix Inverse',
    % i.e., the last (N-K) columns of the parity-check matrix (i.e. PB) is not triangular.
    % Let's try to factorize it in GF(2).
    % See the comments in gf2factorize for details about what it does.
    [PL PB RowOrder invertible] = gf2factorize(PB);
    if ~invertible
        error('comm:ldpcenc:NonInvertibleParityCheckMatrix', ...
              'The last (N-K) columns of the parity-check matrix must be invertible in GF(2).');
    else
        % PB is invertible in GF(2), and has been modified by gf2factorize.
        h.EncodingMethod = int8(0);
        [h.MatrixL_RowIndices h.MatrixL_RowStartLoc h.MatrixL_ColumnSum] = ConvertMatrixFormat(tril(PL, -1));
        PB = PB(RowOrder, :); % Need to do this before the next line.
        P = triu(PB, 1);      % Now PB is upper triangular. Remove the diagonal and put it in P.
    end
end

% Update all internal data structures for the encoding operation.
h.RowOrder = int32(RowOrder-1);
[h.MatrixA_RowIndices h.MatrixA_RowStartLoc h.MatrixA_ColumnSum] = ConvertMatrixFormat(H(:,1:K));
[h.MatrixB_RowIndices h.MatrixB_RowStartLoc h.MatrixB_ColumnSum] = ConvertMatrixFormat(P);

% Update all external properties.
h.StoredParityCheckMatrix = H;  % For the property ParityCheckMatrix
h.BlockLength = N;
h.NumInfoBits = K;
h.NumParityBits = N - K;
h.EncodingAlgorithm = Alg;



%% Internal function
function shape = isfulldiagtriangular(X)
% X must be a square logical matrix.
% shape = 1  if X is lower triangular and has a full diagonal.
% shape = -1 if X is upper triangular and has a full diagonal.
% Otherwise, shape = 0.
% If X is a diagonal matrix, X is considered upper triangular.

N = size(X,1);
NumNonzeros = nnz(X);
if ~all(diag(X)) % Full diagonal?
    shape = 0;   % Must have a full diagonal.
else
    NumNonzerosInLowerPart = nnz(tril(X));
    if NumNonzerosInLowerPart == NumNonzeros
        shape = 1;  % X is lower triangular.
    elseif NumNonzerosInLowerPart == N
        shape = -1; % X is upper triangular.
    else
        shape = 0;  % X is not triangular.
    end
end


%% Internal function
function [RowIndices RowStartLoc ColumnSum] = ConvertMatrixFormat(X)
% Create an alternative representation of a zero-one matrix.

% Find nonzero elements.
[i,j] = find(X);  %#ok

% Generate zero-based row indices and use int32 for C-MEX function.
RowIndices = int32(i-1);

% Find the number of nonzero elements in each column.
% Use int32 for C-MEX function.
ColumnSum  = int32(full(sum(X)));

% For each column, find where the corresponding row indices start in RowIndices.
% Generate zero-based indices and use int32 for C-MEX function.
CumulativeSum = cumsum(double(ColumnSum));
RowStartLoc = int32([0 CumulativeSum(1:end-1)]);


%% Internal function
function [A B chosen_pivots invertible] = gf2factorize(X)
%GF2FACTORIZE  Factorize a square matrix in GF(2).
%   [A B chosen_pivots invertible] = gf2factorize(X) factorizes a square matrix X
%   in GF(2) using Gaussian elimination.
%
%   X = A * B    (in GF(2), i.e., using modulo-2 arithmetic)
%
%   X may be a sparse matrix. Nonzero elements are treated as ones.
%   A and B are sparse logical matrices.
%
%   A is always lower triangular.
%   If X is invertible in GF(2), then B(chosen_pivots,:) is upper triangular and
%   invertible = true.
%   If X is non-invertible in GF(2), then X = A * B still holds and invertible = false.
%
%   To evaluate A * B in GF(2), use mod(A*double(B),2).

n = size(X,1);
if n ~= size(X,2)
    % This should never occur.
    error('comm:ldpcenc:NonSquareInputForFactorization', ...
          'Input for gf2factorize must be a square matrix.');
end

Y1 = logical(eye(n,n));
Y2 = full(X~=0);
chosen_pivots = zeros(n,1); % Haven't chosen any pivots yet.
invertible = true; % Assume that X is invertible in GF(2).

for col = 1:n
    candidate_rows = Y2(:,col);
    candidate_rows(chosen_pivots(1:(col-1))) = 0; % Never use a chosen pivot.
    candidate_rows = find(candidate_rows); % Convert into row indices.

    if isempty(candidate_rows)
        invertible = false; % X is not invertible in GF(2).
        break;
    else
        pivot = candidate_rows(1);      % Choose the first candidate row as the pivot row.
        chosen_pivots(col) = pivot;     % Record this pivot.

        % Find all nonzero elements in the pivot row.
        % They will be xor-ed with the corresponding elements in other
        % candidate rows.
        columnind = find(Y2(pivot,:));

        % Subtract the pivot row from all other candidate_rows.
        % Exploit the fact that we are working in GF(2).
        % Just use logical NOT.
        % As we continue in this loop, Y2 will become "psychologically"
        % upper triangular.
        Y2(candidate_rows(2:end), columnind) = not(Y2(candidate_rows(2:end), columnind));

        % Update the lower triangular matrix Y1.
        Y1(candidate_rows(2:end), pivot) = 1;
    end
end

% Output sparse matrices to save memory.
A = sparse(Y1);
B = sparse(Y2);

if ~invertible
    % Output the chosen pivots even if X is not invertible in GF(2).
    chosen_pivots = [chosen_pivots(1:(col-1)); setdiff((1:n)', chosen_pivots(1:(col-1)))];
end
