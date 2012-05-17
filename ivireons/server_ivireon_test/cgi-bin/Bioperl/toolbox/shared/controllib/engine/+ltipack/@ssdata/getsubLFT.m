function [IC,B] = getsubLFT(IC,B,rowIndex,colIndex,xMinFlag)
% Selects subset of external I/Os in LFT model and eliminates 
% structurally nonminimal blocks and delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:16 $

% States and delays
Delay = IC.Delay;
nfd = length(Delay.Internal);
nx = size(IC.a,1);
xMin = (nargin==5 && xMinFlag);  % eliminate non s-minimal states when true

% Signal dimensions
[rs,cs] = size(IC.d);
[nu,ny] = iosize(B);
nz0 = rs-ny-nfd;  
nw0 = cs-nu-nfd;
nz = length(rowIndex);  
nw = length(colIndex);
nb = numel(B);

% Select I/Os
ix = [reshape(rowIndex,[1 nz]) , nz0+1:rs];
jx = [reshape(colIndex,[1 nw]) , nw0+1:cs];
b = IC.b(:,jx);
c = IC.c(ix,:);
d = IC.d(ix,jx);
Delay.Output = Delay.Output(ix(1:nz+ny),:);
Delay.Input = Delay.Input(jx(1:nw+nu),:); 

% Replace each block by a scalar in IC matrix
ICS = ([IC.a b;c d]~=0);  % D has nz+ny+nfd rows and nw+nu+nfd columns
ir = nx+nz;   ic = nx+nw;
for ct=1:nb
   bs = iosize(B(ct));
   ICS(:,nx+nw+ct) = any(ICS(:,ic+1:ic+bs(1)),2);
   ICS(nx+nz+ct,:) = any(ICS(ir+1:ir+bs(2),:),1);
   ir = ir+bs(2);   ic = ic+bs(1); 
end
[rs,cs] = size(ICS);
ICS(:,ic+1:ic+nfd) = ICS(:,cs-nfd+1:cs);
ICS(ir+1:ir+nfd,:) = ICS(rs-nfd+1:rs,:); 
% D now has nz+nb+nfd rows and nw+nb+nfd columns

% Identify structurally disconnected blocks and delays
if isempty(IC.e)
   E = [];
else
   E = blkdiag(IC.e,eye(nb+nfd));
end
ix = nx+1:nx+nz;  ixc = 1:nx+nz+nb+nfd;  ixc(ix) = [];
jx = nx+1:nx+nw;  jxc = 1:nx+nw+nb+nfd;  jxc(jx) = [];
[~,~,~,~,xbdkeep] = smreal(ICS(ixc,jxc),ICS(ixc,jx),ICS(ix,jxc),E);
xkeep = xbdkeep(1:nx);
bkeep = xbdkeep(nx+1:nx+nb);
dkeep = xbdkeep(nx+nb+1:nx+nb+nfd);

% Eliminate structurally disconnected blocks and delays
[jkeep,ikeep] = getRowColSelection(B,bkeep);
rkeep = false(ny,1);  rkeep(ikeep) = true;  rkeep = [true(nz,1) ; rkeep ; dkeep];
ckeep = false(nu,1);  ckeep(jkeep) = true;  ckeep = [true(nw,1) ; ckeep ; dkeep];
B = B(bkeep);
Delay.Internal = Delay.Internal(dkeep,:);

% Build IC
if xMin
   % Keep only s-minimal states
   IC.a = IC.a(xkeep,xkeep);
   if ~isempty(IC.e)
      IC.e = IC.e(xkeep,xkeep);
   end
   IC.b = b(xkeep,ckeep);
   IC.c = c(rkeep,xkeep);
else
   % Keep all states
   IC.b = b(:,ckeep);
   IC.c = c(rkeep,:);
end
IC.d = d(rkeep,ckeep);
Delay.Output = Delay.Output(rkeep(1:nz+ny),:);
Delay.Input = Delay.Input(ckeep(1:nw+nu),:);
IC.Delay = Delay;
