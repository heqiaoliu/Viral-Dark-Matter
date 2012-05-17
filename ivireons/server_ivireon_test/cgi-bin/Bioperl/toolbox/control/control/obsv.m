function ob = obsv(a,c)
%OBSV  Compute the observability matrix.
%
%   OB = OBSV(A,C) returns the observability matrix [C; CA; CA^2 ...]
%
%   CO = OBSV(SYS) returns the observability matrix of the 
%   state-space model SYS with realization (A,B,C,D).  This is 
%   equivalent to OBSV(sys.a,sys.c).
%
%   For ND arrays of state-space models SYS, OB is an array with N+2
%   dimensions where OB(:,:,j1,...,jN) contains the observability 
%   matrix of the state-space model SYS(:,:,j1,...,jN).  
%
%   See also OBSVF, SS.

%   Thanks to Joseph C. Slater (Wright State University) and
%             Jesse A. Leitner (AFRL/VSSS, USAF)
%   Copyright 1986-2009 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2009/11/09 16:17:45 $
if nargin>0 && ~isnumeric(a)
   ctrlMsgUtils.error('Control:general:NotSupportedModelsofClass','obsv',class(a))
end
error(nargchk(2,2,nargin))

% Dimension checking
n = size(a,1);
ny = size(c,1);
if ~isequal(n,size(a,2),size(c,2)),
   ctrlMsgUtils.error('Control:ltiobject:obsv1')
end

% Allocate OB and compute each C A^k term
ob = zeros(n*ny,n);
ob(1:ny,:) = c;
for k=1:n-1
  ob(k*ny+1:(k+1)*ny,:) = ob((k-1)*ny+1:k*ny,:) * a;
end


