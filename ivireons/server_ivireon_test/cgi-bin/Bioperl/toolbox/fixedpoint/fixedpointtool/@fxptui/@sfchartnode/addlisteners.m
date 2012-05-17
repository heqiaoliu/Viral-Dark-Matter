function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2010/05/20 02:18:23 $

h.listeners = handle.listener(h.daobject, 'NameChangeEvent', @(s,e)firepropertychange(h));
h.listeners(2) = handle.listener(h.daobject, findprop(h.daobject, 'MinMaxOverflowLogging'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(3) = handle.listener(h.daobject, findprop(h.daobject, 'DataTypeOverride'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
ed = DAStudio.EventDispatcher;
%listen to EventDispatcher HierarchyChangedEvent for Stateflow add/remove
h.listeners(4) = handle.listener(ed, 'HierarchyChangedEvent', @(s,e)lochierarchychanged(s,e,h));
h.listeners(5) = handle.listener(ed, 'ChildRemovedEvent', @(s,e)lochierarchychanged(s,e,h));
%--------------------------------------------------------------------------
function locpropertychange(ed,h)
% Update the display icons in the tree hierarchy.
h.firehierarchychanged;

%--------------------------------------------------------------------------
function lochierarchychanged(s,e,h)
if(~isa(h.daobject, 'Simulink.SubSystem'))
  return;
end
%Get the SF object that this node points to.
myobj = fxptui.sfchartnode.getSFChartObject(h.daobject);
%if our chart is not the one who's hierarchy changed, return
if(~isequal(myobj, e.Source)); return; end
keys = h.hchildren.keySet;
if(isempty(keys))
  keysarray = [];
else
  keysarray = keys.toArray;
end
for i = 1:numel(keysarray)
  try
    jfxpblk = h.hchildren.remove(keysarray(i));
    fxpblk = handle(jfxpblk);
    jfxpblk.releaseReference;
    fxpblk.unpopulate;
    delete(fxpblk); % This will cause the Dialog view to be empty if the current object selected is the node being deleted.
  catch
  end
end
h.hchildren.clear;
h.populate;
% Select the stateflow chart object to refresh the Dialog view.
me = fxptui.getexplorer;
me.imme.selectTreeViewNode(h);
h.firehierarchychanged;

% [EOF]
