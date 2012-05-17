function f = isAllLinear(this,Type)
% TRUE if all channels have unitgain (none0 nonlinearity.
% Type: type of channel: 'input'/'output'

% Copyright 1986-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/11/17 13:31:20 $

m = this.NlhwModel;
switch lower(Type)
    case 'input'
        nl = m.InputNonlinearity;
    case 'output'
        nl = m.OutputNonlinearity;
end

f = true;
for k = 1:length(nl)
    if ~isa(nl(k),'unitgain')
        f = false;
        break;
    end
end
