function [h, g, n, k] = hammgen(m, p)
%HAMMGEN Produce parity-check and generator matrices for Hamming code.
%   H = HAMMGEN(M) produces the parity-check matrix H for a given integer M, M
%   >= 3. The code length of a Hamming code is N=2^M-1. The message length is K
%   = 2^M - M - 1. The parity-check matrix is an M-by-N matrix.
%
%   H = HAMMGEN(M, P) produces the parity-check matrix using a given GF(2)
%   primitive polynomial P.
%
%   [H, G] = HAMMGEN(...) produces the parity-check matrix H as well as the
%   generator matrix G. The generator matrix is a K-by-N matrix.
%
%   [H, G, N, K] = HAMMGEN(...) produces the codeword length N and the message
%   length K.
%
%   Note: The parameter M must be an integer greater than or equal to 3.
%   Hamming code is a single-error-correction code.
%
%   See also ENCODE, DECODE, GEN2PAR.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.13.4.3 $

% Error checking.
error(nargchk(1,2,nargin,'struct'));

% Error checking - M.
if ( isempty(m) || ~isreal(m) || m<3 || floor(m)~=m || numel(m)~=1 )
    error('comm:hammgen:InvalidM','M must be a real integer greater than two.');
end

% dimension
n = 2^m - 1;
k = n - m;

if nargin < 2 || isempty(p)
    % assign primitive polynomial if not supplied
    p = gfprimdf(m);
else
    % test supplied polynomial for primitiveness
    p = gfrepcov(p);
    if gfprimck(p) ~= 1
        error('comm:hammgen:InvalidP','The input polynomial must be primitive.');
    end;
end;

% generate the parity-check matrix.
h = gftuple((0:n-1)', p, 2)';

% when needed, produce generator matrix
if nargout > 1
    g = gen2par(h);
end;
%--end of hammgen--