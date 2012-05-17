function addPZ(this,Type,Zeros,Poles)
% Adds new pole/zero group to the TunedZPK.
%

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:29:02 $

if isempty(Zeros)
    PZType = 'Pole';
else
    PZType = 'Zero';
end

if isAddpzAllowed(this,Type,PZType)
    % Create new PZ group
    NewGroup = sisodata.(['PZGroup',Type])(this);
    set(NewGroup,'Zero',Zeros(:),'Pole',Poles(:));

    % Add to groups
    if utIsIntOrDiff(NewGroup,this.Ts)
        % Prevent jumps when integrators or differentiators are deleleted
        k = this.getZPKGain;
        this.PZGroup = [this.PZGroup ; NewGroup];
        this.setZPKGain(k);
    else
        this.PZGroup = [this.PZGroup ; NewGroup];
    end
else
    ctrlMsgUtils.error('Control:compDesignTask:addPZ')
end