function D = simplifyDelay(D)
% Replaces internal delays by input or output delays
% when possible.

%   Author(s): P. Gahinet
%   Copyright 1986-2005 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:31:40 $
Delay = D.Delay;
nfd = length(Delay.Internal);
if nfd>0
   % Data and size info
   a = D.a;  b = D.b;  c = D.c;  d = D.d;
   [nr,nc] = size(d);
   nu = nc-nfd;
   ny = nr-nfd;
   nx = size(a,1);

   % Determine which subset of delays affect each I/O pair
   if isempty(D.e)
      E = [];
   else
      E = blkdiag(D.e,eye(nfd));
   end
   xdkeep = iosmreal(...
      [a b(:,nu+1:nc);c(ny+1:nr,:) d(ny+1:nr,nu+1:nc)],...
      [b(:,1:nu) ; d(ny+1:nr,1:nu)],[c(1:ny,:) , d(1:ny,nu+1:nc)] , E);
   dkeep = permute(xdkeep(nx+1:nx+nfd,:,:),[2 3 1]);

   % Analyze zero entry structure of H22
   xkeep = iosmreal(a,b(:,nu+1:nc),c(ny+1:nr,:),D.e);
   zH22 = (d(ny+1:nr,nu+1:nc)==0 & reshape(~any(xkeep,1),[nfd nfd]));
   isZeroRowCol = all(zH22,1)' | all(zH22,2);

   % Potential input or output delays should affect only one row or
   % one column of H(s,tau), and correspond to a zero row or column
   % in H22
   AffectsColumn = any(dkeep,1);
   nAC = sum(AffectsColumn,2);
   isInputDelay = (nAC(:)==1 & isZeroRowCol);
   AffectsRow = any(dkeep,2);
   nAR = sum(AffectsRow,1);
   isOutputDelay = (nAR(:)==1 & isZeroRowCol);

   % For each candidate input delay, H(:,j) = H0(:,j) + exp(-s*tau_k) Delta(s).
   % Check that H0(:,j) is structurally zero
   iInput = find(isInputDelay);
   for ct=1:length(iInput)
      k = iInput(ct);                 % delay index
      j = find(AffectsColumn(:,:,k)); % input channel it affects
      kbar = 1:nfd;   kbar(k) = [];
      if all(d(1:ny,j)==0)
         [A,B,C,junk,xdkeep] = smreal([a b(:,nu+kbar);c(ny+kbar,:) d(ny+kbar,nu+kbar)],...
            [b(:,j) ; d(ny+kbar,j)],[c , d(:,nu+kbar)] , E);
      else
         xdkeep = true;
      end
      isInputDelay(k) = ~any(xdkeep);
   end

   % For each candidate output delay, H(i,:) = H0(i,:) + exp(-s*tau_k) Delta(s).
   % Check that H0(i,:) is structurally zero
   iOutput = find(isOutputDelay);
   for ct=1:length(iOutput)
      k = iOutput(ct);             % delay index
      i = find(AffectsRow(:,:,k)); % output channel it affects
      kbar = 1:nfd;   kbar(k) = [];
      if all(d(i,1:nu)==0)
         [A,B,C,junk,xdkeep] = smreal([a b(:,nu+kbar);c(ny+kbar,:) d(ny+kbar,nu+kbar)],...
            [b ; d(ny+kbar,:)],[c(i,:) , d(i,nu+kbar)] , E);
      else
         xdkeep = true;
      end
      isOutputDelay(k) = ~any(xdkeep);
   end

   % Transfer validated candidates from internal delays from input and output delays
   iInput = find(isInputDelay);
   for ct=1:length(iInput)
      k = iInput(ct);
      j = find(AffectsColumn(:,:,k));
      Delay.Input(j) = Delay.Input(j) + Delay.Internal(k);
      Delay.Internal(k) = 0;
   end
   iOutput = find(isOutputDelay);
   for ct=1:length(iOutput)
      k = iOutput(ct);
      i = find(AffectsRow(:,:,k));
      Delay.Output(i) = Delay.Output(i) + Delay.Internal(k);
      Delay.Internal(k) = 0;
   end

   % Eliminate zero internal delays
   if any(Delay.Internal==0)
      D.Delay = Delay;
      D = elimZeroDelay(D);
   end
end  % simplifyDelay
