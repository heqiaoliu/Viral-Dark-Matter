function boo = isstable(D,tol)
% Returns 0 for stable, 1 for unstable, and NaN 
% when stability cannot be determined analytically.

%   Copyright 1986-2006 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:21 $
if nargin==1
   tol = 0;
end

if hasDelayDynamics(D,'pole')
   boo = NaN;
else
   % Compute poles (A unchanged by delays)
   p = pole(D);
   if D.Ts==0
      boo = all(real(p)<-tol*(1+abs(p)));
   else
      boo = all(abs(p)<1-tol);
   end
   boo = double(boo);
end
