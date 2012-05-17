function [K,prec,message] = place(A,B,P)
%PLACE  Closed-loop pole assignment using state feedback.
%
%   K = PLACE(A,B,P) computes a state-feedback matrix K such that
%   the eigenvalues of A-B*K are those specified in the vector P.
%   No eigenvalue should have a multiplicity greater than the 
%   number of inputs.
%
%   [K,PREC] = PLACE(A,B,P) returns PREC, an estimate of how
%   closely the eigenvalues of A-B*K match the specified locations P
%   (PREC measures the number of accurate decimal digits in the actual
%   closed-loop poles).  A warning is issued if some nonzero closed-loop 
%   pole is more than 10% off from the desired location. 
%
%   See also ACKER.

%   M. Wette 10-1-86
%   Revised 9-25-87 JNL
%   Revised 8-4-92 Wes Wang
%   Revised 10-5-93, 6-1-94 Andy Potvin
%   Revised 4-11-2001 John Glass, Pascal Gahinet
%
%   Ref:: Kautsky, Nichols, Van Dooren, "Robust Pole Assignment in Linear 
%         State Feedback," Intl. J. Control, 41(1985)5, pp 1129-1155

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.16.4.4 $  $Date: 2008/01/15 18:47:03 $
message = '';  % obsolete
prec = 15;

% Number of iterations for optimization
NTRY = 5;

[nx,na] = size(A);
[n,m] = size(B);
P = P(:);
if na~=nx,
    ctrlMsgUtils.error('Control:design:place1')
elseif nx~=n,
    ctrlMsgUtils.error('Control:design:place2')
elseif length(P)~=nx,
    ctrlMsgUtils.error('Control:design:place3')
elseif nx==0,
   K = zeros(m,n); return
end

% Check for a complex plant
if ~isreal(A) || ~isreal(B)
   cmplx_sys = true;
elseif ~isequal(sort(P(imag(P)>0)),sort(conj(P(imag(P)<0))))
   cmplx_sys = true;
   ctrlMsgUtils.warning('Control:design:PlaceComplexGain')
else
   cmplx_sys = false;
end

% Compute a reduced order B
[Bu,Bs,Bv] = svd(B);
ns = min(m,n);
svB = diag(Bs(1:ns,1:ns));
m = sum(svB > 100*eps*svB(1));
if m==0
   ctrlMsgUtils.error('Control:design:place4')
end

% Compute sorted eigenvalue vector
if cmplx_sys
   n_ccj=0;
else
   Pc = P(imag(P)>0);
   n_ccj = length(Pc);
   P = [P(~imag(P)) ; Pc ; conj(Pc)];
end

% Make sure there are more inputs than repeated poles:
ps = sort(P);
mult = diff([0;find(diff(ps)~=0);n]);
if any(mult>m)
   ctrlMsgUtils.error('Control:design:place5')
end

