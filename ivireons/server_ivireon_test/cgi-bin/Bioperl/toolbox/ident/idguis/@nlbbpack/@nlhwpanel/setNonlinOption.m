function setNonlinOption(this,PropName,PropVal)
% set nonlinear options field PropName's value to PropValue.

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2008/10/31 06:13:08 $

if strcmpi(PropName,'FinestCell') 
    if ischar(PropVal) && ~strcmpi(PropVal,'auto')
        PropVal = str2double(PropVal);
    end
end

Ind = this.WaveNLData.Index;
m = this.NlhwModel;
if strcmpi(this.WaveNLData.Type,'input')
    m.InputNonlinearity(Ind).Options.(PropName) = PropVal;
else
    m.OutputNonlinearity(Ind).Options.(PropName) = PropVal;
end

this.updateModel(m);
