function sys = ss2ss(sys,T)
%SS2SS  Change of state coordinates for state-space models.
%
%   MOD = SS2SS(SYS,T) performs the similarity transformation 
%   z = Tx on the state vector x of the state-space model SYS.  
%   The resulting state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u + [TK] e
%                       -1
%               y = [CT   ] z + D u + e
%
%
%   SS2SS is applicable to both continuous- and discrete-time 
%   models.
%
%   Covariance information is lost in the transformation.

%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2008/10/02 18:49:35 $

error(nargchk(2,2,nargin,'struct'))

% Check dimensions
 [A,B,C,D,K,X0] = ssdata(sys);
asizes = size(A);  Nx = asizes(1);
tsizes = size(T);
if length(tsizes)>2 || tsizes(1)~=tsizes(2),
   ctrlMsgUtils.error('Ident:transformation:ss2ssCheck1')
elseif Nx~=tsizes(1),
   ctrlMsgUtils.error('Ident:transformation:ss2ssCheck2')
end

% LU decomposition of T
[l,u,p] = lu(T);
if rcond(u)<eps,
   ctrlMsgUtils.error('Ident:transformation:ss2ssCheck1')
end

% Perform coordinate transformation
 
 sys = pvset(sys,'A',T*((A/u)/l)*p,'B',T*B,'K',T*K,'X0',T*X0,...
	     'C',((C/u)/l)*p);
 
  sys.As = T*((sys.As/u)/l)*p;
   sys.Bs = T*sys.Bs;
   sys.Ks = T*sys.Ks;
   sys.Cs = ((sys.Cs/u)/l)*p;
   sys.X0s = T*sys.X0s;
 
%sys.StateName(1:Nx) = {''};
