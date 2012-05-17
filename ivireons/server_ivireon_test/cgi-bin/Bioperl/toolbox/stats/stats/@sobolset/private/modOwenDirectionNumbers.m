function V = modOwenDirectionNumbers(varargin)
%MODOWENDIRECTIONNUMBERS  Get Modified Owen direction numbers.
%   MODOWENDIRECTIONNUMBERS(S) returns a matrix of direction numbers for the
%   dimensions up to the value of S.  The n'th column of the output will
%   contain the direction numbers for the n'th dimension.  The direction
%   numbers are scrambled according to a modified Owen scheme.
%
%   MODOWENDIRECTIONNUMBERS(S1,S2) returns the matrix of scrambled
%   direction numbers for dimensions between S1 and S2.

%   References:
%      [1] Hee Sun Hong and Fred J. Hickernell (2003) ALGORITHM 823
%          Implementing Scrambled Digital Sequences, ACM Transactions on
%          Mathematical Software, Vol. 29, No. 2.

%   Copyright 2007-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $    $Date: 2010/03/16 00:21:32 $

% Get the standard direction numbers
V = standardDirectionNumbers(varargin{:});
NBits = size(V, 2);

for idx = 1:size(V,1)
    % Place the bits of the direction numbers into a binary matrix
    Vmat = DNToMatrix(V(idx,:));
    
    % Form a full rank random lower triangular matrix for scrambling
    L = double(tril(rand(NBits)>.5) | eye(NBits));

    % Apply scramble
    Vmat_scr = mod(L*Vmat,2);

    % Extract scrambled bits into new direction numbers
    V(idx,:) = MatrixToDN(Vmat_scr).';
end
