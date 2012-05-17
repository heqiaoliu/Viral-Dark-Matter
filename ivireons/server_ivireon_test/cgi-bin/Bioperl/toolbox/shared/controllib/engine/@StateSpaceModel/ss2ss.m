function sys = ss2ss(sys,T)
%SS2SS  Change of state coordinates for state-space models.
%
%   SYS = SS2SS(SYS,T) performs the similarity transformation z = Tx on 
%   the state vector x of the state-space model SYS. The resulting 
%   state-space model is described by:
%
%               .       -1        
%               z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u
%
%   or, in the descriptor case,
%
%           -1  .       -1        
%       [TET  ] z = [TAT  ] z + [TB] u
%                       -1
%               y = [CT   ] z + D u  .
%
%   SS2SS is applicable to both continuous- and discrete-time models. 
%   For arrays of state-space models SYS, the transformation T is applied
%   to each individual model in the array.
%
%   See also CANON, BALREAL, SS.

%	 Clay M. Thompson, P. Gahinet
%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:37:37 $
error(nargchk(2,2,nargin))
if numsys(sys)==0
   return
end

% Check dimensions
tsizes = size(T);
if length(tsizes)>2 || tsizes(1)~=tsizes(2),
   ctrlMsgUtils.error('Control:transformation:ss2ss1')
end

% LU decomposition of T
[l,u,p] = lu(T,'vector');

% Perform coordinate transformation
hw = ctrlMsgUtils.SuspendWarnings; %#ok<*NASGU>
try
   sys = ss2ss_(sys,T,l,u,p);
catch E
   ltipack.throw(E,'command','ss2ss',class(sys))
end
hw = [];

% Issue warning if T ill conditioned
if rcond(u)<eps && ~isequal(T,diag(diag(T))),
   ctrlMsgUtils.warning('Control:transformation:Ss2ssAccuracy')
end
