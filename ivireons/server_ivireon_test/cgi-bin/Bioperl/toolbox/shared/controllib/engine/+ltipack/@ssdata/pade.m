function D = pade(D,Ni,No,Nf)
% Pade approximation of delays in state-space models.

%   Author(s): P. Gahinet
%   Copyright 1986-2008 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:33 $
Delay = D.Delay;
if all(Delay.Input==0) && all(Delay.Output==0) && isempty(Delay.Internal)
   % watch for all zero internal delays
   return
end

% Check arguments
[Ni,No,Nf] = checkPadeOrders(D,Ni,No,Nf);
ny = length(No);
nu = length(Ni);

% Approximate internal delays
% NOTE: This may increase the order or produce a NaN model if approximation
% leads to singular algebraic loops 
if all(Nf==0)
   % Optimized code for zero-order approximation
   ndx = length(Nf);
   if ndx>0
      Dx = ltipack.ssdata([],zeros(0,ndx),zeros(ndx,0),eye(ndx),[],0);
      D.Delay.Internal = zeros(0,1);
      D.Delay.Input(nu+ndx,1) = 0;
      D.Delay.Output(ny+ndx,1) = 0;
      D = lft(D,Dx,nu+1:nu+ndx,ny+1:ny+ndx,1:ndx,1:ndx);
   end
else
   isAppx = isfinite(Nf);
   idx = find(isAppx);  % internal delays to be approximated
   ndx = length(idx);
   dperm = [idx ; find(~isAppx)];
   if ndx>0
      % Approximate specified delays
      Dx = LocalPadeAppx(Delay.Internal(idx),Nf(idx));
      % Push non-appx delays to last row/columns of D.d
      yperm = [(1:ny).' ; ny+dperm];
      uperm = [(1:nu).' ; nu+dperm];
      D.b = D.b(:,uperm);
      D.c = D.c(yperm,:);
      D.d = D.d(yperm,uperm);
      D.Delay.Internal(idx,:) = [];
      D.Delay.Input(nu+ndx,1) = 0;
      D.Delay.Output(ny+ndx,1) = 0;
      D = lft(D,Dx,nu+1:nu+ndx,ny+1:ny+ndx,1:ndx,1:ndx);
   end
end

% Approximate input delays
InputDelay = Delay.Input;
idx = find(isfinite(Ni) & InputDelay>0);
if ~isempty(idx)
   if any(Ni(idx)>0)
      D.Delay.Input(:) = 0;
      Ni(isinf(Ni)) = 0;
      D = mtimes(D,LocalPadeAppx(InputDelay,Ni));
   end
   InputDelay(idx,:) = 0;
   D.Delay.Input = InputDelay;
end

% Approximate output delays
OutputDelay = Delay.Output;
idx = find(isfinite(No) & OutputDelay>0);
if ~isempty(idx)
   if any(No(idx)>0)
      D.Delay.Output(:) = 0;
      No(isinf(No)) = 0;
      D = mtimes(LocalPadeAppx(OutputDelay,No),D);
   end
   OutputDelay(idx,:) = 0;
   D.Delay.Output = OutputDelay;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Dx = LocalPadeAppx(Delays,Nappx)
% Pade approximation of a vector of delays
n = length(Nappx);
a = []; b = []; c = []; d = [];
for ct=1:n
   if Delays(ct)>0 && Nappx(ct)>0
      [ax,bx,cx,dx] = pade(Delays(ct),Nappx(ct));
      a = blkdiag(a,ax);
      b = blkdiag(b,bx);
      c = blkdiag(c,cx);
      d = blkdiag(d,dx);
   else
      nx = size(a,1);
      b = [b , zeros(nx,1)]; %#ok<AGROW>
      c = [c ; zeros(1,nx)]; %#ok<AGROW>
      d = blkdiag(d,1);
   end
end
Dx = ltipack.ssdata(a,b,c,d,[],0);

