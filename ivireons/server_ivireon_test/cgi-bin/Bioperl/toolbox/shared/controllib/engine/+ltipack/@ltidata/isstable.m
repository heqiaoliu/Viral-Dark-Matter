function boo = isstable(D,tol)
% Returns 0 for stable, 1 for unstable, and NaN for "don't know"

%   Copyright 1986-2005 The MathWorks, Inc. 
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:30:20 $
if nargin==1
   tol = 0;
end
% Compute poles
p = pole(D,'fast');
% Test for stability
if D.Ts==0
   boo = all(real(p)<-tol*(1+abs(p)));
else
   boo = all(abs(p)<1-tol);
end
boo = double(boo);