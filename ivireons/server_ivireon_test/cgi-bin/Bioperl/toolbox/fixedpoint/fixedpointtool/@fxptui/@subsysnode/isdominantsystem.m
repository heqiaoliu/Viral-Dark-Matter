function b = isdominantsystem(h, prop)
%ISDOMINANTSYSTEM   returns true if the H is dominant.

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2009/07/27 20:12:02 $

b = false;
%SubSystem, BlockDiagram or Charts are valid
if(~fxptui.isvalidtreenode(h));return;end;
%if this is a ModelReference, LinkedLibrary or a system under a linked library (disable mmo and dto)
if(h.daobject.isModelReference || h.daobject.isLinked || isUnderLinkedLibrary(h))
	return;
end
%if this is an eML block return (disable mmo and dto)
if(fxptui.issfmaskedsubsystem(h.daobject))
  sfobj = h.daobject.getHierarchicalChildren;
  if(isa(sfobj, 'Stateflow.EMChart') && strcmp('MinMaxOverflowLogging', prop))
    return;
  end
end
[dSys, dParam] = getdominantsystem(h, prop);
b = isa(h, 'fxptui.blkdgmnode') || isequal(dSys, h.daobject);

if(b)
	switch prop
		case 'MinMaxOverflowLogging'
			h.MMODominantSystem = [];
			h.MMODominantParam = '';
		case 'DataTypeOverride'
			h.DTODominantSystem = [];
			h.DTODominantParam = '';
		otherwise
	end
else
	switch prop
		case 'MinMaxOverflowLogging'
			h.MMODominantSystem = dSys;
			h.MMODominantParam = dParam;
		case 'DataTypeOverride'
			h.DTODominantSystem = dSys;
			h.DTODominantParam = dParam;
		otherwise
	end
end

% [EOF]
