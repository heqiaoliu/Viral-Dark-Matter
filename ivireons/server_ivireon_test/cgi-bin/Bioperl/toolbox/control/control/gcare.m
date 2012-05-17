function varargout = gcare(H,varargin)
%GCARE  Generalized solver for continuous algebraic Riccati equations.
%
%   [X,L] = GCARE(H,J,NS) computes the unique stabilizing solution
%   X of the continuous-time algebraic Riccati equation associated 
%   with Hamiltonian pencils of the form
% 
%                  [  A     F     S1 ]       [  E   0   0 ]
%      H - t J  =  [  G    -A'   -S2 ]  - t  [  0   E'  0 ]
%                  [ S2'   S1'     R ]       [  0   0   0 ]
% 
%   where F,G,R are symmetric matrices. The optional input NS is 
%   the row size of the A matrix. Omitting NS amounts to setting 
%   R=[] and omitting J amounts to setting E=I. The output L is
%   the vector of closed-loop eigenvalues.
%
%   [X,L,REPORT] = GCARE(H,J,NS) suppresses errors when X fails
%   to exist. The diagnosis REPORT is set to:
%     * -1 when the Hamiltonian pencil has jw-axis eigenvalues
%     * -2 when there is no finite stabilizing solution X
%     * 0 when a finite stabilizing solution X exists.
%
%   [X1,X2,D,L] = GCARE(H,...,'factor') returns two matrices X1, X2 
%   and a diagonal scaling matrix D such that X = D*(X2/X1)*D.
%   The vector L contains the closed-loop eigenvalues.  All outputs 
%   are empty when the associated Hamiltonian matrix has eigenvalues 
%   on the imaginary axis.
%
%   [...] = GCARE(H,...,'nobalance') disables automatic scaling of 
%   the data.
%
%   See also CARE, GDARE.

%   Author(s): Pascal Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.11 $ $Date: 2009/08/08 01:08:19 $

% Flags
idx1 = find(strcmp(varargin,'factor'));
FactorFlag = (~isempty(idx1));
idx2 = find(strcmp(varargin,'nobalance'));
NoBalanceFlag = (~isempty(idx2));

% J and NS
varargin(:,[idx1,idx2]) = [];
nextra = length(varargin);
if nextra<1
   J = [];
else
   J = varargin{1};
end
if nextra<2
   n = size(H,1)/2;
   if n~=round(n)
       ctrlMsgUtils.error('Control:foundation:ARE11')
   end
else
   n = varargin{2};
end

% Error checks
n2 = 2*n;
m = size(H,1)-n2;
if m<0
   ctrlMsgUtils.error('Control:foundation:ARE13','gcare')
elseif ~isempty(J) && ~isequal(size(H),size(J))
   ctrlMsgUtils.error('Control:foundation:ARE10','gcare')
elseif isempty(J) && m>0
   % Must go to pencil because of compression step
   J = blkdiag(eye(n2),zeros(m));
end

% Check Hamiltonian structure: S*H should be symmetric,
% S*J should be skew-symmetric, and the last m columns of
% J should be zero
SH = [-H(n+1:n2,:) ; H(1:n,:) ; H(n2+1:n2+m,:)];
BadStruct = (abs(SH-SH') > 100*eps*abs(SH));
if ~isempty(J)
   SJ = [-J(n+1:n2,:) ; J(1:n,:) ; J(n2+1:n2+m,:)];
   BadStruct = BadStruct | (abs(SJ+SJ') > 100*eps*abs(SJ));
end
if any(BadStruct(:)) || norm(J(:,n2+1:end),1) > 0
   ctrlMsgUtils.error('Control:foundation:ARE12','gcare','gcare')
end

% Scale Hamiltonian matrix/pencil (D = state matrix scaling)
% RE: Before compression to preserve Hamiltonian structure
if NoBalanceFlag
   D = ones(n,1);  perm = 1:n2;
else
   [H,J,D,perm] = arescale(H,J,n);
end

% Grab E matrix
if ~isempty(J)
   E = J(1:n,1:n);
end

% Compression step on H(:,n2+1:n2+m) = [S1;-S2;R]
if m>0
   [q,r] = qr(H(:,n2+1:n2+m)); %#ok<NASGU>
   H = q(:,m+1:n2+m)'*H(:,1:n2);
   J = q(1:n2,m+1:n2+m)'*J(1:n2,1:n2);
end

% Solve equation
hw = ctrlMsgUtils.SuspendWarnings; 
if isempty(J)
   % Hamiltonian matrix
   % RE: Apply triangularizing permutation to enhance SCHUR numerics (g147863)
   if isreal(H)
      [z,t] = schur(H(perm,perm),'real');
   else
      [z,t] = schur(H(perm,perm),'complex');
   end
   
   % Reorder eigenvalues to push stable eigenvalues to the top
   [z(perm,:),t,Success] = ordschur(z,t,'lhp');
   L = ordeig(t);
     
else
   % Hamiltonian pencil
   % Use QZ algorithm to deflate pencil
   if isreal(H) && isreal(J)
      [HH,JJ,q,z] = qz(H(perm,perm),J(perm,perm),'real');
   else
      [HH,JJ,q,z] = qz(H(perm,perm),J(perm,perm),'complex');
   end
   
   % Reorder eigenvalues to push stable eigenvalues to the top
   [HH,JJ,~,z(perm,:),Success] = ordqz(HH,JJ,q,z,'lhp');
   L = ordeig(HH,JJ);
   
   % Account for non-identity E matrix and orthonormalize basis
   if ~isequal(E,eye(n))
      ez1 = E*z(1:n,1:n);
      [q,~] = qr([ez1;z(n+1:n2,1:n)]);
      z = q(:,1:n);
   end

end
delete(hw)
X1 = z(1:n,1:n);
X2 = z(n+1:n2,1:n);

% Check that stable invariant subspace was properly extracted
% RE: Lack of symmetry in X1'*X2 indicates that a stable invariant subspace of 
%     dimension n could not be reliably isolated
Report = arecheckout(X1,X2,Success,(real(L)<0));   
if Report<0
   X1 = [];  X2 = [];  D = [];  
end

% Build output argument list
L = L(1:n);
if FactorFlag
   varargout = {X1 X2 diag(D) L Report};
else
   % Compute X if requested
   [X,Report] = arefact2x(X1,X2,D,Report);
   varargout = {X L Report};
   
   % Exit errors
   if nargout<=2
      switch Report
         case -1
             ctrlMsgUtils.error('Control:foundation:ARE06')
         case -2
             ctrlMsgUtils.error('Control:foundation:ARE05')
      end
   end  
end



