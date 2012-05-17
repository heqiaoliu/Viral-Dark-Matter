function D = mtimes(D1,D2,ScalarFlags)
% Multiplies two transfer functions D = D1 * D2

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:52 $
if nargin<3
   ScalarFlags = false(1,2);
end

% Delay management: inner dimension
[Delay,D1,D2,ElimFlag] = mtimesDelay(D1,D2,ScalarFlags);
if ElimFlag
   ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
end

% Perform multiplication
if ~any(ScalarFlags)
   % Regular multiplication
   ny = size(D1.num,1);
   [nin,nu] = size(D2.num);
   num = cell(ny,nu);
   den = cell(ny,nu);
   for j=1:nu
      for i=1:ny
         nij = 0;
         dij = 1;
         % Evaluate sum of D1(i,k)*D2(k,j) for k=1:m1
         for m=1:nin,
            [nij,dij] = utAddSISO(nij,dij,...
               conv(D1.num{i,m},D2.num{m,j}),...
               conv(D1.den{i,m},D2.den{m,j}));
         end
         num{i,j} = nij;
         den{i,j} = dij;
      end
   end
   
elseif ScalarFlags(1)
   % Scalar multiplication sys1 * SYS2 with sys1 SISO
   scalnum = D1.num{1};
   scalden = D1.den{1};
   [ny,nu] = size(D2.num);
   num = cell(ny,nu);
   den = cell(ny,nu);
   for ct=1:ny*nu
      nct = conv(scalnum,D2.num{ct});
      if ~any(nct)
         num{ct} = 0;  den{ct} = 1;
      else
         num{ct} = nct;
         den{ct} = conv(scalden,D2.den{ct});
      end
   end
      
else
   % Scalar multiplication SYS1 * sys2 with sys2 SISO
   scalnum = D2.num{1};
   scalden = D2.den{1};
   [ny,nu] = size(D1.num);
   num = cell(ny,nu);
   den = cell(ny,nu);
   for ct=1:ny*nu
      nct = conv(scalnum,D1.num{ct});
      if ~any(nct)
         num{ct} = 0;  den{ct} = 1;
      else
         num{ct} = nct;
         den{ct} = conv(scalden,D1.den{ct});
      end
   end

end

% Eliminate leading zeros generated, e.g., in s*1/s
[num,den] = utRemoveLeadZeros(num,den);

D = ltipack.tfdata(num,den,D1.Ts);
D.Delay = Delay;
