function co = ctrb(a,b)
%CTRB  Compute the controllability matrix.
%
%   CO = CTRB(A,B) returns the controllability matrix [B AB A^2B ...].
%
%   CO = CTRB(SYS) returns the controllability matrix of the 
%   state-space model SYS with realization (A,B,C,D).  This is
%   equivalent to CTRB(sys.a,sys.b).
%
%   For ND arrays of state-space models SYS, CO is an array with N+2
%   dimensions where CO(:,:,j1,...,jN) contains the controllability 
%   matrix of the state-space model SYS(:,:,j1,...,jN).  
%
%   See also CTRBF, SS.

%   Thanks to Joseph C. Slater (Wright State University) and
%             Jesse A. Leitner (AFRL/VSSS, USAF)
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2009/11/09 16:17:43 $
if nargin>0 && ~isnumeric(a)
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','ctrb',class(a))
end
error(nargchk(2,2,nargin))

% Dimension checking
n = size(a,1);
nu = size(b,2);
if ~isequal(n,size(a,2),size(b,1)),
    ctrlMsgUtils.error('Control:ltiobject:ctrb1')
end

% Allocate CO and compute each A^k B term
co = zeros(n,n*nu);
co(:,1:nu) = b;
for k=1:n-1
  co(:,k*nu+1:(k+1)*nu) = a * co(:,(k-1)*nu+1:k*nu);
end
