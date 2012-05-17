function vint = interpresp(tint,D,t,v,vL1,vL3)
% Copyright 2003-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:32:18 $

% Lagrange interp between major time steps
L1 = 1.726731646460115e-001; % (1 - sqrt(3/7))/2
L3 = 8.273268353539885e-001; % (1 + sqrt(3/7))/2
L31 = 6.546536707079771e-001; % sqrt(3/7);  % L3-L1
fact = 1+100*eps;
nt = length(t);

lint = length(tint);
vint = zeros(size(v,1),lint);
ndx = 1;
for i = 1:lint
   arg = tint(i);
   if arg<D(1)   
      vint(:,i) = v(:,1);
   elseif arg==D(1)
      % Make sure to grab y(0+) when D(1)==0
      vint(:,i) = v(:,1+(t(2)==D(1)));
   else   
      % Compute ndx = first index s.t. t(ndx) >= arg.
      % Uses fact that tint is in increasing order.
      arg = fact * arg;  % make sure to robustly evaluate at tjump+, see g341405
      while arg>t(ndx) && ndx<nt
         ndx = ndx+1;
      end
      t1 = t(ndx-1);
      t4 = t(ndx);
      h = t4-t1;
      arg1 = arg - t1;
      arg2 = arg1 - L1*h;  % arg - t2;
      arg3 = arg1 - L3*h;  % arg - t3;
      arg4 = arg - t4;
      aux12 = (arg1/L31) * vL1(:,ndx-1) - arg2 * v(:,ndx-1);
      aux34 = (arg4/L31) * vL3(:,ndx-1) - arg3 * v(:,ndx);
      vint(:,i) = 7 * ( arg3*arg4*aux12 - arg1*arg2*aux34 ) / (h*h*h);  % L1*L3 = 1/7
   end    
end

