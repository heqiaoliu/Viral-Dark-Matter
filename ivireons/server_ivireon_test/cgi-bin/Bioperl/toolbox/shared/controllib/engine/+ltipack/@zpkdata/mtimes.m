function D = mtimes(D1,D2,ScalarFlags)
% Multiplies two zpk models D = D1 * D2

%   Copyright 1986-2009 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:47 $
if nargin<3
   ScalarFlags = false(1,2);
end
Ts = D1.Ts;

% Delay management: inner dimension
[Delay,D1,D2,ElimFlag] = mtimesDelay(D1,D2,ScalarFlags);
if ElimFlag
   ctrlMsgUtils.warning('Control:ltiobject:UseSSforInternalDelay')
end

% Perform multiplication
if ScalarFlags(1)
   % Scalar multiplication sys1 * SYS2 with sys1 SISO
   scalz = D1.z{1};
   scalp = D1.p{1};
   [ny,nu] = size(D2.k);
   z = cell(ny,nu);
   p = cell(ny,nu);
   k = D2.k * D1.k;
   for ct=1:ny*nu
      z{ct} = [scalz ; D2.z{ct}];
      p{ct} = [scalp ; D2.p{ct}];
   end
   
elseif ScalarFlags(2)
   % Scalar multiplication SYS1 * sys2 with sys2 SISO
   scalz = D2.z{1};
   scalp = D2.p{1};
   [ny,nu] = size(D1.k);
   z = cell(ny,nu);
   p = cell(ny,nu);
   k = D2.k * D1.k;
   for ct=1:ny*nu
      z{ct} = [D1.z{ct} ; scalz];
      p{ct} = [D1.p{ct} ; scalp];
   end

else
   % Regular multiplication
   [ny,nin] = size(D1.k);
   nu = size(D2.k,2);
   k = zeros(ny,nu);
   z = cell(ny,nu); 
   p = cell(ny,nu); 
   if nin==1
      % Unit inner dimension (SISO products)
      k = D1.k * D2.k;
      for j=1:nu
         for i=1:ny
            z{i,j} = [D1.z{i} ; D2.z{j}];
            p{i,j} = [D1.p{i} ; D2.p{j}];
         end
      end
   else
      % MIMO case: use state space for higher accuracy
      % Note: Use 'generic' flag to bypass common denominator optimization      
      Dss1 = ss(ltipack.zpkdata(D1.z,D1.p,D1.k,Ts),'generic');
      Dss2 = ss(ltipack.zpkdata(D2.z,D2.p,D2.k,Ts),'generic');
      Dss = mtimes(Dss1,Dss2);
      
      % Compute dynamics for each I/O pair
      a = Dss.a;  b = Dss.b;  c = Dss.c;  d = Dss.d;  e = Dss.e;
      xkeep = iosmreal(a,b,c,e);
      eij = [];
      for j=1:nu
         for i=1:ny
            % Include only terms with nonzero product
            nzp = find(D1.k(i,:)~=0 & D2.k(:,j)'~=0);
            if ~isempty(nzp)
               % Expected poles
               pij = cat(1,D1.p{i,nzp},D2.p{nzp,j});
               % Extract s-minimal data for (i,j) pair and compute ZPK data
               xij = find(xkeep(:,i,j));
               if ~isempty(e)
                  eij = e(xij,xij);
               end
               [z{i,j},p{i,j},k(i,j)] = ...
                  utSS2ZPK(a(xij,xij),b(xij,j),c(i,xij),d(i,j),eij,Ts,pij);               
            end
         end
      end
   end
end

% Clean up
zg = find(k==0);
z(zg) = {zeros(0,1)};
p(zg) = {zeros(0,1)};

% Construct output
D = ltipack.zpkdata(z,p,k,Ts);
D.Delay = Delay;
