function Value = getValue(this,Format,units)
% GETVALUE sets the value for the pzgroup based on flag
%
% Format = 1,  Value =  [zero;pole]
% Format = 2,  Value =  [PhaseMax;Wmax]

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.2 $  $Date:  

if (nargin == 1) || (Format == 1)
    Value = [this.Zero; this.Pole];
else
    if nargin < 3
        units.FrequencyUnits = 'rad/s';
        units.PhaseUnits = 'rad';
    end
    
    if isempty(this.VirtualProperties)
        this.updateVirtualProperties;
    end
    PhaseMax = this.VirtualProperties(1);
    Wmax = this.VirtualProperties(2);
    
    Value = [unitconv(PhaseMax,'rad',units.PhaseUnits); ...
             unitconv(Wmax,'rad/s',units.FrequencyUnits)];
end
