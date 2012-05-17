function setValue(this,Value,Format,units)
% SETVALUE sets the value for the pzgroup based on flag
%
% Format 1 [Wn, ZetaZ, ZetaP]

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date: 2006/01/26 01:46:00 $

if nargin < 4
    units.FrequencyUnits = 'rad/s';
end

Wn = unitconv(Value(1), units.FrequencyUnits, 'rad/s');
Zeta1 = Value(2);
Zeta2 = Value(3);

if abs(Zeta1)>1
    Zeta1= sign(Zeta1);
end

if abs(Zeta2)>1
    Zeta1= sign(Zeta2);
end

ZeroLoc = -Zeta1*Wn + Wn*sqrt(Zeta1^2-1);
ZeroLocation = [ZeroLoc; conj(ZeroLoc)];

PoleLoc = -Zeta2*Wn + Wn*sqrt(Zeta2^2-1);
PoleLocation = [PoleLoc; conj(PoleLoc)];

Ts = this.Parent.Ts;
if Ts ~= 0
    ZeroLocation = exp(ZeroLocation*Ts);
    PoleLocation = exp(PoleLocation*Ts);
end

this.Zero = ZeroLocation;
this.Pole = PoleLocation;
