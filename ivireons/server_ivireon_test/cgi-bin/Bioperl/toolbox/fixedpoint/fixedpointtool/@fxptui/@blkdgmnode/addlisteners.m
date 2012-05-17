function addlisteners(h)
%ADDLISTENERS  adds listeners to this object

%   Author(s): G. Taillefer
%   Copyright 2006-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/07/27 20:11:50 $

ed = DAStudio.EventDispatcher;
% Force a search that loads all libraries that the model has references to
% before attaching listeners. This prevents firing of PropertyChangedEvent
% listeners when libraries are loaded into memory. Turn off warnings before 
% calling find_system. This will prevent warnings pertaining to libraries 
% not being able to load - G518520. The tree hierarchy displayes children 
% under library linked blocks that are not masked, so follow library links 
% in find_system to load all libraries that are referenced under library 
% linked blocks.
warn_state = warning('off','all');
find_system(h.daobject.getFullName,'FollowLinks','On','LookUnderMasks','all','BlockType','dummy');
warning(warn_state);
h.listeners = handle.listener(h.daobject, findprop(h.daobject, 'MinMaxOverflowLogging'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(2) = handle.listener(h.daobject, findprop(h.daobject, 'DataTypeOverride'), 'PropertyPostSet', @(s,e)locpropertychange(e,h));
h.listeners(3) = handle.listener(h.daobject, 'ObjectChildAdded', @(s,e)objectadded(h,s,e));
h.listeners(4) = handle.listener(h.daobject, 'ObjectChildRemoved', @(s,e)objectremoved(h,s,e));
h.listeners(5) = handle.listener(h.daobject, 'CloseEvent', @(s,e)locdestroy(h));
h.listeners(6) = handle.listener(h.daobject, 'PostSaveEvent', @(s,e)locfirepropertychange(h));
h.listeners(7) = handle.listener(ed, 'DirtyChangedEvent', @(s,e)locfirepropertychange(h));

%--------------------------------------------------------------------------
function locpropertychange(ed,h)
% Update the display icons in the tree hierarchy.

h.firehierarchychanged;
%--------------------------------------------------------------------------
function locfirepropertychange(h)
h.firehierarchychanged;
h.firepropertychange;

%--------------------------------------------------------------------------
function locdestroy(h)
% This is to handle cases where the model is closed while question dialogs are still up. The HG question dialogs do not block Simulink, and a
% user is free to change the model or close it if they please. In this case, we want to make sure the dialogs are closed and any code that
% is waiting on the value returned by the question dialog completes execution before the FPT is destroyed, otherwise it will crash MATLAB.

% Flag to indicate that the model is closing.
h.isClosing = true;
h.listeners = [];
me = fxptui.getexplorer;
% FPT could have been deleted via a call to delete(). In this case there
% will be no explorer object. 
if ~isempty(me)
  % Close all the warning/question dialogs.
  isBeingDestroyed = me.closeWarningDlgs;
  % If there are no dialogs to be destroyed, then go ahead and delete the FPT at this point. If there were dialogs present, then add a listener to 
  % the PostHide event and destroy the FPT when we get that event.
  if ~isBeingDestroyed
     % delete results and the tree hierarchy.
     locclearresults(me);
     delete(me);
  else
     % delete results and the tree hierarchy.
     locclearresults(me);  
     me.listeners(end+1) = handle.listener(me,'MEPostHide',@(s,e)locDestroyME(me,e));
     % Hide the FPT
     me.hide;
  end
end
    

%--------------------------------------------------------------------------
function locclearresults(me)
% local function to clear the results and unpopulate the root.
me.clearresults;
root = me.getRoot;
root.unpopulate;
delete(me.imme);

%-------------------------------------
function locDestroyME(me,e) %#ok
% Delete the FPT object when the POST_HIDE_EVENT is issued.
delete(me);


% [EOF]
