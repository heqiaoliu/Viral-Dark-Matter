function D = times(D1,D2,ScalarFlags)
% Element-by-element multiplication of
% two transfer functions D = D1 .* D2

%   Copyright 1986-2007 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:04 $
if nargin<3
   ScalarFlags = false(1,2);
end

% Delay management
Delay = timesDelay(D1,D2);

% Perform multiplication (allowing for scalar D1 or D2)
if ScalarFlags(1)
   [ny,nu] = size(D2.num);
else
   [ny,nu] = size(D1.num);
end
num = cell(ny,nu);
den = cell(ny,nu);
numel1 = numel(D1.num);
numel2 = numel(D2.num);
for ct=1:ny*nu
   idx1 = min(ct,numel1);
   idx2 = min(ct,numel2);
   nct = conv(D1.num{idx1},D2.num{idx2});
   if ~any(nct)
      num{ct} = 0;  den{ct} = 1;
   else
      num{ct} = nct;
      den{ct} = conv(D1.den{idx1},D2.den{idx2});
   end
end

% Eliminate leading zeros generated, e.g., in s*1/s
[num,den] = utRemoveLeadZeros(num,den);

D = ltipack.tfdata(num,den,D1.Ts);
D.Delay = Delay;
