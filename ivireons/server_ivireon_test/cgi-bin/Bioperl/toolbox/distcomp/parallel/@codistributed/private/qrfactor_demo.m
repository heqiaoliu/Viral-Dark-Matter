function [A,R] = qrfactor_demo(A)
%QRFACTOR_DEMO  Demo of first step of QR factorization
%   [H,R] = QRFACTOR_DEMO(A)
%   R = the R of the QR factorization.
%   Columns of H define Householder transformations,
%   H_k = I - tau(k)*v_k*v_k', where tau(k) = H(k,k) and
%   v_k = [zeros(k-1,1); 1; H(k+1:m,k)]
%
%   See also QRAPPLY_DEMO.

%   Uses Mex-files for LAPACK routines DGEQRF and DORMQR.

%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/03/25 21:57:29 $

if ~isCodistributedMatrix(A)
   error('distcomp:codistributed:qrfactor_demo:notByColumns',...
         'Matrix must be distributed by columns.')
end

% Column permutation to improve load balancing

A = loadbalance(A);

% Loop over the subblocks and the processors

[m n] = size(A);
np = numlabs;
Aloc = getLocalPart(A);
D = getCodistributor(A);
nloc = size(Aloc,2);
tau = zeros(n,1);
w = floor(n/np^2);  % Number of columns in "offdiagonal" subblocks.
s = 0;  % Number of rows already processed by ALL processors.
t = 0;  % Number of columns already processed by this processor.

mwTag1 = 31386;
mwTag2 = 31387;

for k = 1:np
   for r = 1:np

      % Number of columns in k-th subblock on r-th processor

      if k ~= r
         nkr = w;
      else
         nkr = length(globalIndices(A, D.Dimension, r)) - (np-1)*w;
      end

      if r == labindex

         % Compute the Householder reflectors for the (k,r)-th subblock

         i = (s+1):m;
         j = (t+1):(t+nkr);
         [Hkr,taukr] = dgeqrf(Aloc(i,j));
         Aloc(i,j) = Hkr;
         labSend(Hkr,[1:r-1 r+1:np],mwTag1);
         labSend(taukr,[1:r-1 r+1:np],mwTag2);
         t = t + nkr;

      else

         % Wait to receive reflectors.

         Hkr = labReceive(r,mwTag1);
         taukr = labReceive(r,mwTag2);

      end

      % Apply reflectors to following subblocks.

      i = (s+1):m;
      j = (t+1):nloc;
      Aloc(i,j) = dormqr('L','T',Hkr,taukr,Aloc(i,j));
      i = (s+1):(s+nkr);
      tau(i) = taukr;
      s = s + nkr;
   end
end

% Undo the loadbalancing permutation.

A = codistributed.build(Aloc,D);
A = loadbalance(A);

% Split off R and put tau on the diagonal of H.

R = triu(A);
[e,f] = globalIndices(A, D.Dimension, labindex);
k = e:m+1:(f-e+1)*(m+1);
Aloc = getLocalPart(A);
Aloc(k) = tau(e:f);
A = tril(codistributed.build(Aloc,D));
