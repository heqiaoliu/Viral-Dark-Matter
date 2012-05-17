function D = times(D1,D2,ScalarFlags)
% Element-by-element multiplication of
% two zpk models D = D1 .* D2

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:58 $
if nargin<3
   ScalarFlags = false(1,2);
end

% Delay management
Delay = timesDelay(D1,D2);

% Perform multiplication (allowing for scalar D1 or D2)
if ScalarFlags(1)
   [ny,nu] = size(D2.k);
else
   [ny,nu] = size(D1.k);
end
z = cell(ny,nu);
p = cell(ny,nu);
k = zeros(ny,nu);
numel1 = numel(D1.k);
numel2 = numel(D2.k);
for ct=1:ny*nu
   idx1 = min(ct,numel1);
   idx2 = min(ct,numel2);
   k(ct) = D1.k(idx1) * D2.k(idx2);
   if k(ct)==0
      z{ct} = zeros(0,1);
      p{ct} = zeros(0,1);
   else
      z{ct} = [D1.z{idx1} ; D2.z{idx2}];
      p{ct} = [D1.p{idx1} ; D2.p{idx2}];
   end
end

D = ltipack.zpkdata(z,p,k,D1.Ts);
D.Delay = Delay;
