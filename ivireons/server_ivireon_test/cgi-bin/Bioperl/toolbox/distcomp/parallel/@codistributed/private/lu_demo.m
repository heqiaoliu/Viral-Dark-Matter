function [L,U,piv] = lu_demo(A)
%LU     Demo of distributed LU factorization
%   [L,U,p] = lu(A) produces a unit lower trapezoidal matrix L the
%   same size as A, and a square upper triangular matrix U, and a
%   permutation vector p, so that L*U = A(p,:);
%
%   See also QRFACTOR_DEMO, QRAPPLY_DEMO, SYMEIG_DEMO.

%   *** THIS VERSION DOES NOT DO LOAD BALANCING SUBBLOCKS ***

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:26 $

if ~isCodistributedMatrix(A)
   error('distcomp:codistributed:lu_demo:matrixInput', ...
       'Matrix must be distributed by columns.')
end
[m,n] = size(A);

% Loop over the processors

Aloc = getLocalPart(A);
nloc = size(Aloc,2);
piv = (1:m)';
s = 0;  % Number of rows already processed by ALL processors.
t = 0;  % Number of columns already processed by this processor.

mwTag1 = 32027;
mwTag2 = 32028;

for p = 1:numlabs

   % Number of columns on p-th processor

   np = ceil(p*n/numlabs)-ceil((p-1)*n/numlabs);

   if p == labindex

      % Compute the LU factorization of the p-th block

      j = (t+1):(t+np);
      i = (s+1):m;
      [Aloc(i,j) pivp] = lurectpiv(Aloc(i,j));
      Lp = tril(Aloc(i,j));
      Lp(1:(m-s+1):(m-s)*np) = 1;
      pivp = pivp+s;
      to = [1:p-1 p+1:numlabs];
      labSend(Lp,to,mwTag1);
      labSend(pivp,to,mwTag2);
      t = t + np;

   else

      % Wait to receive multipliers and pivots.

      Lp = labReceive(p,mwTag1);
      pivp = labReceive(p,mwTag2);

   end

   % Apply pivots to all other blocks.

   i = (s+1):m;
   piv(i) = piv(pivp);
   if p == labindex
      j = [1:(t-np) (t+1):nloc];
   else
      j = 1:nloc;
   end
   Aloc(i,j) = Aloc(pivp,j);

   % Apply multipliers to following blocks.

   k = 1:np;
   iu = k+s;
   ia = (s+np+1):m;
   il = ia-s;
   j = (t+1):nloc;
   Aloc(iu,j) = Lp(k,k)\Aloc(iu,j);
   Aloc(ia,j) = Aloc(ia,j) - Lp(il,k)*Aloc(iu,j);
   s = s + np;

end

% Break into upper and lower triangular matrices.

D = getCodistributor(A);
A = codistributed.build(Aloc,D);
L = tril(A,-1) + eye(size(A),codistributor);
Uloc = getLocalPart(A);
if m > n
   Uloc = Uloc(1:n,:);
end
U = triu(codistributed.build(Uloc,D, 'obsolete:calculateSize'));
