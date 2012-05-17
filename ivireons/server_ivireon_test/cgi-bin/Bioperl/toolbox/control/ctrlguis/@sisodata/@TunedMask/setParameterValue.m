function setParameterValue(this,idx,Value)
% setParameterValue set parameter value of the idx parameter and updates zpk
% representation

%   Copyright 1986-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/10/15 22:40:42 $

CurrentValue = this.Parameters(idx).Value;

this.Parameters(idx).Value = Value;
try
    this.updateZPK;
catch
    this.Parameters(idx).Value = CurrentValue;
end