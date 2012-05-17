function [B,rkeep,ckeep,bkeep] = smblock(IC,B,nz,nw)
%SMBLOCK   Eliminates structurally non-minimal blocks in static LFT model.
%
%   SMBLOCK eliminates the blocks that do not contribute to the static LFT 
%   model M = lft(IC,B). NZ and NW are the numbers of rows and columns in M.
%   The reduced model is 
%      M = lft(IC(rkeep,bkeep),B(bkeep))
%   where BKEEP is a logical vector with as many entries as blocks in B 
%   (taking repetitions into account) that flags which blocks are kept 
%   (true) and which blocks are eliminated (false).

%   Author(s): P. Gahinet
%   Copyright 1986-2010 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2010/02/08 22:46:45 $
[rs,cs] = size(IC);
nu = cs-nw;   ny = rs-nz;
nb = numel(B);

% Identify structurally disconnected blocks
ICS = (IC~=0);
ir = nz;   ic = nw;
for ct=1:nb
   bs = iosize(B(ct));
   ICS(:,nw+ct) = any(ICS(:,ic+1:ic+bs(1)),2);
   ICS(nz+ct,:) = any(ICS(ir+1:ir+bs(2),:),1);
   ir = ir+bs(2);   ic = ic+bs(1); 
end
[~,~,~,~,bkeep] = smreal(ICS(nz+1:nz+nb,nw+1:nw+nb),ICS(nz+1:nz+nb,1:nw),...
   ICS(1:nz,nw+1:nw+nb),[]);

% Eliminate structurally disconnected blocks
[jkeep,ikeep] = getRowColSelection(B,bkeep);
rkeep = false(ny,1);  rkeep(ikeep) = true;  rkeep = [true(nz,1) ; rkeep];
ckeep = false(nu,1);  ckeep(jkeep) = true;  ckeep = [true(nw,1) ; ckeep];
B = B(bkeep,:);
