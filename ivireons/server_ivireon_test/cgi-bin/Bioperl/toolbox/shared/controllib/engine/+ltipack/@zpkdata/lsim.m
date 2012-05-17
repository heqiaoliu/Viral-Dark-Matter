function [y,x] = lsim(D,u,t,x0,InterpRule) %#ok<INUSL>
% Linear response simulation of ZPK models.
% U is assumed to be Ns-by-Nu

%	 Author: P. Gahinet
%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:44 $
x = [];
if D.Ts==0
   y = lsim(ss(D),u,t,[],InterpRule);
else
   z = D.z;
   p = D.p;
   k = D.k;
   % Limit delays to simulation horizon to avoid "out of memory" errors in TFSIM
   ns = size(u,1);
   iod = min(getIODelay(D,'total'),ns);
   % Sort roots to avoid overflow in large models
   for ct=1:numel(k)
      z{ct} = LocalSortRoots(z{ct});
      p{ct} = LocalSortRoots(p{ct});
   end
   InitState = linsimstate('zpk',z,p,iod);
   y = zpksim(z,p,k,iod,u,InitState);
end


function rs = LocalSortRoots(r)
% Puts complex roots upfront
iscplx = (imag(r)~=0);
rs = [r(iscplx) ; r(~iscplx)];