if (m==n),
   % Special case: (#inputs)==(#states) - efficient, but not clean
   if cmplx_sys
      As = A - diag(P);
   else
      Pcomp = zeros(2*length(Pc),1);
      Pcomp(1:2:end) = Pc;
      Pcomp(2:2:end) = conj(Pc);
      P = [Pcomp; P(~imag(P))];
      As = A - diag(real(P));
      for ct = 1 : 2 : 2*n_ccj
         As(ct,ct+1) = As(ct,ct+1) + imag(P(ct));
         As(ct+1,ct) = As(ct+1,ct) - imag(P(ct));
      end
   end

   K = diag(1./svB(1:m))*Bu(:,1:m)'*As;

else
   % Compute subspace Sr = {x: U1'x=0, U1'Ax = 0} (included in all S(P) subspaces)
   U1 = Bu(:,m+1:n);
   if n_ccj>0  % real data with complex poles
      [T,Gamma,Sr] = svd([U1' ; U1'*A]);
      nsv = min(n,2*(n-m));
      r = sum(diag(Gamma(1:nsv,1:nsv)) > 100*eps*Gamma(1,1));
      Sr = Sr(:,r+1:n);
   end

   % Compute assignable subspaces Sj = null(U1'*(A-pj*I)) for target eigenvalues
   I = eye(n);
   S = cell(1,n-n_ccj);
   for i=1:n-n_ccj,
      if n_ccj>0 && imag(P(i))~=0
         % Compute the subspace of Sj orthogonal to Sr
         [T,Gamma,Sj] = svd([U1'*(P(i)*I-A) ; Sr']);
         nsv = min(n,n-m+size(Sr,2));
         r = sum(diag(Gamma(1:nsv,1:nsv)) > 100*eps*Gamma(1,1));
         S{i} =  [Sj(:,r+1:n) , Sr];
      else
         % Compute Sj
         [T,Gamma,Sj] = svd(U1'*(P(i)*I-A));
         nsv = n-m;
         r = sum(diag(Gamma(1:nsv,1:nsv)) > 100*eps*Gamma(1,1));
         S{i} =  Sj(:,r+1:n);
      end
   end

   % Choose basis set
   cnt = 1;  X = zeros(n);
   for i=1:n-n_ccj,
      if cnt > size(S{i},2), cnt = 1; end
      X(:,i) = S{i}(:,1);   %#ok<AGROW>
      cnt = cnt + 1;
   end
   X(:,n-n_ccj+1:n) = conj(X(:,n-2*n_ccj+1:n-n_ccj));

   % Orthogonalize e-vector matrix X
   if (m>1),
      [Q,R] = qr(X);
      for k = 1:NTRY,
         for j = 1:n-n_ccj, % n-n_ccj = # e-vals - # number of complex conj e-val pairs
            [Q,R] = qrdelete(Q,R,j);
            % Note: Q(:,n) represents perp of X minus the j-th column
            Yj = S{j}'*Q(:,n);
            nu = norm(Yj);
            if nu>sqrt(eps)
               Yj = S{j}*Yj / nu;
               if n_ccj>0 && imag(P(j))~=0 && abs(Yj'*conj(Yj))>0.9
                  % If the projection Yj is close to Sr, it is nearly real
                  % and (Yj,conj(Yj)) is nearly rank one. Add contribution
                  % from orthogonal complement of Sr in Sj
                  idx = 1 + rem(k,size(S{j},2)-size(Sr,2));
                  Yj = (Yj + S{j}(:,idx))/sqrt(2);
               end
               X(:,j) = Yj;
            end
            [Q,R] = qrinsert(Q,R,j,X(:,j));

            % Need to enforce conjugacy of eigenmatrix in order to get a real K for real problems
            if j > n-2*n_ccj         % If j is a e-val with a complex conjugate compute Xj+n_ccj
               [Q,R] = qrdelete(Q,R,j+n_ccj);
               X(:,j+n_ccj) = conj(X(:,j));
               [Q,R] = qrinsert(Q,R,j+n_ccj,X(:,j+n_ccj));
            end
         end
      end
   end

   % Check final conditioning of the eigenvector matrix
   if rcond(X)<eps
      ctrlMsgUtils.error('Control:design:place6')
   end

   % Compute feedback
   % If the system is not complex remove any complex terms from the computation
   % of Xf*diag(P,0)*Xf.
   if cmplx_sys
      K = lrscale(Bu(:,1:m)'*(A-X*diag(P,0)/X),1./svB(1:m),[]);
   else
      K = lrscale(Bu(:,1:m)'*(A-real(X*diag(P,0)/X)),1./svB(1:m),[]);
   end
end
K = Bv(:,1:m) * K;

% Since sort orders by magnitude and doesn't care about the order
% of complex conjugate pairs, explicitly check using the cmpeig local 
% function instead. Check results. Start by removing 0.0 pole locations.
Pc = eig(A-B*K);
Pc = localcmpeig(P,Pc);
nz = find(P ~= 0);
P = P(nz);Pc = Pc(nz);
relacc = max(abs(1-Pc./P));
if relacc>.1
   if nargout<3
      ctrlMsgUtils.warning('Control:design:PlaceAccuracy')
   else
      message = ctrlMsgUtils.message('Control:design:PlaceAccuracy');
   end
end
if relacc>eps
   prec = floor(-log10(relacc));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function
%
%   Pc_sorted = localcmpeig(P, Pc);
%
%   Sorts the vector Pc to be in the order of P.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Pc_sorted = localcmpeig(P, Pc)

Pc_sorted = zeros(size(P));
for i = 1:length(P)
   [diff, j] = min(abs(P(i,1) - Pc(:,1)));
   Pc_sorted(i,1) = Pc(j,1);Pc(j)=[];
end
