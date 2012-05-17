function opt = getNonlinOptions(this)
% return wavenet's special options (no other nonlinearity has special
% options for idnlhw)

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:18 $

Ind = this.WaveNLData.Index;
if strcmpi(this.WaveNLData.Type,'input')
    obj = this.NlhwModel.InputNonlinearity(Ind);
else
    obj = this.NlhwModel.OutputNonlinearity(Ind);
end

if ~isa(obj,'wavenet')
    obj = wavenet;
end

opt = obj.Options;
