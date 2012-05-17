function Value = getValue(this,Format,units)
% GETVALUE sets the value for the pzgroup based on flag
%
% Format = 1; Value = [Real; Imag]; 
% Format = 2; Value = [Zeta, Wn];

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date:  

if (nargin == 1) || (Format == 1);
    if isempty(this.Pole)
        Location = this.Zero(1);
    else
        Location = this.Pole(1);
    end
    Value = [real(Location); imag(Location)];
else
    if nargin < 3
        units.FrequencyUnits = 'rad/s';
    end
    if isempty(this.VirtualProperties)
        this.updateVirtualProperties
    end
    Zeta = this.VirtualProperties(1);
    Wn = this.VirtualProperties(2);

    Value = [Zeta; unitconv(Wn,'rad/s',units.FrequencyUnits)];
end




