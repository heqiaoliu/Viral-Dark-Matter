function [IC,B] = getsubLFT(IC,B,rowIndex,colIndex,~)
% Selects subset of external I/Os in LFT model and eliminates 
% structurally nonminimal blocks and delays.

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.2 $  $Date: 2010/03/31 18:36:10 $
Delay = IC.Delay;

% Signal dimensions
[rs,cs,~] = size(IC.Response);
[nu,ny] = iosize(B);
nz0 = rs-ny;  nw0 = cs-nu;
nz = length(rowIndex);  
nw = length(colIndex);
nb = numel(B);

% Select I/Os
ix = [reshape(rowIndex,[1 nz]) , nz0+1:rs];
jx = [reshape(colIndex,[1 nw]) , nw0+1:cs];
R = IC.Response(ix,jx,:);
Delay.Output = Delay.Output(ix,:);
Delay.Input = Delay.Input(jx,:); 
Delay.IO = Delay.IO(ix,jx); 

% Replace each block by a scalar in IC matrix
ICS = any(R~=0,3);  % ICS has nz+ny rows and nw+nu columns
ir = nz;   ic = nw;
for ct=1:nb
   bs = iosize(B(ct));
   ICS(:,nw+ct) = any(ICS(:,ic+1:ic+bs(1)),2);
   ICS(nz+ct,:) = any(ICS(ir+1:ir+bs(2),:),1);
   ir = ir+bs(2);   ic = ic+bs(1); 
end
% ICS now has nz+nb rows and nw+nb columns

% Identify structurally disconnected blocks
[~,~,~,~,bkeep] = smreal(ICS(nz+1:nz+nb,nw+1:nw+nb),ICS(nz+1:nz+nb,1:nw),ICS(1:nz,nw+1:nw+nb),[]);

% Eliminate structurally disconnected blocks
[jkeep,ikeep] = getRowColSelection(B,bkeep);
rkeep = false(ny,1);  rkeep(ikeep) = true;  rkeep = find([true(nz,1) ; rkeep]);
ckeep = false(nu,1);  ckeep(jkeep) = true;  ckeep = find([true(nw,1) ; ckeep]);
B = B(bkeep);
IC.Response = R(rkeep,ckeep,:);
Delay.Output = Delay.Output(rkeep,:);
Delay.Input = Delay.Input(ckeep,:); 
Delay.IO = Delay.IO(rkeep,ckeep); 
IC.Delay = Delay;
