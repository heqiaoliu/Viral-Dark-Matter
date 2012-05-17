function subsys = getsfsubsys(h)
% GETSFSUBSYS returns the subsystem object containing the Stateflow object. This method is
% used by sfresult and sfchartresult and is specific to Stateflow.
%   Author: V. Srinivasan
%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/11/13 17:56:54 $
    
obj = h.daobject;
while(~isa(obj, 'Stateflow.Chart') && ~isa(obj, 'Stateflow.EMChart') && ~isa(obj, 'Stateflow.TruthTableChart') && ~isa(obj,'Simulink.BlockDiagram'))
  obj = obj.getParent;
end
if isa(obj,'Simulink.BlockDiagram')
  subsys = obj;
else
    % get the subsys containing the Stateflow chart
  subsys = obj.up;
end

%--------------------------------------------------------------------------
% [EOF]
    
