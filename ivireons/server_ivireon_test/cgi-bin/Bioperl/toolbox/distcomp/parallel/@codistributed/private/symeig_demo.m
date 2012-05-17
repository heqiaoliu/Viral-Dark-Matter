function lambda = symeig_demo(A,b)
%SYMEIG_DEMO  Demo of eigenvalues of symmetric codistributed matrix
%   LAMBDA = SYMEIG_DEMO(A) returns the eigenvalues only of a symmetric
%   codistributed matrix A. SYMEIG_DEMO uses a default block size of 32.
%
%   LAMBDA = SYMEIG(A,BLKSZ) also specifies the block size BLKSZ.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:39 $

if nargin < 2, b = 32; end
[n,n] = size(A);
Aloc = getLocalPart(A);
aDist = getCodistributor(A);
d = zeros(n,1);
e = zeros(n-1,1);
[s,t] = globalIndices(A, aDist.Dimension, labindex);
for k = 0:b:n-1
   m = n-k;
   p = k+1:n;
   ploc = intersect(p,s:t)-(s-1);
   kloc = intersect(p,s:t)-k;
   W = zeros(m,0);
   Y = zeros(m,0);
   for j = 1:b
      u = W*Y(j,:)';
      u(j) = u(j) + 1;
      u = gplus(Aloc(p,ploc)*u(kloc));
      u = u + Y*(W'*u);
      d(k+j) = u(j);
      if k+j == n
         break
      end
      u(1:j) = 0;
      q = j+1:m;
      sigma = norm(u(q));
      if sigma == 0
         u(j+1) = 1;
         sigma = 1;
      end
      if u(j+1) < 0, sigma = -sigma; end
      u(j+1) = u(j+1) + sigma;
      rho = 1/(sigma'*u(j+1));
      W(:,j) = -rho*(u + W*(Y(q,:)'*u(q)));
      Y(:,j) = u;
      e(k+j) = -sigma;
   end
   Z = gplus(Aloc(p,ploc)*W(kloc,:));
   Z = Z + Y*(0.5*(W'*Z));
   Aloc(p,ploc) = Aloc(p,ploc) + (Y*Z(kloc,:)' + Z*Y(kloc,:)');
end
lambda = tqr(d,e);

%%% BEGIN SUBFUNCTIONS %%%

function [d,X,iters] = tqr(d,e,X)
%TQR    Eigenvalues and vectors of symmetric tridiagonal matrix.
%   Eigenvalues of tridiagonal matrix.
%     lambda = tqr(d,e)
%     where d is the diagonal and e is the super- and subdiagonal of an
%     n-by-n symmetric tridiagonal matrix.  length(d) = n, length(e) = n-1.
%   Eigenvalues and vectors of tridiagonal matrix.
%     [lambda,X] = tqr(d,e)
%     [lambda,X] = tqr(d,e,X)
%     [lambda,X,iters] = tqr(...)

n = length(d);
e(2:n) = e(1:n-1);
wantx = nargout > 1;
if wantx && nargin < 3
   X = eye(n,n);
end
iters = zeros(n,1);
for k = n:-1:1
   iter = 0;
   while 1

      % Find negligible subdiagonal element and convergence check

      m = k;
      while m > 1 && abs(e(m)) > eps(abs(d(m-1)) + abs(d(m)))
         m = m - 1;
      end
      if m == k, break, end  % if m == k, d(k) is an eigenvalue

      % Compute shift from [d(k-1) e(k); e(k) d(k)]

      g = (d(k-1) - d(k))/(2*e(k));
      r = hypot(1,g);
      if g < 0, r = -r; end
      shift = d(k) - e(k)/(g + r);

      % Implicit tridiagonal QR algorithm

      s = 1;
      c = 1;
      p = 0;
      g = d(m) - shift;
      for j = m+1:k
         f = s*e(j);
         b = c*e(j);
         r = hypot(f,g);
         e(j-1) = r;
         if r == 0
            d(j-1) = d(j-1) - p;
            break
         end
         s = f/r;
         c = g/r;
         g = d(j-1) - p;
         r = (d(j) - g)*s + 2*c*b;
         p = s*r;
         d(j-1) = g + p;
         g = c*r - b;

         % Accumulate transformation.

         if wantx
            x1 = X(:,j-1);
            x2 = X(:,j);
            X(:,j-1) = c*x1 + s*x2;
            X(:,j) = -s*x1 + c*x2;
         end
      end
      if r ~= 0
         d(k) = d(k) - p;
         e(k) = g;
      end
      e(m) = 0;
      iter = iter + 1;
   end
   iters(k) = iter;
end

% Sort eigenvalues

[d,p] = sort(d);
if wantx
   X = X(:,p);
end

%%% END SUBFUNCTIONS %%%
