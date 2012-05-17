function updateVirtualProperties(this)
% UPDATEVIRTUALPROPERTIES for LeadLag

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date:  

if isempty(this.Pole) || isempty(this.Zero)
    this.VirtualProperties = [NaN; NaN];
else

    Ts = this.Parent.Ts;
    if (Ts == 0)
        ZeroLocation = this.Zero;
        PoleLocation = this.Pole;
    else
        % discrete case
        ZeroLocation = log(this.Zero)/Ts;
        PoleLocation = log(this.Pole)/Ts;
    end

    % Calculate the maximum phase addition from lead/lag and freq
    % at which it occurs
    alpha = ZeroLocation/PoleLocation;
    PhaseMax = asin((1-alpha)/(1+alpha));
    Wmax = -ZeroLocation/sqrt(alpha);
    this.VirtualProperties = [PhaseMax;Wmax];
end