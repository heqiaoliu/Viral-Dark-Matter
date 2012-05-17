function deletePZ(this,PZGroup)
%DELETEPZ  Deletes a new pole/zero group of the TunedZPK

%   Author(s): C. Buhr
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.4 $ $Date: 2007/12/14 14:29:03 $

if isDeletePZAllowed(this, PZGroup)
    isel = find(PZGroup == this.PZGroup);
    
    % delete from groups
    if utIsIntOrDiff(PZGroup,this.Ts) 
        % Prevent jumps when integrators or differentiators are deleleted
        k = this.getZPKGain;
        delete(this.PZGroup(isel));
        this.PZGroup = this.PZGroup([1:isel-1,isel+1:end],:);
        this.setZPKGain(k);
    else
        delete(this.PZGroup(isel));
        this.PZGroup = this.PZGroup([1:isel-1,isel+1:end],:);
    end
else 
        ctrlMsgUtils.error('Control:compDesignTask:deletePZ')
end