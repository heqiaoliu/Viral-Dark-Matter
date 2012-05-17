function [y,ti,x] = mergeresp(Sol,tau_out,D,t,Tfocus,refine)
%   Copyright 2003-2009 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $ $Date: 2009/11/09 16:32:20 $
ny = length(tau_out);
nu = length(Sol);

% Compute max settling time and min final time
Tf = Inf;  Tset = 0;
for j=1:nu
   st = Sol(j).t;
   sy = Sol(j).y;
   Tf = min(Tf,st(end));
   for i=1:ny
      dy = abs(sy(i,:) - sy(i,end));
      Tset = max([Tset st(find(dy>0.01*max(dy),1,'last'))]);
   end
end
Tset = max(Tset,Tfocus/4);

% Pick final time grid
if isempty(t)
   % Separate points of D and interpolate there to
   % get sharp corners in the graph.
   del = 1e-6*Tf;
   tmpD = [(D(1:end-1)-del) (D(1:end-1)+del)];
   % Now account for delays in the components of y
   ti = zeros(1,0);
   for j=1:ny
      ti = [ti (tmpD+tau_out(j))]; %#ok<AGROW>
   end
   ti = ti(ti>=0 & ti<=Tf);

   % How many mesh points in the various integrations?
   ntmp = 0;
   for j=1:nu
      ntmp = max(ntmp,length(Sol(j).t));
   end
   if nargin>5
      ntmp = (refine + 1)*ntmp;
   end
   if Tset>0
      ti = [ti linspace(0,Tset,max(150,round(ntmp*Tset/Tf)))];
   end
   if Tf>Tset
      ti = [ti linspace(Tset,Tf,round(50*(1-Tset/Tf)))];
   end 
   ti = sort(ti);
   ti = ti([true,abs(diff(ti))>10*eps*abs(ti(2:end))]).';
else
   % User-defined grid
   ti = t;
end

% Interpolate y
y = zeros(length(ti),ny,nu);
for j=1:nu
   st = Sol(j).t;
   sy = Sol(j).y;
   syL1 = Sol(j).yL1;
   syL3 = Sol(j).yL3;
   for i=1:ny
      % Get y_j(t - tau_out(j)).
      y(:,i,j) = interpresp(ti-tau_out(i),D,st,sy(i,:),syL1(i,:),syL3(i,:));
   end
end

if nargout > 2
   x = cell(1,nu);
   for j=1:nu
      xtmp = interpresp(ti,D,Sol(j).t,Sol(j).x,Sol(j).xL1,Sol(j).xL3);
      x(j) = {xtmp};
   end
   x = x';
end
