% Copyright 2008-2010 The MathWorks, Inc.
% $Revision: 1.1.6.2 $

function result = bridge(etm, cs)

if nargin < 1 || ~isa(cs, 'Simulink.ConfigSet')
    return;
else
    etm.csCopyFrom = cs;
end

format = 'MATLAB function';
noComment = true;

etm.initialize(format);
etm.populateConfigSetPane(noComment);
etm.printed = containers.Map('KeyType', 'int32', 'ValueType', 'int32');
etm.constructCSP();
etm.preprocess(noComment);
result = etm.generateToBridge(noComment);

end
