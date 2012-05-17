function subsys = createsubsys(blk)
%CREATESUBSYS   

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/07/27 20:11:47 $

subsys = [];
clz = class(blk);
switch clz
  case 'Simulink.BlockDiagram'
    subsys = fxptui.blkdgmnode;
    subsys.daobject = blk;
  case 'Simulink.ModelReference'
    subsys = fxptui.mdlrefnode;
    subsys.daobject = blk;    
  case 'Stateflow.EMChart'
    subsys = fxptui.emlnode;		
    subsys.daobject = blk.up;
  case {'Stateflow.Chart', ...
        'Stateflow.LinkChart', ...
        'Stateflow.TruthTableChart'}
    subsys = fxptui.sfchartnode;		
    subsys.daobject = blk.up;
  case {'Stateflow.State', ...
        'Stateflow.Box', ...
        'Stateflow.Function', ...
        'Stateflow.EMFunction', ...
        'Stateflow.TruthTable'}
    subsys = fxptui.sfobjectnode;		
    subsys.daobject = blk;
  otherwise
    subsys = fxptui.subsysnode;
    subsys.daobject = blk;	
end

if(isempty(subsys))
	return;
end
subsys.Name = blk.Path;
subsys.CachedFullName = fxptds.getpath(blk.getFullName);
subsys.addlisteners;
subsys.hchildren = java.util.LinkedHashMap;
subsys.PropertyBag = java.util.HashMap;

% [EOF]
