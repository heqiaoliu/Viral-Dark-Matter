function children = getHierarchicalChildren(h)
%GETHIERARCHICALCHILDREN returns tree nodes

%   Author(s): G. Taillefer
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/29 17:11:12 $

if(~isa(h, 'DAStudio.Object'))
  return;
end
children = [];
if(isempty(h.hchildren) || h.hchildren.size == 0)
  return;
end
me = fxptui.getexplorer;
%get the java wrapped subsysnodes
jchildren = h.hchildren.values.toArray;
%unwrap the subsysnodes and add them to the output array
idx = 1;
for chIdx = 1:numel(jchildren)
  thisChild  = handle(jchildren(chIdx));
  %G356323 make sure that any linked subsystems get refreshed if they were
  %lost during compile time. Don't do this during edit time because
  %Stateflow object removed events will cause this code to get hit with
  %handles of deleted objects and we don't want to deal with them
  if(~isempty(me) && strcmp('running', me.status) && ~isa(thisChild.daobject, 'DAStudio.Object'))
    blk = get_param(thisChild.CachedFullName, 'Object');
    thisChild.daobject = blk;
  end
  if ~isa(thisChild.daobject,'DAStudio.Object') 
      % The block that this object was referring to was cleared from
      % memory and should no longer be reflected in the UI.
      % The key for the invalid entry is corrupted and we have no way of
      % removing just this entry from the HashMap. We have to do a copy
      % and restore this HashMap.
      jhc = h.hchildren.clone;
      % Clear the property bag of the parent node
      h.hchildren.clear;
      jhc_array = jhc.values.toArray;
      for i = 1:length(jhc_array)
          child = handle(jhc_array(i));
          % restore the property bag of the parent
          if isa(child.daobject,'DAStudio.Object')
              h.hchildren.put(child.daobject,jhc_array(i));
          end
      end
      jhc.clear;
      unpopulate(thisChild);
      %update tree
      ed = DAStudio.EventDispatcher;
      %update tree
      ed.broadcastEvent('ChildRemovedEvent', h, thisChild);
      continue;
  end
  if(isempty(children))
    children = thisChild;
  else
    children(idx) = thisChild;
  end
  idx = idx+1;
end


% EOF
