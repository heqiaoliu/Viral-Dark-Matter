function [H,J,sx,perm] = arescale(H,J,n)
%ARESCALE  Computes diagonal scaling for GARE.
%
%   [H,J,S] = ARESCALE(H,J,NA) computes a state vector scaling S
%   that balances the Hamiltonian/Symplectic matrix or pencil. 
%   The state matrix is transformed to D*A/D where D=diag(S), and 
%   the solutions X and Y to the original and rescaled equations 
%   are related by X = D*Y*D.
%
%   See also GCARE, GDARE.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.8 $ $Date: 2006/12/27 20:32:38 $
n2 = 2*n;
m = size(H,1)-n2;
TolZero = 1e2*eps;

% Form matrix M to be balanced
if isempty(J)
   M = H;
else
   Hd = H-diag(diag(H));
   nh = norm(Hd(1:n,1:n),1)+norm(Hd(n+1:n2,n+1:n2),1);
   Jd = J-diag(diag(J));
   nj = norm(Jd(1:n,1:n),1)+norm(Jd(n+1:n2,n+1:n2),1);
   if nh>0 && nj>0
      M = nj * abs(H) + nh * abs(J);
   else
      M = abs(H) + abs(J);
   end   
end

% Small parasitic entries can trick scaling into making X1 nearly singular
% (see tare:lvlTwo_Hinf1). Zero out such entries in the magnitude matrix M
% RE: Also helps identifying near-triangularizing permutation, e.g.,
%     [1 eps;1/eps 1] -> (ignore eps) -> [1 1/eps;eps 1]
if m==0
   mu = abs(diag(M));
   mu = mu(:,ones(n2,1));
   M(abs(M)<TolZero*(mu+mu')) = 0;
end

% Rescale magnitude matrix
% RE: 1) Use two-step approach to acquire permutation, see g162709
%     2) Acquire permutation making H(perm,perm) more upper triangular. This 
%        enhances numerics when H can be permuted to nearly upper-triangular 
%       (SCHUR may underperform EIG without this permutation, see g147863)
%     3) Full balancing needed when F,G<<1 (tare:lvlOne2, customer reported)
%        but can hurt when A has small entries (roundoff) and F=0 or G=0 
%       (tare:lvlTwo_Hinf1)
[s,perm] = mscale(M,'perm','fullbal');
perm = perm(perm<=n2);
perm(perm) = 1:n2;
s = log2(s); % unconstrained balancing diag(D1,D2,DR)

% Impose the constraint that diagonal scalings must be of the form 
% diag(D,1./D,DR). 
sx = round((-s(1:n)+s(n+1:n2))/2);  % D=sqrt(D1/D2)
s = pow2([sx ; -sx ; -s(n2+1:n2+m)]);
sx = s(1:n); % N-by-1 vector

% Rescale H,J and return diagonal scaling of state matrix
H = lrscale(H,s,1./s);
if ~isempty(J)
   J = lrscale(J,s,1./s);
end
