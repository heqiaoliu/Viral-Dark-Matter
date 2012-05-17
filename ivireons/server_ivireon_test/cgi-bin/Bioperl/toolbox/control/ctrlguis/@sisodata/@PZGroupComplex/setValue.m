function setValue(this,Value,Format,units)
% SETVALUE sets the value for the pzgroup based on Format
%
% Format = 1; Value = [Real; Imag]; 
% Format = 2; Value = [Zeta, Wn];

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2005/12/22 17:39:15 $

if Format == 1
    R = Value(1);
    I = Value(2);
    if isempty(this.Pole)
        this.Zero = [R+i*I; R-i*I];
    else
        this.Pole =  [R+i*I; R-i*I];
    end
else
    Zeta = Value(1);
    if abs(Zeta)>1
        Zeta = sign(Zeta);
    end
    if nargin < 4
        units.FrequencyUnits = 'rad/s';
    end
    Wn = unitconv(Value(2), units.FrequencyUnits, 'rad/s');
    Loc = -Zeta*Wn + Wn*sqrt(Zeta^2-1);
    Location = [Loc; conj(Loc)];
    
    Ts = this.Parent.Ts;
    if Ts ~= 0
        Location = exp(Location*Ts);
    end
    
    if isempty(this.Pole)
        this.Zero = Location;
    else
        this.Pole = Location;
    end
    
end
        