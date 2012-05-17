function h = gen2par(g)
%GEN2PAR Convert between parity-check and generator matrices.
%   H = GEN2PAR(G) computes parity-check matrix H from the standard form of a
%   generator matrix G. The function can also used to convert a parity-check
%   matrix to a generator matrix. The conversion is used in GF(2) only.
%
%   See also CYCLGEN, HAMMGEN.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $   $Date: 2007/08/03 21:17:33 $

errID = 'comm:gen2par:InvalidInput';
errmsg = 'The input for GEN2PAR is not the standard form of a generator or parity-check matrix.';
[n,m] = size(g);
if n >= m
    error(errID,errmsg);
end;

I = eye(n);
if isequal(g(:, m-n+1:m), I)
    h = [eye(m-n) g(:,1:m-n)'];
elseif isequal(g(:, 1:n), I)
    h = [g(:,n+1:m)' eye(m-n)];
else
    error(errID,errmsg);
end;

% eof
