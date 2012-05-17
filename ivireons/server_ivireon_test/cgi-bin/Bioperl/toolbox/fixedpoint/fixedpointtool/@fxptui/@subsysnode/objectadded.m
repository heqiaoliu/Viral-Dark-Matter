function objectadded(h,src,event)
%OBJECTADDED

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2008/07/18 18:40:02 $

me = fxptui.getexplorer;
if(~strcmp('done', me.status)); return; end

if isprop(event,'Child')
   blk = event.Child;
else
   % find the child Chart object that is wrapped in the subsystem whos name just changed. 
   % the event.Source is the newly named Simulink.SubSystem object that wraps the Stateflow.Chart object. We need to find the Stateflow.Chart object
   % to re-populate the Tree view. Perform a find only with depth=1 since we don't want to grab other Stateflow.Chart objects that are deep within other 
   % contained Simulink.Subsystem objects.
   blk =  find(event.Source.getHierarchicalChildren,'-isa','Stateflow.Chart','-or','-isa','Stateflow.TruthTableChart','-or','-isa','Stateflow.LinkChart','-depth',1);
end
blk = fxptui.filter(blk);

if(isempty(blk)); return; end

%Stateflow charts are wrapped by masked subsystems. We want to wrap the
%chart, not the subsystem, so listen temporarily for the chart being
%added to the subsystem. If several charts are being added (paste
%operation) we need to listen to all of them (listener vector) Simulink
%adds all the subsystems and then adds all the charts to the subsystems
%in the same order. In the case of making the chart a subsystem, we need to listen to namechange events to
% add the chart correctly in the tree hierarchy.
if(fxptui.issfmaskedsubsystem(blk))
  l = handle.listener(blk, 'ObjectChildAdded', @(s,e)locsfobjectadded(s,e,h));
  if(isempty(h.sfobjectbeingaddedlisteners))
    h.sfobjectbeingaddedlisteners = l;
  else
    h.sfobjectbeingaddedlisteners(end+1) = l;
  end
  l = handle.listener(blk,'NameChangeEvent',@(s,e)locsfobjectadded(s,e,h));
  h.sfobjectbeingaddedlisteners(end+1) = l;
  return;
end
newnode = h.addchild(blk);
newnode.populate;
%updatre tree
ed = DAStudio.EventDispatcher;
ed.broadcastEvent('ChildAddedEvent', h, newnode);
%update listview
ed.broadcastEvent('ListChangedEvent', h);
%--------------------------------------------------------------------------
function locsfobjectadded(s,e,h)
%remove the listeners in FIFO order and add the chart to the parent
delete(h.sfobjectbeingaddedlisteners(1:length(h.sfobjectbeingaddedlisteners)));
h.sfobjectbeingaddedlisteners = [];
h.objectadded(s,e);

%-------------------------------------------------------------------------

% [EOF]
