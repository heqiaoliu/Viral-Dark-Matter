function Value = getValue(this,Format,units)
% GETVALUE sets the value for the pzgroup
%

%   Copyright 1986-2005 The MathWorks, Inc. 
%   $Revision: 1.1.8.1 $  $Date:  

if isempty(this.Pole)
    Value = this.Zero;
else
    Value = this.Pole;
end
