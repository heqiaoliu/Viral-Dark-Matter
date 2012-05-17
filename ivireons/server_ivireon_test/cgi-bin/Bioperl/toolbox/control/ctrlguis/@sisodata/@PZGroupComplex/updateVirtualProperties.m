function updateVirtualProperties(this)
% UPDATEVIRTUALPROPERTIES Updates virtual properties for complex pzgroup

%   Copyright 1986-2008 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date:  

if isempty(this.Pole) && isempty(this.Zero)
    this.VirtualProperties = [NaN; NaN];
else
    if isempty(this.Pole)
        Location = this.Zero(1);
    else
        Location = this.Pole(1);
    end
    [Wn, Zeta] = damp(Location, this.Parent.Ts);

    this.VirtualProperties = [Zeta; Wn];
end