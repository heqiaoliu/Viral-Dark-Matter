function setParameters(this,Parameters)
% setPARAMS set parameters and updates zpk representation

%   Copyright 1986-2005 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/01/26 01:46:19 $

CurrentValue = this.Parameters;

this.Parameters = Parameters;
try
    this.updateZPK;
catch
    this.Parameters = CurrentValue;
end