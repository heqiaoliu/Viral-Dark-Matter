function [a1,b1,c1,a2,b2,c2,u,tx,a,b,c] = esplit(a,b,c,select,TestFcn)
%ESPLIT  Decomposes (A,B,C,0) into (A1,B1,C1,0)+(A2,B2,C2,0) 
%        where A1 contains all eigenvalues selected by SELECT,
%        plus non-selected eigenvalues that cannot be safely 
%        pulled out of the A1 cluster. This safety check is 
%        performed by the function TESTCFN.
%
%   Assumes that A is a Schur matrix and that the signature 
%   of TESTFCN is
%      TESTFCN(A1,C1,A2,C2,T) 
%   where T is the computed solution of A1*T-T*A2+A12=0.
%
%   On exit, (A,B,C) contain the reordered Schur form and U the 
%   reordering Schur transformation.
%
%   See also UTCHECKSEPARABILITY.

%   Author(s): P. Gahinet
%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:32:15 $

% RE: The block diagonalizing state transformation is TT = U * TX
%     where U is the Schur reordering orthogonal transformation.
%     (TT \ A * TT = blkdiag(A1,A2))
nx = size(a,1);
ny = size(c,1);
nu = size(b,2);
b0 = b;
c0 = c;
u = eye(nx);
   
% Initial partition
nx1 = sum(select);
nx2 = nx - nx1;
idx1 = 1:nx1;
idx2 = nx1+1:nx;

% Iterative splitting loop: grow A11 cluster until the targeted
% accuracy is met
while nx1>0 && nx2>0
   % If needed, reorder to push selected eigs into upper left corner
   if any(diff(select)>0)
      [u,a] = ordschur(u,a,select);
      % RE: U is the cumulative transformation!
      b = u' * b0;
      c = c0 * u;
   end
   e = ordeig(a);

   % Try separating A11 and A22 clusters
   a1 = a(idx1,idx1);   b1 = b(idx1,:);  c1 = c(:,idx1);
   a2 = a(idx2,idx2);   b2 = b(idx2,:);  c2 = c(:,idx2);
   try
      tx = bdschur(a,[],[nx1 nx2]);
      t = tx(idx1,idx2);  % TX = [I T;0 I]
      Pass = TestFcn(a1,b1,c1,a2,b2,c2,t);
   catch
      % Should never happen
      Pass = false;
   end
      
   if Pass
      % Done: apply splitting transformation T
      b1 = b1 - t * b2;
      c2 = c2 + c1 * t;
      break
   else
      % Target accuracy is not met: grow cluster by absorbing eigs 
      % closest to current cluster
      select = LocalNearestNeighborExpand(e,nx1);
      nx1 = sum(select);
      nx2 = nx - nx1;
      idx1 = 1:nx1;
      idx2 = nx1+1:nx;
   end
end

% Set TX to identity if one block is empty
if nx1==0 || nx2==0
   tx = eye(nx);
   a1 = a(idx1,idx1);   b1 = b(idx1,:);  c1 = c(:,idx1);
   a2 = a(idx2,idx2);   b2 = b(idx2,:);  c2 = c(:,idx2);
end

%--------------- Local Function ------------------

function cmf = LocalNearestNeighborExpand(e,nx1)
e1 = e(1:nx1);
e2 = e(nx1+1:end);
% Find eigenvalues closest to current cluster
[e1opt,e2opt] = LocalMinDistPairing(e1,e2);
rho = abs(e1opt-e2opt);
% New cluster membership function
% REVISIT: real data only!
cmf = [true(nx1,1) ; (abs(e1opt-e2)<=rho | abs(conj(e1opt)-e2)<=rho)];

function [e1,e2] = LocalMinDistPairing(e1,e2)
% Min distance pairing
e2 = e2.';
d = abs(e1(:,ones(1,length(e2)))-e2(ones(1,length(e1)),:));
[dmin,I] = min(d,[],1);
[junk,J] = min(dmin);
e1 = e1(I(J));
e2 = e2(J);
