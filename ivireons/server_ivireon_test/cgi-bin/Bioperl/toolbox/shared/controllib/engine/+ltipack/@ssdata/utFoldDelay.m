function D = utFoldDelay(D,InputDelay,OutputDelay)
% Folds specified subset of input and output delays into
% internal delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:02 $
Delay = D.Delay;

% Process inputs
if isempty(InputDelay)
   InputDelay = zeros(size(Delay.Input));
end
infold = (InputDelay>0); 
nfin = sum(infold);
if isempty(OutputDelay)
   OutputDelay = zeros(size(Delay.Output));
end
outfold = (OutputDelay>0);
nfout = sum(outfold);
if nfin==0 && nfout==0
   return
end

% Sizes
nfd = length(Delay.Internal);
[rs,cs] = size(D.d);
ny = rs-nfd;
nu = cs-nfd;
idxin = 1:nu;
idxout = 1:ny;
nx = size(D.a,1);

% Update delays
% RE: Supports one-shot specification and folding of input or output delays
Delay.Input = max(0,Delay.Input - InputDelay);
Delay.Output = max(0,Delay.Output - OutputDelay);
Delay.Internal = [...
      OutputDelay(outfold) ; ...
      Delay.Internal ; ...
      InputDelay(infold)];

% Assemble D matrix
d = D.d;
% Append columns [d11(:,infold);d21(:,infold)]
d = [d , d(:,idxin(infold))];  
% Insert rows [d11(outfold,:) d12(outfold,:) d11(outfold,infold)]
d = [d(1:ny,:) ; d(idxout(outfold),:) ; d(ny+1:ny+nfd,:)];

% Assemble B and C
b = D.b;
b = [b , b(:,idxin(infold))];
c = D.c;
c = [c(1:ny,:) ; c(idxout(outfold),:); c(ny+1:ny+nfd,:)];

% Account for zero/nonzero pattern in INPUTDELAY
if nfin>0
   % Delta_in
   d(:,idxin(infold)) = 0;
   b(:,idxin(infold)) = 0;
   % Projector Pin
   Pin = eye(nu);  
   Pin = Pin(:,infold);
   d = [d ; [Pin' zeros(nfin,nfd+nfin)]];
   c = [c ; zeros(nfin,nx)];
end

% Account for zero/nonzero pattern in OUTPUTDELAY
if nfout>0
   % Delta_out
   d(idxout(outfold),:) = 0;
   c(idxout(outfold),:) = 0;
   % Projector Pout
   Pout = eye(ny);  
   Pout = Pout(:,outfold);
   d = [d(:,1:nu) [Pout ; zeros(nfd+nfin+nfout,nfout)] d(:,nu+1:end)];
   b = [b(:,1:nu) zeros(nx,nfout) b(:,nu+1:end)];
end

% Update matrices
D.b = b;
D.c = c;
D.d = d;
D.Delay = Delay;


