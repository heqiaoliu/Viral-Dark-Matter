function h = init(h, blk, ds)
%INIT

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/12/01 07:13:36 $

h.daobject = blk;
h.figures = java.util.HashMap;
h.outport = h.port4result;
loggingchanged(h);
h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)propertychange(h,s,e));
h.listeners(2) = handle.listener(h.daobject, 'DeleteEvent', @(s,e)locdestroy(h,ds));
h.listeners(3) = handle.listener(h, findprop(h, 'ProposedDT'), 'PropertyPostSet', @(s,e)setProposedDT(h));
h.listeners(4) = handle.listener(h, findprop(h, 'Alert'), 'PropertyPostSet', @(s,e)firepropertychange(h));
if(~isempty(h.outport))
  h.listeners(5) = handle.listener(h.outport, findprop(h.outport, 'DataLogging'), 'PropertyPostSet', @(s,e)loggingchanged(h));
end
h.addmodelcloselistener(ds);

%--------------------------------------------------------------------------
function loggingchanged(h)
if(isempty(h.outport)); return; end
state = strcmpi('On', h.outport.DataLogging);
h.LogSignal = state;
h.firepropertychange;

%-------------------------------------------------------------------------
function locdestroy(h,ds)

destroy(h,ds);
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('HierarchyChangedEvent');

%------------------------------------------------------------------------


% [EOF]
