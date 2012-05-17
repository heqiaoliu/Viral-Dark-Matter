function blocks=GetBlocks(h,Selected)
% GETBLOCKS returns the start and stop indices of blocks within a
% continuous integer vctor.  Block is separated by discontiuity

% Author: Rong Chen 
% Revised: 
% Copyright 1986-2004 The MathWorks, Inc.

if isempty(Selected)
    blocks=[];
    return
end
tmp=1:length(Selected);
index=diff(Selected);
breakpoint=Selected(index~=1);
tmp=tmp(index~=1);
k=1;
if length(breakpoint)>0
    j=1;
    for i=1:length(breakpoint)
        blocks(k,1)=Selected(j);
        blocks(k,2)=breakpoint(i);
        j=tmp(i)+1;
        k=k+1;
    end
    blocks(k,1)=Selected(j);
    blocks(k,2)=Selected(end);
else
    blocks(k,1)=Selected(1);
    blocks(k,2)=Selected(end);
end
