function Value = getValue(this,Format,units)
% GETVALUE sets the value for the pzgroup based on flag
%
% Format = 1,  Value =  [Wn; Zetaz; Zetap]

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date:  


if nargin < 3
    units.FrequencyUnits = 'rad/s';
end

if isempty(this.VirtualProperties)
    this.updateVirtualProperties;
end
Wn = this.VirtualProperties(1);
ZetaZ = this.VirtualProperties(2);
ZetaP = this.VirtualProperties(3);

Value = [unitconv(Wn,'rad',units.FrequencyUnits); ZetaZ; ZetaP];

