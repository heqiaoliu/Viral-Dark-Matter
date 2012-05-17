function varargout = gdare(H,J,n,varargin)
%GDARE  Generalized solver for discrete algebraic Riccati equations.
%
%   [X,L] = GDARE(H,J,NS) computes the unique stabilizing solution 
%   X of the discrete-time algebraic Riccati equation associated  
%   with Symplectic pencils of the form
% 
%                    [  A   0   B  ]       [ E   0   0 ]
%        H - t J  =  [ -Q   E' -S  ]  - t  [ 0   A'  0 ]
%                    [  S'  0   R  ]       [ 0  -B'  0 ]
% 
%   The third input NS is the row size of the A matrix. The output
%   L is the vector of closed-loop eigenvalues.
%
%   [X,L,REPORT] = GDARE(H,J,NS) suppresses errors when X fails
%   to exist. The diagnosis REPORT is set to:
%     * -1 when the Symplectic pencil has eigenvalues on the unit circle
%     * -2 when there is no finite stabilizing solution X
%     * 0 when a finite stabilizing solution X exists.
%
%   [X1,X2,D,L] = GDARE(H,J,NS,'factor') returns two matrices X1, X2 
%   and a diagonal scaling matrix D such that X = D*(X2/X1)*D.
%   The vector L contains the closed-loop eigenvalues.  All outputs 
%   are empty when the Symplectic pencil has eigenvalues on the 
%   unit circle.
%
%   [...] = GDARE(H,...,'nobalance') disables automatic scaling of 
%   the data.
%
%   See also DARE, GCARE.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $ $Date: 2009/08/08 01:08:20 $

% Flags
FactorFlag = (any(strcmp(varargin,'factor')));
NoBalanceFlag = (any(strcmp(varargin,'nobalance')));
n2 = 2*n;
m = size(H,1)-n2;
if ~isequal(size(H),size(J))
   ctrlMsgUtils.error('Control:foundation:ARE10','gdare')
elseif m<0
   ctrlMsgUtils.error('Control:foundation:ARE13','gdare')
end

% Scale Symplectic matrix/pencil (D = state matrix scaling)
% RE: Before compression to preserve Symplectic structure
if NoBalanceFlag
   D = ones(n,1);  perm = 1:n2;
else
   [H,J,D,perm] = arescale(H,J,n);
end
E = J(1:n,1:n);

% Compression step on H(:,n2+1:n2+m) = [S1;-S2;R]
if m>0
   [q,r] = qr(H(:,n2+1:n2+m)); %#ok<NASGU>
   H = q(:,m+1:n2+m)'*H(:,1:n2);
   J = q(:,m+1:n2+m)'*J(:,1:n2);
end

% QZ algorithm
% RE: Usual formulation is in terms of the pencil (H,J), but generalized eigenvalues 
%     have a tendency to deflate out in the "desired" order, so work with
%     (J,H) instead
hw = ctrlMsgUtils.SuspendWarnings; 
RealFlag = isreal(H) && isreal(J);
if RealFlag
   [JJ,HH,q,z] = qz(J(perm,perm),H(perm,perm),'real');
else
   [JJ,HH,q,z] = qz(J(perm,perm),H(perm,perm),'complex');
end

% Reorder eigenvalues to push eigenvalues outside the unit circle (inside for (H,J)) to the top
[JJ,HH,~,z(perm,:),Success] = ordqz(JJ,HH,q,z,'udo');
L = ordeig(JJ,HH);
delete(hw)

% Account for non-identity E matrix and orthonormalize basis
if ~isequal(E,eye(n))
   ez1 = E*z(1:n,1:n);
   [q,~] = qr([ez1;z(n+1:n2,1:n)]);
   z = q(:,1:n);
end
X1 = z(1:n,1:n);
X2 = z(n+1:n2,1:n);

% Check that stable invariant subspace was properly extracted
Report = arecheckout(X1,X2,Success,(abs(L)>1));
if Report<0
   X1 = [];  X2 = [];  D = [];  
end
   
% Stable eigenvalues
if RealFlag
   % RE: Last N eigs are inside the unit circle
   L = L(n+1:n2);
else
   % eig(H,J)=[t,1/conj(t)], |t|<1 => L = eig(J,H)=[1/t,conj(t)] 
   %                               => t = conj(L(n+1:2*n))
   L = conj(L(n+1:n2));   
end

% Build output argument list
if FactorFlag
   % X given in implicit form
   varargout = {X1 X2 diag(D) L 0};
else
   % Compute X if requested
   [X,Report] = arefact2x(X1,X2,D,Report);
   varargout = {X L Report};
   
   % Exit errors
   if nargout<=2
      switch Report
         case -1
             ctrlMsgUtils.error('Control:foundation:ARE07')
         case -2
             ctrlMsgUtils.error('Control:foundation:ARE05')
      end
   end  
end
